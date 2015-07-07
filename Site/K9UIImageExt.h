//
//  K9UIViewExt.h
//  Beep
//
//  Created by Sania on 27.06.14.
//  Copyright (c) 2014 OrangeSoft_Brest. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (K9_Ext)

- (UIImage*)addBlurEffect; // with default Radius (10.0)
- (UIImage*)addBlurEffectWithRadius:(NSNumber*)radius;
- (UIImage*)addBlackoutWithAlpha:(NSNumber*)alphaChannel;
+ (UIImage*)arrowWithSize:(CGSize)size width:(CGFloat)width color:(UIColor*)color;
- (UIImage*)resizeForSize:(CGSize)size; // resize with mode ScaleToFill
- (UIImage*)resizeForSize:(CGSize)size withEdgeInsets:(UIEdgeInsets)insets; // special for speack bubbles
- (UIImage*)normalizedImage;
- (NSArray*)detectedFeatures;
@end
