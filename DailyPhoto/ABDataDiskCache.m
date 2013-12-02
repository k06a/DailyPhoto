//
//  ABImageMapCache.m
//  DailyPhoto
//
//  Created by Антон Буков on 30.11.13.
//  Copyright (c) 2013 Codeless Solution. All rights reserved.
//

#import "ABDataDiskCache.h"

@interface ABDataDiskCache ()
@property (strong, nonatomic) NSString *path;
@end

@implementation ABDataDiskCache

- (NSString *)pathForKey:(NSString *)key
{
    NSString *path = self.path ?: NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *filename = [NSString stringWithFormat:@"%lu-%d",(unsigned long)[key hash], (int)[key length]];
    return [path stringByAppendingPathComponent:filename];
}

- (id)initWithPath:(NSString *)path
{
    if (self = [super init]) {
        self.path = path;
    }
    return self;
}

- (NSData *)objectForKey:(NSString *)key
{
    id obj = [super objectForKey:key];
    if (obj == nil) {
        obj = [NSData dataWithContentsOfFile:[self pathForKey:key] options:(NSDataReadingMappedAlways) error:nil];
        if (obj)
            [super setObject:obj forKey:key];
    }
    return obj;
}

- (void)setObject:(NSData *)obj forKey:(NSString *)key
{
    [super setObject:obj forKey:key];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [obj writeToFile:[self pathForKey:key] atomically:YES];
    });
}

@end
