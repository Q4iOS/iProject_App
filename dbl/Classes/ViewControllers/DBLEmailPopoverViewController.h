//
//  DBLEmailPopoverViewController.h
//  DBL
//
//  Created by Kelvin Quiroz on 11/19/12.
//
//

#import <UIKit/UIKit.h>
#import "DBLAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@protocol EmailPopoverDelegate <NSObject>
-(void)didClickSendEmailButton;
@end

@interface DBLEmailPopoverViewController : UIViewController
@property (retain, nonatomic) IBOutlet UITextField *emailTextField;

@property (nonatomic, assign) id<EmailPopoverDelegate> delegate;
- (IBAction)sendEmailButtonClick:(id)sender;

@end
