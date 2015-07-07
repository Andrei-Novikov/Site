//
//  K9NSManagedObject.h
//
//
//  Created by dev on 14.06.13.
//  Copyright (c) 2013 Orangesoft. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "K9Helpers.h"

@interface NSManagedObject (K9_Ext)

+ (id)create:(NSDictionary*)info;
+ (void)createWithBlock:(K9InitObjectBlock)initBlock;
+ (void)create:(NSDictionary*)info completed:(K9CompleteWithObjectBlock)completed;
- (void)load:(NSDictionary*)info;   // load new, merge with old
- (void)reload:(NSDictionary*)info; // clean all, load new

- (void)setDefaultValues;

- (NSMutableDictionary*)serializeToDictionary;
- (NSMutableDictionary*)serializeToDictionary:(DateFormat)dateFormat;

- (NSDictionary*)allProperties;

@end
