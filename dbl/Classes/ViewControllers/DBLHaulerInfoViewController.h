//
//  DBLHaulerInfoViewController.h
//  DBL
//
//  Created by Ryan Emmons on 3/21/11.
//  Copyright 2011 Luck Stone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SDZTickets.h"
#import "DBLAppDelegate.h"
#import "CKCalendarView.h"
#import <QuartzCore/QuartzCore.h>

@protocol MonthlyPopoverDelegate <NSObject>
-(void)clickedSelect: (NSDate*) newDate;
-(void)clickedCancel;
@end

@interface MonthlyPopover : UIViewController {
  UIDatePicker *monthPicker;
  UIButton *btnCancel;
  UIButton *btnSelect;
}

@property (retain, nonatomic) id<MonthlyPopoverDelegate> delegate;

-(void)setPickerDate: (NSDate *)newDate;

@end

@interface DBLHaulerInfoViewController : UIViewController <CKCalendarDelegate, MonthlyPopoverDelegate, UIPopoverControllerDelegate>

#pragma mark -
#pragma mark User Interaction Defined
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) IBOutlet UILabel *totalTonsToday;
@property (nonatomic, retain) IBOutlet UILabel *totalHaulRate;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic, retain) IBOutlet UILabel *totalFSCToday;

@property (nonatomic, retain) CKCalendarView *myCalendar;
@property (retain, nonatomic) IBOutlet UISegmentedControl *sgmntSelectType;
@property (retain, nonatomic) IBOutlet UILabel *lblSelectedDate;
@property (retain, nonatomic) IBOutlet UILabel *lblDateHeader;
@property (retain, nonatomic) NSDate *selectedDate;
@property (assign, nonatomic) NSInteger previousIndex;

@property (retain, nonatomic) MonthlyPopover *myMonthlyPopover;
@property (nonatomic,retain) UIPopoverController *popControl;

- (IBAction)refreshButtonClick:(id)sender;
- (IBAction)sgmntValueChanged:(id)sender;

@end
