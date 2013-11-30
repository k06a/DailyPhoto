//
//  ABImageMapCache.m
//  DailyPhoto
//
//  Created by Антон Буков on 30.11.13.
//  Copyright (c) 2013 Codeless Solution. All rights reserved.
//

#import "ABDiskCache.h"

@interface ABDiskCache ()
@property (strong, nonatomic) NSMutableSet *addedToCache;
@end

@implementation ABDiskCache

- (NSMutableSet *)addedToCache
{
    if (_addedToCache == nil)
        _addedToCache = [NSMutableSet set];
    return _addedToCache;
}

+ (NSString *)pathForKey:(id<NSObject>)key
{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *filename = [NSString stringWithFormat:@"%lu",(unsigned long)[key hash]];
    return [path stringByAppendingPathComponent:filename];
}

- (id)objectForKey:(id<NSObject,NSCopying>)key
{
    id obj = [super objectForKey:key];
    if (obj == nil && [self.addedToCache member:key])
    {
        obj = [NSData dataWithContentsOfFile:[ABDiskCache pathForKey:key] options:(NSDataReadingMappedAlways) error:nil];
        if (obj)
            [super setObject:obj forKey:key];
        else
            [self.addedToCache removeObject:key];
    }
    return obj;
}

- (void)setObject:(NSData *)obj forKey:(id<NSObject,NSCopying>)key
{
    [super setObject:obj forKey:key];
    [self.addedToCache addObject:key];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [obj writeToFile:[ABDiskCache pathForKey:key] atomically:YES];
    });
}

@end
