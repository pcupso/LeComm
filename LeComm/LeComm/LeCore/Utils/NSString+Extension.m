//
//  NSString+Extension.m
//  Letronic
//
//  Created by caic on 16/6/13.
//  Copyright © 2016年 caic. All rights reserved.
//

#import "NSString+Extension.h"
#import "LePublicDefine.h"
#import "RegexKitLite.h"

@implementation NSString (Extension)

- (NSString *)LE_trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL)LE_isContain:(NSString *)str
{
    if (str == nil || str.length == 0) {
        return NO;
    }
    
    if ([self respondsToSelector:@selector(containsString:)]) {
        return [self containsString:str];
    } else {
        NSRange range = [self rangeOfString:str];
        if (range.location != NSNotFound) {
            return YES;
        }
        
        return NO;
    }
}

- (BOOL)LE_hasPrefixIgnoreCase:(NSString *)strPrefix
{
    if (self.length < strPrefix.length) {
        return NO;
    }
    
    NSString *selfPrefix = [self substringWithRange:NSMakeRange(0, strPrefix.length)];
    return [selfPrefix LE_isEqualsIgnoreCase:strPrefix];
}


#pragma mark - Validate

- (BOOL)LE_isEquals:(NSString*)toString
{
    // compare:的参数不允许为nil，因此当toString为nil时，直接返回NO.
    if (nil == toString) {
        return NO;
    }
    
    if (NSOrderedSame == [self compare:toString])
        return YES;
    
    return NO;
}

- (BOOL)LE_isEqualsIgnoreCase:(NSString*) toString
{
    if(NSOrderedSame == [self compare:toString options:NSCaseInsensitiveSearch])
        return YES;
    return NO;
}

- (BOOL)LE_isValidString
{
    if ([self length] > 0) {
        return YES;
    }
    return NO;
}

- (BOOL)LE_isValidEmail
{
    NSString *regexString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    return [self isMatchedByRegex:regexString];
}

- (BOOL)LE_isValidMobile
{
    NSString *regexString = @"^(\\+\\d{2})?\\d+$";
    
    return [self isMatchedByRegex:regexString];
}

- (BOOL)LE_isValidStrictMobile
{
    NSString *regexString = @"^(1[3-8][0-9])\\d{8}$";
    
    return [self isMatchedByRegex:regexString];
}

- (BOOL)LE_isValidAmount
{
    if ([self length] == 0) {
        return NO;
    }
    
    NSString* patternStr = @"^(-)?(([1-9]\\d*)|0)(\\.\\d*)?$";
    
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc]
                                              initWithPattern:patternStr
                                              options:NSRegularExpressionCaseInsensitive
                                              error:nil];
    NSUInteger numberofMatch = [regularexpression numberOfMatchesInString:self
                                                                  options:NSMatchingReportProgress
                                                                    range:NSMakeRange(0, self.length)];
    SAFE_RELEASE(regularexpression);
    return numberofMatch > 0;
}

- (BOOL)LE_isValidAuthCode
{
    NSString *regexString = @"^\\d{6}$";
    
    return [self isMatchedByRegex:regexString];
}

- (BOOL)LE_isValidIdentityCardNumber
{
    UInt16 len = [self length];
    if (len != 15 && len != 18) {
        return NO;
    }
    
    BOOL isNewStyle = len == 18;
    NSString* regexString = isNewStyle ? @"^[1-9]\\d{5}((1\\d)|(20))\\d{2}((0[1-9])|(1[0-2]))((0[1-9])|([12]\\d)|(3[01]))\\d{3}[\\dxX]$" : @"^[1-9]\\d{7}((0[1-9])|(1[0-2]))((0[1-9])|([12]\\d)|(3[01]))\\d{3}$";
    
    return [self isMatchedByRegex:regexString] && (!isNewStyle || [self verifyNewStyleIDNumber]);
}

- (BOOL)LE_isValidBankCardNumber
{
    /*
     Luhm校验规则：16位银行卡号（19位通用）:
     1.将未带校验位的 15（或18）位卡号从右依次编号 1 到 15（18），位于奇数位号上的数字乘以 2。
     2.将奇位乘积的个位和十位相加，并全部相加，再加上所有偶数位上的数字。
     3.将加法和加上校验位能被 10 整除。
     */
    
    NSString* cardNo = self;
    int sum = 0;
    NSUInteger len = [cardNo length];
    int i = 0;
    
    if (len < 16) {
        return NO;
    }
    
    if (0 == [[cardNo substringWithRange:NSMakeRange(0, 1)] intValue]) {
        return NO;
    }
    
    if (![self LE_isPureInt]) {
        return NO;
    }
    
    while (i < len) {
        NSString *tmpString = [cardNo substringWithRange:NSMakeRange(len - 1 - i, 1)];
        int tmpVal = [tmpString intValue];
        if (i % 2 != 0) {
            tmpVal *= 2;
            if(tmpVal>=10) {
                tmpVal -= 9;
            }
        }
        sum += tmpVal;
        i++;
    }
    
    return (sum % 10) == 0;
}

- (BOOL)LE_isPureInt{
    NSUInteger length = [self length];
    if (length <= 0) {
        return NO;
    }
    
    for (int index = 0; index < length; index++)
    {
        unichar endCharacter = [self characterAtIndex:index];
        if (endCharacter < '0' || endCharacter > '9') {
            return NO;
        }
    }
    return YES;
}


#pragma mark private extension methods
- (BOOL)verifyNewStyleIDNumber {
    int total = 0;
    NSString * upper = [self uppercaseString];
    unichar verify = [upper characterAtIndex:17];
    //w[i] = pow(2, 18-i-1) mod 11
    static int w[17] = {7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2};
    static int v[11] = {'1', '0', 'X', '9', '8', '7', '6', '5', '4', '3', '2'};
    for (int i = 0; i < 17; ++i) {
        int a = [[upper substringWithRange:NSMakeRange(i, 1)] intValue];
        total += a * w[i];
    }
    int mod = total % 11;
    return v[mod] == verify;
}


@end
