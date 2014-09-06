//
//  MIFileManagerSource.m
//  MIFileManager
//
//  Created by morph85 on 3/26/13.
//  Copyright (c) 2013 Noctorus. All rights reserved.
//

#import "MIFileManagerSource.h"

@interface MIFileManagerSource()
@property (strong, nonatomic) NSMutableArray *containerList;
@property (strong, nonatomic) NSMutableArray *containerGroupList;
@end

@implementation MIFileManagerSource
@synthesize delegate;
@synthesize taskOperations;

#pragma mark - FileTableViewSourceDelegate Functions

- (id)initWithDelegate:(id<MIFileManagerSourceDelegate>)aDelegate
{
    self = [super init];
    if (self)
    {
        delegate = aDelegate;
        _containerList = [[NSMutableArray alloc] init];
        _containerGroupList = [[NSMutableArray alloc] init];
        
        UITableView *tableView = [self getTableView];
        if (tableView)
        {
            [tableView setDelegate:self];
            [tableView setDataSource:self];
        }
    }
    return self;
}

- (void)clear
{
    [_containerList removeAllObjects];
    [_containerGroupList removeAllObjects];
}

- (void)setContainers:(NSArray *)containers
{
    [_containerList removeAllObjects];
    [_containerList addObjectsFromArray:containers];
}

- (void)addContainer:(MIContainer *)container
{
    [_containerList addObject:container];
}

- (void)setGroups:(NSArray *)groups
{
    [_containerGroupList removeAllObjects];
    [_containerGroupList addObjectsFromArray:groups];
}

- (void)addGroup:(MIContainerGroup *)containerGroup
{
    [_containerGroupList addObject:containerGroup];
}

- (MIContainer *)itemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_containerList.count > 0)
    {
        if (indexPath.section == 0 && indexPath.row < _containerList.count)
        {
            return [_containerList objectAtIndex:indexPath.row];
        }
    }
    else if (_containerGroupList.count > 0)
    {
        if (indexPath.section < _containerGroupList.count)
        {
            MIContainerGroup *containerGroup = [_containerGroupList objectAtIndex:indexPath.section];
            if (indexPath.row < containerGroup.containerCount)
            {
                return [containerGroup containerAtIndex:indexPath.row];
            }
        }
    }
    NSLog(@"Invalid item at index path: section %d row %d", indexPath.section, indexPath.row);
    return nil;
}

- (UITableView *)getTableView
{
    if (delegate != nil)
    {
        if ([[delegate class] isSubclassOfClass:[UITableView class]])
        {
            return ((UITableView *)delegate);
        }
        else if ([[delegate class] isSubclassOfClass:[UITableViewController class]])
        {
            return ((UITableViewController *)delegate).tableView;
        }
    }
    return nil;
}

- (id<MIFileManagerSourceDelegate>)getFileTableViewDelegate
{
    if (delegate != nil && [delegate conformsToProtocol:@protocol(MIFileManagerSourceDelegate)])
    {
        return ((id<MIFileManagerSourceDelegate>)delegate);
    }
    return nil;
}

- (void)reloadData
{
    if (delegate != nil && [delegate respondsToSelector:@selector(reloadData)])
    {
        if ([[delegate class] isSubclassOfClass:[UITableView class]])
        {
            [(UITableView *)delegate reloadData];
        }
        else if ([[delegate class] isSubclassOfClass:[UITableViewController class]])
        {
            [((UITableViewController *)delegate).tableView reloadData];
        }
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_containerList.count > 0)
    {
        // no header view
        return 0;
    }
    else if (_containerGroupList.count > 0)
    {
        return CELL_HEIGHT;
    }
    return 0;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    if (_containerList.count > 0)
//    {
//        // no header view
//        return nil;
//    }
//    else if (_containerGroupList.count > 0)
//    {
//        return UIView;
//    }
//    return nil;
//}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (_containerList.count > 0)
    {
        // no header view
        return nil;
    }
    else if (_containerGroupList.count > 0 && section < _containerGroupList.count)
    {
        return [[_containerGroupList objectAtIndex:section] label];
    }
    return nil;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [aTableView deselectRowAtIndexPath:indexPath animated:NO];
    MIContainer *currentItem = [self itemAtIndexPath:indexPath];
    id<MIFileManagerSourceDelegate> fileTableViewDelegate = [self getFileTableViewDelegate];
    if (fileTableViewDelegate != nil)
    {
        [fileTableViewDelegate tableView:[self getTableView] didSelectRowAtIndexPath:indexPath withContainer:currentItem];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_containerList.count > 0)
    {
        return 1;
    }
    else if (_containerGroupList.count > 0)
    {
        return _containerGroupList.count;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_containerList.count > 0)
    {
        return _containerList.count;
    }
    else if (_containerGroupList.count > 0 && section < _containerGroupList.count)
    {
        return [[_containerGroupList objectAtIndex:section] containerCount];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // initialize cell
    static NSString *cellIdentifier = @"FileTableViewCell";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    if (_containerList.count > 0)
    {
        MIContainer *item = [self itemAtIndexPath:indexPath];
        cell.textLabel.text = [item label];
        
        if ([item thumbnail] != nil)
        {
            cell.imageView.image = [item thumbnail];
        }
        else
        {
            // lazy loading for image:
            // i) only load when needed
            // ii) do not load twice (performance issue)
            cell.imageView.image = [ImageHelper imageWithColor:[UIColor whiteColor] andSize:CGSizeMake(CELL_HEIGHT, CELL_HEIGHT)];
            [self startOperationForContainer:item atIndexPath:indexPath];
        }
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source
        [_containerList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

#pragma mark - ImageLoaderDelegate

- (void)ImageLoaderDidFinish:(MIImageLoader *)loader
{
    [self performSelectorOnMainThread:@selector(refreshCellAtIndexPath:) withObject:loader.indexPath waitUntilDone:NO];
}

- (void)refreshCellAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"Refreshing cell for indexPath section %d, row %d", indexPath.section, indexPath.row);
    if (indexPath.row < [_containerList count])
    {
        UITableView *tableView = [self getTableView];
        if (tableView != nil)
        {
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        [self.taskOperations.imageLoadInProgress removeObjectForKey:indexPath];
    }
}

#pragma mark - TaskOperations

- (MITaskOperations *)taskOperations
{
    // lazy initialization
    if (!taskOperations)
    {
        taskOperations = [[MITaskOperations alloc] init];
    }
    return taskOperations;
}

- (void)cancelTaskOperations
{
    [_containerList removeAllObjects];
    [self reloadData];
    
    [self.taskOperations cancelAllOperations:TASK_IMAGE_LOAD];
    [self.taskOperations.imageLoadInProgress removeAllObjects];
}

- (void)startOperationForContainer:(MIContainer *)container atIndexPath:(NSIndexPath *)indexPath
{
    UITableView *tableView = [self getTableView];
    if (tableView == nil)
    {
        NSLog(@"Invalid delegate");
        return;
    }
    
    if (tableView.isDragging || tableView.isDecelerating)
    {
        NSLog(@"Currently dragging, halt loading");
        return;
    }
    
    if ([self.taskOperations.imageLoadInProgress.allKeys containsObject:indexPath])
    {
        NSLog(@"Thumbnail already registered in dictionary");
        return;
    }
    
    MIImageLoader *imageLoader = [[MIImageLoader alloc] initWithContainer:container atIndexPath:indexPath delegate:self];
    [self.taskOperations.imageLoadInProgress setObject:imageLoader forKey:indexPath];
    [self.taskOperations.imageLoadQueue addOperation:imageLoader];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.taskOperations.imageLoadQueue setSuspended:YES];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self.taskOperations.imageLoadQueue setSuspended:NO];
        [self loadImagesForOnscreenCells];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.taskOperations.imageLoadQueue setSuspended:NO];
    [self loadImagesForOnscreenCells];
}

- (void)loadImagesForOnscreenCells
{
    UITableView *tableView = [self getTableView];
    if (tableView == nil)
    {
        NSLog(@"Invalid delegate");
        return;
    }
    
    NSSet *visibleRows = [NSSet setWithArray:[tableView indexPathsForVisibleRows]];
    NSMutableSet *operations = [NSMutableSet setWithArray:[self.taskOperations.imageLoadInProgress allKeys]];
    
    NSMutableSet *toBeCancelled = [operations mutableCopy];
    NSMutableSet *toBeStarted = [visibleRows mutableCopy];
    [toBeStarted minusSet:operations];
    [toBeCancelled minusSet:visibleRows];
    
    for (NSIndexPath *anIndexPath in toBeCancelled)
    {
        MIImageLoader *imageLoad = [self.taskOperations.imageLoadInProgress objectForKey:anIndexPath];
        [imageLoad cancel];
        [self.taskOperations.imageLoadInProgress removeObjectForKey:anIndexPath];
    }
    toBeCancelled = nil;
    
    for (NSIndexPath *anIndexPath in toBeStarted)
    {
        MIContainer *container = [self itemAtIndexPath:anIndexPath];
        if ([container thumbnail] == nil)
        {
            [self startOperationForContainer:container atIndexPath:anIndexPath];
        }
        else
        {
            [self performSelectorOnMainThread:@selector(refreshCellAtIndexPath:) withObject:anIndexPath waitUntilDone:NO];
        }
    }
    toBeStarted = nil;
}

@end
