//
//  K9UIHelpers.m
//
//  Created by Sania on 16.05.13.
//  Copyright (c) 2013 Orangesoft Brest. All rights reserved.
//

#import "K9UIHelpers.h"

#define ARTEFACT_WIDTH 0.0f

@implementation UIImage (K9ImageHelper)

- (UIImage*)makeResizable
{
    CGSize originalSize = self.size;//CGSizeMake(CGImageGetWidth(self.CGImage), CGImageGetHeight(self.CGImage));
    UIEdgeInsets imageInsets = UIEdgeInsetsMake(originalSize.height * 0.5f, originalSize.width * 0.5f, originalSize.height * 0.5f, originalSize.width * 0.5f);
    return [self resizableImageWithCapInsets:imageInsets];
}

- (UIImage*)scaleToSize:(CGSize)destSize withBorder:(CGFloat)borderWidth
{
    destSize.width *= DEVICE_SCALE;
    destSize.height *= DEVICE_SCALE;
    
    borderWidth *= DEVICE_SCALE;
    
    UIGraphicsBeginImageContext(destSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (context != nil)
    {
        CGSize originalSize = CGSizeMake(CGImageGetWidth(self.CGImage), CGImageGetHeight(self.CGImage));
        
        // Transform context Y mirror
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -destSize.height);

        
        // Top Left Corner
        CGRect topLeftRect = CGRectMake(0, 0, (borderWidth + ARTEFACT_WIDTH), (borderWidth + ARTEFACT_WIDTH));
        CGImageRef topLeftCorner = CGImageCreateWithImageInRect(self.CGImage, topLeftRect);
        CGContextDrawImage(context, CGRectMake(0, destSize.height - borderWidth - ARTEFACT_WIDTH, borderWidth + ARTEFACT_WIDTH, (borderWidth + ARTEFACT_WIDTH)), topLeftCorner);
        CGImageRelease(topLeftCorner);
        
        // Top Border
        CGRect topRect = CGRectMake((borderWidth - ARTEFACT_WIDTH), 0, (originalSize.width - (borderWidth - ARTEFACT_WIDTH) * 2.0f), (borderWidth + ARTEFACT_WIDTH));
        CGImageRef topBorder = CGImageCreateWithImageInRect(self.CGImage, topRect);
        CGContextDrawImage(context, CGRectMake(borderWidth - ARTEFACT_WIDTH, destSize.height - borderWidth - ARTEFACT_WIDTH, destSize.width - (borderWidth - ARTEFACT_WIDTH) * 2.0f, (borderWidth + ARTEFACT_WIDTH)), topBorder);
        CGImageRelease(topBorder);

        // Top Right Corner
        CGRect topRightRect = CGRectMake(originalSize.width - borderWidth - ARTEFACT_WIDTH, 0, borderWidth + ARTEFACT_WIDTH, borderWidth + ARTEFACT_WIDTH);
        CGImageRef topRightCorner = CGImageCreateWithImageInRect(self.CGImage, topRightRect);
        CGContextDrawImage(context, CGRectMake(destSize.width - borderWidth - ARTEFACT_WIDTH, destSize.height - borderWidth - ARTEFACT_WIDTH, borderWidth + ARTEFACT_WIDTH, (borderWidth + ARTEFACT_WIDTH)), topRightCorner);
        CGImageRelease(topRightCorner);
        
        
        // Left Border
        CGRect leftRect = CGRectMake(0, borderWidth - ARTEFACT_WIDTH, borderWidth + ARTEFACT_WIDTH, originalSize.height - (borderWidth - ARTEFACT_WIDTH) * 2.0f);
        CGImageRef leftBorder = CGImageCreateWithImageInRect(self.CGImage, leftRect);
        CGContextDrawImage(context, CGRectMake(0, borderWidth - ARTEFACT_WIDTH, borderWidth + ARTEFACT_WIDTH, destSize.height - (borderWidth - ARTEFACT_WIDTH) * 2.0f), leftBorder);
        CGImageRelease(leftBorder);
        
        // Center
        CGRect centerRect = CGRectMake(borderWidth - ARTEFACT_WIDTH, borderWidth - ARTEFACT_WIDTH, originalSize.width - (borderWidth - ARTEFACT_WIDTH) * 2.0f, originalSize.height - (borderWidth - ARTEFACT_WIDTH) * 2.0f);
        CGImageRef center = CGImageCreateWithImageInRect(self.CGImage, centerRect);
        CGContextDrawImage(context, CGRectMake(borderWidth - ARTEFACT_WIDTH, borderWidth - ARTEFACT_WIDTH, destSize.width - (borderWidth - ARTEFACT_WIDTH) * 2.0f, destSize.height - (borderWidth - ARTEFACT_WIDTH) * 2.0f), center);
        CGImageRelease(center);
        
        // Right Border
        CGRect rightRect = CGRectMake(originalSize.width - borderWidth - ARTEFACT_WIDTH, borderWidth - ARTEFACT_WIDTH, borderWidth + ARTEFACT_WIDTH, originalSize.height - (borderWidth - ARTEFACT_WIDTH) * 2.0f);
        CGImageRef rightBorder = CGImageCreateWithImageInRect(self.CGImage, rightRect);
        CGContextDrawImage(context, CGRectMake(destSize.width - borderWidth - ARTEFACT_WIDTH, borderWidth - ARTEFACT_WIDTH, borderWidth + ARTEFACT_WIDTH, destSize.height - (borderWidth - ARTEFACT_WIDTH) * 2.0f), rightBorder);
        CGImageRelease(rightBorder);
        
        
        // Bottom Left Corner
        CGRect bottomLeftRect = CGRectMake(0, originalSize.height - borderWidth - ARTEFACT_WIDTH, borderWidth + ARTEFACT_WIDTH, borderWidth + ARTEFACT_WIDTH);
        CGImageRef bottomLeftCorner = CGImageCreateWithImageInRect(self.CGImage, bottomLeftRect);
        CGContextDrawImage(context, CGRectMake(0, 0, borderWidth + ARTEFACT_WIDTH, (borderWidth + ARTEFACT_WIDTH)), bottomLeftCorner);
        CGImageRelease(bottomLeftCorner);
        
        // Bottom Border
        CGRect bottomRect = CGRectMake(borderWidth - ARTEFACT_WIDTH, originalSize.height - borderWidth - ARTEFACT_WIDTH, originalSize.width - (borderWidth - ARTEFACT_WIDTH) * 2.0f, borderWidth + ARTEFACT_WIDTH);
        CGImageRef bottomBorder = CGImageCreateWithImageInRect(self.CGImage, bottomRect);
        CGContextDrawImage(context, CGRectMake(borderWidth - ARTEFACT_WIDTH, 0, destSize.width - (borderWidth - ARTEFACT_WIDTH) * 2.0f, borderWidth + ARTEFACT_WIDTH), bottomBorder);
        CGImageRelease(bottomBorder);
        
        // Bottom Right Corner
        CGRect bottomRightRect = CGRectMake(originalSize.width - borderWidth - ARTEFACT_WIDTH, originalSize.height - borderWidth - ARTEFACT_WIDTH, borderWidth + ARTEFACT_WIDTH, borderWidth + ARTEFACT_WIDTH);
        CGImageRef bottomRightCorner = CGImageCreateWithImageInRect(self.CGImage, bottomRightRect);
        CGContextDrawImage(context, CGRectMake(destSize.width - borderWidth - ARTEFACT_WIDTH, 0, borderWidth + ARTEFACT_WIDTH, borderWidth + ARTEFACT_WIDTH), bottomRightCorner);
        CGImageRelease(bottomRightCorner);
        
        
        UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return resultImage;
    }
    
    return nil;
}

- (UIImage*)scaleToSize:(CGSize)destSize leftBorder:(CGFloat)leftWidth rightBorder:(CGFloat)rightWidth
{
    destSize.width *= DEVICE_SCALE;
    destSize.height *= DEVICE_SCALE;
    
    leftWidth *= DEVICE_SCALE;
    rightWidth *= DEVICE_SCALE;
    
    UIGraphicsBeginImageContext(destSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (context != nil)
    {
        CGSize originalSize = CGSizeMake(CGImageGetWidth(self.CGImage), CGImageGetHeight(self.CGImage));
        
        // Transform context Y mirror
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -destSize.height);
        
        
        // Left
        CGRect leftRect = CGRectMake(0, 0, (leftWidth + ARTEFACT_WIDTH), originalSize.height);
        CGImageRef leftImage = CGImageCreateWithImageInRect(self.CGImage, leftRect);
        CGContextDrawImage(context, CGRectMake(0, 0, leftWidth + ARTEFACT_WIDTH, destSize.height), leftImage);
        CGImageRelease(leftImage);
        
        // Center
        CGRect centerRect = CGRectMake((leftWidth - ARTEFACT_WIDTH), 0, (originalSize.width - leftWidth - rightWidth + ARTEFACT_WIDTH * 2.0f), originalSize.height);
        CGImageRef centerImage = CGImageCreateWithImageInRect(self.CGImage, centerRect);
        CGContextDrawImage(context, CGRectMake(leftWidth - ARTEFACT_WIDTH, 0, destSize.width - leftWidth - rightWidth + ARTEFACT_WIDTH * 2.0f, destSize.height), centerImage);
        CGImageRelease(centerImage);
        
        // Right
        CGRect rightRect = CGRectMake(originalSize.width - rightWidth - ARTEFACT_WIDTH, 0, rightWidth + ARTEFACT_WIDTH, originalSize.height);
        CGImageRef rightImage = CGImageCreateWithImageInRect(self.CGImage, rightRect);
        CGContextDrawImage(context, CGRectMake(destSize.width - rightWidth - ARTEFACT_WIDTH, 0, rightWidth + ARTEFACT_WIDTH, destSize.height), rightImage);
        CGImageRelease(rightImage);
        
        UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return resultImage;
    }
    return nil;
}

- (UIImage*)scaleToSize:(CGSize)destSize leftBorder:(CGFloat)leftWidth rightBorder:(CGFloat)rightWidth topBorder:(CGFloat)topHeight bottomBorder:(CGFloat)bottomHeight
{
    destSize.width *= DEVICE_SCALE;
    destSize.height *= DEVICE_SCALE;
    
    leftWidth *= DEVICE_SCALE;
    rightWidth *= DEVICE_SCALE;
    topHeight *= DEVICE_SCALE;
    bottomHeight *= DEVICE_SCALE;
    
    UIGraphicsBeginImageContext(destSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (context != nil)
    {
        CGSize originalSize = CGSizeMake(CGImageGetWidth(self.CGImage), CGImageGetHeight(self.CGImage));
        
        // Transform context Y mirror
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -destSize.height);
        
        
        // Top Left Corner
        CGRect topLeftRect = CGRectMake(0, 0, leftWidth, topHeight);
        CGImageRef topLeftCorner = CGImageCreateWithImageInRect(self.CGImage, topLeftRect);
        CGContextDrawImage(context, CGRectMake(0, destSize.height - topHeight - ARTEFACT_WIDTH, (leftWidth + ARTEFACT_WIDTH), (topHeight + ARTEFACT_WIDTH)), topLeftCorner);
        CGImageRelease(topLeftCorner);
        
        // Top Border
        CGRect topRect = CGRectMake(leftWidth, 0, originalSize.width - (leftWidth + rightWidth), topHeight);
        CGImageRef topBorder = CGImageCreateWithImageInRect(self.CGImage, topRect);
        CGContextDrawImage(context, CGRectMake((leftWidth - ARTEFACT_WIDTH), destSize.height - topHeight - ARTEFACT_WIDTH, destSize.width - (leftWidth + rightWidth - ARTEFACT_WIDTH * 2.0f), (topHeight + ARTEFACT_WIDTH)), topBorder);
        CGImageRelease(topBorder);
        
        // Top Right Corner
        CGRect topRightRect = CGRectMake(originalSize.width - rightWidth, 0, rightWidth, topHeight);
        CGImageRef topRightCorner = CGImageCreateWithImageInRect(self.CGImage, topRightRect);
        CGContextDrawImage(context, CGRectMake(destSize.width - (rightWidth - ARTEFACT_WIDTH), destSize.height - topHeight - ARTEFACT_WIDTH, (rightWidth + ARTEFACT_WIDTH), (topHeight + ARTEFACT_WIDTH)), topRightCorner);
        CGImageRelease(topRightCorner);
        
        
        // Left Border
        CGRect leftRect = CGRectMake(0, topHeight, leftWidth, originalSize.height - (topHeight + bottomHeight));
        CGImageRef leftBorder = CGImageCreateWithImageInRect(self.CGImage, leftRect);
        CGContextDrawImage(context, CGRectMake(0, bottomHeight - ARTEFACT_WIDTH, leftWidth + ARTEFACT_WIDTH, destSize.height - (topHeight + bottomHeight - ARTEFACT_WIDTH * 2.0f)), leftBorder);
        CGImageRelease(leftBorder);
        
        // Center
        CGRect centerRect = CGRectMake(leftWidth, topHeight, originalSize.width - (leftWidth + rightWidth), originalSize.height - (topHeight + bottomHeight));
        CGImageRef center = CGImageCreateWithImageInRect(self.CGImage, centerRect);
        CGContextDrawImage(context, CGRectMake(leftWidth - ARTEFACT_WIDTH, bottomHeight - ARTEFACT_WIDTH, destSize.width - (leftWidth + rightWidth - ARTEFACT_WIDTH * 2.0f), destSize.height - (topHeight + bottomHeight - ARTEFACT_WIDTH * 2.0f)), center);
        CGImageRelease(center);
        
        // Right Border
        CGRect rightRect = CGRectMake(originalSize.width - rightWidth, topHeight, rightWidth, originalSize.height - (topHeight + bottomHeight));
        CGImageRef rightBorder = CGImageCreateWithImageInRect(self.CGImage, rightRect);
        CGContextDrawImage(context, CGRectMake(destSize.width - rightWidth - ARTEFACT_WIDTH, bottomHeight - ARTEFACT_WIDTH, rightWidth + ARTEFACT_WIDTH, destSize.height - (topHeight + bottomHeight - ARTEFACT_WIDTH * 2.0f)), rightBorder);
        CGImageRelease(rightBorder);
        
        
        // Bottom Left Corner
        CGRect bottomLeftRect = CGRectMake(0, originalSize.height - bottomHeight, leftWidth, bottomHeight);
        CGImageRef bottomLeftCorner = CGImageCreateWithImageInRect(self.CGImage, bottomLeftRect);
        CGContextDrawImage(context, CGRectMake(0, 0, leftWidth + ARTEFACT_WIDTH, (bottomHeight + ARTEFACT_WIDTH)), bottomLeftCorner);
        CGImageRelease(bottomLeftCorner);
        
        // Bottom Border
        CGRect bottomRect = CGRectMake(leftWidth, originalSize.height - bottomHeight, originalSize.width - (leftWidth + rightWidth), bottomHeight);
        CGImageRef bottomBorder = CGImageCreateWithImageInRect(self.CGImage, bottomRect);
        CGContextDrawImage(context, CGRectMake(leftWidth - ARTEFACT_WIDTH, 0, destSize.width - (leftWidth + rightWidth - ARTEFACT_WIDTH * 2.0f), bottomHeight + ARTEFACT_WIDTH), bottomBorder);
        CGImageRelease(bottomBorder);
        
        // Bottom Right Corner
        CGRect bottomRightRect = CGRectMake(originalSize.width - rightWidth, originalSize.height - bottomHeight, rightWidth, bottomHeight);
        CGImageRef bottomRightCorner = CGImageCreateWithImageInRect(self.CGImage, bottomRightRect);
        CGContextDrawImage(context, CGRectMake(destSize.width - rightWidth - ARTEFACT_WIDTH, 0, rightWidth + ARTEFACT_WIDTH, bottomHeight + ARTEFACT_WIDTH), bottomRightCorner);
        CGImageRelease(bottomRightCorner);
        
        
        UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return resultImage;
    }
    
    return nil;
}

- (UIImage*)createTiledImageToSize:(CGSize)destSize
{
    destSize.width *= DEVICE_SCALE;
    destSize.height *= DEVICE_SCALE;
    
    UIGraphicsBeginImageContext(destSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (context != nil)
    {
        CGSize originalSize = CGSizeMake(CGImageGetWidth(self.CGImage), CGImageGetHeight(self.CGImage));
        
        // Transform context Y mirror
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -destSize.height);
        
        CGFloat offsetX = 0;
        CGFloat offsetY = 0;
        
        while (offsetY < destSize.height)
        {
            offsetX = 0;
            while (offsetX < destSize.width)
            {
                CGContextDrawImage(context, CGRectMake(offsetX, offsetY, originalSize.width + ARTEFACT_WIDTH, originalSize.height + ARTEFACT_WIDTH), self.CGImage);
                offsetX += originalSize.width;
            }
            offsetY += originalSize.height;
        }
        
        UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return resultImage;
    }
    
    return nil;
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

@implementation UIButton (K9ImageHelper)

- (void)scaleBackgorundImageToSize:(CGSize)destSize leftBorder:(CGFloat)leftWidth rightBorder:(CGFloat)rightWidth
{
    UIImage* normalImage = [self backgroundImageForState:UIControlStateNormal];
    normalImage = [normalImage scaleToSize:self.frame.size leftBorder:leftWidth rightBorder:rightWidth];
    [self setBackgroundImage:normalImage forState:UIControlStateNormal];
    UIImage* highligtedImage = [self backgroundImageForState:UIControlStateSelected];
    highligtedImage = [highligtedImage scaleToSize:self.frame.size leftBorder:leftWidth rightBorder:rightWidth];
    [self setBackgroundImage:highligtedImage forState:UIControlStateSelected];
    [self setBackgroundImage:highligtedImage forState:UIControlStateHighlighted];
}

- (void)scaleBackgorundImageToSize:(CGSize)destSize withBorder:(CGFloat)border
{
    UIImage* normalImage = [self backgroundImageForState:UIControlStateNormal];
    normalImage = [normalImage scaleToSize:self.frame.size withBorder:border];
    [self setBackgroundImage:normalImage forState:UIControlStateNormal];
    UIImage* highligtedImage = [self backgroundImageForState:UIControlStateSelected];
    highligtedImage = [highligtedImage scaleToSize:self.frame.size  withBorder:border];
    [self setBackgroundImage:highligtedImage forState:UIControlStateSelected];
    [self setBackgroundImage:highligtedImage forState:UIControlStateHighlighted];
}

- (void)makeBackgroundResizable
{
    UIImage* normalImage = [self backgroundImageForState:UIControlStateNormal];
    UIEdgeInsets normalImageInsets = UIEdgeInsetsMake(normalImage.size.height * 0.5f, normalImage.size.width * 0.5f, normalImage.size.height * 0.5f, normalImage.size.width * 0.5f);
    [self setBackgroundImage:[normalImage resizableImageWithCapInsets:normalImageInsets] forState:UIControlStateNormal];
    
    UIImage* highligtedImage = [self backgroundImageForState:UIControlStateSelected];
    UIEdgeInsets highligtedImageInsets = UIEdgeInsetsMake(highligtedImage.size.height * 0.5f, highligtedImage.size.width * 0.5f, highligtedImage.size.height * 0.5f, highligtedImage.size.width * 0.5f);
    highligtedImage = [highligtedImage resizableImageWithCapInsets:highligtedImageInsets];
    [self setBackgroundImage:highligtedImage forState:UIControlStateSelected];
    [self setBackgroundImage:highligtedImage forState:UIControlStateHighlighted];
}

@end


@implementation UILabel (K9Helper)

- (void)correctLineSpacingOf:(CGFloat)pixels
{
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = pixels; // InPixels
    paragraphStyle.alignment = self.textAlignment;
    paragraphStyle.lineBreakMode = self.lineBreakMode;
    
    UIFont* font = self.font;
    
    self.attributedText = [[NSAttributedString alloc] initWithString:
                                        self.text attributes:
                                        @{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : font}];
}

@end

@implementation UITextView (K9Helper)

- (void)correctLineSpacingOf:(CGFloat)pixels
{
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = pixels; // InPixels
    paragraphStyle.alignment = self.textAlignment;
    
    UIFont* font = self.font;
    
    self.attributedText = [[NSAttributedString alloc] initWithString:
                           self.text attributes:
                           @{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : font}];
}

@end

