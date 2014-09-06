//
//  MediaManager.m
//  MIFileManager
//
//  Created by PRDCM CDC on 3/27/13.
//  Copyright (c) 2013 Noctorus. All rights reserved.
//

#import "MIMediaManager.h"
#import "ImageHelper.h"

@implementation MIMediaManager

+ (id)getInstance
{
    static MIMediaManager *instance = nil;
    
    // using GCD to make sure only dispatch once
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

#pragma mark - ManagerProtocol

- (BOOL)isFileExists:(NSURL *)url
{
    NSNumber *persistentID = [self getPersistentIDWithURL:url];
    MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:persistentID forProperty:MPMediaItemPropertyPersistentID];
    MPMediaQuery *query = [[MPMediaQuery alloc] init];
    [query addFilterPredicate:predicate];
    if ([[query items] count] > 0)
    {
        return YES;
    }
    return NO;
}

- (AVAssetExportSession *)getMediaExporterFromMediaURL:(NSURL *)url toTargetPath:(NSString *)targetPath
{
    NSNumber *persistentID = [self getPersistentIDWithURL:url];
    MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:persistentID forProperty:MPMediaItemPropertyPersistentID];
    MPMediaQuery *query = [[MPMediaQuery alloc] init];
    [query addFilterPredicate:predicate];
    NSArray *items = [query items];
    if ([items count] != 1)
    {
        NSLog(@"Media not found:%@", persistentID);
        return nil;
    }
    NSString *mediaTitle = [[items objectAtIndex:0] valueForProperty:MPMediaItemPropertyTitle];
    
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL: url options:nil];
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset: songAsset
                                                                      presetName: AVAssetExportPresetPassthrough];
    NSURL *mediaLocalURL;
    
    NSString *extension = [url pathExtension];
    if ([extension caseInsensitiveCompare:@"mp4"] == NSOrderedSame)
    {
        exporter.outputFileType = AVFileTypeMPEG4;
        mediaLocalURL = [NSURL fileURLWithPath:[[targetPath stringByAppendingPathComponent:mediaTitle] stringByAppendingPathExtension:extension]];
    }
    else if ([extension caseInsensitiveCompare:@"mov"] == NSOrderedSame)
    {
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
        mediaLocalURL = [NSURL fileURLWithPath:[[targetPath stringByAppendingPathComponent:mediaTitle] stringByAppendingPathExtension:extension]];
    }
    else if ([extension caseInsensitiveCompare:@"mp4"] == NSOrderedSame)
    {
        exporter.outputFileType = AVFileTypeAppleM4V;
        mediaLocalURL = [NSURL fileURLWithPath:[[targetPath stringByAppendingPathComponent:mediaTitle] stringByAppendingPathExtension:extension]];
    }
    else
    {
        NSLog(@"Invalid media file format for export");
    }
    if (mediaLocalURL == nil)
    {
        NSLog(@"Invalid media URL for export");
        return nil;
    }
    NSLog(@"Output file type:%@", exporter.outputFileType);
    exporter.outputURL = mediaLocalURL;
    return exporter;
}

- (NSURL *)copyFileFromURL:(NSURL *)url toPath:(NSString *)toPath
{
    AVAssetExportSession *exporter = [self getMediaExporterFromMediaURL:url toTargetPath:toPath];
    if (exporter == nil)
    {
        NSLog(@"Error getting media exporter");
        return nil;
    }
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void)
    {
        // do the export
        // (completion handler block omitted)
        [exporter exportAsynchronouslyWithCompletionHandler:
         ^{
             //NSData *data = [NSData dataWithContentsOfFile: [[self myDocumentsDirectory]
             //                                                stringByAppendingPathComponent: @"exported.mp4"]];
             //
             NSLog(@"Export media completed:%@", exporter.outputURL);
             dispatch_semaphore_signal(sem);
         }];
    });
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    return exporter.outputURL;
}

#pragma mark - MediaManager Functions

- (NSNumber *)getPersistentIDWithURL:(NSURL *)url
{
    URLParser *parser = [[URLParser alloc] initWithURLString:[url absoluteString]];
    NSString *persistentIdString = [parser valueForVariable:@"id"];
    unsigned long long ullvalue = strtoull([persistentIdString UTF8String], NULL, 0);
    return [[NSNumber alloc]initWithUnsignedLongLong:ullvalue];
}

- (NSMutableArray *)getMediaAssets
{
    NSMutableArray *mediaItems = [[NSMutableArray alloc] init];
    MPMediaPropertyPredicate *typePredicate = [MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithInt:MPMediaTypeAny] forProperty:MPMediaItemPropertyMediaType];
    MPMediaQuery *allQuery = [[MPMediaQuery alloc] initWithFilterPredicates:[NSSet setWithObject:typePredicate]];
    NSArray *allItems = [allQuery items];
    for (MPMediaItem *item in allItems)
    {
        //NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
        //if ([url.pathExtension compare:@"mp4"] == NSOrderedSame)
        //{
        [mediaItems addObject:item];
        //}
    }
    return mediaItems;
}

+ (UIImage *)getMediaThumbnailSyncFromURL:(NSURL *)url
{
    __block UIImage *thumbnail = nil;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void)
    {
        NSArray *keys = [NSArray arrayWithObject:@"duration"];
        __block AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
        [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^()
        {
            NSError *error = nil;
            AVKeyValueStatus valueStatus = [asset statusOfValueForKey:@"duration" error:&error];
            switch (valueStatus)
            {
                case AVKeyValueStatusLoaded:
                    if ([asset tracksWithMediaCharacteristic:AVMediaTypeVideo])
                    {
                        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                        //Float64 movieDuration = CMTimeGetSeconds([asset duration]);
                        //CMTime middleFrame = CMTimeMakeWithSeconds(movieDuration/2.0, 600);
                        CMTime time = CMTimeMakeWithSeconds(MEDIA_THUMBNAIL_TIME, 1);
                        
                        NSError *error;
                        CGImageRef imageForThumbnail = [generator copyCGImageAtTime:time actualTime:NULL error:&error];
                        if (error == nil)
                        {
                            if (imageForThumbnail != nil)
                            {
                                // set media thumbnail
                                thumbnail = [ImageHelper image:[UIImage imageWithCGImage:imageForThumbnail] fitInSize:CGSizeMake(MAX_THUMBNAIL_SIZE, MAX_THUMBNAIL_SIZE)];
                                CGImageRelease(imageForThumbnail);
                                dispatch_semaphore_signal(sem);
                                return;
                            }
                            else
                            {
                                NSLog(@"Error getting thumbnail");
                            }
                        }
                        else
                        {
                            NSLog(@"Error getting thumbnail: %@", [error localizedDescription]);
                        }
                    }
                    break;
                case AVKeyValueStatusFailed:
                    NSLog(@"Error finding duration");
                    break;
                case AVKeyValueStatusCancelled:
                    NSLog(@"Cancelled finding duration");
                    break;
            }
            
            // set default blank thumbnail
            //>>>thumbnail = [UIImage imageNamed:THUMB_BLANK];
            thumbnail = nil;
            dispatch_semaphore_signal(sem);
        }];
    });
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    return thumbnail;
    
    /*NSError *error;
     if (![FileAssetsManager isURLExists:anURL])
     {
     NSLog(@"FileAssetsManager:Media does not exists: %@", error);
     return nil;
     }
     
     MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:url];
     UIImage *thumbnail = [player thumbnailImageAtTime:MEDIA_THUMBNAIL_TIME timeOption:MPMovieTimeOptionNearestKeyFrame];
     player = nil;
     if (thumbnail == nil)
     {
     NSLog(@"FileAssetsManager:Media thumbnail generation failed");
     return [UIImage imageNamed:THUMB_BLANK];
     }
     return thumbnail;*/
}


@end
