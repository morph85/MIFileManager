//
//  FileManager.h
//  MIFileManager
//
//  Created by PRDCM CDC on 3/27/13.
//  Copyright (c) 2013 Noctorus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIManagerProtocol.h"

@interface MIFileManager : NSObject <MIManagerProtocol>

+ (id)getInstance;

+ (long long)getFolderSizeFromPath:(NSString *)folderPath;
+ (long long)getFileSizeFromPath:(NSString *)filePath;
//+ (NSUInteger)getFileSizeFromURL:(NSURL *)url;
+ (NSDate *)getFileCreationDateWithLocalURL:(NSURL *)url;

- (BOOL)removeLocalFileWithURL:(NSURL *)url;

@end
