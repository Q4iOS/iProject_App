//
//  DBLScheduleViewController.h
//  DBL
//
//  Created by Ryan Emmons on 5/26/11.
//  Copyright 2011 Luck Stone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "DBLMapViewController.h"
#import "PullRefreshTableViewController.h"
#import "Reachability.h"

@interface DBLScheduleViewController : PullRefreshTableViewController <UIAlertViewDelegate> {
  Reachability *hostReach;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *getLatestScheduleButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) NSMutableArray *schedulearray;
@property (nonatomic, retain) NSMutableArray *sectionheadersarray;
@property (nonatomic, retain) NSMutableArray *sectionrowsarray;
@property (nonatomic, retain) UIView *disablingView;
@property (nonatomic, retain) UITextField *myDeviceID;

//core data add ons//
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
/////////////////////

- (IBAction)getLatestScheduleButtonClick:(id)sender;

@end

