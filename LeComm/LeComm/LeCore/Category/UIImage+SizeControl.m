//
//  UIImage+SizeControl.m
//  Letronic
//
//  Created by caic on 16/6/10.
//  Copyright © 2016年 caic. All rights reserved.
//

#import "UIImage+SizeControl.h"

@implementation UIImage (SizeControl)

- (UIImage *)scaledToFixedWidth:(CGFloat)width withRatio:(float) ratio
{
    if (width <= 0) {
        return NULL;
    }
    return [self scaledToSize:CGSizeMake(width, width*ratio)];
}

- (UIImage *)scaledToFixedWidth:(CGFloat)width
{
    if (width <= 0) {
        return NULL;
    }
    width = width * [UIScreen mainScreen].scale;
    CGSize curSz = self.size;
    float rate = curSz.width / width;//600 300
    float height = curSz.height / rate;
    
    return [self scaledToSize:CGSizeMake(width, height)];
}

- (UIImage *)scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, YES, [UIScreen mainScreen].scale);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage*)scaleFitOut:(CGSize)size
{
    return [self scaleFitOut:size supportTransparent:NO];
}

- (UIImage*)scaleFitOut:(CGSize)size supportTransparent:(BOOL)isTransparent
{
    UIImage* resultImage	= nil;
    @try {
        UIGraphicsBeginImageContextWithOptions(size, !isTransparent, [UIScreen mainScreen].scale);
        
        long nWidth;
        long nHeight;
        if (self.size.height * size.width >= self.size.width * size.height) {
            nWidth = (long)(size.width + 3) & ~3;
            nHeight = nWidth * self.size.height / self.size.width;
            nHeight = (nHeight + 3) & ~3;
        } else {
            nHeight = (long)(size.height + 3) & ~3;
            nWidth = nHeight * self.size.width / self.size.height;
            nWidth = (nWidth + 3) & ~3;
        }
        
        [self drawInRect:CGRectMake((size.width - nWidth)/2, (size.height - nHeight)/2, nWidth, nHeight)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    @catch (NSException *exception) {
        NSLog(@"exception:%@",exception);
    }
    @finally {
        NSLog(@"finish");
    }
    return resultImage;
}

- (NSData *)compressionMaxLength:(NSUInteger)maxLength defaultQuality:(float)quality
{
    if (maxLength < 1024) {
        return nil;
    }
    
    if (quality < 0 ) {
        quality = 0;
    }
    if(quality > 1.0) {
        quality = 1.0;
    }
    
    const CGFloat sizeCompressRate = 0.8;
    CGFloat rate    = 0.8;
    NSData* imgData = nil;
    BOOL isFirst = YES;
    NSUInteger lastNewLength = 0;
    UIImage* compressionimage = self;
    
    while(YES) {
        
        imgData = UIImageJPEGRepresentation(compressionimage, quality);
        
        NSUInteger newLength = [imgData length];
        NSLog(@"compressionImage quality:%f length:%lu/%lu",quality,(unsigned long)newLength,(unsigned long)maxLength);
        
        if (newLength <= maxLength) {
            break;
        }
        
        //直接第一次直接计算出rate
        if (isFirst) {
            isFirst = NO;
            rate = (CGFloat)maxLength / (CGFloat)newLength;
        }
        
        //当质量较低时会出现压缩后大小不变，此时智能进一步缩小图片的size来达到尺寸裁剪
        if (lastNewLength == newLength) {
            CGFloat newWidth = compressionimage.size.width / [UIScreen mainScreen].scale * sizeCompressRate;
            compressionimage = [compressionimage scaledToFixedWidth:newWidth];
        }
        
        lastNewLength = newLength;
        quality *= rate;
    }
    
    return imgData;
}


@end
