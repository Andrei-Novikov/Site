//
//  K9NSManagedObject.m
//
//
//  Created by dev on 14.06.13.
//  Copyright (c) 2013 Orangesoft. All rights reserved.
//

#import "K9NSManagedObject.h"
#import <objc/runtime.h>
#import "K9ServerCache.h"
//#import "K9ChatCoreData.h"
#import "K9ServerManager.h"

@implementation NSManagedObject (K9_Ext)

#pragma mark - Deserialization

+ (id)create:(NSDictionary*)info
{
    if ([K9ServerCache descriptionForClass:[self class]] != nil)
    {
        id object = [K9ServerCache createObjectForClass:[self class]];
        if (object != nil)
        {
            [object reload:info];
            return object;
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
    return nil;
}

+ (void)createWithBlock:(K9InitObjectBlock)initBlock
{
    if ([K9ServerCache descriptionForClass:[self class]] != nil)
    {
        [K9ServerCache createObjectForClass:[self class] completed:^(id object) {
            if (object != nil)
            {
                [object reload:@{}];
            }
            if (initBlock != nil)
            {
                initBlock(object);
            }
        }];
    }
//    else if ([K9ChatCoreData descriptionForClass:[self class]] != nil)
//    {
//        [K9ChatCoreData createObjectForClass:[self class] completed:^(id object) {
//            if (object != nil)
//            {
//                [object reload:@{}];
//            }
//            if (initBlock != nil)
//            {
//                initBlock(object);
//            }
//        }];
//    }
}

+ (void)create:(NSDictionary*)info completed:(K9CompleteWithObjectBlock)completed
{
    if ([K9ServerCache descriptionForClass:[self class]] != nil)
    {
        [K9ServerCache createObjectForClass:[self class] completed:^(id object) {
            if (object != nil)
            {
                [object reload:info];
            }
            if (completed != nil)
            {
                completed(object);
            }
        }];
    }
//    else if ([K9ChatCoreData descriptionForClass:[self class]] != nil)
//    {
//        [K9ChatCoreData createObjectForClass:[self class] completed:^(id object) {
//            if (object != nil)
//            {
//                [object reload:info];
//            }
//            if (completed != nil)
//            {
//                completed(object);
//            }
//        }];
//    }
}

- (void)load:(NSDictionary*)info   // load new, merge with old
{
    if (info != nil && [info isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* infoDictionary = (NSDictionary*)info;
        NSDictionary* properties = [self allProperties];
        
        for (NSString* itemName in info.allKeys)
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
                                [self setValue:itemValue forKey:itemName];
                            }
                            else if (![itemValue isKindOfClass:[properties valueForKey:itemName]])
                            {
                                LOG(@"Type mismatch! Current type of '%@.%@' is '%@'. Expect type '%@'. Value: '%@'", NSStringFromClass([self class]), itemName, NSStringFromClass([properties valueForKey:itemName]), NSStringFromClass([[infoDictionary valueForKey:itemName] class]), [infoDictionary valueForKey:itemName]);
                            }
                            else
                            {
                                [self setValue:itemValue forKey:itemName];
                            }
                        }
                    }
                    else
                    {
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
                      //          LOG(@"Can't find property '%@' of class '%@'. Use '%@' value: '%@'", itemName, NSStringFromClass([self class]), propertyName, value);
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

- (void)reload:(NSDictionary*)info // clean all, load new
{
    [self setDefaultValues];
    [self load:info];
}

- (void)setDefaultValues
{
}

- (BOOL)preCustomConvertField:(NSString*)key value:(NSObject*)value
{
    return NO;
}

- (BOOL)customConvertField:(NSString*)key value:(NSObject*)value
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
        else
        {
            [result setValue:[self valueForKey:propertyName] forKey:propertyName];
        }
    }
    return result;
}


/*
- (NSString*)description // Need for print russian symbols to console
{
    NSDictionary* allValueDictionary = [self serializeToDictionary:NO];
    NSString* convertedString = [K9ServerManager convertDictionaryToString:allValueDictionary leftSymbols:@""];
    return [[super description] stringByAppendingFormat:@" %@", convertedString];
}*/

@end
