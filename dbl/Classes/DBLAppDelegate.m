//
//  DBLAppDelegate.m
//  DBL
//
//  Created by Ryan Emmons on 3/4/11.
//  Copyright 2011 Luck Stone. All rights reserved.
//

#import "DBLAppDelegate.h"
#import "DBLTicketsViewController.h"
#import "DBLCLController.h"
#import "DBLTaskManager.h"
#import "DBLWindow.h"
#import "DBLMessage.h"

#import "DBLSignatureManager.h"

#import <AudioToolbox/AudioToolbox.h>

@implementation MessageAlertView

@synthesize messageType;
@synthesize messageID;

-(id) init {
  [super init];
  
  //THE TAG PROPERTY ON MESSAGEALERTVIEW SHOULD NEVER BE
  self.tag = ALERT_MESSAGE;
  return self;
}

@end

@implementation DBLAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize taskManager;
@synthesize alertBeingDisplayed;
@synthesize messages;
@synthesize setupVC, deviceIDField;

@synthesize signatureManager = _signatureManager;
@synthesize responsesArray, activitiesArray;

#pragma mark -
#pragma mark Object lifecycle

- (void)dealloc {
  [_signatureManager release];
  [alertBeingDisplayed release];
  [taskManager release];
  [tabBarController release];
  [window release];
	[managedObjectContext release];
	[managedObjectModel release];
	[persistentStoreCoordinator release];
  [messages release];
  [responsesArray release];
  [activitiesArray release];
  [setupVC release];
  [super dealloc];
}

#pragma mark -
#pragma mark Application lifecycle

-(void)newMessageReceived {
  hasNewMessage = YES;
}

-(void)applicationDidBecomeActive:(UIApplication *)application{
  //Always synchronize this app with the stored defaults whenever the app is active
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  //Check if location services are off or if this app doesn't have access to them
  if(![CLLocationManager locationServicesEnabled] ||
     [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
    
    //Send a message to lock the app if so
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_locationServicesOff
                                                        object:nil];
  }
  
  if (hasNewMessage) {
    UIAlertView *newAlert = [[UIAlertView alloc]initWithTitle:@"You have pending messages" message:@"Please read them as soon as possible." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [newAlert show];
    [newAlert release];
    
    hasNewMessage = NO;
  }
}

-(void)applicationDidEnterBackground:(UIApplication *)application {
  
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  hasNewMessage = NO;
  
  //IMMEDIATELY CHECK TO MAKE SURE THE SDZTickets serviceUrl is equal to the TICKETS_SERVICE_URL constant
  SDZTickets* service = [SDZTickets service];
  
  NSAssert([[service serviceUrl] isEqualToString:TICKETS_SERVICE_URL],
           @"SDZTickets serviceUrl should be equal to TICKETS_SERVICE_URL. (%@) != (%@)",
           [service serviceUrl], TICKETS_SERVICE_URL);
  
  //Set default values for preferences
  NSDictionary *appDefaults = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:DEFAULTS_isAvailable];
  [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
  
  //Dirty way to check if a previous version was installed and setup
  if ([[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_deviceID] != nil) {
    
    //This app is in the most updated state and has ran at least once already
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DEFAULTS_hasLaunchedOnce]) {
      [self goToMain];
    }
    
    //Need to get some server information and set our launch flag
    else {
      [self getRepliesFromServer];
      [self getStatusesFromServer];
      [self getSpeedLimitFromServer];
      [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DEFAULTS_hasLaunchedOnce];
      [[NSUserDefaults standardUserDefaults] synchronize];
      [self goToMain];
    }
  }
  
  //Clean install scenario
  else {
    //Make a quick view controller for our setup screen
    
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    self.vcStartup = [[UIViewController alloc]init];
    
    [self.vcStartup.view setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
    
    UILabel *header = [[UILabel alloc]initWithFrame:CGRectMake((appFrame.size.width/2)-340, 20, 680, 200)];
    [header setText:@"This appears to be your first time running this app. Please take a moment to enter the following information:"];
    [header setTextAlignment:NSTextAlignmentCenter];
    [header setTextColor:[UIColor whiteColor]];
    [header setFont:[UIFont boldSystemFontOfSize:25.0f]];
    [header setBackgroundColor:[UIColor clearColor]];
    [header setNumberOfLines:0];
    
    UILabel *deviceLabel = [[UILabel alloc]initWithFrame:CGRectMake((appFrame.size.width/2)-200, 375, 400, 25)];
    [deviceLabel setText:@"Device ID:"];
    [deviceLabel setTextAlignment:NSTextAlignmentLeft];
    [deviceLabel setTextColor:[UIColor whiteColor]];
    [deviceLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [deviceLabel setBackgroundColor:[UIColor clearColor]];
    
    //Text field for deviceID
    self.deviceIDField = [[UITextField alloc]init];
    [self.deviceIDField setPlaceholder:@"Enter your device ID"];
    [self.deviceIDField setDelegate:self];
    [self.deviceIDField setFrame:CGRectMake((appFrame.size.width/2)-200, 400, 400, 31)];
    [self.deviceIDField setBorderStyle:UITextBorderStyleRoundedRect];
    
    UIButton *continueBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [continueBtn addTarget:self action:@selector(continueClick) forControlEvents:UIControlEventTouchUpInside];
    [continueBtn setFrame:CGRectMake((appFrame.size.width/2)-150, 600, 300, 44)];
    [continueBtn setTitle:@"Continue" forState:UIControlStateNormal];
    
    
    [self.vcStartup.view addSubview:self.deviceIDField];
    [self.vcStartup.view addSubview:continueBtn];
    [self.vcStartup.view addSubview:header];
    [self.vcStartup.view addSubview:deviceLabel];
    
    [header release];
    [deviceLabel release];
    
    [self.window addSubview:self.vcStartup.view];
    [self.window makeKeyAndVisible];
    [(DBLWindow *) [self window] windowDidLoad];
  }
  
  [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
  
  return YES;
}

-(void)continueClick{
  //Validate the deviceIDField string to check if it's not empty
  
  NSString *value = self.deviceIDField.text;
  if ([value length] > 0) {
    [self.setupVC.view endEditing:YES];
    [self.window endEditing:YES];
    
    //Set our device ID field in settings
    [[NSUserDefaults standardUserDefaults] setValue:self.deviceIDField.text forKey:DEFAULTS_deviceID];
    self.deviceIDField = nil;
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DEFAULTS_hasLaunchedOnce];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.setupVC.view removeFromSuperview];
    self.setupVC = nil;
    
    //Grab default values from the server for later use
    
    [self getStatusesFromServer];
    [self getRepliesFromServer];
    [self getSpeedLimitFromServer];
    
    
    //Initialize some more userdefaults values
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:DEFAULTS_switchStatus];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:DEFAULTS_statusLabel];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [self.vcStartup.view removeFromSuperview];
    self.vcStartup = nil;
    [self.vcStartup release];
    
    [self goToMain];
  }
  
  else {
    UIAlertView *newAlert = [[UIAlertView alloc]initWithTitle:@"No device ID entered" message:@"Please enter your device ID" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [newAlert setTag:ALERT_SETUP];
    [newAlert show];
    [newAlert release];
  }
  
}

-(void)goToMain {
  
  isLoadingTickets = NO;
  
  // Add the tab bar controller's current view as a subview of the window
  DBLTicketsViewController *dblTicketsViewController = [[DBLTicketsViewController alloc] initWithStyle:UITableViewStylePlain];
  
  NSMutableArray *messagesArray = [[NSMutableArray alloc] init];
  [self setMessages:messagesArray];
  [messagesArray release];
  
  [tabBarController setDelegate:self];
  [self.window addSubview:tabBarController.view];
  [self.window makeKeyAndVisible];
  [(DBLWindow*)[self window] windowDidLoad];
  
  [dblTicketsViewController release];
  
  _signatureManager = [[DBLSignatureManager alloc] init];
  taskManager = [[DBLTaskManager alloc] init];
  [[DBLCLController sharedCLController].locationManager startUpdatingLocation];
  
  
  if ([[NSUserDefaults standardUserDefaults]boolForKey:DEFAULTS_switchStatus]) {
    [[tabBarController.tabBar.items objectAtIndex:[tabBarController.tabBar.items count]-1] setBadgeValue:@"    "];
  }
  
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
  NSDictionary *userInfo = [notification userInfo];
  if([application applicationState] != UIApplicationStateBackground) {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"tritone" ofType:@"mp3"];
    if ([[NSFileManager defaultManager] fileExistsAtPath : path])
    {
      NSURL *pathURL = [NSURL fileURLWithPath:path];
      SystemSoundID audioEffect;
      AudioServicesCreateSystemSoundID((CFURLRef) pathURL, &audioEffect);
      AudioServicesPlaySystemSound(audioEffect);
    }
    else
    {
      NSLog(@"error, file not found: %@", path);
    }
  }
  
  MessageAlertView *localAlert = nil;
  if([[userInfo objectForKey:@"messageType"] intValue] == 2) { //auction message
    localAlert = [[MessageAlertView alloc] initWithTitle:[NSString stringWithFormat:@"From: %@", [userInfo valueForKey:@"sender"]]
                                                 message:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"message"]]
                                                delegate:self
                                       cancelButtonTitle:@"Decline"
                                       otherButtonTitles:@"Accept", nil];
  }
  
  else  { //simple message
    localAlert = [[MessageAlertView alloc]
                  initWithTitle:[NSString stringWithFormat:@"From: %@", [userInfo valueForKey:@"sender"]]
                  message:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"message"]]
                  delegate:self
                  cancelButtonTitle:@"Ok"
                  otherButtonTitles:nil];
  }
  
  
  //pass the messageID as a tag to the localAlert so we know which message this is when presented in the UIAlertView later on
  [localAlert setMessageID:[[userInfo valueForKey:@"messageID"] intValue]];
  [localAlert setMessageType:[[userInfo valueForKey:@"messageType"] intValue]];
  
  [localAlert show];
  [self setAlertBeingDisplayed:localAlert];
  [localAlert release];
  
  [[UIApplication sharedApplication] cancelLocalNotification:notification];
}

#pragma mark - UITabBarControllerDelegate functions

// Called when a button is clicked. The view will be automatically dismissed after this call returns
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  [self setAlertBeingDisplayed:nil];
  
  //Check first if this is a setup alert, shouldn't do anything if it is
  if (alertView.tag == ALERT_SETUP) {
    return;
  }
  
  //Check if the alert is a message from the server/dispatch team
  else if (alertView.tag == ALERT_MESSAGE) {
    
    //Since we know this is our unique class of MessageAlertView we can safely cast the alertview pointer as a MessageAlertView
    MessageAlertView *message = (MessageAlertView *) alertView;
    
    SDZTickets *service = [[SDZTickets alloc] init];
    
    if (message.messageType == 2) { //auction message
      int accepted = (buttonIndex == 0) ? 2 : 1;
      [service AcceptMessage:self
                      action:@selector(handleAcceptMessage:)
                    deviceid:[APP_DELEGATE deviceId]
                        udid:[APP_DELEGATE UDID]
                    accepted:accepted
           acceptedddatetime:[NSDate date]
                   messageid:message.messageID];
    }
    
    else { //regular message
      [service AcknowledgeMessage:self
                           action:@selector(handleAcknowledgeMessage:)
                         deviceid:[APP_DELEGATE deviceId]
                             udid:[APP_DELEGATE UDID]
                     acknowledged:1
            acknnowledgeddatetime:[NSDate date]
                        messageid:message.messageID];
      
    }
    
    [service release];
    
  }
  
  [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_messageDismissed
                                                      object:nil];
  
}

// Handle the response from AcknowledgeMessage.

- (void) handleAcknowledgeMessage: (id) value {
  
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
		return;
	}
  
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
		return;
	}
  
  
	// Do something with the NSString* result
  NSString* result = (NSString*)value;
	NSLog(@"AcknowledgeMessage returned the value: %@", result);
  
}

- (void) handleAcceptMessage: (id) value {
  
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
		return;
	}
  
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
		return;
	}
  
  
	// Do something with the NSString* result
  NSString* result = (NSString*)value;
	NSLog(@"AcceptMessage returned the value: %@", result);
  
  UIAlertView *loadAlert = nil;
  loadAlert = [[UIAlertView alloc] initWithTitle:@"Attention"
                                         message:result
                                        delegate:self
                               cancelButtonTitle:@"Ok"
                               otherButtonTitles:nil];
  
  [loadAlert show];
  [self setAlertBeingDisplayed:loadAlert];
  [loadAlert release];
  
}

#pragma mark - server methods

-(void) getStatusesFromServer {
  SDZTickets *service = [[SDZTickets alloc]init];
  [service GetStatuses:self
                action:@selector(getStatusesHandler:)
              deviceid:[APP_DELEGATE deviceId]
                  udid:[APP_DELEGATE UDID]];
  [service release];
}

-(void) getStatusesHandler: (id) value {
  if([value isKindOfClass:[NSError class]]) {
    NSLog(@"GetStatuses error: %@", value);
		return;
	}
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"GetStatuses error: %@", value);
		return;
	}
  
  NSString *result = (NSString *) value;
  
  
  if ([result isEqualToString:@"User Credentials Error"]) {
    self.activitiesArray = [[NSArray alloc]initWithObjects:nil];
  }
  
  else {
    
    //The result is a comma-separated string so parse it first
    NSArray *parsedResults = [[NSArray alloc]initWithArray:[result componentsSeparatedByString:@","]];
    NSError *error;
    NSManagedObjectContext *context = [self managedObjectContext];
    
    //keep an index value just to retain ordering from the server
    int index = 0;
    for (NSString *newStatus in parsedResults) {
      DBLActivity *newActivity = [NSEntityDescription insertNewObjectForEntityForName:@"DBLActivity" inManagedObjectContext:context];
      [newActivity setValue:[NSString stringWithString:newStatus] forKey:@"label"];
      [newActivity setValue:[NSNumber numberWithInt:index] forKey:@"index"];
      index++;
    }
    
    if (![context save:&error]) {
      NSLog(@"Failed To Save Status Locally: %@", [error localizedDescription]);
    }
    
    [parsedResults release];
  }
}

-(void) getRepliesFromServer {
  SDZTickets *service = [[SDZTickets alloc]init];
  [service GetReplys:self
              action:@selector(getRepliesHandler:)
            deviceid:[APP_DELEGATE deviceId]
                udid:[APP_DELEGATE UDID]];
  [service release];
}

-(void) getRepliesHandler: (id) value {
  if([value isKindOfClass:[NSError class]]) {
    NSLog(@"GetReplies error: %@", value);
		return;
	}
  
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"GetReplies error: %@", value);
		return;
	}
  
  NSString *result = (NSString *) value;
  
  if ([result isEqualToString:@"User Credentials Error"]) {
    return;
  }
  
  else {
    
    //The result is just a comma-separated string so parse it first
    NSArray *parsedResults = [[NSArray alloc]initWithArray:[result componentsSeparatedByString:@","]];
    
    NSError *error;
    NSManagedObjectContext *context = [self managedObjectContext];
    
    //keep an index value just to retain ordering from the server
    int index = 0;
    for (NSString *newType in parsedResults) {
      NSLog(@"reply: %@", newType);
      DBLReplyType *newReply = [NSEntityDescription insertNewObjectForEntityForName:@"DBLReplyType" inManagedObjectContext:context];
      [newReply setValue:[NSString stringWithString:newType] forKey:@"label"];
      [newReply setValue:[NSNumber numberWithInt:index] forKey:@"index"];
      index++;
    }
    if (![context save:&error]) {
      NSLog(@"Failed To Save Status Locally: %@", [error localizedDescription]);
    }
    
    [parsedResults release];
  }
}

-(void) getSpeedLimitFromServer {
  SDZTickets *service = [[SDZTickets alloc]init];
  [service GetSpeedLimit:self
                  action:@selector(getSpeedLimitHandler:)
                deviceid:[APP_DELEGATE deviceId]
                    udid:[APP_DELEGATE UDID]];
  [service release];
}

-(void) getSpeedLimitHandler: (id) value {
  if([value isKindOfClass:[NSError class]]) {
    NSLog(@"GetSpeedLimit error: %@", value);
		return;
	}
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"GetSpeedLimit error: %@", value);
		return;
	}
  
  NSString *result = (NSString *) value;
  
  //check if the speed limit value is 0 or less, if so, change it to something else because 0 does not make sense
  if ([result intValue] <= 0) {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:SPEEDLIMIT_MAX] forKey:DEFAULTS_speedLimit];
  }
  
  else {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:[result intValue]]
                                             forKey:DEFAULTS_speedLimit];
  }
  NSLog(@"Speed limit: %d", [result intValue]);
}

#pragma mark -
#pragma mark Property Implementation

-(void)setLoadingTickets: (BOOL) state {
  isLoadingTickets = state;
  if (isLoadingTickets) {
    [(DBLWindow *) [self window] disableForLoading];
  }
  else {
    [(DBLWindow *) [self window] enableInterface];
  }
}

- (BOOL)status
{
  return [[NSUserDefaults standardUserDefaults] boolForKey:DEFAULTS_isAvailable];
}

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (void)setStatus:(BOOL)status
{
  if([self status] != status) {
    [[NSUserDefaults standardUserDefaults] setBool:status forKey:DEFAULTS_isAvailable];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    int availableNumber = ([self status] ? 1 : 0);
    [[SDZTickets service] Available:self
                             action:@selector(AvailableHandler:)
                           deviceid:[APP_DELEGATE deviceId]
                               udid:[APP_DELEGATE UDID]
                          timestamp:[NSDate date]
                          available:availableNumber];
    //
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"DBLStatusChanged"
    //                                                        object:nil];
  }
  
}

- (void) AvailableHandler: (id) value {
  
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
		return;
	}
  
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
		return;
	}
  
	// Do something with the NSString* result
  NSString* result = (NSString*)value;
	NSLog(@"Available returned the value: %@", result);
  
}

#pragma mark -
#pragma mark CoreData Stuff

- (NSManagedObjectContext *) managedObjectContext {
	if (managedObjectContext != nil) {
		return managedObjectContext;
	}
  
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (coordinator != nil) {
		managedObjectContext = [[NSManagedObjectContext alloc] init];
		[managedObjectContext setPersistentStoreCoordinator: coordinator];
	}
	
	return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
	if (managedObjectModel != nil) {
		return managedObjectModel;
	}
  
  NSString *path = [[NSBundle mainBundle] pathForResource:@"DBL" ofType:@"momd"];
  NSURL *momURL = [NSURL fileURLWithPath:path];
  managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
	
	return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
  if (persistentStoreCoordinator != nil) {
    return persistentStoreCoordinator;
  }
  
  NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"DBL.sqlite"]];
  
  NSLog(@"DataStore Path: %@", [storeUrl path]);
  
  NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                           [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
  
  NSError *error = nil;
  persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
  if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
  }
  
  return persistentStoreCoordinator;
  
}

- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString*)deviceId
{
  return [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_deviceID];
  //return @"iPad3";
}

- (NSString *)UDID
{
  
  return [[UIDevice currentDevice] uniqueIdentifier];
  //return @"7EB2BC01-DAB0-5873-8ED0-5D819FE754E3";
}

-(NSNumber *)speedLimit {
  return [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_speedLimit];
}

-(void)reloadRepliesFromServer {
  //fetch any and all items in coredata for DBLReplyType and DBLActivity
  
  NSManagedObjectContext *context = self.managedObjectContext;
  NSFetchRequest *fetchReplies = [[NSFetchRequest alloc] init];
  NSEntityDescription *replyEntity = [NSEntityDescription entityForName:@"DBLReplyType" inManagedObjectContext:context];
  
  [fetchReplies setEntity:replyEntity];
  
  NSError *error;
  NSArray *fetchedReplies = [context executeFetchRequest:fetchReplies error:&error];
  
  for (DBLReplyType *toDelete in fetchedReplies) {
    [context deleteObject:toDelete];
  }
  
  if (![context save:&error]) {
    NSLog(@"error deleting replies");
  }
  
  [fetchReplies release];
  
  [self getRepliesFromServer];
  [self getSpeedLimitFromServer];
}

-(void)reloadStatusesFromServer {
  NSManagedObjectContext *context = self.managedObjectContext;
  NSError *error;
  NSFetchRequest *fetchActivities = [[NSFetchRequest alloc] init];
  NSEntityDescription *activityEntity = [NSEntityDescription entityForName:@"DBLActivity" inManagedObjectContext:context];
  [fetchActivities setEntity:activityEntity];
  
  NSArray *fetchedActivities = [context executeFetchRequest:fetchActivities error:&error];
  
  for (DBLActivity *toDelete in fetchedActivities) {
    [context deleteObject:toDelete];
  }
  
  [fetchActivities release];
  
  if (![context save:&error]) {
    NSLog(@"error deleting  activities");
  }
  
  [self getStatusesFromServer];
  [self getSpeedLimitFromServer];
  
}

@end

