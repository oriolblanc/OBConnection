//
//  OBCache.h
//  OBConnection
//
//  Created by Oriol Blanc on 02/12/11.
//  Copyright (c) 2012 Oriol Blanc. All rights reserved.
//

@interface OBCache : NSObject
@property (nonatomic) BOOL debug;

+ (OBCache *)instance;

+ (void)cacheObject:(id<NSObject, NSCopying, NSCoding>)object forKey:(NSString *)key;
+ (id)cachedObjectForKey:(NSString *)key;

+ (void)invalidateCachedObjectForKey:(NSString *)key;
+ (void)invalidateAllCachedObjects;

@end
