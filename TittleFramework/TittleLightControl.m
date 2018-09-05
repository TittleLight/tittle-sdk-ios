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

// MARK: Socket setup
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

- (void) connectTittleForStandardConfig {
    
    if (self.socketConnection != nil) {
        [self.socketConnection disconnect];
        self.socketConnection = nil;
    }
    self.socketConnection = [[SocketConnection alloc] init];
    [self.socketConnection connect:self ip: TITTLE_STANDARD_CONFIG_IP port:TITTLE_STANDARD_CONFIG_PORT];
}

// MARK: Search Tittles
- (void) stopSearchingTittles {
    [_onloadTimer invalidate];
    [self.socketListener disconnect];
    self.socketListener = nil;
    [self.socketService stop];
    self.socketService = nil;
    self.foundTittles = nil;
    self.connectedSockets = nil;
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
    self.connectedSockets = [[NSMutableArray alloc] initWithCapacity: SOCKET_POOL];
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

// MARK: Socket delegate
- (void)socket:(GCDAsyncSocket *)socket didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    @synchronized(self.connectedSockets)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.connectedSockets.count < SOCKET_POOL) {
                [self.connectedSockets addObject:newSocket];
            }else {
                [self.connectedSockets removeObjectAtIndex:0];
                [self.connectedSockets addObject:newSocket];
            }
            
            if (self.currentMode == TITTLE_DOING_STANDARD_CONFIG) {
                [newSocket readDataWithTimeout:-1 tag: TITTLE_COMMAND_VERIFY_STANDARD_CONFIG];
            }else {
                [newSocket readDataWithTimeout:-1 tag: TITTLE_COMMAND_NEW_TITTLE_TAG];
            }
        });
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    if ([self.delegate respondsToSelector:@selector(didReceivedResponsedFromLightMode:)] && tag == TITTLE_COMMAND_LIGHT_MODE) {
        [self.delegate didReceivedResponsedFromLightMode: [Utils getAckCodeFromData: data]];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(didReceivedResponsedFromStandardConfigMode:)] && tag == TITTLE_COMMAND_STANDARD_CONFIG) {
        [self.delegate didReceivedResponsedFromStandardConfigMode: [Utils getAckCodeFromData: data]];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(receivedNewTittle:)] && tag == TITTLE_COMMAND_NEW_TITTLE_TAG) {
        TittleData *tittle = [self getTittleObjFromData:data];
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
        [sock disconnect];
        [self removeSockInPool:sock];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(standardConfigVerified:)] &&  tag == TITTLE_COMMAND_VERIFY_STANDARD_CONFIG) {
        self.theConfigTittle = [self getTittleObjFromData:data];
        if (self.theConfigTittle != NULL) {
            [self.delegate standardConfigVerified: self.theConfigTittle];
        }
        [sock disconnect];
        [self removeSockInPool:sock];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(standardConfigDone:)] && tag == TITTLE_COMMAND_DONE_STANDARD_CONFIG ) {
        [self.socketConnection disconnect];
        [self.delegate standardConfigDone: TITTLE_ACK_SUCCESS];
        return;
    }
    
    
    
}

- (void) socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    if ([self.delegate respondsToSelector:@selector(socket:didConnectToHost:port:)]) {
        [self.delegate socket:sock didConnectToHost:host port:port];
    }
}

- (void) socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    //    NSLog(@"disconnect - %@", err.description);
    if ([self.delegate respondsToSelector:@selector(socketDidDisconnect:withError:)]) {
        [self.delegate socketDidDisconnect:sock withError:err];
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    
    if ([self.delegate respondsToSelector:@selector(receivedNewTittle:)]) {
        TittleData *tittle = [self getTittleObjFromData:data];
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


// MARK: Utils
- (BOOL) tittleExistInList: (TittleData *)newTittle {
    for (TittleData *tittle in self.foundTittles) {
        if ([tittle.name isEqualToString:newTittle.name]) {
            return true;
        }
    }
    return false;
}

- (TittleData *) getTittleObjFromData: (NSData *)data {
    
    char dataBytes[data.length];
    
    [data getBytes:dataBytes length:data.length];
    
    if ( dataBytes[0] == 0x70 && (dataBytes[1] == 0x04 || dataBytes[1] == 0x08) && data.length >= 15 ) {
        
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

- (void) removeSockInPool:(GCDAsyncSocket *)sock {
    
    for (int i = 0 ; i < [_connectedSockets count ] ; i++) {
        GCDAsyncSocket *sockInPool = (GCDAsyncSocket *)[_connectedSockets objectAtIndex:i];
        if ([[sockInPool connectedHost] isEqualToString:[sock connectedHost]] && [sockInPool connectedPort] == [sock connectedPort]) {
            [_connectedSockets removeObject:sockInPool];
            break;
        }
    }
}


// MARK: commands

// Set color and intensity of light mode
// Color - RGB values
// Intensity - int value from 0 to 255
// No value checking here
//- (void) setLightModeWithR: (int)r G:(int)g B:(int)b intensity: (int)intensity {
//    [self.socketConnection writeData: [ByteDataCreator lightCommandWithR:r G:g B:b intensity:intensity] withTag: TITTLE_COMMAND_LIGHT_MODE withController: self];
//}

- (void) lightModeWithR: (uint8_t)r g:(uint8_t)g b:(uint8_t)b intensity: (uint8_t)intensity {
    [self.socketConnection writeData: [ByteDataCreator lightCommandWithR:r G:g B:b intensity:intensity] withTag: TITTLE_COMMAND_LIGHT_MODE withController: self];
}

- (void) standardConfig: (NSString *)wifiName password: (NSString *)password {
    [self.socketConnection writeData: [ByteDataCreator standardConfigWifiDataCommand:wifiName password:password] withTag: TITTLE_COMMAND_STANDARD_CONFIG withController: self];
}

- (void) verifyStandardConfig {
    if (_socketService != nil) {
        [self.socketListener disconnect];
    }
    [self startTcpListener:self];
    self.currentMode = TITTLE_DOING_STANDARD_CONFIG;
}

- (void) confirmStandardConfig: (NSString *)ip {
    if (_socketService != nil) {
        [self.socketListener disconnect];
        self.socketListener = nil;
        self.connectedSockets = nil;
        [self.socketService stop];
    }
    [self connectTittleWithIP: ip];
    [self.socketConnection writeData:[ByteDataCreator standardConfigDoneCommand] withTag:TITTLE_COMMAND_DONE_STANDARD_CONFIG withController:self];
}

@end
