//
//  TittleLightControl.h
//  TittleFramework
//
//  Created by Jackie on 30/8/2018.
//  Copyright © 2018 clarityhk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "constants.h"

@interface TittleLightControl : NSObject
- (NSData *) lightModePackageWithR: (int)r G:(int)g B:(int)b intensity: (int)intensity;
- (UInt16) defaultSocketPort;
- (int) getAckCodeFromData:(NSData *)data;
@end
