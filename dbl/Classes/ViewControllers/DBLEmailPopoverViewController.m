//
//  DBLEmailPopoverViewController.m
//  DBL
//
//  Created by Kelvin Quiroz on 11/19/12.
//
//

#import "DBLEmailPopoverViewController.h"

@interface DBLEmailPopoverViewController ()

@end

@implementation DBLEmailPopoverViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  [_emailTextField release];
  self.delegate = nil;
  [super dealloc];
}
- (void)viewDidUnload {
  [self setEmailTextField:nil];
  [super viewDidUnload];
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
  BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
  NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
  NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
  NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
  NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
  return [emailTest evaluateWithObject:checkString];
}

- (IBAction)sendEmailButtonClick:(id)sender {
  
  if ([self NSStringIsValidEmail:self.emailTextField.text]) {
    [self.delegate didClickSendEmailButton];
  }
  else {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Invalid e-mail" message:@"Please check to make sure the email address is correct" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
  }
}

@end
