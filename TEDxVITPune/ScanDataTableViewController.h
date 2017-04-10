//
//  ScanDataTableViewController.h
//  TEDxVITPune
//
//  Created by Yash Gorana on 04/04/16.
//  Copyright © 2016 Yash Gorana. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ScanDataTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
