//
//  K9UIColorExt.m
//  Beep
//
//  Created by Navigator on 27.04.14.
//  Copyright (c) 2014 OrangeSoft_Brest. All rights reserved.
//

#import "K9UIColorExt.h"

#define verificationColor [UIColor colorWithRed:242.0/255.0  green:161.0/255.0   blue:51.0 /255.0 alpha:1.0]    //На проверке - оранжевый
#define responseColor     [UIColor colorWithRed:54.0 /255.0  green:144.0/255.0   blue:47.0 /255.0 alpha:1.0]    //Ответ - зеленый
#define cancelledColor    [UIColor colorWithRed:159.0/255.0  green:41.0 /255.0   blue:50.0 /255.0 alpha:1.0]    //Отклонено - красный
#define registrationColor [UIColor colorWithRed:84.0 /255.0  green:174.0/255.0   blue:148.0/255.0 alpha:1.0]    //Зарегистрировано - светло зеленый
#define reviewColor       [UIColor colorWithRed:52.0 /255.0  green:121.0/255.0   blue:135.0/255.0 alpha:1.0]    //Рассмотрение - сине-зеленый
#define lightgrayColor    [UIColor colorWithRed:235.0/255.0  green:235.0/255.0   blue:235.0/255.0 alpha:1.0]    //Не прочитанное сообщение - светло-серый

#define BACKGROUND_COLOR        [UIColor colorWithRed:0.0/255.0      green:122.0/255.0   blue:255.0 /255.0 alpha:1.0]
#define BACKGROUND_SEARCH_BAR   [UIColor colorWithRed:249.0/255.0    green:249.0/255.0   blue:251.0 /255.0 alpha:1.0]

#define PLACEHOLDER_TEXT_COLOR  [UIColor colorWithRed:155.0/255.0    green:155.0/255.0   blue:155.0 /255.0 alpha:1.0]
#define BACKGROUND_VIEW_COLOR   [UIColor colorWithRed:229.0/255.0    green:229.0/255.0   blue:229.0 /255.0 alpha:1.0]

@implementation UIColor (K9Color)

+ (UIColor*)VerificationColor{
    return verificationColor;
}

+ (UIColor*)ResponseColor{
    return responseColor;
}

+ (UIColor*)CancelledColor{
    return cancelledColor;
}

+ (UIColor*)RegistrationColor{
    return registrationColor;
}

+ (UIColor*)ReviewColor{
    return reviewColor;
}

+ (UIColor*)LightGrayColor{
    return lightgrayColor;
}

+ (UIColor*)backgroundColor{
    return BACKGROUND_COLOR;
}

+ (UIColor*)backgroundSearchBarColor{
    return BACKGROUND_SEARCH_BAR;
}

+ (UIColor*)placeholderTextColor{
    return PLACEHOLDER_TEXT_COLOR;
}

+ (UIColor*)backgroundViewColor{
    return BACKGROUND_VIEW_COLOR;
}

+ (UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])  cString = [cString substringFromIndex:1];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

+ (UIColor*)textColorForBackground:(UIColor*)backgroundColor
{
    const CGFloat *componentColors = CGColorGetComponents([backgroundColor CGColor]);
    
    CGFloat contrast = (componentColors[0]*299 + componentColors[1]*587 + componentColors[2]*114)/1000;
    
    if (contrast < 0.5) {
        return [UIColor whiteColor];
    }else{
        return [UIColor blackColor];
    }
}

+ (void)max:(int*)max andMin:(int*)min ofArray:(float[])array
{
    *min=0;
    *max=0;
    for(int i=1; i<3; i++)
    {
        if(array[i] > array[*max])
            *max=i;
        if(array[i] < array[*min])
            *min=i;
    }
}

+ (K9HSBColor*)colorWithRed:(float)red Green:(float)green Blue:(float)blue
{
    K9HSBColor* toReturn = [[K9HSBColor alloc] init];
    
    float colorArray[3];
    colorArray[0] = red;
    colorArray[1] = green;
    colorArray[2] = blue;
    //NSLog(@"RGB: %f %f %f",colorArray[0],colorArray[1],colorArray[2]);
    int max;
    int min;
    [self max:&max andMin:&min ofArray:colorArray];
    
    if(max==min)
    {
        toReturn.hue=0;
        toReturn.saturation=0;
        toReturn.brightness=colorArray[0];
    }
    else
    {
        toReturn.brightness=colorArray[max];
        
        toReturn.saturation=(colorArray[max]-colorArray[min])/(colorArray[max]);
        
        if(max==0) // Red
            toReturn.hue = (colorArray[1]-colorArray[2])/(colorArray[max]-colorArray[min])*60/360;
        else if(max==1) // Green
            toReturn.hue = (2.0 + (colorArray[2]-colorArray[0])/(colorArray[max]-colorArray[min]))*60/360;
        else // Blue
            toReturn.hue = (4.0 + (colorArray[0]-colorArray[1])/(colorArray[max]-colorArray[min]))*60/360;
    }
    return toReturn;
}

+ (K9HSBColor*)colorWithSystemColor:(UIColor*)color
{
    
    const CGFloat* components = CGColorGetComponents(color.CGColor);
    
    return [self colorWithRed:components[0] Green:components[1] Blue:components[2]];
}

@end
