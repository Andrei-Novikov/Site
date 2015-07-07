//
//  K9UIFontExt.h
//  Beep
//
//  Created by Sania on 16.07.14.
//  Copyright (c) 2014 OrangeSoft_Brest. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (K9_Ext)
+ (NSString*)registerCustomFontWithFilePath:(NSString*)fileFullPath; // return registered font name or nil
+ (NSString*)registerCustomFontWithURL:(NSURL*)fileURL; // return registered font name or nil
@end
