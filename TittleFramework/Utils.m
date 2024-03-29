//
//  Utils.m
//  TittleFramework
//
//  Created by Jackie on 3/9/2018.
//  Copyright © 2018 clarityhk.com. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (NSString *)getIPAddress {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}

+(NSString *)getBroadcastAddress {
    NSString * broadcastAddr= @"Error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    
    if (success == 0)
    {
        temp_addr = interfaces;
        
        while(temp_addr != NULL)
        {
            // check if interface is en0 which is the wifi connection on the iPhone
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    broadcastAddr = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)];
                    
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    return broadcastAddr;
}

+ (int)byteToInt:(char)byte {
    
    if ((int)byte < 0) {
        return (int)byte + 256;
    }else {
        return byte;
    }
}

+ (int) getAckCodeFromData:(NSData *)data {
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
