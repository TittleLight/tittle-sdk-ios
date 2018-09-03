//
//  UDPSocketConnection.m
//  TittleFramework
//
//  Created by Jackie on 3/9/2018.
//  Copyright © 2018 clarityhk.com. All rights reserved.
//

#import "UDPSocketConnection.h"

@implementation UDPSocketConnection

- (void)initSocket:(id)controller {
    
    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:controller delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    
    if (![udpSocket bindToPort: TITTLE_DEFAULT_BROADCAST_PORT error:&error]) {
        return;
    }
    
    if (![udpSocket beginReceiving:&error]) {
        NSLog(@"receiving error - %@", error);
        return;
    }
    
    if (![udpSocket enableBroadcast:YES error:&error]) {
        NSLog(@"Error enableBroadcast: %@",error);
        return;
    }
}

-(void) close {
    if (udpSocket != nil) {
        [udpSocket close];
        udpSocket = nil;
    }
}


-(void)writeData:(NSData *)data host:(NSString *)host port:(uint16_t)port tag:(int)tag controller:(id)controller {
    NSLog(@"send UDP package -%@ - %d",host, port);
    
    [udpSocket sendData:data toHost:host port:port withTimeout:-1 tag:tag];
}


@end
