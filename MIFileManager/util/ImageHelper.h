/*
 * The MIT License
 *
 * Copyright (c) 2011 Paul Solt, PaulSolt@gmail.com
 *
 * https://github.com/PaulSolt/UIImage-Conversion/blob/master/MITLicense.txt
 *
 */

#import <Foundation/Foundation.h>

#define CGAutorelease(x) (__typeof(x))[NSMakeCollectable(x) autorelease]

// ARGB Offset Helpers
NSUInteger alphaOffset(NSUInteger x, NSUInteger y, NSUInteger w);
NSUInteger redOffset(NSUInteger x, NSUInteger y, NSUInteger w);
NSUInteger greenOffset(NSUInteger x, NSUInteger y, NSUInteger w);
NSUInteger blueOffset(NSUInteger x, NSUInteger y, NSUInteger w);

// This version mallocs an actual bitmap, so make sure you understand the memory issues:
// Use free(CGBitmapContextGetData(context)); and CGContextRelease(context);
CGContextRef CreateARGBBitmapContext(CGSize size);


@interface ImageHelper : NSObject {
	
}

/** Converts a UIImage to RGBA8 bitmap.
 @param image - a UIImage to be converted
 @return a RGBA8 bitmap, or NULL if any memory allocation issues. Cleanup memory with free() when done.
 */
+ (unsigned char *)convertUIImageToBitmapRGBA8:(UIImage *)image;

/** A helper routine used to convert a RGBA8 to UIImage
 @return a new context that is owned by the caller
 */
+ (CGContextRef)newBitmapRGBA8ContextFromImage:(CGImageRef)image;


/** Converts a RGBA8 bitmap to a UIImage. 
 @param buffer - the RGBA8 unsigned char * bitmap
 @param width - the number of pixels wide
 @param height - the number of pixels tall
 @return a UIImage that is autoreleased or nil if memory allocation issues
 */
+ (UIImage *)convertBitmapRGBA8ToUIImage:(unsigned char *)buffer
	withWidth:(int)width
	withHeight:(int)height;

// create image
+ (UIImage *)imageFromView: (UIView *)theView;
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;

// bits
+ (UIImage *)imageWithBits:(unsigned char *)bits withSize:(CGSize)size;
+ (unsigned char *)bitmapFromImage:(UIImage *)image;

// base image fitting
+ (CGSize)fitSize:(CGSize)thisSize inSize:(CGSize)aSize;
+ (CGRect)frameSize:(CGSize)thisSize inSize:(CGSize)aSize;

+ (UIImage *)unrotateImage:(UIImage *)image;

+ (UIImage *)image:(UIImage *)image fitInSize:(CGSize)size; // retain proportions, fit in size
+ (UIImage *)image:(UIImage *)image fitInView:(UIView *)view;

+ (UIImage *)image:(UIImage *)image centerInSize:(CGSize)size; // center, no resize
+ (UIImage *)image:(UIImage *)image centerInView:(UIView *)view;

+ (UIImage *)image:(UIImage *)image fillSize:(CGSize)size; // fill all pixels with resize
+ (UIImage *)image:(UIImage *)image fillView:(UIView *)view;

// paths
+ (void)addRoundedRect:(CGRect)rect toContext:(CGContextRef)context withOvalSize:(CGSize)ovalSize;
+ (UIImage *)roundedImage:(UIImage *)image withOvalSize: (CGSize) ovalSize withInset:(CGFloat)inset;
+ (UIImage *)roundedImage:(UIImage *)img withOvalSize: (CGSize) ovalSize;
+ (UIImage *)roundedBacksplashOfSize:(CGSize)size andColor:(UIColor *)color withRounding:(CGFloat)rounding andInset:(CGFloat)inset;
+ (UIImage *)ellipseImage:(UIImage *)image withInset:(CGFloat)inset;

// masking
+ (UIImage *)frameImage:(UIImage *)image withMask:(UIImage *)mask;
+ (UIImage *)grayscaleImage:(UIImage *)image;


@end
