//
//  NetworkImagesViewControllerTableViewController.m
//  MIFileManagerSample
//
//  Created by morph85 on 9/6/14.
//  Copyright (c) 2014 morph85. All rights reserved.
//

#import "NetworkImagesViewControllerTableViewController.h"

@interface NetworkImagesViewControllerTableViewController ()
@property (strong, nonatomic) MIFileManagerSource *tableSource;
@end

@implementation NetworkImagesViewControllerTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // source initialization
    self.tableSource = [[MIFileManagerSource alloc] initWithDelegate:self];
    self.tableView.backgroundColor = [UIColor orangeColor];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // initialize through storyboard
    MIContainer *item1 = [[MIContainer alloc] init];
    [item1 setLabel:@"item 1: tiger"];
    [item1 setUrl:[NSURL URLWithString:@"http://www.jattyouth.com/photobyusers/data/Animals/501933a6111c2.jpg"]];
    
    MIContainer *item2 = [[MIContainer alloc] init];
    [item2 setLabel:@"item 2: giraffe"];
    [item2 setUrl:[NSURL URLWithString:@"http://images.fanpop.com/images/image_uploads/giraffe-animals-172255_500_750.jpg"]];
    
    MIContainer *item3 = [[MIContainer alloc] init];
    [item3 setLabel:@"item 3: cat"];
    [item3 setUrl:[NSURL URLWithString:@"http://hellogiggles.com/wp-content/uploads/2012/03/23/cute-animals-1.jpg"]];
    
    NSArray *container = [NSArray arrayWithObjects:item1, item2, item3, nil];
    [self.tableSource setContainers:container];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.tableSource.taskOperations cancelAllOperations:TASK_IMAGE_LOAD];
}

#pragma mark - MITableViewDelegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath withContainer:(MIContainer *)container
{
    NSLog(@"%@ selected...", [container label]);
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
