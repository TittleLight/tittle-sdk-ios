//
//  TittleLightControl.h
//  TittleFramework
//
//  Created by Jackie on 30/8/2018.
//  Copyright © 2018 clarityhk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "constants.h"
#import "Utils.h"
#import "SocketConnection.h"
#import "UDPSocketConnection.h"
#import "ByteDataCreator.h"
#import "GCDAsyncSocket.h"

@interface TittleLightControl : NSObject

@property (strong, nonatomic) SocketConnection *socketConnection;
@property (strong, nonatomic) UDPSocketConnection *udpSocketConnection;
@property (strong, nonatomic) GCDAsyncSocket *socketListener;
@property (strong, nonatomic) NSNetService *socketService;
@property (strong, nonatomic) NSTimer *onloadTimer;

- (void) setLightModeInController: (id)controller R: (int)r G:(int)g B:(int)b intensity: (int)intensity;
- (void) connectTittleWithController: (id)controller ip: (NSString *)ip;
- (void) disconnectTittleWithController;
- (int) getAckCodeFromData:(NSData *)data;
- (void) startSearchingTittlesInController: (id)controller;
- (void) stopSearchingTittlesInController: (id)controller;
@end
