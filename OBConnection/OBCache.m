//
//  OBCache.m
//  OBConnection
//
//  Created by Oriol Blanc on 02/12/11.
//  Copyright (c) 2012 Oriol Blanc. All rights reserved.
//

#import "OBCache.h"

#import "EGOCache.h"

#define kImageCacheDurationInSeconds 1296000 // 15 days
#define kDataCacheDurationInSeconds 604800 // 7 days

@interface OBCache ()
    @property (nonatomic, assign) dispatch_queue_t cacheQueue;

    + (void)debugLog:(NSString *)debug, ... NS_REQUIRES_NIL_TERMINATION;
@end

@implementation OBCache
@synthesize cacheQueue = _cacheQueue;
@synthesize debug = _debug;

#pragma mark - Singleton

+ (OBCache *)instance
{
    static dispatch_once_t dispatchOncePredicate;
    static OBCache *myInstance = nil;
    
    dispatch_once(&dispatchOncePredicate, ^{
        myInstance = [[self alloc] init];
        myInstance.debug = NO;
        myInstance.cacheQueue = dispatch_queue_create("OBCacheQueue", DISPATCH_QUEUE_CONCURRENT);
        
        [self invalidateAllCachedObjects];
    });
    
    return myInstance;
}

#pragma mark -

+ (void)cacheObject:(id<NSObject, NSCopying, NSCoding>)object forKey:(NSString *)key
{
    id objectToArchive = object;
    
    if ([objectToArchive isKindOfClass:[NSMutableArray class]] || [objectToArchive isKindOfClass:[NSMutableDictionary class]] || [objectToArchive isKindOfClass:[NSMutableSet class]]) // If its'a mutable collection, make a copy to avoid it being mutated while archiving
    {
        objectToArchive = [[(NSObject *)object copy] autorelease];
    }
    
    dispatch_async([self instance].cacheQueue, ^{
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:objectToArchive];
        [self debugLog:@"Caching object %@ for key %@", object, key, nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[EGOCache currentCache] setData:data forKey:key withTimeoutInterval:kDataCacheDurationInSeconds];
        });
        
    });
}

+ (id)cachedObjectForKey:(NSString *)key
{
    id cachedObject = [[EGOCache currentCache] dataForKey:key];
    
    if (cachedObject)
    {
        [self debugLog:@"Returning cached object for key", key, nil];
        id object = [NSKeyedUnarchiver unarchiveObjectWithData:cachedObject];
        return object;
    }
    else
    {
        [self debugLog:@"Cache miss for key ", key, nil];
        return nil;
    }
}

+ (void)invalidateCachedObjectForKey:(NSString *)key
{
    [self debugLog:@"Invalidating cached object for key ", key, nil];
    [[EGOCache currentCache] removeCacheForKey:key];
}

+ (void)invalidateAllCachedObjects
{
    [self debugLog:@"Invalidating all cached objects", nil];
    [[EGOCache currentCache] clearCache];
}

#pragma mark - Debug

+ (void)debugLog:(NSString *)debug, ...
{
    if ([self instance].debug == YES)
    {
        va_list vl;
        va_start(vl, debug);
        NSString* formattedDebug = [[[NSString alloc] initWithFormat:debug arguments:vl] autorelease];
        va_end(vl);
        NSLog(@"[%@] %@", NSStringFromClass([self class]), formattedDebug);
    }
}

#pragma mark - Memory Management

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    dispatch_release(_cacheQueue);
    
    [super dealloc];
}

@end
