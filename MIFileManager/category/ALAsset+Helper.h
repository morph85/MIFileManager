//
//  ALAsset+Helper.h
//  MIFileManager
//
//  Created by morph85 on 3/26/13.
//  Copyright (c) 2013 Noctorus. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAsset (Helper)
- (BOOL)exportDataToURL: (NSURL*) fileURL error: (NSError**) error;
@end
