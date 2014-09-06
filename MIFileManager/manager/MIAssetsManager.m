//
//  MIAssetManager.m
//  MIFileManager
//
//  Created by morph85 on 9/10/12.
//  Singleton class from:
//    http://galloway.me.uk/tutorials/singleton-classes
//
//

#import "MIAssetsManager.h"
#import <ImageIO/ImageIO.h>
#import "ALAsset+Helper.h"
#import "MIContainerGroup.h"

@interface MIAssetsManager()
@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@end

@implementation MIAssetsManager
@synthesize assetsLibrary;

+ (id)getInstance
{
    static MIAssetsManager *instance = nil;
    
    // using GCD to make sure only dispatch once
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (id)init
{
    if (self = [super init])
    {
        // do nothing
        assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return self;
}

#pragma mark - ManagerProtocol

- (BOOL)isFileExists:(NSURL *)url
{
    __block BOOL isExist = NO;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void)
    {
        [[[MIAssetsManager getInstance] assetsLibrary] assetForURL:url resultBlock:^(ALAsset *asset)
        {
            if(asset != nil)
            {
                isExist = YES;
            }
            dispatch_semaphore_signal(sem);
        } failureBlock:^(NSError *error) {
            if (error != nil)
            {
                NSLog(@"Error Asset:%@", [error localizedDescription]);
            }
            dispatch_semaphore_signal(sem);
        }];
    });
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    return isExist;
}

- (NSURL *)copyFileFromURL:(NSURL *)url toPath:(NSString *)toPath
{
    __block NSURL *assetLocalURL = nil;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void)
    {
        void (^assetForURL)(ALAsset *) = ^(ALAsset *asset)
        {
            if (asset)
            {
                ALAssetRepresentation *assetRep = [asset defaultRepresentation];
                //assetLocalURL = [[FileAssetsManager defaultCacheURL] URLByAppendingPathComponent:[assetRep filename]];
                assetLocalURL = [[NSURL fileURLWithPath:toPath] URLByAppendingPathComponent:[assetRep filename]];
                
                // remove file if exists
                [MIAssetsManager removeFileIfExistsInLocalURL:assetLocalURL];
                
                NSError *error;
                [asset exportDataToURL:assetLocalURL error:&error];
                if (error)
                {
                    NSLog(@"Error exporting file:%@", [error localizedDescription]);
                }
            }
            else
            {
                NSLog(@"Invalid asset:%@", [url absoluteString]);
            }
            dispatch_semaphore_signal(sem);
        };
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:url resultBlock:assetForURL failureBlock:^(NSError *error)
        {
            NSLog(@"Error: %@", [error localizedDescription]);
            dispatch_semaphore_signal(sem);
        }];
    });
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    return assetLocalURL;
}

- (void)getThumbnailFromURL:(NSURL *)url withInsertBlock:(InsertContainerBlock)insertContainerBlock
{
    [assetsLibrary assetForURL:url resultBlock:^(ALAsset *asset)
    {
        UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
        ALAssetRepresentation *assetRep = [asset defaultRepresentation];
        NSString *fileName = [assetRep filename];
        NSURL *fileURL = [assetRep url];
        
        // construct container
        MIContainer *container = [[MIContainer alloc] init];
        [container setUrl:fileURL];
        [container setLabel:fileName];
        [container setThumbnail:image];
        
        insertContainerBlock(container);
    } failureBlock:^(NSError *error) {
        insertContainerBlock(nil);
    }];
}

#pragma mark - FileAssetsManager Functions

+ (BOOL)removeFileIfExistsInLocalURL:(NSURL *)url
{
    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]])
    {
        [[NSFileManager defaultManager] removeItemAtPath:[url path] error:&error];
        if (error)
        {
            NSLog(@"Error removing file:%@", [error localizedDescription]);
            return NO;
        }
    }
    
    return YES;
}

- (void)getPhotoAssetsWithPhotosOnly:(BOOL)photosOnly withInsertContainerBlock:(InsertContainerBlock)insertContainerBlock
{
    void (^enumerateAssetsBlock)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop)
    {
        if (result != nil)
        {
            UIImage *image = [UIImage imageWithCGImage:[result thumbnail]];
            ALAssetRepresentation *assetRep = [result defaultRepresentation];
            NSString *fileName = [assetRep filename];
            NSURL *fileURL = [assetRep url];
            
            // construct container
            MIContainer *container = [[MIContainer alloc] init];
            [container setUrl:fileURL];
            [container setLabel:fileName];
            [container setThumbnail:image];
            
            insertContainerBlock(container);
        }
        else
        {
            NSLog(@"End of enumerate assets");
        }
    };
    
    void (^enumerateGroupsBlock)(ALAssetsGroup*, BOOL*) = ^(ALAssetsGroup *group, BOOL *stop)
    {
        if (group != nil)
        {
            if (photosOnly)
            {
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            }
            else
            {
                [group setAssetsFilter:[ALAssetsFilter allAssets]];
            }
            
            // enumerate photo group
            ALAssetsGroupType groupType = [[group valueForProperty:ALAssetsGroupPropertyType] intValue];
            switch (groupType)
            {
                case ALAssetsGroupAlbum:
                case ALAssetsGroupLibrary:
                case ALAssetsGroupSavedPhotos:
                    [group enumerateAssetsUsingBlock:enumerateAssetsBlock];
                    break;
                case ALAssetsGroupPhotoStream:
                    // not supported with iCloud
                    break;
                default:
                    NSLog(@"Invalid photo group asset type:%d", groupType);
            }
        }
        else
        {
            NSLog(@"End of enumerate asset groups");
        }
    };
    
    void (^enumerateGroupsFailureBlock)(NSError *) = ^(NSError *error)
    {
        NSLog(@"Failed to get photo asset groups: %@", [error localizedDescription]);
        return;
    };
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes: ALAssetsGroupAll
                           usingBlock:enumerateGroupsBlock
                         failureBlock:enumerateGroupsFailureBlock
     ];
}

- (void)getPhotoAssetGroupsWithPhotosOnly:(BOOL)photosOnly withInsertContainerBlock:(InsertContainerBlock)insertContainerBlock
{
    void (^enumerateGroupsBlock)(ALAssetsGroup*, BOOL*) = ^(ALAssetsGroup *group, BOOL *stop)
    {
        if (group != nil)
        {
            if (photosOnly)
            {
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            }
            else
            {
                [group setAssetsFilter:[ALAssetsFilter allAssets]];
            }
            
            NSURL *groupURL = [group valueForProperty:ALAssetsGroupPropertyURL];
            NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
            NSInteger groupItemCount = [group numberOfAssets];
            UIImage *groupImage = nil;//[UIImage imageNamed:@"thumb_blank"];
            if ([group posterImage] != nil && groupItemCount > 0)
            {
                groupImage = [UIImage imageWithCGImage:[group posterImage]];
            }
            
            // arrange photo albums
            MIContainerGroup *container;
            ALAssetsGroupType groupType = [[group valueForProperty:ALAssetsGroupPropertyType] intValue];
            switch (groupType)
            {
                case ALAssetsGroupAlbum:
                case ALAssetsGroupLibrary:
                case ALAssetsGroupSavedPhotos:
                    container = [[MIContainerGroup alloc] init];
                    [container setUrl:groupURL];
                    [container setThumbnail:groupImage];
                    [container setLabel:[NSString stringWithFormat:@"%@ (%d)", groupName, groupItemCount]];
                    
                    insertContainerBlock(container);
                    break;
                case ALAssetsGroupPhotoStream:
                    // not supported with iCloud
                    break;
                default:
                    NSLog(@"Invalid photo group asset type:%d", groupType);
            }
        }
        else
        {
            NSLog(@"End of enumerate asset groups");
        }
    };
    
    void (^enumerateGroupsFailureBlock)(NSError *) = ^(NSError *error)
    {
        NSLog(@"Failed to get photo asset groups: %@", [error localizedDescription]);
        return;
    };
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes: ALAssetsGroupAll
                           usingBlock:enumerateGroupsBlock
                         failureBlock:enumerateGroupsFailureBlock
     ];
}

- (void)getPhotoAssetsWithGroupURL:(NSURL *)groupURL withPhotosOnly:(BOOL)photosOnly withInsertContainerBlock:(InsertContainerBlock)insertContainerBlock
{
    void (^enumerateAssetsBlock)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop)
    {
        if (result != nil)
        {
            UIImage *image = [UIImage imageWithCGImage:[result thumbnail]];
            ALAssetRepresentation *assetRep = [result defaultRepresentation];
            NSString *fileName = [assetRep filename];
            NSURL *fileURL = [assetRep url];
            
            // construct container
            MIContainer *container = [[MIContainer alloc] init];
            [container setUrl:fileURL];
            [container setLabel:fileName];
            [container setThumbnail:image];
            
            insertContainerBlock(container);
        }
        else
        {
            NSLog(@"End of enumerate assets with group");
        }
    };
    
    void (^getGroupForURLResultBlock)(ALAssetsGroup *) = ^(ALAssetsGroup *group)
    {
        if (group != nil)
        {
            //NSLog(@"Enumerating for group %@", [group valueForProperty:ALAssetsGroupPropertyName]);
            if (photosOnly)
            {
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            }
            else
            {
                [group setAssetsFilter:[ALAssetsFilter allAssets]];
            }
            [group enumerateAssetsUsingBlock:enumerateAssetsBlock];
        }
        else
        {
            NSLog(@"End of enumerate asset groups");
        }
    };
    
    void (^getGroupForURLFailureBlock)(NSError *) = ^(NSError *error)
    {
        NSLog(@"Failed to get photo assets: %@", [error localizedDescription]);
        return;
    };
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library groupForURL:groupURL resultBlock:getGroupForURLResultBlock failureBlock:getGroupForURLFailureBlock];
}

- (void)getPhotoAssetGroupNameWithGroupURL:(NSURL *)groupURL withPhotosOnly:(BOOL)photosOnly
{
    void (^getGroupForURLResultBlock)(ALAssetsGroup *) = ^(ALAssetsGroup *group)
    {
        if (group != nil)
        {
            //NSLog(@"Enumerating for group %@", [group valueForProperty:ALAssetsGroupPropertyName]);
            if (photosOnly)
            {
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            }
            else
            {
                [group setAssetsFilter:[ALAssetsFilter allAssets]];
            }
            //NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
            //NSInteger groupItemCount = [group numberOfAssets];
            //[sender photoAssetsGroupNameNotification:[NSString stringWithFormat:@"%@ (%d)", groupName, groupItemCount]];
        }
    };
    
    void (^getGroupForURLFailureBlock)(NSError *) = ^(NSError *error)
    {
        NSLog(@"Failed to get photo assets: %@", [error localizedDescription]);
        return;
    };
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library groupForURL:groupURL resultBlock:getGroupForURLResultBlock failureBlock:getGroupForURLFailureBlock];
}

- (UIImage *)getThumbnailImageSyncFromURL:(NSURL *)url
{
    __block UIImage *thumbnail = nil;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void)
    {
        void (^assetForURL)(ALAsset *) = ^(ALAsset *asset)
        {
            if (asset)
            {
                //ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
                //UIImage *thumbnail = [[UIImage alloc] initWithCGImage:[assetRepresentation fullResolutionImage] scale:1.0f orientation:(UIImageOrientation)[assetRepresentation orientation]];
                
                // display thumbnail
                thumbnail = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
            }
            else
            {
                NSLog(@"Invalid asset:%@", [url absoluteString]);
            }
            dispatch_semaphore_signal(sem);
        };
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:url resultBlock:assetForURL failureBlock:^(NSError *error)
        {
            NSLog(@"Error: %@", [error localizedDescription]);
            dispatch_semaphore_signal(sem);
        }];
    });
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    return thumbnail;
}

- (UIImage *)getFullResolutionImageSyncFromURL:(NSURL *)url
{
    __block UIImage *image = nil;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void)
    {
        void (^assetForURL)(ALAsset *) = ^(ALAsset *asset)
        {
            if (asset)
            {
                // display thumbnail
                ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
                image = [[UIImage alloc] initWithCGImage:[assetRepresentation fullResolutionImage] scale:1.0f orientation:[assetRepresentation orientation]];
            }
            else
            {
                NSLog(@"Invalid asset:%@", [url absoluteString]);
            }
            dispatch_semaphore_signal(sem);
        };
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:url resultBlock:assetForURL failureBlock:^(NSError *error)
        {
            NSLog(@"Error: %@", [error localizedDescription]);
            dispatch_semaphore_signal(sem);
        }];
    });
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    return image;
}

@end
