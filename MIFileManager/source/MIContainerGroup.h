//
//  MIContainerGroup.h
//  MIFileManager
//
//  Created by morph85 on 3/27/13.
//  Copyright (c) 2013 Noctorus. All rights reserved.
//

#import "MIContainer.h"

@interface MIContainerGroup : MIContainer

- (void)clear;
- (void)addContainer:(MIContainer *)container;
- (void)addContainer:(MIContainer *)container atIndex:(NSUInteger)index;
- (NSUInteger)containerCount;
- (MIContainer *)containerAtIndex:(NSUInteger)index;

@end
