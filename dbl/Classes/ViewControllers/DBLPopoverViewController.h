//
//  DBLPopoverViewController.h
//  DBL
//
//  Created by Kelvin Quiroz on 11/15/12.
//
//
// This popover is for replies

#import <UIKit/UIKit.h>
#import "DBLAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

#define DEFAULT_TEXT_FIELD_STRING @"Enter additional comment here"

@protocol MyPopoverDelegate <NSObject>
-(void)didClickSendButton;
-(void)didSelectType;
@end

@class DBLMessagingViewController;

@interface DBLPopoverViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, assign) id<MyPopoverDelegate> delegate;
@property (retain, nonatomic) IBOutlet UITextView *commentTextView;

@property (retain, nonatomic) NSArray *myReplyTypes;
@property (retain, nonatomic) IBOutlet UIButton *selectType;

- (IBAction)selectTypeClick:(id)sender;
- (IBAction)sendReplyButton:(id)sender;

-(void) resetView;
-(void) resetTags;
-(BOOL) emptyText;

@end
