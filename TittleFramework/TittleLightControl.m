//
//  TittleLightControl.m
//  TittleFramework
//
//  Created by Jackie on 30/8/2018.
//  Copyright © 2018 clarityhk.com. All rights reserved.
//

#import "TittleLightControl.h"

@interface TittleLightControl()<GCDAsyncSocketDelegate, GCDAsyncUdpSocketDelegate>
@end
@implementation TittleLightControl

// Set color and intensity of light mode
// Color - RGB values
// Intensity - int value from 0 to 255
// No value checking here
- (void) setLightModeWithR: (int)r G:(int)g B:(int)b intensity: (int)intensity {
    
    [self.socketConnection writeData: [ByteDataCreator lightCommandWithR:r G:g B:b intensity:intensity] withTag: TITTLE_COMMAND_LIGHT_MODE withController: self];
}

- (void) connectTittleWithIP: (NSString *)ip {
    if (self.socketConnection != nil) {
        [self.socketConnection disconnect];
        self.socketConnection = nil;
    }
    self.socketConnection = [[SocketConnection alloc] init];
    [self.socketConnection connect:self ip:ip port:TITTLE_DEFAULT_SOCKET_PORT];
}

- (void) disconnectTittle {
    if (self.socketConnection != nil) {
        [self.socketConnection disconnect];
        self.socketConnection = nil;
    }
}

- (void) stopSearchingTittles {
    [_onloadTimer invalidate];
    [self.socketListener disconnect];
    [self.socketService stop];
    self.socketService = nil;
}


- (void) startSearchingTittles {
    
    if (![[Utils getIPAddress] isEqualToString:@"error"]) {
        
        if (self.udpSocketConnection == nil) {
            self.udpSocketConnection = [[UDPSocketConnection alloc] init];
            [self.udpSocketConnection initSocket:self];
        }
        
        _foundTittles = [[NSMutableArray alloc] initWithCapacity: SOCKET_POOL];
        
        _onloadTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(broadcastData:) userInfo:self repeats:YES];
        [self broadcastData: _onloadTimer];
        
        // start TCP listener
        if (_socketService == nil) {
            [self startTcpListener:self];
        }
    }
}

- (void)broadcastData: (NSTimer *)sender {
    
    NSData *data = [ByteDataCreator broadcastIPCommand:[Utils getIPAddress]];
    [self.udpSocketConnection writeData:data host:[Utils getBroadcastAddress] port:TITTLE_DEFAULT_BROADCAST_PORT tag:TITTLE_COMMAND_BROADCAST_TAG controller:[sender userInfo]];
}

- (void)startTcpListener: (id)controller {
    
    self.socketListener = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // Start Listening for Incoming Connections
    NSError *error = nil;
    
    if ([self.socketListener acceptOnPort:TITTLE_DEFAULT_SOCKET_LISTENER_PORT error:&error]) {
        // Initialize Service
        self.socketService = [[NSNetService alloc] initWithDomain:@"local." type:@"_iQuest._tcp." name:@"" port:TITTLE_DEFAULT_SOCKET_LISTENER_PORT];
        
        // Configure Service
        [self.socketListener setDelegate:self];
        
        // Publish Service
        [self.socketService publish];
        
    } else {
        NSLog(@"Setting - Unable to create socket. Error %@ with user info %@.", error, [error userInfo]);
    }
}

- (TittleData *) getTittleObjFromData: (NSData *)data {
    
    char dataBytes[data.length];
    
    [data getBytes:dataBytes length:data.length];
    
    if ( dataBytes[0] == 0x70 && dataBytes[1] == 0x04 && data.length >= 15 ) {
        
        NSData *nameData = [data subdataWithRange:NSMakeRange(2, data.length-15)];
        
        NSString *name = [[NSString alloc] initWithData:nameData encoding:NSUTF8StringEncoding];
        
        NSString *ipAddr = [NSString stringWithFormat:@"%d.%d.%d.%d", [Utils byteToInt:dataBytes[data.length - 6]], [Utils byteToInt:dataBytes[data.length - 5]], [Utils byteToInt:dataBytes[data.length - 4]], [Utils byteToInt:dataBytes[data.length - 3]]];
        
        //        NSString *macAddr = [NSString stringWithFormat:@"%d:%d:%d:%d:%d:%d", [self byteToInt:dataBytes[data.length - 12]],[self byteToInt:dataBytes[data.length - 11]],[self byteToInt:dataBytes[data.length - 10]], [self byteToInt:dataBytes[data.length - 9]], [self byteToInt:dataBytes[data.length - 8]], [self byteToInt:dataBytes[data.length - 7]]];
        
        TittleData *tittle = [[TittleData alloc] init];
        [tittle assignAttributes:name ip:ipAddr];
        return tittle;
    }else {
        return NULL;
    }
    
}


- (void)socket:(GCDAsyncSocket *)socket didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    //    NSLog(@"new socket");
    //    [newSocket readDataWithTimeout:-1 tag:TITTLE_COMMAND_NEW_TITTLE_TAG];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    //    TittleData *tittle = [self getTittleObjFromData:data tag:tag sock:sock];
    //    [self.delegate receivedNewTittle: tittle];
    if ([self.delegate respondsToSelector:@selector(didReceivedResponsedFromLightMode:)]) {
        if (tag == TITTLE_COMMAND_LIGHT_MODE) {
            [self.delegate didReceivedResponsedFromLightMode: [Utils getAckCodeFromData: data]];
        }
    }
}

- (void) socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    if ([self.delegate respondsToSelector:@selector(socket:didConnectToHost:port:)]) {
        [self.delegate socket:sock didConnectToHost:host port:port];
    }
}

- (void) socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    if ([self.delegate respondsToSelector:@selector(socketDidDisconnect:withError:)]) {
        [self.delegate socketDidDisconnect:sock withError:err];
    }
    
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    TittleData *tittle = [self getTittleObjFromData:data];
    if ([self.delegate respondsToSelector:@selector(receivedNewTittle:)]) {
        if (tittle != NULL) {
            if (![self tittleExistInList: tittle]) {
                @synchronized(self.foundTittles)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self.foundTittles.count >= SOCKET_POOL) {
                            [self.foundTittles removeObjectAtIndex:0];
                        }
                        [self.foundTittles addObject:tittle];
                        
                        [self.delegate receivedNewTittle: tittle];
                    });
                }
            }
        }
    }
}

- (BOOL) tittleExistInList: (TittleData *)newTittle {
    for (TittleData *tittle in self.foundTittles) {
        if ([tittle.name isEqualToString:newTittle.name]) {
            return true;
        }
    }
    return false;
}

@end
