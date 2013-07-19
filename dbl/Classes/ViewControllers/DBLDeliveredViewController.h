//
//  DBLDeliveredViewController.h
//  DBL
//
//  Created by Tobias O'Leary on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBLAppDelegate.h"

@class DBLTicket;

@protocol DeliverDelegate <NSObject>
-(void)didClickDeliverButton;
@end

@interface DBLDeliveredViewController : UIViewController

@property (retain, nonatomic) id<DeliverDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIButton *deliveredButton;
@property (retain, nonatomic) IBOutlet UIImageView *deliveredImageView;
@property (retain, nonatomic) IBOutlet UILabel *deliveredLabel;
@property (assign, nonatomic) BOOL isTicketDelivered;

@property (retain, nonatomic) DBLTicket *ticket;


- (IBAction)ticketDelivered:(id)sender;

@end
