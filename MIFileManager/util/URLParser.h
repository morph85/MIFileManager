//
//  URLParser.h
//  MIFileManager
//
//  Created by PRDCM CDC on 9/26/12.
//
//

#import <Foundation/Foundation.h>

@interface URLParser : NSObject {
    NSArray *variables;
}

@property (nonatomic, retain) NSArray *variables;

- (id)initWithURLString:(NSString *)url;
- (NSString *)valueForVariable:(NSString *)varName;

@end