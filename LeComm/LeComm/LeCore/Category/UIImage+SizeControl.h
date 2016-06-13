//
//  UIImage+SizeControl.h
//  Letronic
//
//  Created by caic on 16/6/10.
//  Copyright © 2016年 caic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SizeControl)

/**
 *	@brief	将图片做压缩成想要的大小
 *
 *	@param 	width 	想要的宽度大小
 *                  ratio    长宽比例
 *                  newSize  长宽
 *	@return
 */
- (UIImage *)scaledToFixedWidth:(CGFloat)width withRatio:(float) ratio;
- (UIImage *)scaledToFixedWidth:(CGFloat)width;
- (UIImage *)scaledToSize:(CGSize)newSize;


/**
 *	@brief	将图片做fit out
 *
 *	@param 	size 	图片的显示尺寸，非像素尺寸。例如10*10像素的图片，在高清设备中显示尺寸是5*5.scale为2 默认不支持透明
 *  @paramisTransparent 是否支持透明
 *	@return
 */
- (UIImage*)scaleFitOut:(CGSize)size;
- (UIImage*)scaleFitOut:(CGSize)size supportTransparent:(BOOL)isTransparent;

/**
 *	@brief	当压缩质量不足以缩小图片尺寸时，会减小图片的size来达到减小尺寸的目的
 *
 *	@param 	maxLength 压缩图片后的最大字节数,至少大于等于1K
 *	@param 	defaultQuality 质量1表示图片质量最佳 0表示图片质量最差
 *
 *	@return	压缩结果
 */
- (NSData *)compressionMaxLength:(NSUInteger)maxLength defaultQuality:(float)quality;


@end
