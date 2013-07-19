//
//  DBLMessagingView.h
//  DBL
//
//  Created by Ryan Emmons on 3/21/11.
//  Copyright 2011 Luck Stone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBLPopoverViewController.h"
#import "DBLMessage.h"
#import "DBLReply.h"
#import "DBLReplyType.h"
#import "SDZTickets.h"
#import "Reachability.h"
#import <QuartzCore/QuartzCore.h>
//#import "DBLAppDelegate.h"

#define REPLYTYPE_VC_CGSize CGSizeMake(350, 250)
#define POPOVER_VC_CGSize CGSizeMake(450, 265)

//Custom class and delegate for handling reply type popover view
@protocol ReplyTypeViewControllerDelegate <NSObject>
-(void)didSelectRow: (DBLReplyType *)selectedReply;
-(void)didClickBack;
@end

@interface ReplyTypeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
  UITableView *replyTypeTable;
  NSMutableArray *replyTypes;
}
@property (retain, nonatomic) UITableView *replyTypeTable;
@property (retain, nonatomic) NSMutableArray *replyTypes;
@property (retain, nonatomic) id<ReplyTypeViewControllerDelegate> delegate;

-(void)reloadReplyTypes: (NSArray*) newReplies;

@end

@interface ReplyQueue : NSObject {
  NSMutableArray *queue;
}

-(void) enqueueReply: (DBLReply *) reply;
-(DBLReply *) dequeueReply;
-(void) clearQueue;
-(BOOL) isEmpty;

@end

@interface TemporaryReply : NSObject {
  NSString * message;
  NSNumber *messageID;
  NSDate* replydatetime;
  BOOL sent;
}

@end

@interface MessageCell : UITableViewCell {
  UILabel *cellTitle;
  UIImageView *cellIcon;
}

-(void)displayIcon;
-(void)hideIcon;

@end

@class DBLAppDelegate;

@interface DBLMessagingViewController : UIViewController <MyPopoverDelegate, ReplyTypeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIAlertViewDelegate>
{
  UIPopoverController *popControl;
  Reachability* hostReach;
}

@property (retain, nonatomic) IBOutlet UILabel *dateLabel;
@property (retain, nonatomic) IBOutlet UILabel *replyHeader;
@property (retain, nonatomic) IBOutlet UITextView *messageBody;
@property (retain, nonatomic) IBOutlet UILabel *messageTitle;
@property (retain, nonatomic) IBOutlet UITableView *messageTable;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *replyButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *deleteAllButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *doneEditing;

@property (nonatomic,retain) UIPopoverController *popControl;
@property (nonatomic, retain) ReplyTypeViewController *replyTypeVC;
@property (nonatomic,retain) DBLPopoverViewController* myPopover;

@property (nonatomic, assign) BOOL isMessageSelected;
@property (nonatomic, assign) int responseType;
@property (nonatomic, retain) NSString *responseMessage;
@property (retain, nonatomic) NSMutableArray *messagesArray;
@property (retain, nonatomic) NSMutableArray *repliesArray;
@property (nonatomic, retain) UIBarButtonItem *stopTypingButton;
@property (nonatomic, retain) NSMutableArray *replyTypes;
@property (nonatomic, retain) ReplyQueue *activeReplyQueue;
@property (nonatomic, assign) BOOL checkReachableOnce;

@property (retain, nonatomic) IBOutlet UILabel *lblReplyType;
@property (retain, nonatomic) IBOutlet UITextView *txtReplyType;
@property (retain, nonatomic) IBOutlet UITextView *txtComment;
@property (retain, nonatomic) IBOutlet UILabel *lblComment;

@property (retain, nonatomic) IBOutlet UIButton *btnReload;
- (IBAction)btnReloadClick:(id)sender;

- (IBAction)doneEditing:(id)sender;
- (IBAction)replyButtonClick:(id)sender;
- (IBAction)deleteButtonClick:(id)sender;
- (IBAction)deleteAllButtonClick:(id)sender;

@end
