//
//  AssetManager.h
//  MIFileManager
//
//  Created by PRDCM CDC on 9/10/12.
//
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MIManagerProtocol.h"

#define INVALID_FILESIZE ((NSUInteger)NSUIntegerMax)

@protocol MIAssetsManagerDelegate <NSObject>
@required
- (void)photoAssetNotification:(MIContainer *)container;
- (void)photoAssetsNotification:(NSArray *)directoryItems;
- (void)photoAssetsGroupNameNotification:(NSString *)groupName;
@end

@interface MIAssetsManager : NSObject <MIManagerProtocol>

+ (id)getInstance;

// Photo
- (void)getPhotoAssetsWithPhotosOnly:(BOOL)photosOnly withInsertContainerBlock:(InsertContainerBlock)insertContainerBlock;
- (void)getPhotoAssetGroupsWithPhotosOnly:(BOOL)photosOnly withInsertContainerBlock:(InsertContainerBlock)insertContainerBlock;
- (void)getPhotoAssetsWithGroupURL:(NSURL *)groupURL withPhotosOnly:(BOOL)photosOnly withInsertContainerBlock:(InsertContainerBlock)insertContainerBlock;

//- (void)getPhotoAssetGroups:(id<PhotoAssetNotificationDelegate>)sender photosOnly:(BOOL)photosOnly;
- (void)getPhotoAssetGroupNameWithGroupURL:(NSURL *)groupURL withPhotosOnly:(BOOL)photosOnly;
//- (void)getPhotoFromAssetURL:(NSURL *)assetURL;

- (UIImage *)getThumbnailImageSyncFromURL:(NSURL *)url;
- (UIImage *)getFullResolutionImageSyncFromURL:(NSURL *)url;

@end
