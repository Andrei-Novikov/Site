//
//  K9UIHelpers.h
//  EDiary4Schools
//
//  Created by Sania on 16.05.13.
//  Copyright (c) 2013 Orangesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (K9ImageHelper)

- (UIImage*)makeResizable;

- (UIImage*)scaleToSize:(CGSize)destSize withBorder:(CGFloat)borderWidth;
- (UIImage*)scaleToSize:(CGSize)destSize leftBorder:(CGFloat)leftWidth rightBorder:(CGFloat)rightWidth;
- (UIImage*)scaleToSize:(CGSize)destSize leftBorder:(CGFloat)leftWidth rightBorder:(CGFloat)rightWidth topBorder:(CGFloat)topHeight bottomBorder:(CGFloat)bottomHeight;

- (UIImage*)createTiledImageToSize:(CGSize)destSize;

+ (UIImage*)imageWithColor:(UIColor *)color;


@end

@interface  UIButton (K9ImageHelper)

- (void)scaleBackgorundImageToSize:(CGSize)destSize leftBorder:(CGFloat)leftWidth rightBorder:(CGFloat)rightWidth;
- (void)scaleBackgorundImageToSize:(CGSize)destSize withBorder:(CGFloat)border;

- (void)makeBackgroundResizable;

@end

@interface UILabel (K9Helper)

- (void)correctLineSpacingOf:(CGFloat)pixels;

@end

@interface UITextView (K9Helper)

- (void)correctLineSpacingOf:(CGFloat)pixels;

@end