//
//  TittleLightControl.m
//  TittleFramework
//
//  Created by Jackie on 30/8/2018.
//  Copyright © 2018 clarityhk.com. All rights reserved.
//

#import "TittleLightControl.h"

@implementation TittleLightControl


#define COMMAND_LIGHT_LENGTH 7


// Set color and intensity of light mode
// Color - RGB values
// Intensity - int value from 0 to 255
// No value checking here
- (void) lightModeWithR: (int)r G:(int)g B:(int)b intensity: (int)intensity {
    
    char command[COMMAND_LIGHT_LENGTH];
    command[0] = 0x10; //Header
    command[1] = r;    //RGB-R
    command[2] = g;    //RGB-G
    command[3] = b;    //RGB-B
    command[4] = intensity;
    command[5] = 0x0d; //tail
    command[6] = 0x0a; //tail
    
    NSData *data = [[NSData alloc] initWithBytes:&command length:COMMAND_LIGHT_LENGTH];
    NSLog(@"send light -- %@", data);
    //    [self initCommandTimer: data];
    
}


@end