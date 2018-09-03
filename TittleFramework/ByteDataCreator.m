//
//  ByteDataCreator.m
//  TittleFramework
//
//  Created by Jackie on 3/9/2018.
//  Copyright © 2018 clarityhk.com. All rights reserved.
//

#import "ByteDataCreator.h"

@implementation ByteDataCreator

+ (NSData *)lightCommandWithR: (int)r G:(int)g B:(int)b intensity: (int)intensity {
    
    char command[TITTLE_COMMAND_LIGHT_LENGTH];
    command[0] = 0x10; //Header
    command[1] = r;    //RGB-R
    command[2] = g;    //RGB-G
    command[3] = b;    //RGB-B
    command[4] = intensity;
    command[5] = 0x0d; //tail
    command[6] = 0x0a; //tail
    
    NSData *data =  [[NSData alloc] initWithBytes:&command length:TITTLE_COMMAND_LIGHT_LENGTH];
    return data;
}


+ (NSData *)broadcastIPCommand:(NSString *)ip {
    char lightBytes[8];
    lightBytes[0] = 0x70;
    lightBytes[1] = 0x04;
    lightBytes[6] = 0x0d;
    lightBytes[7] = 0x0a;
    
    NSArray *ipArray = [ip componentsSeparatedByString: @"."];
    
    lightBytes[2] = [ipArray[0] intValue];
    lightBytes[3] = [ipArray[1] intValue];
    lightBytes[4] = [ipArray[2] intValue];
    lightBytes[5] = [ipArray[3] intValue];
    
    NSData *data = [[NSData alloc] initWithBytes:&lightBytes length:8];
    return data;
}

@end
