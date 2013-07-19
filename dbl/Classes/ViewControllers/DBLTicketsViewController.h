//
//  DBLTicketsViewController.h
//  DBL
//
//  Created by Ryan Emmons on 2/23/11.
//  Copyright 2011 Luck Stone. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "PullRefreshTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Reachability.h"
#import <dispatch/dispatch.h>

@interface DBLTicketsViewController : PullRefreshTableViewController <UIAlertViewDelegate> {
  BOOL _reloading;
  Reachability *hostReach;
  dispatch_queue_t backgroundQueue;
  
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *getLatestTicketButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *getAllTicketsButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *collapseAllButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *expandAllButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) NSMutableArray *ticketsarray;
@property (nonatomic, retain) NSMutableArray *sectionrowsarray;
@property (nonatomic, retain) NSMutableArray *sectionheadersarray;
@property (nonatomic, retain) NSMutableArray *sectioncollapseflags;

- (IBAction)getLatestTicketButtonClick;
- (IBAction)getAllTicketsClick;
- (IBAction)collapseAllClick:(id)sender;
- (IBAction)expandAllClick:(id)sender;

@end

//Custom tap recognizer for managing section collapsing
@interface HeaderTap : UITapGestureRecognizer {
  int tag;
}

@property (nonatomic, assign) int tag;

@end
