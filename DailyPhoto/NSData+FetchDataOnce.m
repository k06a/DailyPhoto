//
//  NSData+AsyncCacher.m
//  DailyPhoto
//
//  Created by Антон Буков on 02.12.13.
//  Copyright (c) 2013 Codeless Solution. All rights reserved.
//

#import "NSData+FetchDataOnce.h"

@implementation NSData (FetchDataOnce)

+ (void)fetchFromURL:(NSURL *)url toBlock:(void(^)(NSData * data, BOOL * retry))block
{
    [NSData fetchFromURL:url toBlock:block forced:NO];
}

+ (void)fetchFromURL:(NSURL *)url toBlock:(void(^)(NSData * data, BOOL * retry))block forced:(BOOL)forced
{
    static NSOperationQueue * mainQueue;
    static NSOperationQueue * parallelQueue;
    static NSMutableDictionary * blocksDict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mainQueue = [[NSOperationQueue alloc] init];
        mainQueue.maxConcurrentOperationCount = 1;
        parallelQueue = [[NSOperationQueue alloc] init];
        parallelQueue.maxConcurrentOperationCount = 64;
        blocksDict = [NSMutableDictionary dictionary];
    });
    
    if (url == nil)
        return;
    
    [mainQueue addOperationWithBlock:^{
        NSMutableDictionary *dict = blocksDict;
        NSMutableSet * blocks = blocksDict[url];
        if (blocks == nil)
        {
            blocks = [NSMutableSet set];
            blocksDict[url] = blocks;
        }
        
        if (!forced && [blocks member:block])
            return;
        [blocks addObject:(id)block ?: (id)[NSNull null]];
        if (!forced && blocks.count != 1)
            return;
        
        [parallelQueue addOperationWithBlock:^{
             NSError * error;
             NSURLResponse * response;
             NSData * data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url] returningResponse:&response error:&error];
             if (error)
                NSLog(@"Error loading url %@: %@", url, error);
            
             [mainQueue addOperationWithBlock:^{
                 NSMutableSet *blocksToDelete = [NSMutableSet set];
                 for (id a in blocks)
                 {
                     void(^aBlock)(NSData *,BOOL *) = a;
                     if ((id)aBlock == [NSNull null])
                         continue;
                     
                     dispatch_sync(dispatch_get_main_queue(), ^{
                         BOOL retry = NO;
                         aBlock(data, &retry);
                         if (retry)
                         {
                             double delayInSeconds = 3.0;
                             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                             dispatch_after(popTime, dispatch_get_main_queue(), ^{
                                 if (block == aBlock)
                                     [NSData fetchFromURL:url toBlock:aBlock forced:YES];
                             });
                         } else {
                             [blocksToDelete addObject:aBlock];
                         }
                     });
                 }
                 [blocks minusSet:blocksToDelete];
             }];
         }];
    }];
}

@end