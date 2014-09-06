/*
 * The MIT License
 *
 * Copyright (c) 2011 Paul Solt, PaulSolt@gmail.com
 *
 * https://github.com/PaulSolt/UIImage-Conversion/blob/master/MITLicense.txt
 *
 */

#import <QuartzCore/QuartzCore.h>

#import "ImageHelper.h"

@implementation ImageHelper

+ (unsigned char *)convertUIImageToBitmapRGBA8:(UIImage *)image
{
	CGImageRef imageRef = image.CGImage;
	
	// Create a bitmap context to draw the uiimage into
	CGContextRef context = [self newBitmapRGBA8ContextFromImage:imageRef];
	
	if(!context) {
		return NULL;
	}
	
	size_t width = CGImageGetWidth(imageRef);
	size_t height = CGImageGetHeight(imageRef);
	
	CGRect rect = CGRectMake(0, 0, width, height);
	
	// Draw image into the context to get the raw image data
	CGContextDrawImage(context, rect, imageRef);
	
	// Get a pointer to the data	
	unsigned char *bitmapData = (unsigned char *)CGBitmapContextGetData(context);
	
	// Copy the data and release the memory (return memory allocated with new)
	size_t bytesPerRow = CGBitmapContextGetBytesPerRow(context);
	size_t bufferLength = bytesPerRow * height;
	
	unsigned char *newBitmap = NULL;
	
	if(bitmapData) {
		newBitmap = (unsigned char *)malloc(sizeof(unsigned char) * bytesPerRow * height);
		
		if(newBitmap) {	// Copy the data
			for(int i = 0; i < bufferLength; ++i) {
				newBitmap[i] = bitmapData[i];
			}
		}
		
		free(bitmapData);
		
	} else {
		NSLog(@"Error getting bitmap pixel data\n");
	}
	
	CGContextRelease(context);
	
	return newBitmap;	
}

+ (CGContextRef)newBitmapRGBA8ContextFromImage:(CGImageRef)image
{
	CGContextRef context = NULL;
	CGColorSpaceRef colorSpace;
	uint32_t *bitmapData;
	
	size_t bitsPerPixel = 32;
	size_t bitsPerComponent = 8;
	size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;
	
	size_t width = CGImageGetWidth(image);
	size_t height = CGImageGetHeight(image);
	
	size_t bytesPerRow = width * bytesPerPixel;
	size_t bufferLength = bytesPerRow * height;
	
	colorSpace = CGColorSpaceCreateDeviceRGB();
	
	if(!colorSpace) {
		NSLog(@"Error allocating color space RGB\n");
		return NULL;
	}
	
	// Allocate memory for image data
	bitmapData = (uint32_t *)malloc(bufferLength);
	
	if(!bitmapData) {
		NSLog(@"Error allocating memory for bitmap\n");
		CGColorSpaceRelease(colorSpace);
		return NULL;
	}
	
	//Create bitmap context
	
	context = CGBitmapContextCreate(bitmapData, 
			width, 
			height, 
			bitsPerComponent, 
			bytesPerRow, 
			colorSpace, 
			kCGImageAlphaPremultipliedLast);	// RGBA
	if(!context) {
		free(bitmapData);
		NSLog(@"Bitmap context not created");
	}
	
	CGColorSpaceRelease(colorSpace);
	
	return context;	
}

+ (UIImage *)convertBitmapRGBA8ToUIImage:(unsigned char *)buffer
		withWidth:(int) width
	   withHeight:(int) height
{
	size_t bufferLength = width * height * 4;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, bufferLength, NULL);
	size_t bitsPerComponent = 8;
	size_t bitsPerPixel = 32;
	size_t bytesPerRow = 4 * width;
	
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	if(colorSpaceRef == NULL) {
		NSLog(@"Error allocating color space");
		CGDataProviderRelease(provider);
		return nil;
	}
	
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault; 
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	CGImageRef iref = CGImageCreate(width, 
				height, 
				bitsPerComponent, 
				bitsPerPixel, 
				bytesPerRow, 
				colorSpaceRef, 
				bitmapInfo, 
				provider,	// data provider
				NULL,		// decode
				YES,			// should interpolate
				renderingIntent);
		
	uint32_t* pixels = (uint32_t*)malloc(bufferLength);
	
	if(pixels == NULL) {
		NSLog(@"Error: Memory not allocated for bitmap");
		CGDataProviderRelease(provider);
		CGColorSpaceRelease(colorSpaceRef);
		CGImageRelease(iref);		
		return nil;
	}
	
	CGContextRef context = CGBitmapContextCreate(pixels, 
				 width, 
				 height, 
				 bitsPerComponent, 
				 bytesPerRow, 
				 colorSpaceRef, 
				 kCGImageAlphaPremultipliedLast); 
	
	if(context == NULL) {
		NSLog(@"Error context not created");
		free(pixels);
	}
	
	UIImage *image = nil;
	if(context) {
		
		CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), iref);
		
		CGImageRef imageRef = CGBitmapContextCreateImage(context);
		
		// Support both iPad 3.2 and iPhone 4 Retina displays with the correct scale
		if([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
			float scale = [[UIScreen mainScreen] scale];
			image = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
		} else {
			image = [UIImage imageWithCGImage:imageRef];
		}
		
		CGImageRelease(imageRef);	
		CGContextRelease(context);	
	}
	
	CGColorSpaceRelease(colorSpaceRef);
	CGImageRelease(iref);
	CGDataProviderRelease(provider);
	
	if(pixels) {
		free(pixels);
	}	
	return image;
}


#pragma mark Functions that build contexts

// The data must be freed from this and the bitmap released
// Use free(CGBitmapContextGetData(context)); and CGContextRelease(context);
CGContextRef CreateARGBBitmapContext(CGSize size)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
	
    void *bitmapData = malloc(size.width * size.height * 4);
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Error: Memory not allocated!");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
	
    CGContextRef context = CGBitmapContextCreate (bitmapData, size.width, size.height, 8, size.width * 4, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace );
    if (context == NULL)
    {
        fprintf (stderr, "Error: Context not created!");
        free (bitmapData);
		return NULL;
    }
	
    return context;
}

#pragma mark Context Utilities

// Fix the context when using image contexts because there are times you must live in quartzland
void FlipContextVertically1(CGContextRef context, CGSize size)
{
	CGAffineTransform transform = CGAffineTransformIdentity;
	transform = CGAffineTransformScale(transform, 1.0f, -1.0f);
	transform = CGAffineTransformTranslate(transform, 0.0f, -size.height);
	CGContextConcatCTM(context, transform);
}

// Add rounded rectangle to context
void addRoundedRectToContext(CGContextRef context, CGRect rect, CGSize ovalSize)
{
	if (ovalSize.width == 0.0f || ovalSize.height == 0.0f) 
	{
		CGContextSaveGState(context);
		CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
		CGContextAddRect(context, rect);
		CGContextClosePath(context);
		CGContextRestoreGState(context);
		return;
	}
	
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
	CGContextScaleCTM(context, ovalSize.width, ovalSize.height);
	float fw = CGRectGetWidth(rect) / ovalSize.width;
	float fh = CGRectGetHeight(rect) / ovalSize.height;
	
	CGContextMoveToPoint(context, fw, fh/2); 
	CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
	CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
	CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); 
	CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
	
	CGContextClosePath(context);
	CGContextRestoreGState(context);
}

#pragma mark Create Image

// screen shot the view
+ (UIImage *)imageFromView:(UIView *)theView
{
	UIGraphicsBeginImageContext(theView.frame.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	[theView.layer renderInContext:context];
	UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return theImage;
}

// create image with color and size
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.height, size.width);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

// fill image with bits
+ (UIImage *)imageWithBits:(unsigned char *)bits withSize:(CGSize)size
{
	// Create a color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
		free(bits);
        return nil;
    }
	
    CGContextRef context = CGBitmapContextCreate (bits, size.width, size.height, 8, size.width * 4, colorSpace, kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        fprintf (stderr, "Error: Context not created!");
        free (bits);
		CGColorSpaceRelease(colorSpace );
		return nil;
    }
	
    CGColorSpaceRelease(colorSpace );
	CGImageRef ref = CGBitmapContextCreateImage(context);
	free(CGBitmapContextGetData(context));
	CGContextRelease(context);
	
	UIImage *img = [UIImage imageWithCGImage:ref];
	CFRelease(ref);
	return img;
}

#pragma mark Contexts and Bitmaps
+ (unsigned char *)bitmapFromImage:(UIImage *)image
{
	CGContextRef context = CreateARGBBitmapContext(image.size);
    if (context == NULL) return NULL;
	
    CGRect rect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
    CGContextDrawImage(context, rect, image.CGImage);
	unsigned char *data = CGBitmapContextGetData (context);
	CGContextRelease(context);
	return data;
}

#pragma mark Base Image Utility

+ (CGSize)fitSize:(CGSize)thisSize inSize:(CGSize)aSize
{
	CGFloat scale;
	CGSize newsize = thisSize;
	
	if (newsize.height && (newsize.height > aSize.height))
	{
		scale = aSize.height / newsize.height;
		newsize.width *= scale;
		newsize.height *= scale;
	}
	
	if (newsize.width && (newsize.width >= aSize.width))
	{
		scale = aSize.width / newsize.width;
		newsize.width *= scale;
		newsize.height *= scale;
	}
	
	return newsize;
}

// centers the fit size in the frame
+ (CGRect)frameSize:(CGSize)thisSize inSize:(CGSize)aSize
{
	CGSize size = [self fitSize:thisSize inSize: aSize];
	float dWidth = aSize.width - size.width;
	float dHeight = aSize.height - size.height;
	
	return CGRectMake(dWidth / 2.0f, dHeight / 2.0f, size.width, size.height);
}

+ (CGRect)fillSize:(CGSize)thisSize inSize:(CGSize)aSize
{
	CGFloat scalex = aSize.width / thisSize.width;
	CGFloat scaley = aSize.height / thisSize.height; 
	CGFloat scale = MAX(scalex, scaley);	
	
	CGFloat width = thisSize.width * scale;
	CGFloat height = thisSize.height * scale;
	
	float dwidth = ((aSize.width - width) / 2.0f);
	float dheight = ((aSize.height - height) / 2.0f);
	
	CGRect rect = CGRectMake(dwidth, dheight, thisSize.width * scale, thisSize.height * scale);
	return rect;
}

#define MIRRORED ((image.imageOrientation == UIImageOrientationUpMirrored) || (image.imageOrientation == UIImageOrientationLeftMirrored) || (image.imageOrientation == UIImageOrientationRightMirrored) || (image.imageOrientation == UIImageOrientationDownMirrored))	
#define ROTATED90	((image.imageOrientation == UIImageOrientationLeft) || (image.imageOrientation == UIImageOrientationLeftMirrored) || (image.imageOrientation == UIImageOrientationRight) || (image.imageOrientation == UIImageOrientationRightMirrored))

+ (UIImage *)doUnrotateImage:(UIImage *)image
{
	CGSize size = image.size;
	if (ROTATED90) size = CGSizeMake(image.size.height, image.size.width);
	
	UIGraphicsBeginImageContext(size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGAffineTransform transform = CGAffineTransformIdentity;
	
	// Rotate as needed
	switch(image.imageOrientation)
	{  
        case UIImageOrientationLeft:
		case UIImageOrientationRightMirrored:
			transform = CGAffineTransformRotate(transform, M_PI / 2.0f);
			transform = CGAffineTransformTranslate(transform, 0.0f, -size.width);
			size = CGSizeMake(size.height, size.width);
			CGContextConcatCTM(context, transform);
            break;
        case UIImageOrientationRight: 
		case UIImageOrientationLeftMirrored:
			transform = CGAffineTransformRotate(transform, -M_PI / 2.0f);
			transform = CGAffineTransformTranslate(transform, -size.height, 0.0f);
			size = CGSizeMake(size.height, size.width);
			CGContextConcatCTM(context, transform);
            break;
		case UIImageOrientationDown:
		case UIImageOrientationDownMirrored:
			transform = CGAffineTransformRotate(transform, M_PI);
			transform = CGAffineTransformTranslate(transform, -size.width, -size.height);
			CGContextConcatCTM(context, transform);
			break;
        default:  
			break;
    }
	
	
	if (MIRRORED)
	{
		// de-mirror
		transform = CGAffineTransformMakeTranslation(size.width, 0.0f);
		transform = CGAffineTransformScale(transform, -1.0f, 1.0f);
		CGContextConcatCTM(context, transform);
	}
	
	// Draw the image into the transformed context and return the image
	[image drawAtPoint:CGPointMake(0.0f, 0.0f)];
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();  
    return newimg;  
}	

+ (UIImage *)unrotateImage:(UIImage *)image
{
	if (image.imageOrientation == UIImageOrientationUp) return image;
	return [ImageHelper doUnrotateImage:image];
}

// proportionately resize, completely fit in view, no cropping
+ (UIImage *)image:(UIImage *)image fitInSize:(CGSize)viewsize
{
	UIGraphicsBeginImageContext(viewsize);
	[image drawInRect:[ImageHelper frameSize:image.size inSize:viewsize]];
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();  
    return newimg;  
}

+ (UIImage *)image:(UIImage *)image fitInView:(UIView *)view
{
	return [self image:image fitInSize:view.frame.size];
}

// no resize, may crop
+ (UIImage *)image:(UIImage *)image centerInSize:(CGSize)viewsize
{
	CGSize size = image.size;
	
	UIGraphicsBeginImageContext(viewsize);
	float dwidth = (viewsize.width - size.width) / 2.0f;
	float dheight = (viewsize.height - size.height) / 2.0f;
	
	CGRect rect = CGRectMake(dwidth, dheight, size.width, size.height);
	[image drawInRect:rect];
	
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();  
	
    return newimg;  
}

+ (UIImage *)image:(UIImage *)image centerInView:(UIView *)view
{
	return [self image:image centerInSize:view.frame.size];
}

// fill every view pixel with no black borders, resize and crop if needed
+ (UIImage *)image:(UIImage *)image fillSize:(CGSize)viewsize

{
	CGSize size = image.size;
	CGFloat scalex = viewsize.width / size.width;
	CGFloat scaley = viewsize.height / size.height; 
	CGFloat scale = MAX(scalex, scaley);	
	
	UIGraphicsBeginImageContext(viewsize);
	
	CGFloat width = size.width * scale;
	CGFloat height = size.height * scale;
	
	float dwidth = ((viewsize.width - width) / 2.0f);
	float dheight = ((viewsize.height - height) / 2.0f);
	
	CGRect rect = CGRectMake(dwidth, dheight, size.width * scale, size.height * scale);
	[image drawInRect:rect];
	
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();  
	
    return newimg;  
}

+ (UIImage *)image:(UIImage *)image fillView:(UIView *)view
{
	return [self image:image fillSize:view.frame.size];
}

#pragma mark Paths

// Convenience function for rounded rect corners that hides built-in function
+ (void)addRoundedRect:(CGRect)rect toContext:(CGContextRef)context withOvalSize:(CGSize)ovalSize
{
	addRoundedRectToContext(context, rect, ovalSize);
}

+ (UIImage *)roundedImage:(UIImage *)image withOvalSize:(CGSize)ovalSize withInset:(CGFloat)inset
{
	UIGraphicsBeginImageContext(image.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect rect = CGRectMake(inset, inset, image.size.width - inset * 2.0f, image.size.height - inset * 2.0f);
	addRoundedRectToContext(context, rect, ovalSize);
	CGContextClip(context);
	
	[image drawInRect:rect];
	
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();  
    return newimg;  
}

+ (UIImage *)roundedImage:(UIImage *)image withOvalSize:(CGSize)ovalSize
{
	return [ImageHelper roundedImage:image withOvalSize:ovalSize withInset: 0.0f];
}

+ (UIImage *)roundedBacksplashOfSize:(CGSize)size andColor:(UIColor *)color withRounding:(CGFloat)rounding andInset:(CGFloat)inset
{
	
	UIGraphicsBeginImageContext(size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect rect = CGRectMake(inset, inset, size.width - 2.0f * inset, size.height - 2.0f * inset);
	addRoundedRectToContext(context, rect, CGSizeMake(rounding, rounding));
	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillPath(context);
    if (!CGContextIsPathEmpty(context))
    {
        CGContextClip(context);
    }
	//CGContextClip(context);
	UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newimg;
}

+ (UIImage *)ellipseImage:(UIImage *)image withInset:(CGFloat)inset
{
	
	UIGraphicsBeginImageContext(image.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGRect rect = CGRectMake(inset, inset, image.size.width - inset * 2.0f, image.size.height - inset * 2.0f);
	CGContextAddEllipseInRect(context, rect);
	CGContextClip(context);
	
	[image drawInRect:rect];
	
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();  
    return newimg;  
}

+ (UIImage *)grayscaleImage:(UIImage *)image
{
	CGSize size = image.size;
	CGRect rect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	CGContextRef context = CGBitmapContextCreate(nil, size.width, size.height, 8, 0, colorSpace, kCGImageAlphaNone);
	CGColorSpaceRelease(colorSpace);
	
	CGContextDrawImage(context, rect, [image CGImage]);
	CGImageRef grayscale = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	
	UIImage *img = [UIImage imageWithCGImage:grayscale];
	CFRelease(grayscale);
	return img;
}

CGImageRef CreateMaskImage(UIImage *image)
{
	CGSize size = image.size;
	CGRect rect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	CGContextRef context = CGBitmapContextCreate(nil, size.width, size.height, 8, 0, colorSpace, kCGImageAlphaNone);
	FlipContextVertically1(context, size);
	CGColorSpaceRelease(colorSpace);
	
	CGContextDrawImage(context, rect, [image CGImage]);
	CGImageRef maskRef = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	
	return maskRef;
}

+ (UIImage*)frameImage:(UIImage *)image withMask:(UIImage *)mask
{
	UIGraphicsBeginImageContext(mask.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Create the mask and clip to it
	CGRect rect = CGRectMake(0.0f, 0.0f, mask.size.width, mask.size.height);
	CGImageRef maskref = CreateMaskImage(mask);
 	CGContextClipToMask(context, rect, maskref);
	CFRelease(maskref);
	
	// Draw the image
	[image drawInRect:[ImageHelper fillSize:image.size inSize:mask.size]];
	
	//CGRect rect1 = CGRectMake(0.0f, 0.0f, mask.size.width, mask.size.height);
	//[image drawInRect:rect1];
	
	// Return the new image
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
	
	/*NSString	*path = @"/a.jpg";
	 NSData *data = UIImageJPEGRepresentation(newimg, 0);
	 [data writeToFile:path atomically:YES];*/
    UIGraphicsEndImageContext();  
    return newimg;
}

// resize based on a square boundary of maxSize, get the scale
// force max size specifies when sourceSize (width & height) is less than maxSize, force resize it with scale
+ (float)getMaxScaleFromSize:(CGSize)sourceSize withMaxSize:(float)maxSize forceMaxSize:(BOOL)forceMaxSize
{
    if (sourceSize.width <= maxSize && sourceSize.height <= maxSize && !forceMaxSize)
    {
        return 1.0f;
    }
    else
    {
        float widthRatio = maxSize / (float)sourceSize.width;
        float heightRatio = maxSize / (float)sourceSize.height;
        
        // w > max && h < max
        // w:1000 x h:100, max:500
        // wR = 500 / 1000 = 0.5 (use lowest)
        // hR = 500 / 100 = 5.0
        // 1000x0.5 x 100x0.5 = 500 x 50
        
        // w < max && h > max
        // w:100 x h: 1000, max:500
        // wR = 500 / 100 = 5.0
        // hR = 500 / 1000 = 0.5 (use lowest)
        // 1000x0.5 x 100x0.5 = 500 x 50
        
        // w > max && h > max
        // w:1000 x h:2000, max:500
        // wR = 500 / 1000 = 0.5
        // hR = 500 / 2000 = 0.25 (use lowest)
        // 1000x0.25 x 2000x0.25 = 250 x 500
        
        // w < max && h < max && forceMaxSize
        // w:100 x h:10, max:500
        // wR = 500 / 100 = 5.0 (use lowest)
        // hR = 500 / 10 = 50.0
        // 100x5.0 x 10x5.0 = 500 x 50
        
        // use the lowest ratio
        return (widthRatio < heightRatio ? widthRatio : heightRatio);
    }
}

@end
