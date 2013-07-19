//
//  DBLAvailabilityView.h
//  DBL
//
//  Created by Tobias O'Leary on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDZTickets.h"
#import "DBLActivityViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Reachability.h"
#import "DBLQueuedCall.h"
#import <dispatch/dispatch.h>

#pragma mark - Definitions for VC that controls entering custom status through popovers
@protocol CustomStatusDelegate <NSObject>
-(void)didClickBack;
-(void)didClickDone;
@end

@interface CustomStatusVC : UIViewController <UITextFieldDelegate, UITextViewDelegate> {
  UITextView *statusTextView;
  UIButton *btnBack;
  UIButton *btnDone;
}

@property (retain, nonatomic) id<CustomStatusDelegate> delegate;
@property (nonatomic, retain) UITextView *statusTextView;

-(BOOL) statusFieldIsEmpty;

@end


@interface DBLStatusViewController : UIViewController <ActivityDelegate, CustomStatusDelegate, UITabBarControllerDelegate> {
  Reachability* hostReach;
}

//status related IBOutlets elements
@property (retain, nonatomic) IBOutlet UIButton *reloadServerBtn;
@property (retain, nonatomic) IBOutlet UITextView *txtViewCurrentStatus;
@property (retain, nonatomic) IBOutlet UITextView *txtViewSelectedStatus;
@property (retain, nonatomic) IBOutlet UIButton *btnSelectStatus;
@property (retain, nonatomic) IBOutlet UILabel *lblAwayStatus;

//availability related IBOutlets elements
@property (retain, nonatomic) IBOutlet UIImageView *statusImage;
@property (retain, nonatomic) IBOutlet UIButton *btnAvailable;
@property (retain, nonatomic) IBOutlet UIButton *btnUnavailable;


@property (retain, nonatomic) IBOutlet UILabel *statusLabel;
@property (retain, nonatomic) IBOutlet UILabel *truckNumberLabel;
@property (retain, nonatomic) IBOutlet UILabel *deviceIDLabel;
@property (retain, nonatomic) IBOutlet UILabel *UDIDLabel;
@property (retain, nonatomic) IBOutlet UILabel *speedLimitLabel;

@property (nonatomic, retain) UIPopoverController *popControl;
@property (nonatomic, retain) DBLActivityViewController* activityPopover;
@property (nonatomic, retain) NSMutableArray *activitiesArray;
@property (nonatomic, retain) CustomStatusVC *customVC;
@property (nonatomic, assign) BOOL statusClickedOn;

- (BOOL)statusAvailable;
- (void)setStatusAvailable:(BOOL)newStatus;

//status related IBActions
- (IBAction)reloadServerInfo:(id)sender;
- (IBAction)btnSelectStatusClick:(id)sender;
- (IBAction)btnStatusOnClick:(id)sender;
- (IBAction)btnStatusOffClick:(id)sender;

//availability related IBActions
- (IBAction)changeStatusToAvailable:(id)sender;
- (IBAction)changeStatusToUnavailable:(id)sender;


@end

