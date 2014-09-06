//
//  FileHelper.h
//  MIFileManager
//
//  Created by Kent Tan on 8/15/14.
//
//

#import <Foundation/Foundation.h>

@interface FileHelper : NSObject

+ (BOOL)isURLLocal:(NSURL *)url;
+ (BOOL)isURLAsset:(NSURL *)url;
+ (BOOL)isURLMedia:(NSURL *)url;
+ (NSURL *)defaultDocumentURL;
+ (NSURL *)defaultCacheURL;
+ (NSURL *)resourceURLFromFilename:(NSString *)filename;

+ (BOOL)createFolder:(NSString*)path;
+ (BOOL)removeFolder:(NSString*)path;

+ (NSString *)getDocumentsDirectory;
+ (NSArray *)getListOfFilesFromPath:(NSString *)path withPathExtension:(NSString *)pathExtension;
+ (BOOL)copyFileFromSourcePath:(NSString *)sourcePath toTargetPath:(NSString *)targetPath;
+ (BOOL)moveFileFromSourcePath:(NSString *)sourcePath toTargetPath:(NSString *)targetPath;

@end
