//
//  DBLAvailabilityView.m
//  DBL
//
//  Created by Tobias O'Leary on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DBLStatusViewController.h"
#import "DBLAppDelegate.h"
#import "DBLTicket.h"

@interface DBLStatusViewController()

//Returns the truck number as a string
- (NSString *)truckNumberString;

@end

@implementation CustomStatusVC

@synthesize statusTextView;

-(BOOL) statusFieldIsEmpty {
  if (self.statusTextView.tag == 0 || [self.statusTextView.text length] == 0) {
    return YES;
  }
  else {
    return NO;
  }
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
  if (self.statusTextView.tag == 0) {
    [self.statusTextView setText:@""];
    [self.statusTextView setTextColor:[UIColor blackColor]];
    [self.statusTextView setTag:1];
  }
}

-(void)textViewDidEndEditing:(UITextView *)textView {
  if ([self.statusTextView.text length] == 0) {
    [self.statusTextView setText:@"Enter custom status here"];
    [self.statusTextView setTextColor:[UIColor lightGrayColor]];
    [self.statusTextView setTag:0];
  }
}

-(id)initWithWidth:(CGFloat)width andHeight:(CGFloat)height {
  [super init];
  
  statusTextView = [[UITextView alloc]initWithFrame:CGRectMake(75, 5, width-150, height-8)];
  [statusTextView setFont:[UIFont systemFontOfSize:20.0f]];
  [self.statusTextView setText:@"Enter custom status here"];
  [self.statusTextView setTextColor:[UIColor lightGrayColor]];
  [self.statusTextView setTag:0];
  
  [statusTextView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
  [statusTextView.layer setBorderWidth:2.0f];
  [statusTextView.layer setCornerRadius:10.0f];
  [statusTextView setDelegate:self];
  
  btnBack = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  //  [btnBack setImage:[UIImage imageNamed:@"whiteButton.png"] forState:UIControlStateNormal];
  [btnBack setTitle:@"Back" forState:UIControlStateNormal];
  [btnBack.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
  
  [btnBack setFrame:CGRectMake(5, 5, 65, height-8)];
  [btnBack addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
  
  btnDone = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  //  [btnDone setImage:[UIImage imageNamed:@"blueButton.png"] forState:UIControlStateNormal];
  [btnDone setTitle:@"Done" forState:UIControlStateNormal];
  [btnDone.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
  [btnDone setFrame:CGRectMake(width-70, 5, 65, height-8)];
  [btnDone addTarget:self action:@selector(doneClick) forControlEvents:UIControlEventTouchUpInside];
  
  [self.view addSubview:statusTextView];
  [self.view addSubview:btnDone];
  [self.view addSubview:btnBack];
  
  return self;
}

-(void)dealloc {
  [super dealloc];
  self.statusTextView = nil;
  self.delegate = nil;
}

-(void)viewDidUnload {
  [super viewDidUnload];
  [btnBack release];
  [btnDone release];
}

-(void) doneClick {
  [self.delegate didClickDone];
}

-(void) backClick {
  [self.delegate didClickBack];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  [self doneClick];
  //  [self performSelector:@selector(doneClick)];
  return YES;
}

@end

@implementation DBLStatusViewController
@synthesize statusImage;
@synthesize statusLabel;
@synthesize truckNumberLabel;
@synthesize deviceIDLabel;
@synthesize UDIDLabel;
@synthesize activityPopover, popControl;
@synthesize activitiesArray;
@synthesize customVC;
@synthesize statusClickedOn;

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)dealloc {
  [statusImage release];
  [statusLabel release];
  [truckNumberLabel release];
  [deviceIDLabel release];
  [UDIDLabel release];
  [_btnAvailable release];
  [_btnUnavailable release];
  [activitiesArray release];
  [customVC release];
  [_reloadServerBtn release];
  [_txtViewCurrentStatus release];
  [_txtViewSelectedStatus release];
  [_btnSelectStatus release];
  [_lblAwayStatus release];
  [_speedLimitLabel release];
  [super dealloc];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkAccessChanged) name:kReachabilityChangedNotification object:nil];
  
  [self setTitle:@"Status"];
  
  //Grab the default response and activities for our complete status window
  self.activitiesArray = [[NSMutableArray alloc]initWithArray:[self getActivitiesFromCoreData]];
  
  [self.btnAvailable setFrame:self.btnUnavailable.frame];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(handleStatusChanged:)
                                               name:NOTIFICATION_statusChange
                                             object:nil];
  
  //Setup the view controller for our popover
  activityPopover = [[DBLActivityViewController alloc]init];
  activityPopover.delegate = self;
  activityPopover.myActivities = [[NSMutableArray alloc]initWithArray:self.activitiesArray];
  //  [activityPopover.myActivities setArray:self.activitiesArray];
  
  popControl = [[UIPopoverController alloc]initWithContentViewController:activityPopover];
  
  if ([self.activitiesArray count] < 10) {
    [popControl setPopoverContentSize:CGSizeMake(350, ([self.activitiesArray count]+1) * 44)];
  }
  else {
    [popControl setPopoverContentSize:CGSizeMake(350, activityPopover.activitiesTable.frame.size.height)];
  }
  
  //UI adjustments
  [self.txtViewCurrentStatus.layer setCornerRadius:10.0f];
  [self.txtViewSelectedStatus.layer setCornerRadius:10.0f];
  
  [self.txtViewSelectedStatus setTag:0];
  [self.txtViewCurrentStatus setTag:0];
  
  //Check if there was a status declared last time this app was opened
  if ([[NSUserDefaults standardUserDefaults]boolForKey:DEFAULTS_switchStatus]) {
    //Modify the UI appropriately
    [self.lblAwayStatus setText:@"Status is On"];
    NSString *myLabel = [[NSUserDefaults standardUserDefaults]valueForKey:DEFAULTS_statusLabel];
    [self.txtViewCurrentStatus setTag:1];
    [self.txtViewCurrentStatus setText:myLabel];
  }
  else {
    [self.lblAwayStatus setText:@"Status is Off"];
  }
}

- (void)viewDidUnload
{
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:NOTIFICATION_statusChange
                                                object:nil];
  
  hostReach = nil;
  [self setActivitiesArray:nil];
  [self setStatusImage:nil];
  [self setStatusLabel:nil];
  [self setTruckNumberLabel:nil];
  [self setDeviceIDLabel:nil];
  [self setUDIDLabel:nil];
  [self setBtnAvailable:nil];
  [self setBtnUnavailable:nil];
  [self setReloadServerBtn:nil];
  
  [self setCustomVC:nil];
  [self setActivityPopover:nil];
  [self setPopControl:nil];
  
  [self setTxtViewCurrentStatus:nil];
  [self setTxtViewSelectedStatus:nil];
  [self setBtnSelectStatus:nil];
  [self setLblAwayStatus:nil];
  [self setSpeedLimitLabel:nil];
  [super viewDidUnload];
}

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  if([APP_DELEGATE status] == YES) {
    [self changeUIStatusToAvailable];
//    [self changeStatusToAvailable:self];
  } else {
    [self changeUIStatusToUnavailable];
//    [self changeStatusToUnavailable:self];
  }
  
  NSString *truckNumber = [NSString stringWithFormat:@"Truck Number: %@", [self truckNumberString]];
  [[self truckNumberLabel] setText:truckNumber];
  
  NSString *deviceId = [NSString stringWithFormat:@"Device ID: %@", [APP_DELEGATE deviceId]];
  [[self deviceIDLabel] setText:deviceId];
  
  NSString *UDID = [NSString stringWithFormat:@"UDID: %@", [APP_DELEGATE UDID]];
  [[self UDIDLabel] setText:UDID];
  
  [self changeSpeedLimitLabel];
}



-(void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  if ([[NSUserDefaults standardUserDefaults] boolForKey:DEFAULTS_switchStatus]) {
    [self changeTabBadge:YES];
  }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}


#pragma mark - availability methods

- (BOOL)statusAvailable
{
  return [APP_DELEGATE status];
}

- (IBAction)changeStatusToAvailable:(id)sender
{
  [self setStatusAvailable:YES];
  
  if (self.txtViewCurrentStatus.tag == 0) {
    [self changeTabBadge:NO];
  }
}

- (IBAction)changeStatusToUnavailable:(id)sender
{
  [self setStatusAvailable:NO];
  [self changeTabBadge:YES];
}

- (void)setStatusAvailable:(BOOL)newStatus
{
  //  [APP_DELEGATE setStatus:newStatus];
  
  if([APP_DELEGATE status] != newStatus) {
    
    int availableNumber = ([APP_DELEGATE status] ? 0 : 1);
    
    hostReach = [[Reachability reachabilityWithHostName: TICKETS_SERVICE_DOMAIN] retain];
    NetworkStatus remoteHostStatus = [hostReach currentReachabilityStatus];
    
    if (remoteHostStatus != NotReachable) {
      [[SDZTickets service] Available:self
                               action:@selector(AvailableHandler:)
                             deviceid:[APP_DELEGATE deviceId]
                                 udid:[APP_DELEGATE UDID]
                            timestamp:[NSDate date]
                            available:availableNumber];
    }
    
    else {
      NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
      DBLQueuedCall *newCall = [NSEntityDescription insertNewObjectForEntityForName:@"DBLQueuedCall" inManagedObjectContext:context];
      
      [newCall setValue:[NSDate date] forKey:@"datetime"];
      [newCall setValue:[NSNumber numberWithInt:availableNumber] forKey:@"available"];
      [newCall setValue:[NSNumber numberWithInt:VC_AVAILABLE] forKey:@"tag"];
      
      NSError *error;
      if (![context save:&error]) {
        NSLog(@"failed to store call");
      }
      
      [[NSUserDefaults standardUserDefaults] setBool:newStatus forKey:DEFAULTS_isAvailable];
      [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
  }
  
}

-(void)changeUIStatusToAvailable {
  [[self statusImage] setImage:[UIImage imageNamed:@"available"]];
  [[self statusLabel] setText:@"You're Available"];
  
  [self.btnAvailable setHidden:YES];
  [self.btnUnavailable setHidden:NO];
}

-(void)changeUIStatusToUnavailable {
  [[self statusImage] setImage:[UIImage imageNamed:@"unavailable"]];
  [[self statusLabel] setText:@"You're Unavailable"];
  
  [self.btnAvailable setHidden:NO];
  [self.btnUnavailable setHidden:YES];
}

- (void) AvailableHandler: (id) value {
  NSString* result = (NSString*)value;
  
	// Handle errors
	if([value isKindOfClass:[NSError class]] && [value isKindOfClass:[SoapFault class]]) {
		NSLog(@"AvailableHandler error: %@", value);
		return;
	}
  
  else if ([result isEqualToString:SERVER_RESPONSE_FAILURE_VALUE]) {
    UIAlertView *newAlert = [[UIAlertView alloc]initWithTitle:FAILURE_ALERT_TITLE_STATUS
                                                      message:FAILURE_ALERT_MESSAGE_STATUS
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [newAlert show];
    [newAlert release];
  }
  
  //status change request was a success, so adjust our values accordingly
  else {
    BOOL oldStatus = [[NSUserDefaults standardUserDefaults] boolForKey:DEFAULTS_isAvailable];
    [APP_DELEGATE setStatus:!oldStatus];
    [[NSUserDefaults standardUserDefaults] setBool:!oldStatus forKey:DEFAULTS_isAvailable];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (oldStatus) {
      [self changeUIStatusToUnavailable];
    }
    
    else {
      [self changeUIStatusToAvailable];
    }
  }
}

#pragma mark - status methods

- (IBAction)btnSelectStatusClick:(id)sender {
  [self.popControl presentPopoverFromRect:self.btnSelectStatus.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)btnStatusOnClick:(id)sender {
  //Check if a status is actually selected because if it isn't the user shouldn't be able to set a status
  if (self.txtViewSelectedStatus.tag == 0) {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No status selected"
                                                   message:@"Please select a status first"
                                                  delegate:self
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
    [alert show];
    [alert release];
    
  }
  
  else if ([self.txtViewCurrentStatus.text isEqualToString:self.txtViewSelectedStatus.text]) {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Cannot apply this status"
                                                   message:@"The selected status matches the current status"
                                                  delegate:self
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
    [alert show];
    [alert release];
  }
  
  else {
    hostReach = [[Reachability reachabilityWithHostName: TICKETS_SERVICE_DOMAIN] retain];
    NetworkStatus remoteHostStatus = [hostReach currentReachabilityStatus];
    self.statusClickedOn = YES;
    
    if(remoteHostStatus != NotReachable) {
      //There's a previous status that wasn't turned off, so let's send a message to turn it off first
      if ([[NSUserDefaults standardUserDefaults] boolForKey:DEFAULTS_switchStatus]) {
        NSString *oldStatus = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_statusLabel];
        
        SDZTickets *service = [[SDZTickets alloc]init];
        [service SendStatus:self
                     action:@selector(sendStatusHandler:)
                   deviceid:[APP_DELEGATE deviceId]
                       udid:[APP_DELEGATE UDID]
             statusdatetime:[NSDate date]
                     status:oldStatus
                  startstop:0];
        [service release];
      }
      
      SDZTickets *service = [[SDZTickets alloc]init];
      [service SendStatus:self
                   action:@selector(sendStatusHandler:)
                 deviceid:[APP_DELEGATE deviceId]
                     udid:[APP_DELEGATE UDID]
           statusdatetime:[NSDate date]
                   status:self.txtViewSelectedStatus.text
                startstop:1];
      [service release];
    }
    
    //Not reachable so store the call
    else {
      NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
      DBLQueuedCall *newCall = [NSEntityDescription insertNewObjectForEntityForName:@"DBLQueuedCall" inManagedObjectContext:context];
      
      //There's a previous status that wasn't turned off, so let's send a message to turn it off first
      if ([[NSUserDefaults standardUserDefaults] boolForKey:DEFAULTS_switchStatus]) {
        NSString *oldStatus = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_statusLabel];
        DBLQueuedCall *clearOldStatus = [NSEntityDescription insertNewObjectForEntityForName:@"DBLQueuedCall" inManagedObjectContext:context];
        
        [clearOldStatus setValue:[NSDate date] forKey:@"datetime"];
        [clearOldStatus setValue:[NSString stringWithString:oldStatus] forKey:@"status"];
        [clearOldStatus setValue:[NSNumber numberWithInt:0] forKey:@"startstop"];
        [clearOldStatus setValue:[NSNumber numberWithInt:VC_STATUS] forKey:@"tag"];
      }
      
      [newCall setValue:[NSDate date] forKey:@"datetime"];
      [newCall setValue:[NSString stringWithString:self.txtViewSelectedStatus.text] forKey:@"status"];
      [newCall setValue:[NSNumber numberWithInt:1] forKey:@"startstop"];
      [newCall setValue:[NSNumber numberWithInt:VC_STATUS] forKey:@"tag"];
      
      NSError *error;
      if (![context save:&error]) {
        NSLog(@"failed to store call");
        return;
      }
    
    [self.lblAwayStatus setText:@"Status is On"];
    [self changeTabBadge:YES];
    [self.txtViewCurrentStatus setText:self.txtViewSelectedStatus.text];
    [self.txtViewCurrentStatus setTag:1];
    
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:DEFAULTS_switchStatus];
    [[NSUserDefaults standardUserDefaults]setValue:self.txtViewSelectedStatus.text forKey:DEFAULTS_statusLabel];
    [[NSUserDefaults standardUserDefaults]synchronize];
    }
  }
}

- (IBAction)btnStatusOffClick:(id)sender {
  if (self.txtViewCurrentStatus.tag == 0) {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No current status declared"
                                                   message:@"There is no current status to turn off"
                                                  delegate:self
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
    [alert show];
    [alert release];
    
  }
  
  else {
    hostReach = [[Reachability reachabilityWithHostName: TICKETS_SERVICE_DOMAIN] retain];
    NetworkStatus remoteHostStatus = [hostReach currentReachabilityStatus];
    self.statusClickedOn = NO;
    
    if(remoteHostStatus != NotReachable) {
      SDZTickets *service = [[SDZTickets alloc]init];
      [service SendStatus:self
                   action:@selector(sendStatusHandler:)
                 deviceid:[APP_DELEGATE deviceId]
                     udid:[APP_DELEGATE UDID]
           statusdatetime:[NSDate date]
                   status:self.txtViewCurrentStatus.text
                startstop:0];
      [service release];
    }
    
    else {
      NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
      DBLQueuedCall *newCall = [NSEntityDescription insertNewObjectForEntityForName:@"DBLQueuedCall" inManagedObjectContext:context];
      
      [newCall setValue:[NSDate date] forKey:@"datetime"];
      [newCall setValue:[NSString stringWithString:self.txtViewCurrentStatus.text] forKey:@"status"];
      [newCall setValue:[NSNumber numberWithInt:1] forKey:@"startstop"];
      [newCall setValue:[NSNumber numberWithInt:VC_STATUS] forKey:@"tag"];
      
      NSError *error;
      if (![context save:&error]) {
        NSLog(@"failed to store call");
      }
      
      if ([self statusAvailable]) {
        [self changeTabBadge:NO];
      }
      
      [self.lblAwayStatus setText:@"Status is Off"];
      [self.txtViewCurrentStatus setText:@"No current status."];
      [self.txtViewCurrentStatus setTag:0];
      
      [[NSUserDefaults standardUserDefaults]setBool:NO forKey:DEFAULTS_switchStatus];
      [[NSUserDefaults standardUserDefaults]setValue:@"" forKey:DEFAULTS_statusLabel];
      [[NSUserDefaults standardUserDefaults]synchronize];
    }
  }
}

-(void)sendStatusHandler: (id) value {
  NSString *result = (NSString *) value;
  
  if([value isKindOfClass:[NSError class]] || [value isKindOfClass:[SoapFault class]]) {
    NSLog(@"Send status error: %@", value);
		return;
	}
  
  else if ([result isEqualToString:SERVER_RESPONSE_FAILURE_VALUE]) {
    UIAlertView *newAlert = [[UIAlertView alloc]initWithTitle:@"Could not connect to server"
                                                      message:@"The server might be down. Please try again later."
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [newAlert show];
    [newAlert release];
  }
  else {
    
    if (self.statusClickedOn) {
    [self.lblAwayStatus setText:@"Status is On"];
    [self changeTabBadge:YES];
    [self.txtViewCurrentStatus setText:self.txtViewSelectedStatus.text];
    [self.txtViewCurrentStatus setTag:1];
    
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:DEFAULTS_switchStatus];
    [[NSUserDefaults standardUserDefaults]setValue:self.txtViewSelectedStatus.text forKey:DEFAULTS_statusLabel];
    [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    else {
      if ([self statusAvailable]) {
        [self changeTabBadge:NO];
      }
      
      [self.lblAwayStatus setText:@"Status is Off"];
      [self.txtViewCurrentStatus setText:@"No current status."];
      [self.txtViewCurrentStatus setTag:0];
      
      [[NSUserDefaults standardUserDefaults]setBool:NO forKey:DEFAULTS_switchStatus];
      [[NSUserDefaults standardUserDefaults]setValue:@"" forKey:DEFAULTS_statusLabel];
      [[NSUserDefaults standardUserDefaults]synchronize];
    }
  }
}

#pragma mark - heper functions

-(void)networkAccessChanged {
  hostReach = [[Reachability reachabilityWithHostName: TICKETS_SERVICE_DOMAIN] retain];
  NetworkStatus remoteHostStatus = [hostReach currentReachabilityStatus];
  
  NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLQueuedCall" inManagedObjectContext:context];
  
  [fetchRequest setEntity:entity];
  NSError *error;
  NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
  [fetchRequest release];
  
  if (remoteHostStatus != NotReachable ) {
    
    //add a 5 second delay before making queued webservice calls so the connection can become more stable, 5 seconds is arbitrary
    int64_t delayInSeconds = 5.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
      
      for (DBLQueuedCall *storedCall in fetchedObjects) {
        NSError *error;
        
        //Check reachability in each case just to make sure we can still send the message at that point
        switch ([[storedCall valueForKey:@"tag"] intValue]) {
          case VC_AVAILABLE:
            if(remoteHostStatus != NotReachable) {
              
              SDZTickets *service = [[SDZTickets alloc]init];
              [service Available:self
                          action:@selector(AvailableHandler:)
                        deviceid:[APP_DELEGATE deviceId]
                            udid:[APP_DELEGATE UDID]
                       timestamp:[storedCall valueForKey:@"datetime"]
                       available:[[storedCall valueForKey:@"available"] intValue]];
              [service release];
              
              //Delete the webservice call upon completion
              [context deleteObject:storedCall];
              if (![context save:&error]) {
                NSLog(@"Error deleting webservice call");
              }
            }
            break;
            
          case VC_STATUS:
            if(remoteHostStatus != NotReachable) {
              
              SDZTickets *service = [[SDZTickets alloc]init];
              [service SendStatus:self
                           action:@selector(sendStatusHandler:)
                         deviceid:[APP_DELEGATE deviceId]
                             udid:[APP_DELEGATE UDID]
                   statusdatetime:[storedCall valueForKey:@"datetime"]
                           status:[storedCall valueForKey:@"status"]
                        startstop:[[storedCall valueForKey:@"startstop"] intValue]];
              [service release];
              
              [context deleteObject:storedCall];
              if (![context save:&error]) {
                NSLog(@"Error deleting webservice call");
              }
            }
            break;
            
          default:
            break;
        }
      }
    });
  }
}

-(void) changeTabBadge: (BOOL) flag {
  //Use explicit tabBarController indexing vs [self tabBarItem] since explicit works in the case of viewDid/WillDisappear cases
  
  if (flag) {
    [[[[[self tabBarController] tabBar] items]
      objectAtIndex:6] setBadgeValue:@"    "];
  }
  else {
    [[[[[self tabBarController] tabBar] items]
      objectAtIndex:6] setBadgeValue:nil];
  }
}

-(void)changeSpeedLimitLabel {
  if ([[APP_DELEGATE speedLimit] intValue] != SPEEDLIMIT_MAX) {
    NSString *speedLimit = [NSString stringWithFormat:@"Speed Limit: %d MPH", [[APP_DELEGATE speedLimit] intValue]];
    [[self speedLimitLabel] setText:speedLimit];
  }
  else {
    //This happens when the speedlimit setting is set to 0
    NSString *speedLimit = @"Speed Limit: Error. Press reload at the bottom of the screen.";
    [[self speedLimitLabel] setText:speedLimit];
  }
}

#pragma mark - coredata functions

- (IBAction)reloadServerInfo:(id)sender {
  [self.reloadServerBtn setEnabled:NO];
  [self.btnSelectStatus setEnabled:NO];
  [self.reloadServerBtn setTitle:@"Reloading..." forState:UIControlStateDisabled];
  
  [popControl setContentViewController:activityPopover];
  
  [APP_DELEGATE reloadStatusesFromServer];
  
  [self performSelector:@selector(delayedReload) withObject:nil afterDelay:1.0];
}

-(void)delayedReload {
  [self changeSpeedLimitLabel];
  NSArray *newActivities = [[NSArray alloc]initWithArray:[self getActivitiesFromCoreData]];
  [self.activitiesArray setArray:newActivities];
  
  [self.activityPopover.myActivities setArray:self.activitiesArray];
  [newActivities release];
  [activityPopover.activitiesTable reloadData];
  
  if ([self.activitiesArray count] < 10) {
    [popControl setPopoverContentSize:CGSizeMake(350, ([self.activitiesArray count]+1) * 44)];
  }
  else {
    [popControl setPopoverContentSize:CGSizeMake(350, activityPopover.activitiesTable.frame.size.height)];
  }
  
  [self.reloadServerBtn setEnabled:YES];
  [self.btnSelectStatus setEnabled:YES];
}

-(NSArray *) getActivitiesFromCoreData {
  NSError *error;
  NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLActivity" inManagedObjectContext:context];
  [fetchRequest setEntity:entity];
  
  NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
  [fetchRequest release];
  
  NSSortDescriptor *sortDescriptor;
  sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"index"
                                                ascending:YES] autorelease];
  NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
  NSArray *sortedArray;
  sortedArray = [fetchedObjects sortedArrayUsingDescriptors:sortDescriptors];
  
  return sortedArray;
}

- (void)handleStatusChanged:(NSNotification*)notification
{
  if([self statusAvailable] == YES) {
    [self changeUIStatusToAvailable];
//    [self changeStatusToAvailable:self];
  } else {
    [self changeUIStatusToUnavailable];
//    [self changeStatusToUnavailable:self];
  }
}



#pragma mark - popover delegate functions

-(void)selectedCustomRow {
  //User selected "custom status" so change the view of the popover
  CGFloat popoverWidth = 560.0f;
  CGFloat popoverHeight = 80.0f;
  
  [self.popControl setPopoverContentSize:CGSizeMake(popoverWidth, popoverHeight) animated:YES];
  
  self.customVC = [[CustomStatusVC alloc]initWithWidth:popoverWidth andHeight:popoverHeight];
  [self.customVC.view setBackgroundColor:[UIColor whiteColor]];
  self.customVC.delegate = self;
  [popControl setContentViewController:self.customVC animated:YES];
}

-(void)didClickBack {
  //User hit cancel in the custom status message so back to the first popover screen
  if ([self.activitiesArray count] < 10) {
    [popControl setPopoverContentSize:CGSizeMake(350, ([self.activitiesArray count]+1) * 44)];
  }
  else {
    [popControl setPopoverContentSize:CGSizeMake(350, activityPopover.activitiesTable.frame.size.height)];
  }
  [popControl setContentViewController:activityPopover];
}

-(void)didClickDone {
  if ([self.customVC statusFieldIsEmpty]) {
    UIAlertView *newAlert = [[UIAlertView alloc]initWithTitle:@"No status entered"
                                                      message:@"Please fill in the custom status message box or hit back."
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [newAlert show];
    [newAlert release];
  }
  
  else {
    [self.popControl dismissPopoverAnimated:YES];
    [self.txtViewSelectedStatus setText:self.customVC.statusTextView.text];
    [self.txtViewSelectedStatus setTag:1];
  }
}

-(void)didSelectRow {
  [self.popControl dismissPopoverAnimated:YES];
  
  DBLActivity *temp = [self.activitiesArray objectAtIndex:
                       self.activityPopover.activitiesTable.indexPathForSelectedRow.row];
  [self.txtViewSelectedStatus setText:temp.label];
  [self.txtViewSelectedStatus setTag:1];
}


- (NSString *)truckNumberString
{
  //Lookup a ticket from core data and grab the truck number from that ticket.
  NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLTicket"
                                            inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
  NSError *error = nil;
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
  [fetchRequest release];
  
  if([fetchedObjects count] <= 0) {
    return @"Undetermined - No Tickets";
  } else {
    DBLTicket *ticket = [fetchedObjects objectAtIndex:0];
    return [ticket truckNumber];
  }
}


@end
