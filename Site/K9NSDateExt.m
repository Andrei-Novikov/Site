//
//  K9NSDateExt.m
//  Beep
//
//  Created by Sania on 21.04.14.
//  Copyright (c) 2014 OrangeSoft_Brest. All rights reserved.
//

#import "K9NSDateExt.h"

@implementation NSDate (K9Helper)

#pragma mark - ISO 8601

- (NSString*)convertDate_iso8601
{
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return [dateFormatter stringFromDate:self];
}

- (NSString*)convertDateTime_iso8601
{
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"];
    return [dateFormatter stringFromDate:self];    
}

- (NSString*)convertTime_iso8601
{
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    return [dateFormatter stringFromDate:self];
}

+ (NSDate*)date_iso8601:(NSString*)src
{
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss.SSSSSS'Z'"];
    NSDate* resultDate = [dateFormatter dateFromString:src];
    
    if (resultDate == nil)
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"];
        resultDate = [dateFormatter dateFromString:src];
    }
    else
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"];
        NSDate* testDate = [dateFormatter dateFromString:src];
        if (testDate != nil && [resultDate compare:testDate] == NSOrderedAscending)
        {
            return testDate;
        }
    }
    
    if (resultDate == nil)
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss.SSS'Z'"];
        resultDate = [dateFormatter dateFromString:src];
    }
    
    if (resultDate == nil)
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        resultDate = [dateFormatter dateFromString:src];
    }
    else
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        NSDate* testDate = [dateFormatter dateFromString:src];
        if (testDate != nil && [resultDate compare:testDate] == NSOrderedAscending)
        {
            return testDate;
        }
    }
    
    if (resultDate == nil)
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss'Z'"];
        resultDate = [dateFormatter dateFromString:src];
    }
    
    if (resultDate == nil)
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        resultDate = [dateFormatter dateFromString:src];
    }
    else
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        NSDate* testDate = [dateFormatter dateFromString:src];
        if (testDate != nil && [resultDate compare:testDate] == NSOrderedAscending)
        {
            return testDate;
        }
    }
    
    if (resultDate == nil)
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss.SSS"];
        resultDate = [dateFormatter dateFromString:src];
    }
    
    if (resultDate == nil)
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
        resultDate = [dateFormatter dateFromString:src];
    }
    else
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
        NSDate* testDate = [dateFormatter dateFromString:src];
        if (testDate != nil && [resultDate compare:testDate] == NSOrderedAscending)
        {
            return testDate;
        }
    }

    if (resultDate == nil)
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss"];
        resultDate = [dateFormatter dateFromString:src];
    }
    
    if (resultDate == nil)
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        resultDate = [dateFormatter dateFromString:src];
    }
    else
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        NSDate* testDate = [dateFormatter dateFromString:src];
        if (testDate != nil && [resultDate compare:testDate] == NSOrderedAscending)
        {
            return testDate;
        }
    }
    
    if (resultDate == nil)
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        resultDate = [dateFormatter dateFromString:src];
    }
    
    if (resultDate == nil)
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        resultDate = [dateFormatter dateFromString:src];
    }
    
    if (resultDate == nil)
    {
        [dateFormatter setDateFormat:@"hh:mm:ss"];
        resultDate = [dateFormatter dateFromString:src];
    }
    
    if (resultDate == nil)
    {
        [dateFormatter setDateFormat:@"HH:mm:ss"];
        resultDate = [dateFormatter dateFromString:src];
    }
    else
    {
        [dateFormatter setDateFormat:@"HH:mm:ss"];
        NSDate* testDate = [dateFormatter dateFromString:src];
        if (testDate != nil && [resultDate compare:testDate] == NSOrderedAscending)
        {
            return testDate;
        }
    }

    if (resultDate == nil)
    {
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        resultDate = [dateFormatter dateFromString:src];
    }

    return resultDate;
}

#pragma mark - User Friendly

- (NSString*)convertDate_Calendar
{
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"dd.MM.yyyy"];
    return [dateFormatter stringFromDate:self];
}

- (NSString*)convertDateTime_Watch
{
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
    return [dateFormatter stringFromDate:self];
}

- (NSString*)convertTime_Watch
{
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    return [dateFormatter stringFromDate:self];
}

- (NSString*)convertDate_Mobile
{
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"dd.MM.yy"];
    return [dateFormatter stringFromDate:self];
}

- (NSString*)convertDateTime_Mobile
{
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"dd.MM.yy HH:mm"];
    return [dateFormatter stringFromDate:self];
}

+ (NSDate*)date_Sabidom:(NSString*)src
{
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    [dateFormatter setDateFormat:@"dd.MM.yyyy hh:mm"];
    NSDate* resultDate = [dateFormatter dateFromString:src];
    
    if (resultDate == nil)
    {
        [dateFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
        resultDate = [dateFormatter dateFromString:src];
    }
    
    if (resultDate == nil)
    {
        [dateFormatter setDateFormat:@"dd.MM.yyyy"];
        resultDate = [dateFormatter dateFromString:src];
    }
    
    if (resultDate == nil)
    {
        [dateFormatter setDateFormat:@"hh:mm"];
        resultDate = [dateFormatter dateFromString:src];
    }
    
    if (resultDate == nil)
    {
        [dateFormatter setDateFormat:@"HH:mm"];
        resultDate = [dateFormatter dateFromString:src];
    }
    
    return resultDate;
}

#pragma mark - RubyRails

+ (NSDate*)date_RubyRails:(NSString*)src
{
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss 'UTC'"];
    NSDate* resultDate = [dateFormatter dateFromString:src];
    
    if (resultDate == nil)
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss 'UTC'"];
        resultDate = [dateFormatter dateFromString:src];
    }
    
    if (resultDate == nil)
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss zzz"];
        resultDate = [dateFormatter dateFromString:src];
    }
    
    if (resultDate == nil)
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
        resultDate = [dateFormatter dateFromString:src];
    }
    
    if (resultDate == nil)
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm"];
        resultDate = [dateFormatter dateFromString:src];
    }
    
    if (resultDate == nil)
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        resultDate = [dateFormatter dateFromString:src];
    }
    
    if (resultDate == nil)
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        resultDate = [dateFormatter dateFromString:src];
    }
    
    return resultDate;
}

- (NSString*)convertDateTime_RubyRails
{
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss zzz"];
    return [dateFormatter stringFromDate:self];
}

- (NSString*)convertDate_RubyRails
{
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return [dateFormatter stringFromDate:self];
}

- (NSString*)convertTime_RubyRails
{
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"hh:mm:ss"];
    return [dateFormatter stringFromDate:self];
}

#pragma mark -

+ (NSDate*)dateFromDateTime:(NSDate*)src
{
    NSString* stringSRC = [src convertDate_iso8601];
    return [NSDate date_iso8601:stringSRC];
}

@end
