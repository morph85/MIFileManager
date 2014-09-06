//
//  MIImageLoader.m
//  MIFileManager
//
//  Created by morph85 on 11/30/12.
//
//

#import "MIImageLoader.h"

@interface MIImageLoader ()
@property (nonatomic, readwrite, strong) NSIndexPath *indexPath;
@property (nonatomic, readwrite, strong) MIContainer *container;
@end

@implementation MIImageLoader
@synthesize delegate;
@synthesize taskDelegate;
@synthesize isForceCancel;
@synthesize indexPath;
@synthesize container;

#pragma mark -
#pragma mark - Life Cycle

- (id)initWithContainer:(MIContainer *)aContainer atIndexPath:(NSIndexPath *)anIndexPath delegate:(id<ImageLoaderDelegate>)aDelegate
{
    if (self = [super init])
    {
        self.delegate = aDelegate;
        self.isForceCancel = NO;
        
        self.indexPath = anIndexPath;
        self.container = aContainer;
    }
    return self;
}

#pragma mark -
#pragma mark - Downloading image

- (void)main {
    @autoreleasepool {
        if (self.isCancelled || self.isForceCancel)
        {
            NSLog(@"Image load cancelled 0");
            return;
        }
        
        NSURL *url = self.container.url;
        __block UIImage *downloadedImage;
        
        NSLog(@"Loading url:%@", [url absoluteString]);
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (data != nil)
        {
            //NSLog(@"Image loaded");
            downloadedImage = [UIImage imageWithData:data];
        }
        else
        {
            NSLog(@"Image not loaded");
            return;
        }
        
        if (self.isCancelled || self.isForceCancel)
        {
            NSLog(@"Image load cancelled 1");
            return;
        }
        
        downloadedImage =  [ImageHelper image:downloadedImage fitInSize:CGSizeMake(60.0f, 60.0f)];
        if (downloadedImage)
        {
            //NSLog(@"setting image");
            [self.container setThumbnail:downloadedImage];
        }
        
        if (self.isCancelled || self.isForceCancel)
        {
            NSLog(@"Image load cancelled 2");
            return;
        }
        
        if (self.delegate != nil)
        {
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(ImageLoaderDidFinish:) withObject:self waitUntilDone:NO];
        }
        //});
    }
}

@end
