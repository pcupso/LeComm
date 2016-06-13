//
//  LeSystemInfo.m
//  Letronic
//
//  Created by caic on 16/6/13.
//  Copyright © 2016年 caic. All rights reserved.
//

#import "LeSystemInfo.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <AdSupport/ASIdentifierManager.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>


@implementation LeSystemInfo

+ (NSString *)generateUUID
{
    NSMutableString *  result;
    CFUUIDRef   uuid;
    CFStringRef uuidStr;
    
    uuid = CFUUIDCreate(NULL);
    NSAssert(uuid != NULL, nil);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    NSAssert(uuidStr != NULL, nil);
    
    result = [NSMutableString stringWithString:[[NSString stringWithFormat:@"%@", uuidStr] stringByReplacingOccurrencesOfString:@"-" withString:@""]];
    NSAssert(result != nil, nil);
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    return result;
}

#pragma mark - System info
// 版本号，如1.0.0
+ (NSString *)version
{
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
}

// 构建版本号，如1.0.0.1
+ (NSString *)build
{
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
}

// 移动设备标识码
+ (NSString *)imei
{
    double version = [UIDevice currentDevice].systemVersion.doubleValue;
    NSString *indentifier = version < 7.0 ? [LeSystemInfo macAddress] : [LeSystemInfo idfv];
    
    if (indentifier.length == 0) {
        indentifier = [LeSystemInfo generateUUID];
    }
    
    indentifier = [LeCrypto md5:indentifier];
    return SAFE_STRING(indentifier);
}

// 广告标识码
+ (NSString *)idfa
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
    if (NSClassFromString(@"ASIdentifierManager") && [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled])
    {
        if (IOS_VERSION >= 6.0) {
            return SAFE_STRING([[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString]);
        }
    }
#endif
    return @"";
}

// 路由器mac地址
+ (NSString *)routerMac
{
    NSString *macIp = nil;
    CFArrayRef interfacesArray = CNCopySupportedInterfaces();
    if (interfacesArray != nil) {
        CFDictionaryRef networkDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(interfacesArray, 0));
        if (networkDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(networkDict);
            macIp = [dict valueForKey:@"BSSID"];
        }
        CFRelease(interfacesArray);
    }
    
    if (![macIp isKindOfClass:[NSString class]]) {
        return @"";
    }
    
    NSArray *array = [macIp componentsSeparatedByString:@":"];
    NSMutableString *macAddress = [NSMutableString string];
    
    for (int i = 0; i < [array count]; i++) {
        NSString *space = array[i];
        if ([space length] == 2) {
            [macAddress appendString:space];
        }
        else {//缺0补0
            [macAddress appendString:[NSString stringWithFormat:@"0%@", space]];
        }
    }
    
    return [macAddress uppercaseString];
}

// 网络类型,如wifi，WWLAN
+ (NSString *)networkType
{
    // Use AFNetworkingReachability
    return @"TODO";
}

// 越狱类型
+ (NSString *)breakType
{
    BOOL jailbroken = NO;
    
    NSString *cydiaPath = @"/Applications/Cydia.app";
    
    NSString *aptPath = @"/private/var/lib/apt/";
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath])
    {
        jailbroken = YES;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath])
    {
        jailbroken = YES;
    }
    
    return jailbroken ? @"YES" : @"NO" ;

}

// 设备类型，iphone，ipod，ipad
+ (NSString *)devType
{
    NSString *modelName = [[UIDevice currentDevice] model];
    if ([modelName LE_isContain:@"iPod"]) {
        return @"iPod";
    }
    
    if ([modelName LE_isContain:@"iPad"]) {
        return @"iPad";
    }
    
    return @"iPhone";
}

// 设备mac地址
+ (NSString *)macAddress
{
    int     mib[6];
    size_t  len;
    char    *buf;
    unsigned char   *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        free(buf);
        printf("Error: sysctl, take 2");
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    // NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    NSString *outstring = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    return outstring;
}

// vindor标识符
+ (NSString *)idfv
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
    if (IOS_VERSION >= 6.0) {
        return SAFE_STRING([[UIDevice currentDevice].identifierForVendor UUIDString]);
    }
#endif
    return @"";
}

// iphone机型
+ (NSString *)iphoneDeviceType
{
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    
    if ([platform LE_isEquals:@"iPhone1,1"]) return @"iPhone 2G (A1203)";
    if ([platform LE_isEquals:@"iPhone1,2"]) return @"iPhone 3G (A1241/A1324)";
    if ([platform LE_isEquals:@"iPhone2,1"]) return @"iPhone 3GS (A1303/A1325)";
    if ([platform LE_isEquals:@"iPhone3,1"]) return @"iPhone 4 (A1332)";
    if ([platform LE_isEquals:@"iPhone3,2"]) return @"iPhone 4 (A1332)";
    if ([platform LE_isEquals:@"iPhone3,3"]) return @"iPhone 4 (A1349)";
    if ([platform LE_isEquals:@"iPhone4,1"]) return @"iPhone 4S (A1387/A1431)";
    if ([platform LE_isEquals:@"iPhone5,1"]) return @"iPhone 5 (A1428)";
    if ([platform LE_isEquals:@"iPhone5,2"]) return @"iPhone 5 (A1429/A1442)";
    if ([platform LE_isEquals:@"iPhone5,3"]) return @"iPhone 5c (A1456/A1532)";
    if ([platform LE_isEquals:@"iPhone5,4"]) return @"iPhone 5c (A1507/A1516/A1526/A1529)";
    if ([platform LE_isEquals:@"iPhone6,1"]) return @"iPhone 5s (A1453/A1533)";
    if ([platform LE_isEquals:@"iPhone6,2"]) return @"iPhone 5s (A1457/A1518/A1528/A1530)";
    if ([platform LE_isEquals:@"iPhone7,1"]) return @"iPhone 6 Plus (A1522/A1524)";
    if ([platform LE_isEquals:@"iPhone7,2"]) return @"iPhone 6 (A1549/A1586)";
    if ([platform LE_isEquals:@"iPhone8,2"]) return @"iPhone 6S";
    if ([platform LE_isEquals:@"iPhone8,1"]) return @"iPhone 6S Plus";
    
    if ([platform LE_isEquals:@"iPod1,1"])   return @"iPod Touch 1G (A1213)";
    if ([platform LE_isEquals:@"iPod2,1"])   return @"iPod Touch 2G (A1288)";
    if ([platform LE_isEquals:@"iPod3,1"])   return @"iPod Touch 3G (A1318)";
    if ([platform LE_isEquals:@"iPod4,1"])   return @"iPod Touch 4G (A1367)";
    if ([platform LE_isEquals:@"iPod5,1"])   return @"iPod Touch 5G (A1421/A1509)";
    
    if ([platform LE_isEquals:@"iPad1,1"])   return @"iPad 1G (A1219/A1337)";
    
    if ([platform LE_isEquals:@"iPad2,1"])   return @"iPad 2 (A1395)";
    if ([platform LE_isEquals:@"iPad2,2"])   return @"iPad 2 (A1396)";
    if ([platform LE_isEquals:@"iPad2,3"])   return @"iPad 2 (A1397)";
    if ([platform LE_isEquals:@"iPad2,4"])   return @"iPad 2 (A1395+New Chip)";
    if ([platform LE_isEquals:@"iPad2,5"])   return @"iPad Mini 1G (A1432)";
    if ([platform LE_isEquals:@"iPad2,6"])   return @"iPad Mini 1G (A1454)";
    if ([platform LE_isEquals:@"iPad2,7"])   return @"iPad Mini 1G (A1455)";
    
    if ([platform LE_isEquals:@"iPad3,1"])   return @"iPad 3 (A1416)";
    if ([platform LE_isEquals:@"iPad3,2"])   return @"iPad 3 (A1403)";
    if ([platform LE_isEquals:@"iPad3,3"])   return @"iPad 3 (A1430)";
    if ([platform LE_isEquals:@"iPad3,4"])   return @"iPad 4 (A1458)";
    if ([platform LE_isEquals:@"iPad3,5"])   return @"iPad 4 (A1459)";
    if ([platform LE_isEquals:@"iPad3,6"])   return @"iPad 4 (A1460)";
    
    if ([platform LE_isEquals:@"iPad4,1"])   return @"iPad Air (A1474)";
    if ([platform LE_isEquals:@"iPad4,2"])   return @"iPad Air (A1475)";
    if ([platform LE_isEquals:@"iPad4,3"])   return @"iPad Air (A1476)";
    if ([platform LE_isEquals:@"iPad4,4"])   return @"iPad Mini 2G (A1489)";
    if ([platform LE_isEquals:@"iPad4,5"])   return @"iPad Mini 2G (A1490)";
    if ([platform LE_isEquals:@"iPad4,6"])   return @"iPad Mini 2G (A1491)";
    
    if ([platform LE_isEquals:@"i386"])      return @"iPhone Simulator";
    if ([platform LE_isEquals:@"x86_64"])    return @"iPhone Simulator";
    return platform;
}



@end
