//
//  MediaManager.h
//  MIFileManager
//
//  Created by PRDCM CDC on 3/27/13.
//  Copyright (c) 2013 Noctorus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MPMediaLibrary.h>
#import <MediaPlayer/MPMediaQuery.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import <AVFoundation/AVFoundation.h>
#import "MIManagerProtocol.h"
#import "URLParser.h"
#import "FileHelper.h"

#define MEDIA_THUMBNAIL_TIME 1.0

@interface MIMediaManager : NSObject <MIManagerProtocol>

+ (id)getInstance;

- (NSMutableArray *)getMediaAssets;
- (NSNumber *)getPersistentIDWithURL:(NSURL *)url;
+ (UIImage *)getMediaThumbnailSyncFromURL:(NSURL *)url;
//+ (void)getMediaThumbnailAsyncFromDirectoryItem:(DirectoryItem *)directoryItem;
//>>>+ (DeskItemProperty *)getDeskItemPropertyFromMediaURL:(NSURL *)url;

@end
