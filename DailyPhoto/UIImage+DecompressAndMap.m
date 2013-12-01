//
//  UIImage+ImageWithDataNoCopy.m
//  DailyPhoto
//
//  Created by Антон Буков on 30.11.13.
//  Copyright (c) 2013 Codeless Solution. All rights reserved.
//

#import <sys/mman.h>
#import "UIImage+DecompressAndMap.h"

@implementation UIImage (DecompressAndMap)

- (UIImage *)decompressAndMap
{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *filename = [@([self hash]) description];
    return [self decompressAndMapToPath:[path stringByAppendingPathComponent:filename]];
}

// conform to CGDataProviderReleaseDataCallback
void munmap_wrapper(void *p, const void *cp, size_t l) { munmap(p,l); }

- (UIImage *)decompressAndMapToPath:(NSString *)path
{
    CGImageRef sourceImage = self.CGImage;
    
    //Parameters needed to create the bitmap context
    size_t width = CGImageGetWidth(sourceImage);
    size_t height = CGImageGetHeight(sourceImage);
    size_t bitsPerComponent = 8;    //Each component is 1 byte, so 8 bits
    size_t bytesPerRow = 4 * width; //Uncompressed RGBA is 4 bytes per pixel
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    FILE *file = fopen([path UTF8String], "w+");
    int filed = fileno(file);
    size_t size = height*bytesPerRow;//+4+4;
    ftruncate(filed, size);
    char *data = mmap(NULL, size, PROT_READ|PROT_WRITE, MAP_SHARED, filed, 0);
    //*(int *)(data+size-8) = (int)width;
    //*(int *)(data+size-4) = (int)height;
    fclose(file);
    
    //Create uncompressed context, draw the compressed source image into it
    //and save the resulting image.
    CGContextRef context = CGBitmapContextCreate(data, width, height, bitsPerComponent, bytesPerRow, colorSpace, (uint32_t)kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), sourceImage);
    //CGImageRef inflatedImage = CGBitmapContextCreateImage(context);
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(data, data, size, munmap_wrapper);
    CGImageRef inflatedImage = CGImageCreate(width, height, bitsPerComponent, 4*8, bytesPerRow, colorSpace, (uint32_t)kCGImageAlphaPremultipliedLast, provider, NULL, NO, kCGRenderingIntentDefault);
    
    //Tidy up
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CGDataProviderRelease(provider);
    
    return [UIImage imageWithCGImage:inflatedImage];
}

@end
