//
//  UIImage+ImageWithDataNoCopy.h
//  DailyPhoto
//
//  Created by Антон Буков on 30.11.13.
//  Copyright (c) 2013 Codeless Solution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (DecompressAndMap)

- (UIImage *)decompressAndMapUsingKey:(NSString *)key;
- (UIImage *)decompressAndMapToPath:(NSString *)path usingKey:(NSString *)key;

+ (UIImage *)imageMapUsingKey:(NSString *)key;
+ (UIImage *)imageMapFromPath:(NSString *)path usingKey:(NSString *)key;

@end
