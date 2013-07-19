//
//  DBLTicketViewController.h
//  DBL
//
//  Created by Ryan Emmons on 2/28/11.
//  Copyright 2011 Luck Stone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "T1Autograph.h"
#import <CoreData/CoreData.h>
#import "DBLAppDelegate.h"
#import "SDZTickets.h"
#import "DBLMapViewController.h"
#import "T1Autograph.h"
#import <QuartzCore/QuartzCore.h>
#import "DBLEmailPopoverViewController.h"
#import "DBLDeliveredViewController.h"


#import "WEPopoverController.h"
#import "LQResponseViewController.h"
#import "LQTicketNote.h"




#define SIGNATURE_WINDOW_WIDTH 700
#define SIGNATURE_WINDOW_HEIGHT 500

//Custom delegate and VC class to handle non-modal signature retrieval using T1Autograph
@protocol MyAutographDelegate <NSObject>
-(void)didClickCancel;
-(void)didClickDone;
@end

@interface AutographViewController : UIViewController {
  UILabel *disclaimer;
  UIBarButtonItem *cancelBtn;
  UIBarButtonItem *clearBtn;
  UIBarButtonItem *doneBtn;
  UIBarButtonItem *spacer;
  UIToolbar *tools;
  UIView *blank;
}

@property (retain, nonatomic) T1Autograph *myAutograph;
@property (retain, nonatomic) id<MyAutographDelegate> delegate;
@property (nonatomic, retain) UILabel *disclaimer;
@property (nonatomic, retain) UIBarButtonItem *cancelBtn;
@property (nonatomic, retain) UIBarButtonItem *clearBtn;
@property (nonatomic, retain) UIBarButtonItem *doneBtn;
@property (nonatomic, retain) UIBarButtonItem *spacer;
@property (nonatomic, retain) UIToolbar *tools;
@property (nonatomic, retain) UIView *blank;
@end


@class DBLTicket;

@interface DBLTicketViewController : UIViewController <T1AutographDelegate, UIAlertViewDelegate, EmailPopoverDelegate, DeliverDelegate, MyAutographDelegate,WEPopoverControllerDelegate,ResponseDelegate,ResponseListDelegate> {
  T1Autograph *autographModal;
  UIPopoverController *popControl;
  WEPopoverController *myPopControl;
  
  UIView      *sign_View;
  UIImageView *sig1View;
  UIImageView *sig2View;
  UIImageView *sig3View;
  UIImageView *sig4View;
  
  LQResponseViewController *vcResponse;
  LQResponseListViewController *vcResponseList;
  NSArray *notesArray;
  UIViewController *viewController;

  
}

@property (nonatomic, retain) DBLTicket *ticket;
@property (retain) T1Autograph *autographModal;
@property (nonatomic, retain) AutographViewController *autographVC;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

#pragma mark -
#pragma mark Ticket Properties Defined

//@property (nonatomic, retain) IBOutlet UILabel *copy;
@property (nonatomic, retain) IBOutlet UILabel *customerAcctNumber;
@property (nonatomic, retain) IBOutlet UITextView *customerAddress;
@property (nonatomic, retain) IBOutlet UITextView *deliveryInstructions;
@property (nonatomic, retain) IBOutlet UILabel *fuelSurcharge;
@property (nonatomic, retain) IBOutlet UILabel *grossWt;
@property (nonatomic, retain) IBOutlet UILabel *haulCharge;
@property (nonatomic, retain) IBOutlet UILabel *haulRate;
@property (nonatomic, retain) IBOutlet UILabel *haulerName;
@property (nonatomic, retain) IBOutlet UILabel *haulerNumber;
@property (nonatomic, retain) IBOutlet UILabel *jobContact;
@property (nonatomic, retain) IBOutlet UILabel *jobPhone;
@property (nonatomic, retain) IBOutlet UITextView *lotSample;
@property (nonatomic, retain) IBOutlet UILabel *maxGross;
@property (nonatomic, retain) IBOutlet UILabel *metricTonsLoadsToday;
@property (nonatomic, retain) IBOutlet UILabel *metricTonsQtyDelivered;
@property (nonatomic, retain) IBOutlet UILabel *metricTonsQtyDeliveryToday;
@property (nonatomic, retain) IBOutlet UILabel *metricTonsQtyOrdered;
@property (nonatomic, retain) IBOutlet UILabel *netTons;
@property (nonatomic, retain) IBOutlet UILabel *netTonsMetric;
@property (nonatomic, retain) IBOutlet UILabel *netWeight;
@property (nonatomic, retain) IBOutlet UILabel *orderID;
@property (nonatomic, retain) IBOutlet UITextView *plant;
@property (nonatomic, retain) IBOutlet UILabel *productCertification;
@property (nonatomic, retain) IBOutlet UILabel *productCertificationDefault;
@property (nonatomic, retain) IBOutlet UILabel *productCode;
@property (nonatomic, retain) IBOutlet UILabel *productDecscription;
@property (nonatomic, retain) IBOutlet UILabel *projectDescription;
@property (nonatomic, retain) IBOutlet UILabel *projectID;
@property (nonatomic, retain) IBOutlet UILabel *purchaseOrder;
@property (nonatomic, retain) IBOutlet UILabel *salesTax;
@property (nonatomic, retain) IBOutlet UILabel *shortTonsLoadsToday;
@property (nonatomic, retain) IBOutlet UILabel *shortTonsQtyDelivered;
@property (nonatomic, retain) IBOutlet UILabel *shortTonsQtyDeliveryToday;
@property (nonatomic, retain) IBOutlet UILabel *shortTonsQtyOrdered;
@property (nonatomic, retain) IBOutlet UITextView *specialInstructions;
@property (nonatomic, retain) IBOutlet UILabel *stonePrice;
@property (nonatomic, retain) IBOutlet UILabel *stoneRate;
@property (nonatomic, retain) IBOutlet UILabel *tareWt;
@property (nonatomic, retain) IBOutlet UILabel *ticketDate;
@property (nonatomic, retain) IBOutlet UILabel *ticketNumber;
@property (nonatomic, retain) IBOutlet UILabel *ticketTime;
@property (nonatomic, retain) IBOutlet UILabel *total;
@property (nonatomic, retain) IBOutlet UILabel *truckNumber;
@property (nonatomic, retain) IBOutlet UILabel *warning1;
@property (nonatomic, retain) IBOutlet UILabel *warning2;
@property (nonatomic, retain) IBOutlet UILabel *weightMaster;

@property (nonatomic,retain) IBOutlet  UIButton *enterNotesBtn;
@property (retain, nonatomic) IBOutlet UITextView *txtNotes;



@property (nonatomic, assign) int sigindex;



#pragma mark -
#pragma mark User Interaction Defined
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *signatureButton;
//@property (nonatomic, retain) UIImageView *signatureImageView;
@property (nonatomic, retain) UIImageView *sig1View;
@property (nonatomic, retain) UIImageView *sig2View;
@property (nonatomic, retain) UIImageView *sig3View;
@property (nonatomic, retain) UIImageView *sig4View;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *goToMapButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *deliverButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *sendAsEmail;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *viewSignature;


@property (nonatomic, retain) DBLDeliveredViewController *deliverPopover;
@property (nonatomic, retain) DBLEmailPopoverViewController* emailPopover;
@property (nonatomic, retain) UIPopoverController *popControl;
@property (nonatomic, retain) NSString *email;

- (IBAction)goToMapButtonClick;
- (IBAction)getSignatureClick;
- (IBAction)deliverButtonClick:(id)sender;
- (IBAction)sendAsEmailClick:(id)sender;
- (IBAction)viewAsSignatureClick:(id)sender;

-(IBAction)enterNotesClick:(id)sender;

@end
