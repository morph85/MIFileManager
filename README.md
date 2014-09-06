# MIFileManagerSource

MIFileManagerSource is an iOS class that facilitate image loader using NSOperationQueue. It can be used by initialize MIFileManagerSource in UITableView, or UITableViewController.

## Requirements

MIFileManagerSource works on any iOS version and is compatible with only ARC project (some tweaks/fixes required). It depends on the following Apple frameworks, which should already be included with most Xcode templates:

* Foundation.framework
* UIKit.framework

## Adding MIFileManagerSource to your project

### Source files

Alternatively you can directly add the `MIFileManagerSource.h` and `MIFileManagerSource.m` source files to your project.

1. Download the [latest code version](https://github.com/morph85/MIFileManager/archive/master.zip) or add the repository as a git submodule to your git-tracked project.
2. Open your project in Xcode, than drag and drop files in TableSource group onto your project (use the "Product Navigator view"). Make sure to select Copy items when asked if you extracted the code archive outside of your project. 
3. Include MITableViewSource wherever you need it with `#import "MIFileManagerSource.h"`.

## Usage

First, inherit MIFileManagerSourceDelegate in UITableView or UITableViewController.

For UITableView, implement this in init function.
For UITableViewController, implement this in ViewDidLoad function.

```objective-c
self.tableSource = [[MIFileManagerSource alloc] initWithDelegate:self];
    
// data initialization
self.tableView.dataSource = self.tableSource;
self.tableView.delegate = self.tableSource;

// UI initialization
self.tableView.backgroundColor = [UIColor orangeColor];
self.tableView.separatorColor = [UIColor clearColor];
self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
```

For UITableView and UITableViewController, implement this in ViewDidLoad function.

```objective-c
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
[self.tableSource setItems:container];
```

## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE).
This code is modified using code/technique introduced in http://www.raywenderlich.com/19788/how-to-use-nsoperations-and-nsoperationqueues.

## Change-log

**Version 0.3** @ 06.09.14

Update and refactoring.
- Converted project becoming static library.
- Updated to remove coupling between files.

**Version 0.2** @ 26.03.13

Support UITableView and UITableViewController delegate and data source for flexible loading.
- Renamed MITableView to MITableViewSource.
- Detached MITableView implementation to MITableSource object to
support MITableView Controller (decoupled code).
- Refactored structure and code.

**Version 0.1** @ 24.03.13

- Initial release.