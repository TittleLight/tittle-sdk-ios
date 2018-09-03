//
//  SocketConnection.m
//  TittleFramework
//
//  Created by Jackie on 3/9/2018.
//  Copyright © 2018 clarityhk.com. All rights reserved.
//

#import "SocketConnection.h"

@implementation SocketConnection

- (void)dealloc {
    [self disconnect];
}

- (void)disconnect {
    [socket disconnect];
}

- (void)connect:(id)controller ip: (NSString *)ip port: (int)port {
    
    if ((socket == nil || [socket isDisconnected]) && ip != nil) {
        
        connectIP = ip;
        connectPort = port;
        
        socket = [[GCDAsyncSocket alloc] initWithDelegate:controller delegateQueue:dispatch_get_main_queue()];
        socketCreateDate = [NSDate date];
        
        NSError* error = nil;
        if (![socket connectToHost:ip onPort: port withTimeout:10 error:&error]) {
            NSLog(@"Failed to create socket with error: %@", error.description);
            error = nil;
        }
    }
}

- (void)writeData:(NSData *) data withTag:(long)tag withController:(id)controller {
    
    
    float timeTaken = [[NSDate date] timeIntervalSinceDate: socketCreateDate];
    if (timeTaken > 5.0f) {
        [socket disconnect];
        socket = nil;
        [self connect:controller ip: connectIP port: connectPort];
    }
    
    [socket writeData:data withTimeout:-1 tag:tag];
    [socket readDataWithTimeout:-1 tag:tag];
}

@end
