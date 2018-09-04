//
//  Utils.h
//  TittleFramework
//
//  Created by Jackie on 3/9/2018.
//  Copyright © 2018 clarityhk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <ifaddrs.h>
#include <arpa/inet.h>

@interface Utils : NSObject
+ (NSString *)getIPAddress;
+ (NSString *)getBroadcastAddress;
+ (int)byteToInt:(char)byte;
@end
