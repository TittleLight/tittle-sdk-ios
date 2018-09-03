//
//  ByteDataCreator.h
//  TittleFramework
//
//  Created by Jackie on 3/9/2018.
//  Copyright © 2018 clarityhk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "constants.h"

@interface ByteDataCreator : NSObject

+ (NSData *)lightCommandWithR: (int)r G:(int)g B:(int)b intensity: (int)intensity;

+ (NSData *)broadcastIPCommand:(NSString *)ip;
@end
