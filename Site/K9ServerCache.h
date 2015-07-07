//
//  K9ServerCache.h
//
//
//  Created by Alexey Artemenko on 6/5/13.
//  Copyright (c) 2013 Orangesoft. All rights reserved.
//

#import "K9SerializableObject.h"

@interface K9ServerCache : NSObject

+ (K9ServerCache*)shareInstance;

+ (NSEntityDescription*)descriptionForClass:(Class)objectClass;


+ (id)createObjectForClass:(Class)objectClass;
+ (void)removeObjectFromBase:(NSManagedObject*)object;
+ (void)removeObjectsArrayFromBase:(NSArray*)array;
+ (void)removeAllObjectOfClass:(Class)objectsClass;
+ (void)replaceObject:(NSManagedObject*)object;
+ (id)singleObjectsForClass:(Class)objectClass;

+ (NSArray*)allObjectsForClass:(Class)objectClass;
+ (NSArray*)allObjectsForClass:(Class)objectClass withFilter:(NSString*)filter; // filter can be nil
+ (NSArray*)allObjectsForClass:(Class)objectClass sortForField:(NSString*)fieldName ascending:(BOOL)ascending;
+ (NSArray*)allObjectsForClass:(Class)objectClass sortForField:(NSString*)fieldName ascending:(BOOL)ascending comparator:(NSComparator)comparator;
+ (NSArray*)allObjectsForClass:(Class)objectClass withFilter:(NSString*)filter sortForField:(NSString*)fieldName ascending:(BOOL)ascending;
+ (NSArray*)allObjectsForClass:(Class)objectClass withFilter:(NSString*)filter sortForField:(NSString*)fieldName ascending:(BOOL)ascending comparator:(NSComparator)comparator;


+ (void)changeBase:(NSString*)baseName;




+ (void)createObjectForClass:(Class)objectClass completed:(K9CompleteWithObjectBlock)completed;
+ (void)descriptionForClass:(Class)objectClass completed:(K9CompleteWithObjectBlock)completed;
+ (void)removeObjectFromBase:(NSManagedObject*)object completed:(K9CompleteBlock)completed;
+ (void)removeObjectsArrayFromBase:(NSArray*)array completed:(K9CompleteBlock)completed;
+ (void)removeAllObjectOfClass:(Class)objectsClass completed:(K9CompleteBlock)completed;
+ (void)replaceObject:(NSManagedObject*)object completed:(K9CompleteBlock)completed;
+ (void)singleObjectsForClass:(Class)objectClass completed:(K9CompleteWithObjectBlock)completed;

+ (void)allObjectsForClass:(Class)objectClass completed:(K9CompleteWithArrayBlock)completed;
+ (void)allObjectsForClass:(Class)objectClass withFilter:(NSString*)filter completed:(K9CompleteWithArrayBlock)completed; // filter can be nil
+ (void)allObjectsForClass:(Class)objectClass sortForField:(NSString*)fieldName ascending:(BOOL)ascending completed:(K9CompleteWithArrayBlock)completed;
+ (void)allObjectsForClass:(Class)objectClass sortForField:(NSString*)fieldName ascending:(BOOL)ascending comparator:(NSComparator)comparator completed:(K9CompleteWithArrayBlock)completed;
+ (void)allObjectsForClass:(Class)objectClass withFilter:(NSString*)filter sortForField:(NSString*)fieldName ascending:(BOOL)ascending completed:(K9CompleteWithArrayBlock)completed;
+ (void)allObjectsForClass:(Class)objectClass withFilter:(NSString*)filter sortForField:(NSString*)fieldName ascending:(BOOL)ascending comparator:(NSComparator)comparator completed:(K9CompleteWithArrayBlock)completed;

+ (void)saveBase;
+ (void)saveBaseWithCompleted:(K9CompleteWithObjectBlock)completed;
+ (void)changeBase:(NSString*)baseName completed:(K9CompleteBlock)completed;

+ (void)performBlockOnBaseQueue:(K9CompleteBlock)block;

@end
