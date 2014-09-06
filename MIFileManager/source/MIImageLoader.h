//
//  ImageLoader.h
//  MIFileManager
//
//  Created by morph85 on 11/30/12.
//
//

#import <Foundation/Foundation.h>
#import "MITaskOperations.h"
#import "MIContainer.h"
#import "../util/ImageHelper.h"

@protocol ImageLoaderDelegate;

@interface MIImageLoader : NSOperation
@property (nonatomic, assign) id <ImageLoaderDelegate> delegate;
@property (nonatomic, assign) id <MITaskOperationDelegate> taskDelegate;
@property (atomic, assign) BOOL isForceCancel;

@property (nonatomic, readonly, strong) NSIndexPath *indexPath;
@property (nonatomic, readonly, strong) MIContainer *container;
- (id)initWithContainer:(MIContainer *)container atIndexPath:(NSIndexPath *)anIndexPath delegate:(id<ImageLoaderDelegate>)aDelegate;
@end

@protocol ImageLoaderDelegate <NSObject>
- (void)ImageLoaderDidFinish:(MIImageLoader *)loader;
@end