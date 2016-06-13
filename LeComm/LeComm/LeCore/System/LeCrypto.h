//
//  LeCrypto.h
//  Letronic
//
//  Created by caic on 16/6/13.
//  Copyright © 2016年 caic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LeCrypto : NSObject

+ (NSString *)md5:(NSString *)str;
+ (NSString *)md5WithData:(NSData *)data;

+ (NSString *)sha1:(NSString *)str;

@end
