//
//  PhotoAssetsViewController.m
//  MIFileManagerSample
//
//  Created by Ivan Gan on 9/6/14.
//  Copyright (c) 2014 morph85. All rights reserved.
//

#import "PhotoAssetsViewController.h"
#import <MIFileManager/manager/MIAssetsManager.h>

@interface PhotoAssetsViewController ()
@property (strong, nonatomic) MIFileManagerSource *tableSource;
@end

@implementation PhotoAssetsViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // source initialization
    self.tableSource = [[MIFileManagerSource alloc] initWithDelegate:self];
    self.tableView.backgroundColor = [UIColor orangeColor];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_tableSource clear];
    [[MIAssetsManager getInstance] getPhotoAssetsWithPhotosOnly:NO withInsertContainerBlock:^(MIContainer *container)
     {
         [_tableSource addContainer:container];
         [self.tableView reloadData];
     }];
    //    [[FileAssetsManager getInstance] getPhotoAssetGroupsWithPhotosOnly:NO withInsertContainerBlock:^(MIContainer *container)
    //    {
    //        [_tableSource addContainer:container];
    //        [self.tableView reloadData];
    //    }];
}

#pragma mark - MITableViewSource delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath withContainer:(MIContainer *)container
{
    NSLog(@"Selected");
}

#pragma mark - View

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
