//
//  NSString+Helper.h
//  MIFileManager
//
//  Source: http://madebymany.com/blog/url-encoding-an-nsstring-on-ios
//
//  Created by PRDCM CDC on 3/26/13.
//  Copyright (c) 2013 Noctorus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Helper)

-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;

@end