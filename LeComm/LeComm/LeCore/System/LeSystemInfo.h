//
//  LeSystemInfo.h
//  Letronic
//
//  Created by caic on 16/6/13.
//  Copyright © 2016年 caic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeSystemInfo : NSObject

/*
 *  @brief  生成uuid
 */
+ (NSString *)generateUUID;

// 版本号，如1.0.0
+ (NSString *)version;

// 构建版本号，如1.0.0.1
+ (NSString *)build;

// 移动设备标识码
+ (NSString *)imei;

// 广告标识码
+ (NSString *)idfa;

// 路由器mac地址
+ (NSString *)routerMac;

// 网络类型,如wifi，WWLAN
+ (NSString *)networkType;

// 越狱类型
+ (NSString *)breakType;

// 设备类型，iphone，ipod，ipad
+ (NSString *)devType;

// 设备mac地址
+ (NSString *)macAddress;

// vindor标识符
+ (NSString *)idfv;

// iphone机型
+ (NSString *)iphoneDeviceType;

@end
