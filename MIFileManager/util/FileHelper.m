//
//  FileHelper.m
//  MIFileManager
//
//  Created by Ivan Gan on 8/15/14.
//
//

#import "FileHelper.h"

@implementation FileHelper

+ (BOOL)isURLLocal:(NSURL *)url
{
    if (url == nil)
    {
        return NO;
    }
    
    if ([url isFileURL])
    {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isURLAsset:(NSURL *)url
{
    if (url == nil)
    {
        return NO;
    }
    
    if ([url scheme] != nil && [[url scheme] caseInsensitiveCompare:@"assets-library"] == NSOrderedSame)
    {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isURLMedia:(NSURL *)url
{
    if (url == nil)
    {
        return NO;
    }
    
    if ([url scheme] != nil && [[url scheme] caseInsensitiveCompare:@"ipod-library"] == NSOrderedSame)
    {
        return YES;
    }
    
    return NO;
}

+ (NSURL *)defaultDocumentURL
{
    return [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
}

+ (NSURL *)defaultCacheURL
{
    return [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
}

+ (NSURL *)resourceURLFromFilename:(NSString *)filename {
    if (filename == nil || [filename length] <= 0)
    {
        NSLog(@"Invalid resource filename");
        return nil;
    }
    
    NSString *filepath = [[NSBundle mainBundle] pathForResource:[filename stringByDeletingPathExtension] ofType:[filename pathExtension]];
    if (filepath == nil)
    {
        NSLog(@"Error or resource file not found");
        return nil;
    }
    
    return [NSURL fileURLWithPath:filepath];
}

#pragma mark - Functionality Methods

+ (BOOL) createFolder:(NSString*) path
{
    NSFileManager *fileManager= [NSFileManager defaultManager];
    BOOL isDir;
    if(![fileManager fileExistsAtPath:path isDirectory:&isDir])
    {
        if(![fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL])
        {
            NSLog(@"Error: Create folder failed: %@", path);
            return NO;
        }
        NSLog(@"Info: Created folder: %@", path);
        return YES;
    }
    NSLog(@"Error: Folder is exist");
    return YES;
}

+ (BOOL) removeFolder:(NSString*) path
{
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    
    NSLog(@"%@", success ? @"Remove folder: Yes" : @"Remove folder: No");
    return success;
}

#pragma mark - Helper Functions

+ (NSString *)getDocumentsDirectory {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

+ (NSArray *)getListOfFilesFromPath:(NSString *)path withPathExtension:(NSString *)pathExtension
{
    NSMutableArray *fileList = [[NSMutableArray alloc] init];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDirectory])
    {
        NSLog(@"Path not a directory");
        // prompt error
        return fileList;
    }
    
    if (!isDirectory)
    {
        NSLog(@"Path not a directory");
        // prompt error
        return fileList;
    }
    
    NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:path error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self ENDSWITH '.%@'", pathExtension]];
    NSArray *filteredFileList = [dirContents filteredArrayUsingPredicate:fltr];
    for (NSString *filePath in filteredFileList)
    {
        NSLog(@"File:%@", filePath);
    }
    
    if (filteredFileList.count <= 0)
    {
        NSLog(@"No file found, count=%d", filteredFileList.count);
    }
    
    //    [fileArray sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(NSString* str1, NSString* str2) {
    //        // Scan for your marker in both strings and split on it...
    //        // Say you store the results in substr1 and substr2...
    //        return [str1 caseInsensitiveCompare:str2];
    //    }];
    
    return filteredFileList;
}

+ (BOOL)copyFileFromSourcePath:(NSString *)sourcePath toTargetPath:(NSString *)targetPath
{
    // check source file exists
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory;
    if (![fileManager fileExistsAtPath:sourcePath isDirectory:&isDirectory])
    {
        NSLog(@"Source path not found");
        return NO;
    }
    
    // check source file is a file
    if (isDirectory)
    {
        NSLog(@"Source path not a file");
        return NO;
    }
    
    // check target path exists
    NSError *error;
    if ([fileManager fileExistsAtPath:targetPath isDirectory:&isDirectory])
    {
        // do not allow target folder/directory method
        if (isDirectory)
        {
            NSLog(@"Target path is a folder");
            return NO;
        }
        
        // remove if exists
        NSLog(@"Removing existing file:%@", targetPath);
        [fileManager removeItemAtPath:targetPath error:&error];
        if (error)
        {
            NSLog(@"Error remove target path:%@, error:%@", targetPath, [error localizedDescription]);
            return NO;
        }
    }
    
    // check target base path exists
    NSString *targetBasePath = [targetPath stringByDeletingLastPathComponent];
    if ([fileManager fileExistsAtPath:targetBasePath isDirectory:&isDirectory])
    {
        // do not allow target file method
        if (!isDirectory)
        {
            NSLog(@"Target base path is a file");
            return NO;
        }
    }
    else
    {
        [fileManager createDirectoryAtPath:targetBasePath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error)
        {
            NSLog(@"Error create intermediate folder:%@, error:%@", targetBasePath, [error localizedDescription]);
            return NO;
        }
    }
    
    [fileManager copyItemAtPath:sourcePath toPath:targetPath error:&error];
    if (error)
    {
        NSLog(@"Error copy file from source:%@, to target:%@, error:%@", sourcePath, targetPath, error);
        return NO;
    }
    
    return YES;
}

+ (BOOL)moveFileFromSourcePath:(NSString *)sourcePath toTargetPath:(NSString *)targetPath
{
    // check source file exists
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory;
    if (![fileManager fileExistsAtPath:sourcePath isDirectory:&isDirectory])
    {
        NSLog(@"Source path not found");
        return NO;
    }
    
    // check source file is a file
    if (isDirectory)
    {
        NSLog(@"Source path not a file");
        return NO;
    }
    
    // check target path exists
    NSError *error;
    if ([fileManager fileExistsAtPath:targetPath isDirectory:&isDirectory])
    {
        // do not allow target folder/directory method
        if (isDirectory)
        {
            NSLog(@"Target path is a folder");
            return NO;
        }
        
        // remove if exists
        NSLog(@"Removing existing file:%@", targetPath);
        [fileManager removeItemAtPath:targetPath error:&error];
        if (error)
        {
            NSLog(@"Error remove target path:%@, error:%@", targetPath, [error localizedDescription]);
            return NO;
        }
    }
    
    // check target base path exists
    NSString *targetBasePath = [targetPath stringByDeletingLastPathComponent];
    if ([fileManager fileExistsAtPath:targetBasePath isDirectory:&isDirectory])
    {
        // do not allow target file method
        if (!isDirectory)
        {
            NSLog(@"Target base path is a file");
            return NO;
        }
    }
    else
    {
        [fileManager createDirectoryAtPath:targetBasePath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error)
        {
            NSLog(@"Error create intermediate folder:%@, error:%@", targetBasePath, [error localizedDescription]);
            return NO;
        }
    }
    
    [fileManager moveItemAtPath:sourcePath toPath:targetPath error:&error];
    if (error)
    {
        NSLog(@"Error move file from source:%@, to target:%@, error:%@", sourcePath, targetPath, error);
        return NO;
    }
    
    return YES;
}

@end
