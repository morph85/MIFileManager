//
//  MIFileManager.m
//  MIFileManager
//
//  Created by morph85 on 3/27/13.
//  Copyright (c) 2013 Noctorus. All rights reserved.
//

#import "MIFileManager.h"
#import "NSString+Helper.h"

@implementation MIFileManager

+ (id)getInstance {
    static MIFileManager *instance = nil;
    
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
    NSString *path = [url path];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (NSURL *)copyFileFromURL:(NSURL *)url toPath:(NSString *)toPath
{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fromPath = url.path;
    NSString *targetPath = [toPath stringByAppendingPathComponent:[fromPath lastPathComponent]];
    if ([fileManager fileExistsAtPath:fromPath isDirectory:nil])
    {
        if (![fileManager copyItemAtPath:fromPath toPath:targetPath error:&error])
        {
            if (error)
            {
                NSLog(@"Error copy source file %@, error:%@", fromPath, [error localizedDescription]);
            }
            else
            {
                NSLog(@"Error copy source file %@", fromPath);
            }
        }
        else
        {
            if ([fileManager fileExistsAtPath:targetPath])
            {
                return [NSURL URLWithString:[targetPath urlEncodeUsingEncoding:NSUTF8StringEncoding]];
            }
            else
            {
                NSLog(@"Error copy target file, %@ not exists", targetPath);
            }
        }
    }
    else
    {
        NSLog(@"Error copy source file, %@ not exists", fromPath);
    }
    return nil;
}

#pragma mark - FileManager Functions

+ (NSDate *)getFileCreationDateWithLocalURL:(NSURL *)url
{
    NSError *error;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[url path] error:&error];
    if (error)
    {
        NSLog(@"Attribute error: %@, file: %@", [error localizedDescription], [url path]);
        return nil;
    }
    
    return [fileAttributes objectForKey:NSFileCreationDate];
}

/*+ (NSNumber *)getFileSizeFromLocalPath:(NSString *)path
 {
 NSError *error = nil;
 NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
 if (error)
 {
 NSLog(@"FileAssetsManager:Get file date error:%@", [error localizedDescription]);
 return nil;
 }
 return [fileAttributes objectForKey:NSFileSize];
 }
 
 + (NSDate *)getFileDateFromLocalPath:(NSString *)path
 {
 NSError *error = nil;
 NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
 if (error)
 {
 NSLog(@"FileAssetsManager:Get file date error:%@", [error localizedDescription]);
 return nil;
 }
 return [fileAttributes objectForKey:NSFileModificationDate];
 }*/

+ (long long)getFolderSizeFromPath:(NSString *)folderPath
{
    NSError *error;
    NSArray *filesArray = nil;
    NSEnumerator *filesEnumerator = nil;
    NSString *fileName;
    long long folderSize = 0;
    
    // get files
    filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:&error];
    filesEnumerator = [filesArray objectEnumerator];
    if (error)
    {
        NSLog(@"Error getting folder size: %@", error);
    }
    
    // get folder size
    while (fileName = [filesEnumerator nextObject])
    {
        NSString *fullPath = [folderPath stringByAppendingPathComponent:fileName];
        BOOL isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir] && !isDir)
        {
            folderSize += [MIFileManager getFileSizeFromPath:fullPath];
        }
    }
    return folderSize;
}

+ (long long)getFileSizeFromPath:(NSString *)filePath
{
    NSError *error;
    NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
    if (error)
    {
        NSLog(@"Error getting file %@ size: %@", filePath, error);
    }
    return [fileDictionary fileSize];
}

//+ (NSUInteger)getFileSizeFromURL:(NSURL *)url
//{
//    if (![FileAssetsManager isURLExists:url])
//    {
//        NSLog(@"File for URL %@ not exists", [url absoluteString]);
//        return INVALID_FILESIZE;
//    }
//
//    if ([FileAssetsManager isFileLocal:url])
//    {
//        NSData *data = [[NSFileManager defaultManager] contentsAtPath:[url path]];
//        return data.length;
//    }
//    else if ([FileAssetsManager isFileAsset:url])
//    {
//        __block NSUInteger assetSize = INVALID_FILESIZE;
//        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void)
//        {
//            [[[FileAssetsManager assetsManager] assetsLibrary] assetForURL:url resultBlock:^(ALAsset *asset)
//            {
//                if(asset != nil)
//                {
//                    ALAssetRepresentation *assetRep = [asset defaultRepresentation];
//                    assetSize = [assetRep size];
//                }
//                dispatch_semaphore_signal(sem);
//            } failureBlock:^(NSError *error) {
//                if (error != nil)
//                {
//                    NSLog(@"Error Asset:%@", [error localizedDescription]);
//                }
//                dispatch_semaphore_signal(sem);
//            }];
//        });
//
//        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
//        dispatch_release(sem);
//        return assetSize;
//    }
//    else if ([FileAssetsManager isFileMedia:url])
//    {
//        /*AVAssetExportSession *exporter = [FileAssetsManager getMediaExporterFromMediaURL:url toTargetPath:[[FileAssetsManager defaultDocumentURL] path]];
//        if (exporter == nil)
//        {
//            NSLog(@"Error getting media exporter");
//            return INVALID_FILESIZE;
//        }
//
//        AVAsset *asset = [AVAsset assetWithURL:url];
//        NSArray *tracks = [asset tracks];
//        NSLog(@"No. of tracks:%d", [tracks count]);
//        for (AVAssetTrack *track in tracks)
//        {
//            NSLog(@"Track natural size: %f, %f", track.naturalSize.width, track.naturalSize.height);
//        }
//
//        NSArray *presets = [AVAssetExportSession exportPresetsCompatibleWithAsset:[AVAsset assetWithURL:url]];
//        for (NSString *preset in presets)
//        {
//            NSLog(@"Compatible preset:%@", preset);
//        }
//
//        AVAssetExportSession *fileexporter = [[AVAssetExportSession alloc] initWithAsset:[AVAsset assetWithURL:url] presetName:AVAssetExportPresetPassthrough];
//        NSArray *supportedFileTypes = fileexporter.supportedFileTypes;
//        for (NSString *fileType in supportedFileTypes)
//        {
//            NSLog(@"Supported:%@", fileType);
//        }
//
//        NSLog(@"File type:%@", fileexporter.outputFileType);
//        //long long fileSize = [assetExport fileLengthLimit];
//        NSArray *metadataItems = [fileexporter metadata];
//        NSLog(@"Metadatas count:%d", [metadataItems count]);
//        for (AVMetadataItem *metadataItem in metadataItems)
//        {
//            NSLog(@"Metadata length: %d", [metadataItem dataValue].length);
//        }
//
//        exporter.outputFileType = AVFileTypeAppleM4V;
//
//        // error in AVAsset framework for detecting estimated output file size
//        // crashes happens here
//        long long fileSize = fileexporter.estimatedOutputFileLength;
//        NSLog(@"File size:%lld", fileSize);
//        fileSize = fileexporter.fileLengthLimit;
//        NSLog(@"File limit:%lld", fileSize);*/
//
//        // warning: file is copied to cache folder to check the actual exported file size
//        // not recommended for large file size
//        NSURL *copiedURL = [FileAssetsManager copyFileFromMediaURL:url toPath:[[FileAssetsManager defaultCacheURL] path]];
//        NSLog(@"Copied media file into cache folder for file size checking: %@", copiedURL.path);
//        NSUInteger fileSize = [FileAssetsManager getFileSizeFromURL:[NSURL fileURLWithPath:copiedURL.path]];
//        [FileAssetsManager removeFileIfExistsInLocalURL:copiedURL];
//        return fileSize;
//    }
//
//    return INVALID_FILESIZE;
//}

- (BOOL)removeLocalFileWithURL:(NSURL *)url {
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

@end
