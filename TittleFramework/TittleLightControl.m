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
- (NSData *) lightModePackageWithR: (int)r G:(int)g B:(int)b intensity: (int)intensity {
    
    char command[TITTLE_COMMAND_LIGHT_LENGTH];
    command[0] = 0x10; //Header
    command[1] = r;    //RGB-R
    command[2] = g;    //RGB-G
    command[3] = b;    //RGB-B
    command[4] = intensity;
    command[5] = 0x0d; //tail
    command[6] = 0x0a; //tail
    
    return [[NSData alloc] initWithBytes:&command length:TITTLE_COMMAND_LIGHT_LENGTH];
    
}

- (UInt16) defaultSocketPort {
    return TITTLE_DEFAULT_SOCKET_PORT;
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
