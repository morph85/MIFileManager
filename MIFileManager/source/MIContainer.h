//
//  MIContainer.h
//  MIFileManager
//
//  Created by morph85 on 3/19/13.
//  Copyright (c) 2013 Noctorus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MIContainer : NSObject
@property (strong, nonatomic) UIImage *thumbnail;
@property (strong, nonatomic) NSString *label;
@property (strong, nonatomic) NSURL *url;
@end
