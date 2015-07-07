//
//  K9UIViewExt.m
//  Beep
//
//  Created by Sania on 25/09/14.
//  Copyright (c) 2014 OrangeSoft_Brest. All rights reserved.
//

#import "K9UIViewExt.h"

@implementation UIView (K9_Ext)

- (UIImage*)createSnapShot
{
    CGRect rect = [self bounds];
    rect.origin = CGPointZero;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    [self drawViewHierarchyInRect:rect afterScreenUpdates:YES];
    UIImage* snapShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return snapShot;
}

@end
