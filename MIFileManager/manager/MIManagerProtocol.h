//
//  MIManagerProtocol.h
//  MIFileManager
//
//  Created by morph85 on 3/27/13.
//  Copyright (c) 2013 Noctorus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../source/MIContainer.h"
#import "MIFileConst.h"

typedef void (^InsertContainerBlock) (MIContainer *container);
typedef void (^GetContainerBlock) (MIContainer *container);
typedef void (^GetHeaderBlock) (NSString *header);

@protocol MIManagerProtocol <NSObject>
@required
+ (id)getInstance;
- (BOOL)isFileExists:(NSURL *)url;
- (NSURL *)copyFileFromURL:(NSURL *)url toPath:(NSString *)toPath;
//- (void)getThumbnailFromURL:(NSURL *)url withInsertBlock:(InsertContainerBlock)insertContainerBlock;
@end
