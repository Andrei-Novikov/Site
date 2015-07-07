//
//  K9ServerCache.m
//
//
//  Created by Alexey Artemenko on 6/5/13.
//  Copyright (c) 2013 Orangesoft. All rights reserved.
//

//
//  Server cache for saved all information and data models
//

#import "K9ServerCache.h"
#import "K9AppDelegate.h"
#import "K9NSManagedObject.h"


@interface K9ServerCache ()
@property (nonatomic, retain) NSManagedObjectContext* m_CoreDataContext;
@property (nonatomic, retain) NSManagedObjectModel* m_CoreDataModel;
@property (nonatomic, readonly) NSManagedObjectContext* m_CDContext;
@property (nonatomic, readonly) NSManagedObjectModel* m_CDModel;
@property (nonatomic, strong) dispatch_queue_t m_databaseQueue;
@property (nonatomic, strong) NSDictionary* m_entityDescriptions;
@end

//static K9ServerCache *share = nil;

// singletone
@implementation K9ServerCache

@synthesize m_CoreDataContext;
@synthesize m_CoreDataModel;
@dynamic m_CDContext;
@dynamic m_CDModel;
@synthesize m_databaseQueue;
@synthesize m_entityDescriptions;

+ (K9ServerCache*)shareInstance {
    
    static K9ServerCache* __instance = nil;
    static dispatch_once_t __onceToken;
    dispatch_once(&__onceToken, ^
                  {
                      __instance = [[K9ServerCache alloc] init];
                  });
    return __instance;
}

- (id)init {

    if ( self = [super init] )
    {
        m_databaseQueue = dispatch_queue_create("CoreData Queue", DISPATCH_QUEUE_SERIAL); // Only SERIAL!!!  (Database thread)
        
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
    //[self saveContextPointers];
    self.m_CoreDataContext = nil;
    self.m_CoreDataModel = nil;
}

- (NSManagedObjectContext*)m_CDContext
{
    if (self.m_CoreDataContext == nil)
    {
        K9AppDelegate* mainApp = (K9AppDelegate*)[UIApplication sharedApplication].delegate;
//        self.m_CoreDataContext = mainApp.managedObjectContext;
    }
    return self.m_CoreDataContext;
}

- (NSManagedObjectModel*)m_CDModel
{
    if (self.m_CoreDataModel == nil)
    {
        K9AppDelegate* mainApp = (K9AppDelegate*)[UIApplication sharedApplication].delegate;
//        self.m_CoreDataModel = mainApp.managedObjectModel;
        self.m_entityDescriptions = [self.m_CoreDataModel entitiesByName];
    }
    return self.m_CoreDataModel;
}

- (void)saveContextPointers
{
    K9AppDelegate* mainApp = (K9AppDelegate*)[UIApplication sharedApplication].delegate;
//    self.m_CoreDataModel = mainApp.managedObjectModel;
    self.m_entityDescriptions = [self.m_CoreDataModel entitiesByName];
//    self.m_CoreDataContext = mainApp.managedObjectContext;
}

+ (id)createObjectForClass:(Class)objectClass
{
    K9ServerCache* cache = [K9ServerCache shareInstance];
    NSString* entityName = NSStringFromClass(objectClass);
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:cache.m_CDContext];
}

+ (NSEntityDescription*)descriptionForClass:(Class)objectClass
{
    K9ServerCache* cache = [K9ServerCache shareInstance];
    if (cache.m_CDModel)
    {
        NSString* entityName = NSStringFromClass(objectClass);
        return cache.m_entityDescriptions[entityName];
    }
    return nil;
}

+ (void)removeObjectFromBase:(NSManagedObject*)object
{
    NSDictionary* properties = [object allProperties];
    
    for (NSString* key in properties.allKeys)
    {
        if ([properties[key] isKindOfClass:[NSArray class]])
        {
            [K9ServerCache removeObjectsArrayFromBase:properties[key]];
        }
        else if ([properties[key] isKindOfClass:[NSManagedObject class]])
        {
            [K9ServerCache removeObjectFromBase:properties[key]];
        }
    }
    
    K9ServerCache* cache = [K9ServerCache shareInstance];
    [cache.m_CDContext deleteObject:object];
}

+ (void)removeObjectsArrayFromBase:(NSArray*)array
{
    K9ServerCache* cache = [K9ServerCache shareInstance];
    for (NSManagedObject* item in array)
    {
        //[cache.m_CDContext performSelectorOnMainThread:@selector(deleteObject:) withObject:item waitUntilDone:YES];
        [cache.m_CDContext deleteObject:item];
    }
}

+ (void)removeAllObjectOfClass:(Class)objectsClass
{
    NSArray* allObjects = [K9ServerCache allObjectsForClass:objectsClass];
    [K9ServerCache removeObjectsArrayFromBase:allObjects];
}

+ (void)replaceObject:(NSManagedObject*)object
{
    K9ServerCache* cache = [K9ServerCache shareInstance];
    [cache.m_CDContext refreshObject:object mergeChanges:YES];
}

+ (id)singleObjectsForClass:(Class)objectClass
{
    NSArray         * models = [K9ServerCache allObjectsForClass:objectClass];
    
    NSManagedObject * object = nil;
    
    if ( models != nil && models.count > 0)
    {
        object = models[0];
        
        for (NSInteger index = 1; index < models.count; ++index)
        {
            NSManagedObject * item = models[index];
            [K9ServerCache removeObjectFromBase:item];
        }
    }
    else
    {
        object = [K9ServerCache  createObjectForClass:objectClass];
    }
    return object;
    
}


+ (NSArray*)allObjectsForClass:(Class)objectClass
{
    NSEntityDescription* entityDescription = [K9ServerCache descriptionForClass:objectClass];
    if (entityDescription != nil)
    {
        NSFetchRequest* fetchRequest = [NSFetchRequest new];
        fetchRequest.entity = entityDescription;
        K9ServerCache* cache = [K9ServerCache shareInstance];
        
        NSError* error = nil;
        NSArray* result = [cache.m_CDContext executeFetchRequest:fetchRequest error:&error];
        if (error != nil)
        {
            LOG(@"Fail fetch objects: %@", error);
        }
        return [NSArray arrayWithArray:result];
    }
    return nil;
}

+ (NSArray*)allObjectsForClass:(Class)objectClass withFilter:(NSString*)filter
{
    NSEntityDescription* entityDescription = [K9ServerCache descriptionForClass:objectClass];
    if (entityDescription != nil)
    {
        NSFetchRequest* fetchRequest = [NSFetchRequest new];
        fetchRequest.entity = entityDescription;
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:filter arguments:nil];
        fetchRequest.predicate = predicate;
        
        K9ServerCache* cache = [K9ServerCache shareInstance];
        
        NSError* error = nil;
        NSArray* result = [cache.m_CDContext executeFetchRequest:fetchRequest error:&error];
        if (error != nil)
        {
            LOG(@"Fail fetch objects: %@", error);
        }
        return result;
    }
    return nil;
}

+ (NSArray*)allObjectsForClass:(Class)objectClass sortForField:(NSString*)fieldName ascending:(BOOL)ascending
{
    NSEntityDescription* entityDescription = [K9ServerCache descriptionForClass:objectClass];
    if (entityDescription != nil)
    {
        NSFetchRequest* fetchRequest = [NSFetchRequest new];
        fetchRequest.entity = entityDescription;
        
        NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:fieldName ascending:ascending];
        fetchRequest.sortDescriptors = @[sortDescriptor];
        
        K9ServerCache* cache = [K9ServerCache shareInstance];
        
        NSError* error = nil;
        NSArray* result = [cache.m_CDContext executeFetchRequest:fetchRequest error:&error];
        if (error != nil)
        {
            LOG(@"Fail fetch objects: %@", error);
        }
        return result;
    }
    return nil;
}

+ (NSArray*)allObjectsForClass:(Class)objectClass sortForField:(NSString*)fieldName ascending:(BOOL)ascending comparator:(NSComparator)comparator
{
    NSEntityDescription* entityDescription = [K9ServerCache descriptionForClass:objectClass];
    if (entityDescription != nil)
    {
        NSFetchRequest* fetchRequest = [NSFetchRequest new];
        fetchRequest.entity = entityDescription;
        
        NSSortDescriptor* sortDescriptor = nil;
        if (comparator != nil)
        {
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:fieldName ascending:ascending comparator:comparator];
        }
        else
        {
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:fieldName ascending:ascending];
        }
        fetchRequest.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        K9ServerCache* cache = [K9ServerCache shareInstance];
        
        NSError* error = nil;
        NSArray* result = [cache.m_CDContext executeFetchRequest:fetchRequest error:&error];
        if (error != nil)
        {
            LOG(@"Fail fetch objects: %@", error);
        }
        return result;
    }
    return nil;
}

+ (NSArray*)allObjectsForClass:(Class)objectClass withFilter:(NSString*)filter sortForField:(NSString*)fieldName ascending:(BOOL)ascending
{
    return [K9ServerCache allObjectsForClass:objectClass withFilter:filter sortForField:fieldName ascending:ascending comparator:nil];
}

+ (NSArray*)allObjectsForClass:(Class)objectClass withFilter:(NSString*)filter sortForField:(NSString*)fieldName ascending:(BOOL)ascending comparator:(NSComparator)comparator
{
    NSEntityDescription* entityDescription = [K9ServerCache descriptionForClass:objectClass];
    if (entityDescription != nil)
    {
        NSFetchRequest* fetchRequest = [NSFetchRequest new];
        fetchRequest.entity = entityDescription;
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:filter arguments:nil];
        fetchRequest.predicate = predicate;
        
        NSSortDescriptor* sortDescriptor = nil;
        if (comparator != nil)
        {
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:fieldName ascending:ascending comparator:comparator];
        }
        else
        {
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:fieldName ascending:ascending];
        }
        fetchRequest.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        K9ServerCache* cache = [K9ServerCache shareInstance];
        
        NSError* error = nil;
        NSArray* result = [cache.m_CDContext executeFetchRequest:fetchRequest error:&error];
        if (error != nil)
        {
            LOG(@"Fail fetch objects: %@", error);
        }
        return result;
    }
    return nil;
}

+ (void)saveBase
{
    K9ServerCache* cache = [K9ServerCache shareInstance];
    NSError* error = nil;
    [cache.m_CDContext save:&error];
    if (error != nil)
    {
        LOG(@"Fail save DataBase: %@", error);
    }
}

+ (void)changeBase:(NSString*)baseName
{
    [K9ServerCache saveBase];
    
    NSString* dataBaseName = [NSString stringWithFormat:@"%@.sqlite", baseName];
    
    K9AppDelegate* mainApp = (K9AppDelegate*)[UIApplication sharedApplication].delegate;
 //   [mainApp changeStorage:dataBaseName];
    
    [[K9ServerCache shareInstance] saveContextPointers];
}

+ (void)performBlockOnBaseQueue:(K9CompleteBlock)block
{
    if (block != nil)
    {
        dispatch_async([K9ServerCache shareInstance].m_databaseQueue, ^{
            @autoreleasepool{
                block();
            }
        });
    }
}

#pragma mark - Async (ServerCache thread)

+ (void)createObjectForClass:(Class)objectClass completed:(K9CompleteWithObjectBlock)completed
{
    dispatch_async([K9ServerCache shareInstance].m_databaseQueue, ^{
        id result = [K9ServerCache createObjectForClass:objectClass];
        if (completed != nil)
        {
            completed(result);
        }
    });
}

+ (void)descriptionForClass:(Class)objectClass completed:(K9CompleteWithObjectBlock)completed
{
    dispatch_async([K9ServerCache shareInstance].m_databaseQueue, ^{
        id result = [K9ServerCache descriptionForClass:objectClass];
        if (completed != nil)
        {
            completed(result);
        }
    });
}

+ (void)removeObjectFromBase:(NSManagedObject*)object completed:(K9CompleteBlock)completed
{
    dispatch_async([K9ServerCache shareInstance].m_databaseQueue, ^{
        [K9ServerCache removeObjectFromBase:object];
        if (completed != nil)
        {
            completed();
        }
    });
}

+ (void)removeObjectsArrayFromBase:(NSArray*)array completed:(K9CompleteBlock)completed
{
    dispatch_async([K9ServerCache shareInstance].m_databaseQueue, ^{
        [K9ServerCache removeObjectsArrayFromBase:array];
        if (completed != nil)
        {
            completed();
        }
    });
}

+ (void)removeAllObjectOfClass:(Class)objectsClass completed:(K9CompleteBlock)completed
{
    dispatch_async([K9ServerCache shareInstance].m_databaseQueue, ^{
        [K9ServerCache removeAllObjectOfClass:objectsClass];
        if (completed != nil)
        {
            completed();
        }
    });
}

+ (void)replaceObject:(NSManagedObject*)object completed:(K9CompleteBlock)completed
{
    dispatch_async([K9ServerCache shareInstance].m_databaseQueue, ^{
        [K9ServerCache replaceObject:object];
        if (completed != nil)
        {
            completed();
        }
    });
}

+ (void)singleObjectsForClass:(Class)objectClass completed:(K9CompleteWithObjectBlock)completed
{
    dispatch_async([K9ServerCache shareInstance].m_databaseQueue, ^{
        id result = [K9ServerCache singleObjectsForClass:objectClass];
        if (completed != nil)
        {
            completed(result);
        }
    });
}

+ (void)allObjectsForClass:(Class)objectClass completed:(K9CompleteWithArrayBlock)completed
{
    dispatch_async([K9ServerCache shareInstance].m_databaseQueue, ^{
        id result = [K9ServerCache allObjectsForClass:objectClass];
        if (completed != nil)
        {
            completed(result);
        }
    });
}

+ (void)allObjectsForClass:(Class)objectClass withFilter:(NSString*)filter completed:(K9CompleteWithArrayBlock)completed // filter can be nil
{
    dispatch_async([K9ServerCache shareInstance].m_databaseQueue, ^{
        id result = [K9ServerCache allObjectsForClass:objectClass withFilter:filter];
        if (completed != nil)
        {
            completed(result);
        }
    });
}

+ (void)allObjectsForClass:(Class)objectClass sortForField:(NSString*)fieldName ascending:(BOOL)ascending completed:(K9CompleteWithArrayBlock)completed
{
    dispatch_async([K9ServerCache shareInstance].m_databaseQueue, ^{
        id result = [K9ServerCache allObjectsForClass:objectClass sortForField:fieldName ascending:ascending];
        if (completed != nil)
        {
            completed(result);
        }
    });
}

+ (void)allObjectsForClass:(Class)objectClass sortForField:(NSString*)fieldName ascending:(BOOL)ascending comparator:(NSComparator)comparator completed:(K9CompleteWithArrayBlock)completed
{
    dispatch_async([K9ServerCache shareInstance].m_databaseQueue, ^{
        id result = [K9ServerCache allObjectsForClass:objectClass sortForField:fieldName ascending:ascending comparator:comparator];
        if (completed != nil)
        {
            completed(result);
        }
    });
}

+ (void)allObjectsForClass:(Class)objectClass withFilter:(NSString*)filter sortForField:(NSString*)fieldName ascending:(BOOL)ascending completed:(K9CompleteWithArrayBlock)completed
{
    dispatch_async([K9ServerCache shareInstance].m_databaseQueue, ^{
        id result = [K9ServerCache allObjectsForClass:objectClass withFilter:filter sortForField:fieldName ascending:ascending];
        if (completed != nil)
        {
            completed(result);
        }
    });
}

+ (void)allObjectsForClass:(Class)objectClass withFilter:(NSString*)filter sortForField:(NSString*)fieldName ascending:(BOOL)ascending comparator:(NSComparator)comparator completed:(K9CompleteWithArrayBlock)completed
{
    dispatch_async([K9ServerCache shareInstance].m_databaseQueue, ^{
        id result = [K9ServerCache allObjectsForClass:objectClass withFilter:filter sortForField:fieldName ascending:ascending comparator:comparator];
        if (completed != nil)
        {
            completed(result);
        }
    });
}

+ (void)saveBaseWithCompleted:(K9CompleteWithObjectBlock)completed
{
    dispatch_async([K9ServerCache shareInstance].m_databaseQueue, ^{
        K9ServerCache* cache = [K9ServerCache shareInstance];
        NSError* error = nil;
        [cache.m_CDContext save:&error];
        if (error != nil)
        {
            LOG(@"Fail save DataBase: %@", error);
        }
        else
        {
            LOG(@"Database Saved!");
        }
        if (completed != nil)
        {
            completed(error);
        }
    });
}

+ (void)changeBase:(NSString*)baseName completed:(K9CompleteBlock)completed
{
    dispatch_async([K9ServerCache shareInstance].m_databaseQueue, ^{
        [K9ServerCache changeBase:baseName];
        if (completed != nil)
        {
            completed();
        }
    });
}

@end
