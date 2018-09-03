//
//  TittleLightControl.m
//  TittleFramework
//
//  Created by Jackie on 30/8/2018.
//  Copyright © 2018 clarityhk.com. All rights reserved.
//

#import "TittleLightControl.h"

@implementation TittleLightControl

// Set color and intensity of light mode
// Color - RGB values
// Intensity - int value from 0 to 255
// No value checking here
- (void) setLightModeInController: (id)controller R: (int)r G:(int)g B:(int)b intensity: (int)intensity {
    
    [self.socketConnection writeData: [ByteDataCreator lightCommandWithR:r G:g B:b intensity:intensity] withTag: TITTLE_COMMAND_LIGHT_MODE withController: controller];
}

- (void) connectTittleWithController: (id)controller ip: (NSString *)ip {
    if (self.socketConnection != nil) {
        [self.socketConnection disconnect];
        self.socketConnection = nil;
    }
    self.socketConnection = [[SocketConnection alloc] init];
    [self.socketConnection connect:controller ip:ip port:TITTLE_DEFAULT_SOCKET_PORT];
}

- (void) disconnectTittleWithController {
    if (self.socketConnection != nil) {
        [self.socketConnection disconnect];
        self.socketConnection = nil;
    }
}

- (void) stopSearchingTittlesInController: (id)controller {
    [_onloadTimer invalidate];
    [self.socketListener disconnect];
    [self.socketService stop];
    self.socketService = nil;
}


- (void) startSearchingTittlesInController: (id)controller {
    
    if (![[Utils getIPAddress] isEqualToString:@"error"]) {
        
        if (self.udpSocketConnection == nil) {
            self.udpSocketConnection = [[UDPSocketConnection alloc] init];
            [self.udpSocketConnection initSocket:self];
        }
        
        _onloadTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(broadcastData:) userInfo:controller repeats:YES];
        [self broadcastData: _onloadTimer];
        
        // start TCP listener
        if (_socketService == nil) {
            [self startTcpListener:controller];
        }
    }
}

- (void)broadcastData: (NSTimer *)sender {
    
    NSData *data = [ByteDataCreator broadcastIPCommand:[Utils getIPAddress]];
//    NSLog(@"%@",[Utils getBroadcastAddress] );
    [self.udpSocketConnection writeData:data host:[Utils getBroadcastAddress] port:TITTLE_DEFAULT_BROADCAST_PORT tag:TITTLE_COMMAND_BROADCAST_TAG controller:[sender userInfo]];
}

- (void)startTcpListener: (id)controller {
    
    self.socketListener = [[GCDAsyncSocket alloc] initWithDelegate:controller delegateQueue:dispatch_get_main_queue()];
    // Setup an array to store all accepted client connections
    //    _connectedSockets = [[NSMutableArray alloc] initWithCapacity: SOCKET_POOL];
    
    // Start Listening for Incoming Connections
    NSError *error = nil;
    
    if ([self.socketListener acceptOnPort:TITTLE_DEFAULT_SOCKET_LISTENER_PORT error:&error]) {
        // Initialize Service
        self.socketService = [[NSNetService alloc] initWithDomain:@"local." type:@"_iQuest._tcp." name:@"" port:TITTLE_DEFAULT_SOCKET_LISTENER_PORT];
        
        // Configure Service
        [self.socketListener setDelegate:controller];
        
        // Publish Service
        [self.socketService publish];
        
    } else {
        NSLog(@"Setting - Unable to create socket. Error %@ with user info %@.", error, [error userInfo]);
    }
}

- (int) getAckCodeFromData:(NSData *)data {
    char dataBytes[data.length];
    
    [data getBytes:dataBytes length:data.length];
    
    if (dataBytes[3] == 0x00) {
        return TITTLE_ACK_SUCCESS;
    }else if (dataBytes[3] == 0x01 && dataBytes[4] == 0x00) {
        return TITTLE_ACK_RESEND;
    }else if (dataBytes[3] == 0x01 && dataBytes[4] == 0x01) {
        return TITTLE_ACK_READY_FOR_DATA;
    }
    
    if (dataBytes[0] == 0x00  && dataBytes[1] == 0x00) {
        return TITTLE_ACK_SUCCESS;
    }else if (dataBytes[0] == 0x00  && dataBytes[1] == 0x01 && dataBytes[2] == 0x00) {
        return TITTLE_ACK_RESEND;
    }else if (dataBytes[0] == 0x00  && dataBytes[1] == 0x01 && dataBytes[2] == 0x01) {
        return TITTLE_ACK_READY_FOR_DATA;
    }
    return TITTLE_ACK_UNKNOWN;
}

@end
