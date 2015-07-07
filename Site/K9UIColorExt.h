//
//  K9UIColorExt.h
//  Beep
//
//  Created by Navigator on 27.04.14.
//  Copyright (c) 2014 OrangeSoft_Brest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "K9HSBColor.h"

@interface UIColor (K9Color)

+ (UIColor*)VerificationColor;
+ (UIColor*)ResponseColor;
+ (UIColor*)CancelledColor;
+ (UIColor*)RegistrationColor;
+ (UIColor*)ReviewColor;
+ (UIColor*)LightGrayColor;
+ (UIColor*)backgroundColor;
+ (UIColor*)backgroundSearchBarColor;
+ (UIColor*)placeholderTextColor;
+ (UIColor*)backgroundViewColor;

+ (UIColor*)colorWithHexString:(NSString*)hex;
+ (UIColor*)textColorForBackground:(UIColor*)backgroundColor;

+ (K9HSBColor*)colorWithSystemColor:(UIColor*)color;
@end
