//
//  LePublicDefine.h
//  Letronic
//
//  Created by caic on 16/6/13.
//  Copyright © 2016年 caic. All rights reserved.
//

#ifndef LePublicDefine_h
#define LePublicDefine_h

// 非空字符串
#ifndef SAFE_STRING
#define SAFE_STRING(x) (x) != nil ? (x) : @""
#endif

// IOS 版本
#ifndef IOS_VERSION
#define IOS_VERSION ([UIDevice currentDevice].systemVersion.doubleValue)
#endif

// 安全释放对象
#ifndef SAFE_RELEASE
#if __has_feature(objc_arc)
#define SAFE_RELEASE(x) (x) = nil;
#else
#define SAFE_RELEASE(x) [(x) release]; (x) = nil;
#endif
#endif



#endif /* LePublicDefine_h */
