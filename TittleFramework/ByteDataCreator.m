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

+ (NSData *)standardConfigWifiDataCommand: (NSString *)wifiName password: (NSString *)password {
    
    NSData* wifiData = [wifiName dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData * wifiPayload = [NSMutableData dataWithData:wifiData];
    
    NSData* passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData * passwordPayload = [NSMutableData dataWithData:passwordData];
    
    NSArray *ipArray = [[Utils getIPAddress] componentsSeparatedByString: @"."];
    char ipData[4];
    ipData[0] = [ipArray[0] intValue];
    ipData[1] = [ipArray[1] intValue];
    ipData[2] = [ipArray[2] intValue];
    ipData[3] = [ipArray[3] intValue];
    NSMutableData *ipPlayload = [NSMutableData dataWithBytes:ipData length:4];
    
    char separator[1];
    separator[0] = '\0';
    NSMutableData *separatorData = [NSMutableData dataWithBytes:separator length:1];
    char separator2[1];
    separator2[0] = '\0';
    NSMutableData *separator2Data = [NSMutableData dataWithBytes:separator2 length:1];
    
    char head[2];
    head[0]=0x70;
    head[1]=0x07;
    NSMutableData *packetHeaderData = [NSMutableData dataWithBytes:head length:2];
    char tail[3];
    tail[0] ='\0';
    tail[1]=0x0d;
    tail[2]=0x0a;
    NSMutableData *packetTailData = [NSMutableData dataWithBytes:tail length:3];
    
    [wifiPayload appendData:separatorData];
    [wifiPayload appendData:passwordPayload];
    [wifiPayload appendData:separator2Data];
    [wifiPayload appendData:ipPlayload];
    [wifiPayload appendData:packetTailData];
    [packetHeaderData appendData:wifiPayload];
    
    return packetHeaderData;
}

+ (NSData *)standardConfigDoneCommand {
    char lightBytes[4];
    lightBytes[0] = 0x70;
    lightBytes[1] = 0x09;
    lightBytes[2] = 0x0d;
    lightBytes[3] = 0x0a;
    
    return [[NSData alloc] initWithBytes:&lightBytes length:4];
    
}

@end
