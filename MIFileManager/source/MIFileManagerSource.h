//
//  MIFileManagerSource.h
//  MIFileManager
//
//  Created by morph85 on 3/26/13.
//  Copyright (c) 2013 Noctorus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MITaskOperations.h"
#import "MIImageLoader.h"
#import "MIContainer.h"
#import "MIContainerGroup.h"
#import "../util/ImageHelper.h"

#define CELL_HEIGHT 60.0f

@protocol MIFileManagerSourceDelegate <NSObject>
@required
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath withContainer:(MIContainer *)container;
@end

@interface MIFileManagerSource : NSObject <UITableViewDelegate, UITableViewDataSource, ImageLoaderDelegate>

@property (assign, nonatomic) id <MIFileManagerSourceDelegate> delegate;
@property (strong, nonatomic) MITaskOperations *taskOperations;

- (id)initWithDelegate:(id<MIFileManagerSourceDelegate>)aDelegate;
- (void)clear;
- (void)setContainers:(NSArray *)containers;
- (void)addContainer:(MIContainer *)container;
- (void)setGroups:(NSArray *)groups;
- (void)addGroup:(MIContainerGroup *)containerGroup;

@end
