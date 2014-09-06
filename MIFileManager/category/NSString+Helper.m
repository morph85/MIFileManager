//
//  NSString+Helper.m
//  MIFileManager
//
//  Source: http://madebymany.com/blog/url-encoding-an-nsstring-on-ios
//
//  Created by PRDCM CDC on 3/26/13.
//  Copyright (c) 2013 Noctorus. All rights reserved.
//

#import "NSString+Helper.h"

@implementation NSString (Helper)

-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
	return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)self,
                                                               NULL,
                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                               CFStringConvertNSStringEncodingToEncoding(encoding));
}

@end
