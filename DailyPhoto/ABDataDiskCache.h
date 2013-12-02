//
//  ABImageMapCache.h
//  DailyPhoto
//
//  Created by Антон Буков on 30.11.13.
//  Copyright (c) 2013 Codeless Solution. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABDataDiskCache : NSCache

- (id)init  __attribute__ ((unavailable));
- (id)initWithPath:(NSString *)path;

- (NSData *)objectForKey:(NSString *)key;
- (void)setObject:(NSData *)obj forKey:(NSString *)key;

@end
