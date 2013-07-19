//
//  DBLDeliveredViewController.m
//  DBL
//
//  Created by Tobias O'Leary on 2/23/12.
//  Copyright (c) 2012 Luck Stone. All rights reserved.
//

#import "DBLDeliveredViewController.h"
#import "DBLTicket.h"
#import "SDZTickets.h"
#import "DBLCLController.h"

@interface DBLDeliveredViewController ()

@end

@implementation DBLDeliveredViewController

int kDeliveredStatus = 2;

@synthesize delegate;
@synthesize deliveredButton;
@synthesize deliveredImageView;
@synthesize deliveredLabel;
@synthesize ticket;
@synthesize isTicketDelivered = _isTicketDelivered;


#pragma mark -
#pragma mark Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
      _isTicketDelivered = NO;
  }
  return self;
}

- (void)dealloc {
  self.delegate = nil;
  
  [ticket release];
  [deliveredLabel release];
  [deliveredImageView release];
  [delegate release];
  [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
  [self setTicket:nil];
  [self setDeliveredLabel:nil];
  [self setDeliveredImageView:nil];
  [self setDeliveredButton:nil];
  [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  [[self deliveredButton] setHidden:_isTicketDelivered];
  [[self deliveredImageView] setHidden:!_isTicketDelivered];
  [[self deliveredLabel] setHidden:!_isTicketDelivered];
  
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - 
#pragma mark IBActions

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (IBAction)ticketDelivered:(id)sender 
{

  if(_isTicketDelivered == YES) {
    return;
  }
  
  _isTicketDelivered = YES;

  
  [[self deliveredButton] setHidden:_isTicketDelivered];
  [[self deliveredImageView] setHidden:!_isTicketDelivered];
  [[self deliveredLabel] setHidden:!_isTicketDelivered];
  
  CLLocation *locationToSend = [[DBLCLController sharedCLController] lastLocation];
  SDZTickets *service = [[SDZTickets alloc] init];
  service.logging = YES;
  [service LoadedDelivered:self
                    action:@selector(handleTicketDelivered:)
                  deviceid:[APP_DELEGATE deviceId]
                      udid:[APP_DELEGATE UDID]
         delivereddatetime:[NSDate date]
                  latitude:[NSString stringWithFormat:@"%f", [locationToSend coordinate].latitude]
                 longitude:[NSString stringWithFormat:@"%f", [locationToSend coordinate].longitude]
              ticketnumber:[[self ticket] ticketNumber]
              locationcode:[NSString stringWithFormat:@"%d", [[ticket locationCode] intValue]]
                    status:kDeliveredStatus];
  
  [service release];
}


- (void) handleTicketDelivered: (id) value {
  
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
    _isTicketDelivered = NO;
    [[self deliveredButton] setHidden:_isTicketDelivered];
    [[self deliveredImageView] setHidden:!_isTicketDelivered];
    [[self deliveredLabel] setHidden:!_isTicketDelivered];
		return;
	}
  
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
    _isTicketDelivered = NO;
    [[self deliveredButton] setHidden:_isTicketDelivered];
    [[self deliveredImageView] setHidden:!_isTicketDelivered];
    [[self deliveredLabel] setHidden:!_isTicketDelivered];
		return;
	}				
  
  
	// Do something with the NSString* result
  NSString* result = (NSString*)value;
	NSLog(@"LoadedDelivered returned the value: %@", result);
  
  _isTicketDelivered = YES;
  
  [[self deliveredButton] setHidden:_isTicketDelivered];
  [[self deliveredImageView] setHidden:!_isTicketDelivered];
  [[self deliveredLabel] setHidden:!_isTicketDelivered];
  
  [self performSelector:@selector(dismissDeliveryPopover) withObject:nil afterDelay:3];
}

-(void) dismissDeliveryPopover {
  [self.delegate didClickDeliverButton];
}

@end
