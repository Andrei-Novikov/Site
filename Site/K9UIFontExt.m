//
//  K9UIFontExt.m
//  Beep
//
//  Created by Sania on 16.07.14.
//  Copyright (c) 2014 OrangeSoft_Brest. All rights reserved.
//

#import "K9UIFontExt.h"
#import <CoreText/CoreText.h>


@implementation UIFont (K9_Ext)

+ (NSString*)registerCustomFontWithFilePath:(NSString*)fileFullPath
{
    CGDataProviderRef fontDataProvider = CGDataProviderCreateWithFilename([fileFullPath UTF8String]);
    if (fontDataProvider)
    {
        CGFontRef customFont = CGFontCreateWithDataProvider(fontDataProvider);
        if (customFont)
        {
            CFStringRef customFontName = CGFontCopyFullName(customFont);
            NSString *fontName = [NSString stringWithFormat:@"%@", customFontName];
            CFRelease(customFontName);
            
            CFErrorRef error = nil;
            CTFontManagerRegisterGraphicsFont(customFont, &error);
            CGFontRelease(customFont);
            
            if (error == nil)
            {
                return fontName;
            }
        }
        CGDataProviderRelease(fontDataProvider);
    }
    return nil;
}

+ (NSString*)registerCustomFontWithURL:(NSURL*)fileURL
{
    CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((CFURLRef)fileURL);
    if (fontDataProvider)
    {
        CGFontRef customFont = CGFontCreateWithDataProvider(fontDataProvider);
        if (customFont)
        {
            CGDataProviderRelease(fontDataProvider);
            
            CFStringRef customFontName = CGFontCopyPostScriptName(customFont);
            NSString* fontName = [NSString stringWithFormat:@"%@", customFontName];
            CFRelease(customFontName);
            
            for (NSString* familie in [UIFont familyNames])
            {
                if ([[UIFont fontNamesForFamilyName:familie] containsObject:fontName])
                {
                    CGFontRelease(customFont);
                    return fontName;
                }
            }
            
            CFErrorRef error = nil;
            CTFontManagerRegisterGraphicsFont(customFont, &error);
            CGFontRelease(customFont);
            
            if (!error)
            {
                return fontName;
            }
        }
        else
        {
            CGDataProviderRelease(fontDataProvider);
        }
    }
    return nil;
}
@end
