//
//  DBLActivityViewController.h
//  DBL
//
//  Created by Kelvin Quiroz on 11/19/12.
//
//

#import <UIKit/UIKit.h>
#import "DBLAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "DBLTicketsViewController.h"

@protocol ActivityDelegate <NSObject>
-(void)didSelectRow;
-(void)selectedCustomRow;
@end

@class DBLStatusViewController;
@class CustomStatusVC;

@interface DBLActivityViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) id<ActivityDelegate> delegate;
@property (retain, nonatomic) IBOutlet UITableView *activitiesTable;
@property (retain, nonatomic) NSMutableArray *myActivities;
//@property (retain, nonatomic) CustomStatusVC *lastCell;

@end
