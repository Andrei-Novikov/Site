//
//  Helpers.h
//  Beep
//
//  Created by Sania on 02.05.14.
//  Copyright (c) 2014 OrangeSoft_Brest. All rights reserved.
//

#ifndef _Helpers_h
#define _Helpers_h


typedef void (^K9CompleteBlock)(void);
typedef void (^K9CompleteWithObjectBlock)(id object);
typedef void (^K9CompleteWithArrayBlock)(NSArray* result);
typedef void (^K9InitObjectBlock)(id object);

CG_INLINE CGPoint
CGPointAdd(CGPoint first, CGPoint second)
{
    return CGPointMake(first.x + second.x, first.y + second.y);
}

CG_INLINE CGPoint
CGPointSub(CGPoint first, CGPoint second)
{
    return CGPointMake(first.x - second.x, first.y - second.y);
}

CG_INLINE CGPoint
CGPointMulF(CGPoint point, CGFloat multiplexor)
{
    return CGPointMake(point.x * multiplexor, point.y * multiplexor);
}

CG_INLINE CGPoint
CGPointDivF(CGPoint point, CGFloat devider)
{
    return CGPointMake(point.x / devider, point.y / devider);
}


CG_INLINE CGRect
CGRectMulF(CGRect rect, CGFloat multiplexor)
{
    return CGRectMake(rect.origin.x * multiplexor, rect.origin.y * multiplexor, rect.size.width * multiplexor, rect.size.height * multiplexor);
}

CG_INLINE CGRect
CGRectDivF(CGRect rect, CGFloat devider)
{
    return CGRectMake(rect.origin.x / devider, rect.origin.y / devider, rect.size.width / devider, rect.size.height / devider);
}

CG_INLINE BOOL emailValidateString(NSString* value)
{
    NSString *emailRegex = @"[A-Z0-9a-z._-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:value];
}

typedef enum
{
    PhoneNumberCountry_Belorussian,
    PhoneNumberCountry_Russian,
} PhoneNumberCountry;

CG_INLINE NSString*
PhoneNumberFromString(NSString* src, PhoneNumberCountry country)
{
    NSString* tmpSrc = src;
    NSString* dst = @"";
    
    switch (country) {
        case PhoneNumberCountry_Belorussian:
        { // Belorussian
            NSInteger length = MIN(tmpSrc.length, 3);
            dst = [NSString stringWithString:[tmpSrc substringToIndex:length]]; // 375
            tmpSrc = [tmpSrc substringFromIndex:length];
            length = MIN(tmpSrc.length, 2);
            dst = (length ? [NSString stringWithFormat:@"%@ (%@)", dst, [tmpSrc substringToIndex:length]] : dst); // Operator code
            tmpSrc = [tmpSrc substringFromIndex:length];
            length = MIN(tmpSrc.length, 3);
            dst = (length ? [NSString stringWithFormat:@"%@ %@", dst, [tmpSrc substringToIndex:length]] : dst);
            tmpSrc = [tmpSrc substringFromIndex:length];
            length = MIN(tmpSrc.length, 2);
            dst = (length ? [NSString stringWithFormat:@"%@-%@", dst, [tmpSrc substringToIndex:length]] : dst);
            tmpSrc = [tmpSrc substringFromIndex:length];
            dst = (tmpSrc.length ? [NSString stringWithFormat:@"%@-%@", dst, tmpSrc] : dst);
        }
            break;
            
        case PhoneNumberCountry_Russian:
        { // Russian
            NSInteger length = MIN(tmpSrc.length, 1);
            dst = [NSString stringWithString:[tmpSrc substringToIndex:length]]; // 7
            tmpSrc = [tmpSrc substringFromIndex:length];
            length = MIN(tmpSrc.length, 3);
            dst = (length ? [NSString stringWithFormat:@"%@ %@", dst, [tmpSrc substringToIndex:length]] : dst); // Operator code
            tmpSrc = [tmpSrc substringFromIndex:length];
            length = MIN(tmpSrc.length, 3);
            dst = (length ? [NSString stringWithFormat:@"%@ %@", dst, [tmpSrc substringToIndex:length]] : dst);
            tmpSrc = [tmpSrc substringFromIndex:length];
            length = MIN(tmpSrc.length, 2);
            dst = (length ? [NSString stringWithFormat:@"%@-%@", dst, [tmpSrc substringToIndex:length]] : dst);
            tmpSrc = [tmpSrc substringFromIndex:length];
            dst = (tmpSrc.length ? [NSString stringWithFormat:@"%@-%@", dst, tmpSrc] : dst);
        }
            break;
            
        default:
            break;
    }
    
    return dst;
}

#endif

#ifndef LOG
    #ifndef DEBUG
        #define LOG(...)
    #else
        #define LOG(FORMAT, ...) NSLog(@"%s - %@", __FUNCTION__, [NSString stringWithFormat: FORMAT, ##__VA_ARGS__])
    #endif
#endif

#ifndef DEVICE_SCALE
    #define DEVICE_SCALE [UIScreen mainScreen].scale
#endif

#ifndef IS_IOS7
    #define IS_IOS7 ([[UIDevice currentDevice] systemVersion].integerValue > 6)
#endif

#ifndef IOS_VERSION
    #define IOS_VERSION ([[UIDevice currentDevice] systemVersion].integerValue)
#endif

#define STR(__LOCALIZED_STRING__) NSLocalizedString((__LOCALIZED_STRING__), nil)

#define DOCUMENTS_DIRECTORY ([[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject])
#define CACHES_DIRECTORY    ([[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask]   lastObject])

#define ALERT_SHOW  if ([NSThread isMainThread]) [alert show]; else [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO]

