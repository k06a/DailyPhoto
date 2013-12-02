//
//  NSData+AsyncCacher.h
//  DailyPhoto
//
//  Created by Антон Буков on 02.12.13.
//  Copyright (c) 2013 Codeless Solution. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (FetchDataOnce)

+ (void)fetchFromURL:(NSURL *)url toBlock:(void(^)(NSData * data, BOOL * retry))block;

@end