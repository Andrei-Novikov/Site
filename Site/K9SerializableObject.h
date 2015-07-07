//
//  K9SerializableObject.h
//
//
//  Created by Sania on 30.04.13.
//  Copyright (c) 2013 Orangesoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "K9Helpers.h"

#define REGISTRATION_PASSWORD_MIN_LENGHT 7
#define AUTHORIZATION_PASSWORD_FAIL @"Ошибка при вводе пароля"

@interface K9SerializableObject : NSObject
@property (nonatomic, retain) NSDictionary* additionalInfo; // can be nil

+ (id)create:(id)info;
+ (void)create:(id)info completed:(K9CompleteWithObjectBlock)completed;   // info NSDictionary or K9BaseResponse
- (void)load:(id)info;   // load new, merge with old    // info NSDictionary or K9BaseResponse
- (void)reload:(id)info; // clean all, load new     // info NSDictionary or K9BaseResponse

- (void)setDefaultValues;

- (NSMutableDictionary*)serializeToDictionary; // Default use date ISO8601
- (NSMutableDictionary*)serializeToDictionary:(DateFormat)dateFormat;

#pragma mark - Helpers

+ (UIColor*)colorFromDictinary:(NSDictionary*)info;
+ (UIColor*)colorFromString:(NSString*)info; // "#RRGGBB"
+ (NSInteger)convertHEXtoINT:(NSString*)hex;

#pragma mark Validation

+ (BOOL)passwordValidateString:(NSString*)value;

@end
