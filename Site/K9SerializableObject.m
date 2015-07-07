//
//  K9SerializableObject.m
//
//
//  Created by Sania on 30.04.13.
//  Copyright (c) 2013 Orangesoft. All rights reserved.
//

#import "K9SerializableObject.h"
#import "K9ServerCache.h"
//#import "K9ChatCoreData.h"
#import <objc/runtime.h>

@interface K9SerializableObject()
@end

#pragma mark -

@implementation K9SerializableObject

@synthesize additionalInfo;

+ (id)create:(id)info
{
    if ([K9ServerCache descriptionForClass:[self class]] != nil)
    {
        id instance = [K9ServerCache createObjectForClass:[self class]];
        if (instance != nil)
        {
            [instance reload:info];
            return instance;
        }
    }
//    else if ([K9ChatCoreData descriptionForClass:[self class]] != nil)
//    {
//        id instance = [K9ChatCoreData createObjectForClass:[self class]];
//        if (instance != nil)
//        {
//            [instance reload:info];
//            return instance;
//        }
//    }
    else
    {
        id instance = [[[self class] alloc] init];
        if (instance != nil)
        {
            [instance reload:info];
            return instance;
        }
    }
    return nil;
}

#pragma mark - Deserialization

+ (void)create:(id)info completed:(K9CompleteWithObjectBlock)completed
{
    [K9ServerCache performBlockOnBaseQueue:^{
        if ([K9ServerCache descriptionForClass:[self class]] != nil)
        {
            id instance = [K9ServerCache createObjectForClass:[self class]];
            [instance reload:info];
            if (completed)
            {
                completed(instance);
            }
        }
//        else if ([K9ChatCoreData descriptionForClass:[self class]] != nil)
//        {
//            id instance = [K9ChatCoreData createObjectForClass:[self class]];
//            [instance reload:info];
//            if (completed)
//            {
//                completed(instance);
//            }
//        }
        else
        {
            if (completed)
            {
                id instance = [[[self class] alloc] init];
                [instance reload:info];
                completed(instance);
            }
        }
    }];
}


- (void)load:(id)info   // load new, merge with old
{
    if (info != nil && [info isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* infoDictionary = (NSDictionary*)info;
        NSDictionary* properties = [self allProperties];
        
        for (NSString* itemName in infoDictionary.allKeys)
        {
            if (![self preCustomConvertField:itemName value:[infoDictionary valueForKey:itemName]])
            {
                if (![self customConvertField:itemName value:[infoDictionary valueForKey:itemName]])
                {
                    if ([properties valueForKey:itemName] != nil)
                    {
                        id value = [infoDictionary valueForKey:itemName];
                        BOOL canConvert = (value != nil);
                        if ([value isKindOfClass:[NSNull class]])
                        {
                            canConvert = NO;
                        }
                        if ([value isKindOfClass:[NSDictionary class]] && [(NSDictionary*)value count] == 0)
                        {
                            canConvert = NO;
                        }
                        if (canConvert)
                        {
                            id itemValue = [infoDictionary valueForKey:itemName];
                            if ([properties valueForKey:itemName] == [NSString class])
                            {
                                itemValue = [NSString stringWithFormat:@"%@", itemValue];
                            }
                            else if (![itemValue isKindOfClass:[properties valueForKey:itemName]])
                            {
                                LOG(@"Type mismatch! Current type of '%@.%@' is '%@'. Expect type '%@'. Value: '%@'", NSStringFromClass([self class]), itemName, NSStringFromClass([properties valueForKey:itemName]), NSStringFromClass([[infoDictionary valueForKey:itemName] class]), [infoDictionary valueForKey:itemName]);
                            }
                            
                            [self setValue:itemValue forKey:itemName];
                        }                    
                    }
                    else
                    {
                        if (additionalInfo == nil)
                        {
                            self.additionalInfo = [NSMutableDictionary dictionary];
                        }
                        NSObject* value = [info valueForKey:itemName];
                        NSString* propertyName = nil;
                        for (NSString* property in properties.allKeys)
                        {
                            if ([property compare:itemName options:NSCaseInsensitiveSearch] == NSOrderedSame)
                            {
                                propertyName = property;
                                break;
                            }
                        }
                        if (propertyName != nil)
                        {
                            BOOL canConvert = (value != nil);
                            if ([value isKindOfClass:[NSNull class]])
                            {
                                canConvert = NO;
                            }
                            if ([value isKindOfClass:[NSDictionary class]] && [(NSDictionary*)value count] == 0)
                            {
                                canConvert = NO;
                            }
                            if (canConvert)
                            {
                                [self setValue:[info valueForKey:itemName] forKey:propertyName];
                         //       LOG(@"Can't find property '%@' of class '%@'. Use '%@' value: '%@'", itemName, NSStringFromClass([self class]), propertyName, value);
                            }
                        }
                        else
                        {
                            LOG(@"Property not exists! Current class: '%@'. Expect property: '%@' Expect type: '%@'. Value: '%@'", NSStringFromClass([self class]), itemName,  NSStringFromClass([value class]), value);
                        }
                    }
                }
            }
        }
    }
}

- (void)reload:(id)info // clean all, load new
{
    [self setDefaultValues];
    [self load:info];
}

- (void)setDefaultValues
{
    self.additionalInfo = [NSMutableDictionary dictionary];
}

- (BOOL)customConvertField:(NSString*)key value:(NSObject*)value
{
    return NO;
}

- (BOOL)preCustomConvertField:(NSString*)key value:(NSObject*)value
{
    return NO;
}

#pragma mark - Serialization

- (NSDictionary*)allProperties // Dictionary of classes
{
    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    
    Class curClass = [self class];
    do
    {
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList(curClass, &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            
            NSString* propertyName = [NSString stringWithUTF8String:property_getName(property)];
            
            char* tmpPropertyClassName = property_copyAttributeValue(property, "T");
            NSString* propertyClassName = [NSString stringWithUTF8String:tmpPropertyClassName];
            if (propertyClassName != nil)
            {
                propertyClassName = [propertyClassName stringByReplacingOccurrencesOfString:@"@" withString:@""];
                propertyClassName = [propertyClassName stringByReplacingOccurrencesOfString:@"\"" withString:@""];

                if (propertyClassName.length == 1)
                {
                    const char* propertyType = [propertyClassName UTF8String];
                    switch (propertyType[0])
                    {
                        case 'i': // int
                        case 's': // short
                        case 'l': // long
                        case 'q': // long long
                        case 'I': // unsigned int
                        case 'S': // unsigned short
                        case 'L': // unsigned long
                        case 'Q': // unsigned long long
                        case 'f': // float
                        case 'd': // double
                        case 'B': // BOOL
                            propertyClassName = @"NSNumber";
                            break;
                    
                        case 'c': // char
                        case 'C': // unsigned char
                            propertyClassName = @"NSString";
                            break;
                                                       
                        default:
                            break;
                    }
                }
                else if (propertyClassName.length == 0)
                {
                    propertyClassName = @"NSObject";
                }
                
                Class propertyClass = NSClassFromString(propertyClassName);

                [result setValue:propertyClass forKey:propertyName];
            }
            
            if (tmpPropertyClassName)
            {
                free(tmpPropertyClassName);
            }
        }
        curClass = [curClass superclass];
        
        if (properties)
        {
            free(properties);
        }
    } while ([curClass isSubclassOfClass:[NSObject class]] && curClass != [NSObject class]);
    
    return result;
}

- (NSMutableDictionary*)serializeToDictionary
{
    return [self serializeToDictionary:DateFormat_ISO6801];
}

- (NSMutableDictionary*)serializeToDictionary:(DateFormat)dateFormat
{
    NSDictionary* properties = [self allProperties];
    
    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    
    for (NSString* propertyName in properties.allKeys)
    {
        if ([[self valueForKey:propertyName] isKindOfClass:[NSDate class]])
        {
            switch (dateFormat) {
                case DateFormat_IOS_Default:
                    [result setValue:[(NSDate*)[self valueForKey:propertyName] description] forKey:propertyName];
                    break;
                    
                case DateFormat_ISO6801:
                    [result setValue:[(NSDate*)[self valueForKey:propertyName] convertDateTime_iso8601] forKey:propertyName];
                    break;
                    
                case DateFormat_RubyRails:
                    [result setValue:[(NSDate*)[self valueForKey:propertyName] convertDateTime_RubyRails] forKey:propertyName];
                    break;
                    
                default:
                    break;
            }
        }
        else if ([[self valueForKey:propertyName] isKindOfClass:[NSArray class]])
        {
            NSArray* originalArray = (NSArray*)[self valueForKey:propertyName];
            NSMutableArray* resultTmp = [NSMutableArray arrayWithCapacity:originalArray.count];
            for (NSObject* item in originalArray)
            {
                if ([item respondsToSelector:@selector(serializeToDictionary)])
                {
                    [resultTmp addObject:[item performSelector:@selector(serializeToDictionary)]];
                }
                else
                {
                    [resultTmp addObject:item];
                }
            }
            [result setValue:resultTmp forKey:propertyName];
        }
        else if ([[self valueForKey:propertyName] isKindOfClass:[K9SerializableObject class]])
        {
            [result setValue:[[self valueForKey:propertyName] serializeToDictionary:dateFormat] forKey:propertyName];
        }
        else
        {
            [result setValue:[self valueForKey:propertyName] forKey:propertyName];
        }
    }
    return result;
}

#pragma mark - Helpers

+ (UIColor*)colorFromDictinary:(NSDictionary*)info
{
    CGFloat red = [[info valueForKey:@"Red"] floatValue];
    CGFloat green = [[info valueForKey:@"Green"] floatValue];
    CGFloat blue = [[info valueForKey:@"Blue"] floatValue];
    CGFloat alpha = [[info valueForKey:@"Alpha"] floatValue];
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor*)colorFromString:(NSString*)info
{
    NSString* rgbString = [info stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    NSInteger rgbColor = [K9SerializableObject convertHEXtoINT:rgbString];
    
    NSInteger red = (rgbColor >> 16) & 0xFF;
    NSInteger green = (rgbColor >> 8) & 0xFF;
    NSInteger blue = rgbColor & 0xFF;
    
    return [UIColor colorWithRed:red / 255.0f green:green / 255.0f blue:blue / 255.0f alpha:1.0f];
}

+ (NSInteger)convertHEXtoINT:(NSString*)hex
{
    static NSString* hexPattern = @"0123456789ABCDEF";
    
    NSInteger result = 0;
    
    for (NSInteger index = hex.length - 1; index >= 0; --index)
    {
        NSString* part = [hex substringWithRange:NSMakeRange(index, 1)];
        NSRange range = [hexPattern rangeOfString:part options:NSCaseInsensitiveSearch];
        result += range.location << ((hex.length - 1 - index) << 2);
    }
    
    return result;
}


+ (BOOL)passwordValidateString:(NSString*)value {
    
    BOOL validate = NO;

    if ([value length] >= REGISTRATION_PASSWORD_MIN_LENGHT) {
        validate =YES;
    }
    
    if (!validate) {
        UIAlertView *alertEmail = [[UIAlertView alloc] initWithTitle: ALERT_ATTENTION
                                                             message: AUTHORIZATION_PASSWORD_FAIL
                                                            delegate: nil
                                                   cancelButtonTitle: ALERT_OK
                                                   otherButtonTitles: nil];
        [alertEmail show];
        alertEmail = nil;

    }
    
    return validate;
    
}

@end
