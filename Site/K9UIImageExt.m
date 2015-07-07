//
//  K9UIViewExt.m
//  Beep
//
//  Created by Sania on 27.06.14.
//  Copyright (c) 2014 OrangeSoft_Brest. All rights reserved.
//

#import "K9UIImageExt.h"

@implementation UIImage(K9_Ext)

- (UIImage*)addBlurEffect
{
    return [self addBlurEffectWithRadius:@(10.0f)];
}

- (UIImage*)addBlurEffectWithRadius:(NSNumber*)radius
{
    CIImage *imageData = [[CIImage alloc] initWithImage:self];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setDefaults];
    [filter setValue:imageData  forKey:@"inputImage"];
    [filter setValue:radius     forKey:@"inputRadius"];
    
    CIImage *filteredImageData = filter.outputImage;
    
    return [UIImage imageWithCIImage:filteredImageData];
}

- (UIImage*)addBlackoutWithAlpha:(NSNumber*)alphaChannel
{
    CGRect rect = (CGRect){CGPointZero, self.size};
    rect.size = CGSizeMake(self.size.width/* / [UIScreen mainScreen].scale*/, self.size.height/* / [UIScreen mainScreen].scale*/);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawInRect:rect];
    
    [[[UIColor blackColor] colorWithAlphaComponent:alphaChannel.floatValue] setFill];
    CGContextFillRect(context, rect);
    
    UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

+ (UIImage*)arrowWithSize:(CGSize)size width:(CGFloat)width color:(UIColor*)color
{
    CGRect rect = (CGRect){CGPointZero, size};
    rect.size = CGSizeMake(size.width * [UIScreen mainScreen].scale, size.height * [UIScreen mainScreen].scale);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    
    CGContextSetLineWidth(context, width);
    CGContextSetLineCap(context, kCGLineCapButt);
    
    CGContextMoveToPoint   (context, width * 0.5f, width * 0.5f);
    CGContextAddLineToPoint(context, rect.size.width - width * 0.5f, rect.size.height * 0.5f);
    CGContextAddLineToPoint(context, width * 0.5f, rect.size.height - width * 0.5f);
    CGContextStrokePath(context);
 
    UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

- (UIImage*)resizeForSize:(CGSize)size
{
    CGRect rect = (CGRect){CGPointZero, size};
//    rect.size = CGSizeMake(size.width * self.scale, size.height * self.scale);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (context)
    {
        // Transform context Y mirror
        CGContextScaleCTM(context, 1.0f, -1.0f);
        CGContextTranslateCTM(context, 0.0f, -rect.size.height);
        
        CGContextSetShouldAntialias(context, true);
        
        CGContextDrawImage(context, rect, self.CGImage);
        
        UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return resultImage;
    }
    
    return nil;
}

- (UIImage*)resizeForSize:(CGSize)size withEdgeInsets:(UIEdgeInsets)insets
{
    CGRect rect = (CGRect){CGPointZero, size};
    rect.size = CGSizeMake(size.width * self.scale, size.height * self.scale);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (context)
    {
        CGSize originalSize = CGSizeMake(CGImageGetWidth(self.CGImage), CGImageGetHeight(self.CGImage));
        
        // Transform context Y mirror
        CGContextScaleCTM(context, 1.0f, -1.0f);
        CGContextTranslateCTM(context, 0.0f, -rect.size.height);
        
        CGContextSetShouldAntialias(context, true);
        
        CGRect originalRectTL = CGRectMake(0.0f, 0.0f, originalSize.width * insets.left,  originalSize.height * insets.top);
        CGRect originalRectCE = CGRectMake(originalSize.width * insets.left,  originalSize.height * insets.top,    originalSize.width * (insets.right - insets.left), originalSize.height * (insets.bottom - insets.top));
        CGRect originalRectBR = CGRectMake(originalSize.width * insets.right, originalSize.height * insets.bottom, originalSize.width * (1.0f - insets.right),        originalSize.height * (1.0f - insets.bottom));

        
        CGRect rectTL = CGRectMake(floor(originalRectTL.origin.x), floor(rect.size.height - originalRectTL.size.height), floor(originalRectTL.size.width), floor(originalRectTL.size.height));
        CGRect rectCE = CGRectMake(floor((rect.size.width - originalRectCE.size.width) * 0.5f), floor((rect.size.height - originalRectCE.size.height) * 0.5f), floor(originalRectCE.size.width), floor(originalRectCE.size.height));
        CGRect rectBR = CGRectMake(floor(rect.size.width - originalRectBR.size.width), 0.0f, floor(originalRectBR.size.width), floor(originalRectBR.size.height));

        
        { // Left
            CGRect tmpRect = CGRectMake(0.0f, originalRectCE.origin.y, originalRectTL.size.width, originalRectCE.size.height);
            CGImageRef tmpImage = CGImageCreateWithImageInRect(self.CGImage, tmpRect);
            CGContextDrawImage(context, CGRectMake(rectTL.origin.x, rectCE.origin.y, rectTL.size.width, rectCE.size.height), tmpImage);
            CGImageRelease(tmpImage);
        }
        
        { // Left Top
            CGRect tmpRect = CGRectMake(originalRectTL.origin.x, CGRectGetMinY(originalRectCE), originalRectTL.size.width, 1.0f);
            CGImageRef tmpImage = CGImageCreateWithImageInRect(self.CGImage, tmpRect);
            CGContextDrawImage(context, CGRectMake(rectTL.origin.x, CGRectGetMaxY(rectCE), rectTL.size.width, CGRectGetMinY(rectTL) - CGRectGetMaxY(rectCE)), tmpImage);
            CGImageRelease(tmpImage);
        }
        
        { // Top Left Corner
            CGRect tmpRect = originalRectTL;
            CGImageRef tmpImage = CGImageCreateWithImageInRect(self.CGImage, tmpRect);
            CGContextDrawImage(context, rectTL, tmpImage);
            CGImageRelease(tmpImage);
        }
        
        { // Top Left
            CGRect tmpRect = CGRectMake(originalRectCE.origin.x, 0, 1, originalRectTL.size.height);
            CGImageRef tmpImage = CGImageCreateWithImageInRect(self.CGImage, tmpRect);
            CGContextDrawImage(context, CGRectMake(CGRectGetMaxX(rectTL), rectTL.origin.y, rectCE.origin.x - CGRectGetMaxX(rectTL), rectTL.size.height), tmpImage);
            CGImageRelease(tmpImage);
        }
        
        { // Top
            CGRect tmpRect = CGRectMake(originalRectTL.size.width, 0, originalRectBR.size.width - originalRectTL.size.width, originalRectTL.size.height);
            CGImageRef tmpImage = CGImageCreateWithImageInRect(self.CGImage, tmpRect);
            CGContextDrawImage(context, rectCE, tmpImage);
            CGImageRelease(tmpImage);
        }
        
        { // Top Right
            CGRect tmpRect = CGRectMake(CGRectGetMaxX(originalRectCE), 0, 1, originalRectTL.size.height);
            CGImageRef tmpImage = CGImageCreateWithImageInRect(self.CGImage, tmpRect);
            CGContextDrawImage(context, CGRectMake(CGRectGetMaxX(rectCE), rectTL.origin.y, rectBR.origin.x - CGRectGetMaxX(rectCE), rectTL.size.height), tmpImage);
            CGImageRelease(tmpImage);
        }
        
        { // Top Right Corner
            CGRect tmpRect = CGRectMake(originalRectBR.size.width, 0, originalSize.width - originalRectBR.size.width, originalRectTL.size.height);
            CGImageRef tmpImage = CGImageCreateWithImageInRect(self.CGImage, tmpRect);
            CGContextDrawImage(context, CGRectMake(rectBR.origin.x, rectTL.origin.y, rectBR.size.width, rectTL.size.height), tmpImage);
            CGImageRelease(tmpImage);
        }
        
        { // Right
            CGRect tmpRect = CGRectMake(originalSize.width * insets.right, originalSize.height * insets.top, originalSize.width * (1.0f - insets.right), originalSize.height * (insets.bottom - insets.top));
            CGImageRef tmpImage = CGImageCreateWithImageInRect(self.CGImage, tmpRect);
            CGContextDrawImage(context, CGRectMake(rect.size.width - tmpRect.size.width, (rect.size.height - tmpRect.size.height) * 0.5f, tmpRect.size.width, tmpRect.size.height), tmpImage);
            CGImageRelease(tmpImage);
        }
        
        { // Bottom Left Corner
            CGRect tmpRect = CGRectMake(0, originalSize.height * insets.bottom, originalSize.width * insets.left, originalSize.height * (1.0f - insets.bottom));
            CGImageRef tmpImage = CGImageCreateWithImageInRect(self.CGImage, tmpRect);
            CGContextDrawImage(context, CGRectMake(0, 0, tmpRect.size.width, tmpRect.size.height), tmpImage);
            CGImageRelease(tmpImage);
        }
        
        { // Bottom
            CGRect tmpRect = CGRectMake(originalSize.width * insets.left, 0, originalSize.width * (insets.right - insets.left), originalSize.height * insets.top);
            CGImageRef tmpImage = CGImageCreateWithImageInRect(self.CGImage, tmpRect);
            CGContextDrawImage(context, CGRectMake((rect.size.width / [UIScreen mainScreen].scale - tmpRect.size.width) * 0.5f, 0, tmpRect.size.width, tmpRect.size.height), tmpImage);
            CGImageRelease(tmpImage);
        }
        
        { // Bottom Right Corner
            CGRect tmpRect = CGRectMake(originalSize.width * insets.right, originalSize.height * insets.bottom, originalSize.width * (1.0f - insets.right), originalSize.height * (1.0f - insets.bottom));
            CGImageRef tmpImage = CGImageCreateWithImageInRect(self.CGImage, tmpRect);
            CGContextDrawImage(context, CGRectMake(rect.size.width - tmpRect.size.width, 0, tmpRect.size.width, tmpRect.size.height), tmpImage);
            CGImageRelease(tmpImage);
        }
        
        UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return resultImage;
    }
    
    return nil;
}

- (UIImage *)normalizedImage {
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawInRect:(CGRect){0, 0, self.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

- (NSArray*)detectedFeatures
{
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil
                                              options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
    
    return [detector featuresInImage:[[CIImage alloc] initWithCGImage:self.CGImage]];
}

@end
