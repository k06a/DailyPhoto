//
//  UIImage+ImageWithDataNoCopy.m
//  DailyPhoto
//
//  Created by Антон Буков on 30.11.13.
//  Copyright (c) 2013 Codeless Solution. All rights reserved.
//

#import <ImageIO/ImageIO.h>
#import "UIImage+ImageWithDataNoCopy.h"

@implementation UIImage (ImageWithDataNoCopy)

- (UIImage *)decompressed
{
	UIGraphicsBeginImageContextWithOptions(self.size, YES, 0.0);
    [self drawAtPoint:CGPointZero blendMode:kCGBlendModeCopy alpha:1.0];
    UIImage *decompressed = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return decompressed;
}

/*
//iOS and Mac OS X compatible function to return a CGImageRef
//loaded from an image file.
CGImageRef CreateCGImageFromImageNamed(NSString *fileName)
{
    //Read in the image file using the appropriate iOS or Mac OS image class
#if (TARGET_OS_IPHONE)
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:fileName];
#else
    NSImage *imageFile = [[NSImage alloc] initWithContentsOfFile: fileName];
    NSBitmapImageRep *image = [[NSBitmapImageRep alloc] initWithData:[imageFile TIFFRepresentation]];
    [imageFile release];
#endif
    
    //Extract CG Image from image class
    CGImageRef cgImage = image.CGImage;
    
    //Ensure that the CG Image was loaded correctly
    if (!cgImage) {
        NSLog(@"%s Failed to load image %@", __PRETTY_FUNCTION__, fileName);
        return nil;
    }
    
    //We need to return a retained CG Image, but can discard the iOS/Mac OS image
    CGImageRetain(cgImage);
    return cgImage;
}

CGImageRef CreateInflatedCGImageFromImageNamed(NSString *fileName)
{
    CGImageRef sourceImage = CreateCGImageFromImageNamed(fileName);
    
    //Parameters needed to create the bitmap context
    size_t width = CGImageGetWidth(sourceImage);
    size_t height = CGImageGetHeight(sourceImage);
    size_t bitsPerComponent = 8;    //Each component is 1 byte, so 8 bits
    size_t bytesPerRow = 4 * width; //Uncompressed RGBA is 4 bytes per pixel
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    //Create uncompressed context, draw the compressed source image into it
    //and save the resulting image.
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), sourceImage);
    CGImageRef inflatedImage = CGBitmapContextCreateImage(context);
    
    //Tidy up
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CGImageRelease(sourceImage);
    
    return inflatedImage;
}
*/
+ (UIImage *)imageWithDataNoCopy:(NSData *)data
{
    CGImageSourceRef source = CGImageSourceCreateWithData(CFBridgingRetain(data), NULL);
    NSDictionary *dict = @{(id)kCGImageSourceShouldCache:@YES};
    CGImageRef cgImage = CGImageSourceCreateImageAtIndex(source, 0, (__bridge CFDictionaryRef)(dict));
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CFRelease(source);
    
    /*
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)(data));
    CGImageRef image = CGImageCreateWithPNGDataProvider(provider, NULL, false, kCGRenderingIntentDefault);
    UIImage *result = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    CGDataProviderRelease(provider);
    */
    return result;
}

@end
