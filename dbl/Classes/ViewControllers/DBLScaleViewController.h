//
//  DBLScaleViewController.h
//  DBL
//
//  Created by Tobias O'Leary on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

typedef enum DBLWeighingType {
    DBLWeighingUnknown = -1,
    DBLWeighingTare = 0,
    DBLWeighingTicket = 1,
} DBLWeighingType;

@class DEBUG_DBLTareService;

@interface DBLScaleViewController : UIViewController
{
  DEBUG_DBLTareService *_service;
}

//Internal Properties
@property (retain, nonatomic) NSString *priorityScaleNumber;
@property (assign, nonatomic) DBLWeighingType selectedWeighingType;

//Interface
@property (retain, nonatomic) IBOutlet UILabel *plantNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *scaleNumberLabel;
@property (retain, nonatomic) IBOutlet UISegmentedControl *scaleSegmentedControl;
@property (retain, nonatomic) IBOutlet UIButton *tareButton;
@property (retain, nonatomic) IBOutlet UIButton *ticketButton;
@property (retain, nonatomic) IBOutlet UIButton *submitButton;
@property (retain, nonatomic) IBOutlet UIButton *resetButton;
@property (retain, nonatomic) IBOutlet UILabel *messageLabel;

//Actions
- (IBAction)weighingButtonTapped:(id)sender;
- (IBAction)submitButtonTapped:(id)sender;
- (IBAction)resetButtonTapped:(id)sender;




@end
