//
//  MITaskOperations.m
//  MIFileManager
//
//  Created by morph85 on 11/30/12.
//
//

#import "MITaskOperations.h"
#import "MIImageLoader.h"

@implementation MITaskOperations
@synthesize imageLoadInProgress = _imageLoadInProgress;
@synthesize imageLoadQueue = _imageLoadQueue;
//@synthesize otherTaskInProgress;
//@synthesize otherTaskQueue;

#pragma mark -
#pragma mark Task Operations

- (NSMutableDictionary *)imageLoadInProgress
{
    if (!_imageLoadInProgress)
    {
        _imageLoadInProgress = [[NSMutableDictionary alloc] init];
    }
    return _imageLoadInProgress;
}

- (void)setImageLoadInProgress:(NSMutableDictionary *)anImageLoadInProgress
{
    if (_imageLoadInProgress != anImageLoadInProgress)
    {
        _imageLoadInProgress = anImageLoadInProgress;
    }
}

- (NSOperationQueue *)imageLoadQueue
{
    if (!_imageLoadQueue)
    {
        _imageLoadQueue = [[NSOperationQueue alloc] init];
        _imageLoadQueue.name = @"Image Load Queue";
        _imageLoadQueue.maxConcurrentOperationCount = 3;
    }
    return _imageLoadQueue;
}

- (void)setImageLoadQueue:(NSOperationQueue *)anImageLoadQueue
{
    if (_imageLoadQueue != anImageLoadQueue)
    {
        _imageLoadQueue = anImageLoadQueue;
    }
}

//- (NSMutableDictionary *)otherTaskInProgress {
//    if (!otherTaskInProgress)
//    {
//        otherTaskInProgress = [[NSMutableDictionary alloc] init];
//    }
//    return otherTaskInProgress;
//}
//
//- (NSOperationQueue *)otherTaskQueue {
//    if (!otherTaskQueue)
//    {
//        otherTaskQueue = [[NSOperationQueue alloc] init];
//        otherTaskQueue.name = @"Other Task Queue";
//        otherTaskQueue.maxConcurrentOperationCount = 1;
//    }
//    return otherTaskQueue;
//}

#pragma mark -
#pragma mark Task Operation Delegate

- (void)cancelAllOperations:(TaskOperationType)taskOperationType
{
    switch (taskOperationType)
    {
        case TASK_IMAGE_LOAD:
            @synchronized (self)
            {
                [_imageLoadQueue cancelAllOperations];
                for (MIImageLoader *operation in _imageLoadQueue.operations)
                {
                    [operation setIsForceCancel:YES];
                }
            }
            break;
        default:
            break;
    }
}

@end
