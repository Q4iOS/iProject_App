//
//  DBLPopoverViewController.m
//  DBL
//
//  Created by Kelvin Quiroz on 11/15/12.
//
//

#import "DBLPopoverViewController.h"

@interface DBLPopoverViewController ()

@end

@implementation DBLPopoverViewController

@synthesize delegate;
@synthesize myReplyTypes;

-(void)textViewDidBeginEditing:(UITextView *)textView {
  if ([self emptyText]) {
    [self.commentTextView setText:@""];
    [self.commentTextView setTextColor:[UIColor blackColor]];
    [self.commentTextView setTag:1];
  }
}

-(void)textViewDidEndEditing:(UITextView *)textView {
  if ([self.commentTextView.text length] == 0) {
    [self resetText];
  }
}

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
  
  [self resetText];
  
  [self.commentTextView.layer setCornerRadius:10.0f];
  [self.commentTextView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
  [self.commentTextView.layer setBorderWidth:2.0f];
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  self.delegate = nil;
  [_selectType release];
  [_commentTextView release];
  [_commentTextView release];
  [super dealloc];
}

- (void)viewDidUnload {
  self.myReplyTypes = nil;
  [self setSelectType:nil];
  [self setCommentTextView:nil];
  [self setCommentTextView:nil];
  [super viewDidUnload];
}

- (IBAction)sendReplyButton:(id)sender {
  [self.delegate didClickSendButton];
}

- (IBAction)selectTypeClick:(id)sender {
  [self.delegate didSelectType];
}

-(void) resetView {
  [self.selectType setTitle:@"Select reply type" forState:UIControlStateNormal];
  [self resetText];
}

-(void) resetText {
  [self.commentTextView setText:DEFAULT_TEXT_FIELD_STRING];
  [self.commentTextView setTextColor:[UIColor lightGrayColor]];
  [self.commentTextView setTag:0];
}

-(void) resetTags {
  [self.commentTextView setTag:0];
  [self.selectType setTag:0];
}

-(BOOL) emptyText {
  return ([self.commentTextView.text length] == 0 || [self.commentTextView.text isEqualToString: DEFAULT_TEXT_FIELD_STRING]);
}

@end
