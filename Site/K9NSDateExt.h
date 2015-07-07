//
//  K9NSDateExt.h
//  Beep
//
//  Created by Sania on 21.04.14.
//  Copyright (c) 2014 OrangeSoft_Brest. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    DateFormat_IOS_Default,
    DateFormat_ISO6801,
    DateFormat_RubyRails,
} DateFormat;


@interface NSDate (K9Helper)

- (NSString*)convertDate_iso8601;
- (NSString*)convertDateTime_iso8601;
- (NSString*)convertTime_iso8601;

- (NSString*)convertDate_Calendar;
- (NSString*)convertDateTime_Watch;
- (NSString*)convertTime_Watch;

- (NSString*)convertDate_Mobile;
- (NSString*)convertDateTime_Mobile;

- (NSString*)convertDateTime_RubyRails;
- (NSString*)convertDate_RubyRails;
- (NSString*)convertTime_RubyRails;


+ (NSDate*)date_iso8601:(NSString*)src; // Example, @"2013-06-25T14:30:25"

+ (NSDate*)date_Sabidom:(NSString*)src;

+ (NSDate*)date_RubyRails:(NSString*)src;

+ (NSDate*)dateFromDateTime:(NSDate*)src;




@end
