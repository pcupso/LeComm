//
//  NSString+Extension.h
//  Letronic
//
//  Created by caic on 16/6/13.
//  Copyright © 2016年 caic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)

#pragma mark - Compare

- (NSString *)LE_trim;

- (BOOL)LE_isContain:(NSString *)str;

- (BOOL)LE_hasPrefixIgnoreCase:(NSString *)strPrefix;

#pragma mark - Validate

- (BOOL)LE_isEquals:(NSString*) toString ;
- (BOOL)LE_isEqualsIgnoreCase:(NSString*) toString;
- (BOOL)LE_isValidString;
- (BOOL)LE_isValidEmail;
- (BOOL)LE_isValidMobile;
- (BOOL)LE_isValidStrictMobile;
- (BOOL)LE_isValidAmount;
- (BOOL)LE_isValidAuthCode;
- (BOOL)LE_isValidIdentityCardNumber;
- (BOOL)LE_isValidBankCardNumber;
- (BOOL)LE_isPureInt;

@end
