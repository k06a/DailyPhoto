//
//  ABImageMapCache.h
//  DailyPhoto
//
//  Created by Антон Буков on 30.11.13.
//  Copyright (c) 2013 Codeless Solution. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABDiskCache : NSCache

- (id)objectForKey:(id<NSObject,NSCopying>)key;
- (void)setObject:(id)obj forKey:(id<NSObject,NSCopying>)key;

@end
