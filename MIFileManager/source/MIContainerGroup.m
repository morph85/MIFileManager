//
//  MIContainerGroup.m
//  MIFileManager
//
//  Created by morph85 on 3/27/13.
//  Copyright (c) 2013 Noctorus. All rights reserved.
//

#import "MIContainerGroup.h"

@interface MIContainerGroup()
@property (strong, nonatomic) NSMutableArray *containerList;
@end

@implementation MIContainerGroup
@synthesize containerList;

- (id)init
{
    self = [super init];
    if (self)
    {
        containerList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)clear
{
    [containerList removeAllObjects];
}

- (void)addContainer:(MIContainer *)container
{
    [containerList addObject:container];
}

- (void)addContainer:(MIContainer *)container atIndex:(NSUInteger)index
{
    [containerList insertObject:containerList atIndex:index];
}

- (NSUInteger)containerCount
{
    return containerList.count;
}

- (MIContainer *)containerAtIndex:(NSUInteger)index
{
    return [containerList objectAtIndex:index];
}

@end
