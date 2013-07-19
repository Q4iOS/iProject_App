//  DBLTicketsViewController.m
//  Northminster
//
//  Created by Kiere El-Shafie on 2/13/11.
//  Copyright 2011 lazyGray, Inc. All rights reserved.
//


/////////////////////////
#pragma mark -
#pragma mark Imports
/////////////////////////

#import "DBLAppDelegate.h"
#import "DBLTicketsViewController.h"
#import "DBLTicketViewController.h"
#import "SDZTickets.h"
#import "NSData+Base64.h"
#import "DBLSignatureLocal.h"
#import "DBLSignatureManager.h"
#import "DBLTicket.h"

#define CLEAR_ALL_TICKETS_ALERT_VIEW_TITLE @"Clear All Tickets?"
#define CLEAR_ALL_TICKETS_NO_BUTTON_INDEX 0
#define CLEAR_ALL_TICKETS_YES_BUTTON_INDEX 1

#define GET_ALL_TICKETS_ALERT_VIEW_TITLE @"Get All Tickets?"
#define GET_ALL_TICKETS_YES_BUTTON_INDEX 1

/////////////////////////
#pragma mark -
#pragma mark Interface
/////////////////////////
@interface DBLTicketsViewController ()

//loading functions
- (void)showLoading;
- (void)hideLoading;
- (void)showPopup:(NSString *)message;
- (void)clearAllTicketsRequested:(id)sender;
- (void)deleteAllTickets;

//notifications
- (void)updateTicket:(NSNotification*)notification;

//core data functions
- (void)getTicketFromWebService;
- (void)getAllTicketsFromWebService;
- (void)fetchTicketsFromCoreData;
- (void)updateTicketsTable;
- (void)checksignatures;
- (void)StoreTicketinCoreData: (id)tkt;
@end

@implementation HeaderTap

@synthesize tag;

@end

/////////////////////////
#pragma mark -
#pragma mark Implementation
/////////////////////////
@implementation DBLTicketsViewController



/////////////////////////
#pragma mark -
#pragma mark Synthesize
/////////////////////////
@synthesize getLatestTicketButton, getAllTicketsButton, expandAllButton, collapseAllButton, spinner;
@synthesize ticketsarray, sectionrowsarray, sectionheadersarray, sectioncollapseflags;


/////////////////////////
#pragma mark -
#pragma mark Property Overrides
/////////////////////////
- (NSMutableArray *)ticketsarray {
  if (!ticketsarray) {
    self.ticketsarray = [NSMutableArray array];
  }
  return ticketsarray;
}
- (NSMutableArray *)sectionrowsarray {
  if (!sectionrowsarray) {
    self.sectionrowsarray = [NSMutableArray array];
  }
  return sectionrowsarray;
}
- (NSMutableArray *)sectionheadersarray {
  if (!sectionheadersarray) {
    self.sectionheadersarray = [NSMutableArray array];
  }
  return sectionheadersarray;
}
- (NSMutableArray *)sectioncollapseflags {
  if (!sectioncollapseflags) {
    self.sectioncollapseflags = [NSMutableArray array];
  }
  return sectioncollapseflags;
}

/////////////////////////
#pragma mark -
#pragma mark View Lifecycle
/////////////////////////
- (void)viewDidLoad {
	[super viewDidLoad];
  
  backgroundQueue = dispatch_queue_create("com.luckstone.luckstone", NULL);
  
  self.title = @"Tickets";
  self.navigationItem.title = @"Tickets";
  
  self.getLatestTicketButton.title = @"Get Latest Ticket";
  self.getAllTicketsButton.title = @"Get All Tickets";
  self.collapseAllButton.title = @"Collapse All";
  self.expandAllButton.title = @"Expand All";
  
  //Create Edit Button
  UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:self
                                                                action:@selector(Edit:)];
  
  //  [self.navigationItem setLeftBarButtonItem:editButton];
  //  [editButton release];
  
  //Add all of the navigation bar items to our navigation bar
  NSMutableArray *leftItems = [[NSMutableArray alloc]init];
  [leftItems addObject:editButton];
  [leftItems addObject:expandAllButton];
  [leftItems addObject:collapseAllButton];
  [self.navigationItem setLeftBarButtonItems:leftItems];
  [editButton release];
  [leftItems release];
  
  NSMutableArray *rightItems = [[NSMutableArray alloc]init];
  [rightItems addObject:getAllTicketsButton];
  [rightItems addObject:getLatestTicketButton];
  [self.navigationItem setRightBarButtonItems:rightItems];
  [rightItems release];
  
  [self.ticketsarray removeAllObjects];
	[self initialTicketFetch];
}

- (void)viewDidUnload {
  self.getLatestTicketButton = nil;
  self.spinner = nil;
  self.getAllTicketsButton = nil;
	self.ticketsarray = nil;
  self.sectionheadersarray = nil;
  self.sectionrowsarray = nil;
  self.sectioncollapseflags = nil;
  hostReach = nil;
  
  dispatch_release(backgroundQueue);
  
  [self setExpandAllButton:nil];
  [super viewDidUnload];
  
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateTicket:)
                                               name:NOTIFICATION_updateTicket
                                             object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateTicketsTable)
                                               name:NOTIFICATION_reloadTickets
                                             object:nil];
  
  //  [self updateTicketsTable];
}

- (void)viewWillDisappear:(BOOL)animated
{
  
  
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:NOTIFICATION_updateTicket
                                                object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_reloadTickets object:nil];
  
  [super viewWillDisappear:animated];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}




/////////////////////////
#pragma mark -
#pragma mark Support Methods
/////////////////////////

- (void)refresh {
  [self getLatestTicketButtonClick];
}

- (BOOL) date:(NSDate*)date isBetween:(NSDate*)beginDate and:(NSDate*)endDate {
  return (([date compare:beginDate] != NSOrderedAscending) && ([date compare:endDate] != NSOrderedDescending));
}

- (void)showPopup:(NSString *)message {
  UIAlertView *alert = [[UIAlertView alloc]
                        initWithTitle: @"Announcement"
                        message: message
                        delegate: nil
                        cancelButtonTitle:@"OK"
                        otherButtonTitles:nil];
  
  [alert show];
  [alert release];
}

- (void)handleError:(NSError *)error {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                  message:[error description]
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
  [alert show];
  [alert release];
}

- (void)showLoading {
  self.navigationItem.titleView = self.spinner;
  [self.spinner startAnimating];
}

- (void)hideLoading {
  [self.spinner stopAnimating];
  [self stopLoading];
  //  [self performSelector:@selector(stopLoading) withObject:nil afterDelay:0.0];
  self.navigationItem.titleView = nil;
}

- (IBAction)collapseAllClick:(id)sender {
  
  for (int i = 0; i < [sectioncollapseflags count]; i++) {
    NSNumber *collapseFlag = [[NSNumber alloc]initWithBool:YES];
    [sectioncollapseflags replaceObjectAtIndex:i withObject:collapseFlag];
    [collapseFlag release];
  }
  
  [self.tableView reloadData];
}

- (IBAction)expandAllClick:(id)sender {
  
  for (int i = 0; i < [sectioncollapseflags count]; i++) {
    NSNumber *collapseFlag = [[NSNumber alloc]initWithBool:NO];
    [sectioncollapseflags replaceObjectAtIndex:i withObject:collapseFlag];
    [collapseFlag release];
  }
  
  [self.tableView reloadData];
}

-(void)tapAction:(HeaderTap *) gesture {
  if (gesture.state == UIGestureRecognizerStateEnded) {
    NSNumber *collapseFlag = [sectioncollapseflags objectAtIndex:gesture.tag];
    [sectioncollapseflags replaceObjectAtIndex:gesture.tag withObject:[NSNumber numberWithBool:![collapseFlag boolValue]]];
    
    [self.tableView reloadData];
  }
}

/////////////////////////
#pragma mark -
#pragma mark Update Refresh Functions
/////////////////////////

//UI clicks refresh button
- (void)getLatestTicketButtonClick
{
  [self showLoading];
  [self getTicketFromWebService];
}

- (void)getAllTicketsClick
{
  UIAlertView *getAllTicketsAlert = [[UIAlertView alloc] initWithTitle:GET_ALL_TICKETS_ALERT_VIEW_TITLE
                                                               message:@"Are you sure you want to get all tickets?"
                                                              delegate:self
                                                     cancelButtonTitle:@"No"
                                                     otherButtonTitles:@"Yes", nil];
  [getAllTicketsAlert show];
  [getAllTicketsAlert release];
}



- (void)getAllTicketsStart
{
  [self showLoading];
  [self getAllTicketsFromWebService];
}

- (void)clearAllTicketsRequested:(id)sender
{
  UIAlertView *clearAllAlert = [[UIAlertView alloc] initWithTitle:CLEAR_ALL_TICKETS_ALERT_VIEW_TITLE
                                                          message:@"Are you sure you want to clear all tickets?"
                                                         delegate:self
                                                cancelButtonTitle:@"No"
                                                otherButtonTitles:@"Yes", nil];
  [clearAllAlert show];
  [clearAllAlert release];
}

- (void)deleteAllTickets
{
  //Find all tickets whose signature has not been sent to the service
  //and send them to the service.
  [self checksignatures];
  
  //Remove all objects from local tickets array
  [[self ticketsarray] removeAllObjects];
  
  //Delete all the tickets from Core Data.
  NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLTicket"
                                            inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	NSError *error = nil;
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
  [fetchRequest release];
  
  if(error) {
    NSLog(@"Error occured fetching tickets for deletion: %@", [error localizedDescription]);
    return;
  }
  
  NSUInteger objectCount = [fetchedObjects count];
  for(NSUInteger i = 0; i < objectCount; ++i) {
    [context deleteObject:[fetchedObjects objectAtIndex:i]];
  }
  
  if (![context save:&error]) {
    // Handle the error.
    NSLog(@"Failed to Save Ticket Deletions: %@", [error localizedDescription]);
    return;
  } else {
    NSLog(@"Successfully Saved Ticket Deletions");
  }
  
  //Reload Ticket Table
  [[self tableView] reloadData];
}

- (void)updateTicket:(NSNotification*)notification
{
  [self updateTicketsTable];
}

- (void)updateTicketsTable {
	[self.ticketsarray removeAllObjects];
	[self fetchTicketsFromCoreData];//gowri
}

//Loops through signatures and checks if they have been sent to the web server.
//If they have been sent then they are deleted, else they are sent to the web server.
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (void)checksignatures
{
  [[APP_DELEGATE signatureManager] cleanSignatureQueue];
}

-(void)finishedFetch {
  [self.tableView reloadData];
  [self checksignatures];
  [self hideLoading];
  [APP_DELEGATE performSelector:@selector(setLoadingTickets:) withObject:NO afterDelay:1.0f];
}

- (void)initialTicketFetch {
  [APP_DELEGATE setLoadingTickets:YES];
  
  dispatch_async(backgroundQueue, ^(void) {
    
    NSLog(@"Fetching Tickets From CoreData");
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    
    [context lock];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLTicket"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    [context unlock];
    
    NSLog(@"Fetched %d Tickets for CoreData", [fetchedObjects count]);
    self.ticketsarray = [NSMutableArray arrayWithArray:fetchedObjects];
    
    //delete any tickets older than 90 days
    NSDate *today = [NSDate date];
    NSCalendar *myCal = [NSCalendar currentCalendar];
    
    //create our start and end day intervals
    NSDateComponents *temp = [[NSDateComponents alloc]init];
    [temp setDay:-90];
    NSDate *startDate = [myCal dateByAddingComponents:temp toDate:today options:0];
    
    NSMutableArray *deleteArray = [[NSMutableArray alloc]init];
    for (DBLTicket *temp in self.ticketsarray) {
      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setDateFormat:SERVICE_DATE_FORMAT];
      NSDate *ticketDate = [dateFormatter dateFromString:temp.ticketDate];
      if (![self date:ticketDate isBetween:startDate and:today]) {
        [deleteArray addObject:temp];
      }
    }
    
    [self.ticketsarray removeObjectsInArray:deleteArray];
    
    for (DBLTicket *temp in deleteArray) {
      [context deleteObject:temp];
    }
    
    [context save:&error];
    
    [deleteArray removeAllObjects];
    [deleteArray release];
    
    //Sort Tickets Array using NSDate comparison not NSString comparison
    [[self ticketsarray] sortUsingComparator:^(id obj1, id obj2){
      NSString *obj1TicketDate = [obj1 valueForKey:@"ticketDate"];
      NSString *obj2TicketDate = [obj2 valueForKey:@"ticketDate"];
      
      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setDateFormat:SERVICE_DATE_FORMAT];
      
      NSDate *obj1Date = [dateFormatter dateFromString:obj1TicketDate];
      NSDate *obj2Date = [dateFormatter dateFromString:obj2TicketDate];
      
      NSComparisonResult result = [obj2Date compare:obj1Date];
      [dateFormatter release];
      
      return result;
    }];
    
    [fetchRequest release];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
      [self finishedFetch];
    });
  });
}

//Adds tickets in core data to ticketsarray
- (void)fetchTicketsFromCoreData {
  //  [APP_DELEGATE setLoadingTickets:YES];
  
  dispatch_async(backgroundQueue, ^(void) {
    
    NSLog(@"Fetching Tickets From CoreData");
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    
    [context lock];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLTicket"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    [context unlock];
    
    NSLog(@"Fetched %d Tickets for CoreData", [fetchedObjects count]);
    self.ticketsarray = [NSMutableArray arrayWithArray:fetchedObjects];
    
    //Sort Tickets Array using NSDate comparison not NSString comparison
    [[self ticketsarray] sortUsingComparator:^(id obj1, id obj2){
      NSString *obj1TicketDate = [obj1 valueForKey:@"ticketDate"];
      NSString *obj2TicketDate = [obj2 valueForKey:@"ticketDate"];
      
      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setDateFormat:SERVICE_DATE_FORMAT];
      
      NSDate *obj1Date = [dateFormatter dateFromString:obj1TicketDate];
      NSDate *obj2Date = [dateFormatter dateFromString:obj2TicketDate];
      
      NSComparisonResult result = [obj2Date compare:obj1Date];
      [dateFormatter release];
      
      return result;
    }];
    
    [fetchRequest release];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
      [self finishedFetch];
    });
  });
}


/////////////////////////
#pragma mark -
#pragma mark Web Service Interactions
/////////////////////////

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (void)getTicketFromWebService {
  hostReach = [[Reachability reachabilityWithHostName: TICKETS_SERVICE_DOMAIN] retain];
  NetworkStatus remoteHostStatus = [hostReach currentReachabilityStatus];
  
  if (remoteHostStatus != NotReachable) {
    /////////////////////////////////
    //Gets Tickets From Web Service
    SDZTickets* service = [[SDZTickets alloc] init];
    [service GetTicket:self
                action:@selector(GetTicketHandler:)
              deviceid:[APP_DELEGATE deviceId]
                  udid:[APP_DELEGATE UDID]
             automated:0];
    [service release];
  }
  
  else {
    UIAlertView *newAlert = [[UIAlertView alloc]initWithTitle:@"Cannot retrieve tickets" message:@"Make sure your internet connection is stable and try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [newAlert show];
    [newAlert release];
  }
}

//Store Ticket in Core Data
- (void)StoreTicketinCoreData: (id)tkt
{
  SDZTicket* result = (SDZTicket*)tkt;
  
  NSError *error = nil;
	
	//TRY AND READ DATA//
	NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLTicket" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ticketNumber = %@", result.TicketNumber];
	[fetchRequest setPredicate:predicate];
	
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	
  DBLTicket *event = nil;
	if ([fetchedObjects count] > 0) {
    //found ticket grab it for updating
    event = [fetchedObjects objectAtIndex:0];
	}
	else {
		//did not find a ticket insert is ok to store record in core data
		//LOAD INTO CORE DATA//
		event = [NSEntityDescription insertNewObjectForEntityForName:@"DBLTicket"
                                          inManagedObjectContext:context];
  }
  /////////////////////////
  event.addressID = [NSNumber numberWithInt:result.AddressID];
  event.copyString = result.Copy;
  event.customerAccountNumber = result.CustomerAcctNumber;
  event.customerAddress = result.CustomerAddress;
  event.deliveryInstructions = result.DeliveryInstructions;
  event.fuelSurcharge = result.FuelSurcharge;
  event.grossWeight = result.GrossWt;
  event.haulCharge = result.HaulCharge;
  event.haulIndicator = result.HaulIndicator;
  event.haulRate = result.HaulRate;
  event.haulerName = result.HaulerName;
  event.haulerNumber = result.HaulerNumber;
  event.jobContractor = result.JobContact;
  event.jobPhone = result.JobPhone;
  event.locationName = result.LocationName;
  event.locationCode = [NSNumber numberWithInt:result.LocationCode];
  event.latitude = result.Latitude;
  event.longitude = result.Longitude;
  event.lotSample = result.LotSample;
  event.maxGross = result.MaxGross;
  event.metricTonsLoadsToday = result.MetricTonsLoadsToday;
  event.metricTonsQtyDelivered = result.MetricTonsQtyDelivered;
  event.metricTonsQtyDeliveryToday = result.MetricTonsQtyDeliveryToday;
  event.metricTonsQtyOrdered = result.MetricTonsQtyOrdered;
  event.netTons = result.NetTons;
  event.netTonsMetric = result.NetTonsMetric;
  event.netWeight = result.NetWeight;
  event.orderID = result.OrderID;
  event.plant = result.Plant;
  event.productCertification = result.ProductCertification;
  event.productCertificationDefault = result.ProductCertificationDefault;
  event.productCode = result.ProductCode;
  event.productDescription = result.ProductDescription;
  event.projectDescription = result.ProjectDescription;
  event.projectID = result.ProjectID;
  event.purchaseOrder = result.PurchaseOrder;
  event.salesTax = result.SalesTax;
  event.shortTonsLoadsToday = result.ShortTonsLoadsToday;
  event.shortTonsQtyDelivered = result.ShortTonsQtyDelivered;
  event.shortTonsQtyDeliveryToday = result.ShortTonsQtyDeliveryToday;
  event.shortTonsQtyOrdered = result.ShortTonsQtyOrdered;
  event.specialInstructions = result.SpecialInstructions;
  event.stonePrice = result.StonePrice;
  event.stoneRate = result.StoneRate;
  event.tareWeight = result.TareWt;
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:SERVICE_DATE_FORMAT];
  event.ticketDate = [dateFormatter stringFromDate:result._TicketDateTime];
  [dateFormatter release];
  event.ticketNumber = result.TicketNumber;
  event.ticketTime = result.TicketTime;
  event.total = result.Total;
  event.truckNumber = result.TruckNumber;
  event.warning1 = result.Warning1;
  event.warning2 = result.Warning2;
  event.weighmaster = result.Weighmaster;
  event.notes=result.Notes;
  
  if(result.Signature1) {
    //result.Signature is data of a base64 encoded string. (Convert it to a String the put it back into data)
    NSString *signatureResult = [[NSString alloc] initWithData:result.Signature1
                                                      encoding:NSUTF8StringEncoding];
    
    NSData *signatureData = [[NSData alloc] initWithBase64EncodedString:signatureResult];
    event.signature1 = signatureData;
    [signatureData release];
    [signatureResult release];
  }
  
  if(result.Signature2) {
    //result.Signature is data of a base64 encoded string. (Convert it to a String the put it back into data)
    NSString *signatureResult = [[NSString alloc] initWithData:result.Signature2
                                                      encoding:NSUTF8StringEncoding];
    
    NSData *signatureData = [[NSData alloc] initWithBase64EncodedString:signatureResult];
    event.signature2 = signatureData;
    [signatureData release];
    [signatureResult release];
  }

  if(result.Signature3) {
    //result.Signature is data of a base64 encoded string. (Convert it to a String the put it back into data)
    NSString *signatureResult = [[NSString alloc] initWithData:result.Signature3
                                                      encoding:NSUTF8StringEncoding];
    
    NSData *signatureData = [[NSData alloc] initWithBase64EncodedString:signatureResult];
    event.signature3 = signatureData;
    [signatureData release];
    [signatureResult release];
  }
  
  if(result.Signature4) {
    //result.Signature is data of a base64 encoded string. (Convert it to a String the put it back into data)
    NSString *signatureResult = [[NSString alloc] initWithData:result.Signature4
                                                      encoding:NSUTF8StringEncoding];
    
    NSData *signatureData = [[NSData alloc] initWithBase64EncodedString:signatureResult];
    event.signature4 = signatureData;
    [signatureData release];
    [signatureResult release];
  }


  
  
  
  if (![context save:&error]) {
    NSLog(@"Failed To Save New Ticket: %@", [error localizedDescription]);
  }
  
  [fetchRequest release];
}

- (void) GetTicketHandler: (id) value {
	if([value isKindOfClass:[NSError class]] || [value isKindOfClass:[SoapFault class]]) {
		NSLog(@"Get Ticket From Web Service Class Fault: %@", value);
    [self showPopup:@"Get Ticket Class Error.  Check Connection."];
    [self updateTicketsTable];
		return;
	}
  
  else if ([value isKindOfClass:[NSString class]]) {
    NSString *response = (NSString *) value;
    if ([response isEqualToString:SERVER_RESPONSE_FAILURE_VALUE]) {
      UIAlertView *newAlert = [[UIAlertView alloc]initWithTitle:FAILURE_ALERT_TITLE_TICKETS
                                                        message:FAILURE_ALERT_MESSAGE_TICKETS
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
      [newAlert show];
      [newAlert release];
    }
    
    else {
      NSLog(@"Error: ticket returned is not of type SDZticket");
      return;
    }
  }
	
	//check for duplicate first
	SDZTicket* result = (SDZTicket*)value;
	
	if (result.TicketNumber == nil) {
		NSLog(@"No Ticket Returned");
		[self showPopup:@"No Ticket Returned."];
		[self updateTicketsTable];
		return;
	}
	
	[self StoreTicketinCoreData:result];
	[self updateTicketsTable];
}


- (void)getAllTicketsFromWebService
{
  hostReach = [[Reachability reachabilityWithHostName: TICKETS_SERVICE_DOMAIN] retain];
  NetworkStatus remoteHostStatus = [hostReach currentReachabilityStatus];
  
  if (remoteHostStatus != NotReachable) {
    
    SDZTickets* service = [[SDZTickets alloc] init];
    [service GetAllTickets:self
                    action:@selector(GetAllTicketsHandler:)
                  deviceid:[APP_DELEGATE deviceId]
                      udid:[APP_DELEGATE UDID]];
    [service release];
  }
  
  else {
    UIAlertView *newAlert = [[UIAlertView alloc]initWithTitle:@"Cannot retrieve tickets" message:@"Make sure your internet connection is stable and try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [newAlert show];
    [newAlert release];
  }
}

- (void) GetAllTicketsHandler: (id) value {
	if([value isKindOfClass:[NSError class]] || [value isKindOfClass:[SoapFault class]]) {
		NSLog(@"Get All Tickets From Web Service Class Fault: %@", value);
    [self showPopup:@"Get All Tickets Class Error.  Check Connection."];
    [self updateTicketsTable];
		return;
	}
  
  NSMutableArray* result = (NSMutableArray*)value;
  
  if([result count]<=0)
  {
    [self showPopup:@"No Tickets Returned."];
  }
  
  for(SDZTicket* tkt in result)
  {
    [self StoreTicketinCoreData:tkt];
  }
  [self updateTicketsTable];
}

/////////////////////////
#pragma mark -
#pragma mark Table view data source
/////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  if([self.ticketsarray count] > 0)
  {
    [self.sectionrowsarray removeAllObjects];
    [self.sectionheadersarray removeAllObjects];
    
    NSString *comparedate = nil;
    int sectioncount = 0;
    int rowcount = 1;
    NSString *formattedDateString = nil;
    
    for (DBLTicket *tempticket in ticketsarray) {
      NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
      [dateFormat setDateFormat:SERVICE_DATE_FORMAT];
      NSDate *date = [dateFormat dateFromString:tempticket.ticketDate];
      [dateFormat setDateFormat:@"MM/dd/yyyy"];
      formattedDateString = [dateFormat stringFromDate:date];
      [dateFormat release];
      
      if ([formattedDateString isEqualToString:comparedate]) {
        rowcount++;
      }
      else {
        [self.sectionrowsarray addObject:[NSNumber numberWithInteger:rowcount]];
        if (comparedate == nil) {
          rowcount = 0;
          [self.sectionheadersarray addObject:@"Current Ticket"];
        }
        else {
          rowcount = 1;
          [self.sectionheadersarray addObject:comparedate];
          
        }
        [self.sectioncollapseflags addObject:[NSNumber numberWithBool:YES]];
        comparedate = formattedDateString;
        sectioncount++;
      }
    }
    
    if(formattedDateString != nil) {
      [self.sectionheadersarray addObject:formattedDateString];
      [self.sectioncollapseflags addObject:[NSNumber numberWithBool:YES]];
    }
    
    sectioncount++;
    
    [self.sectionrowsarray addObject:[NSNumber numberWithInteger:rowcount]];
    return sectioncount;
  }
  else {
    return 0;
  }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];
  
  //Use a gradient to mimic Apple's default header style
  CAGradientLayer *gradient = [CAGradientLayer layer];
  gradient.frame = headerView.bounds;
  //  gradient.colors = [NSArray arrayWithObjects:
  //                     (id)[[UIColor colorWithRed:.6 green:.6 blue:.6 alpha:1.0] CGColor],
  //                     (id)[[UIColor colorWithRed:.8 green:.8 blue:.8 alpha:1.0] CGColor], nil];
  
  gradient.colors = [NSArray arrayWithObjects:
                     (id)[[UIColor colorWithRed:.4 green:.45 blue:.5 alpha:1.0] CGColor],
                     (id)[[UIColor colorWithRed:.6 green:.65 blue:.7 alpha:1.0] CGColor], nil];
  
  headerView.layer.masksToBounds = YES;
  [headerView.layer insertSublayer:gradient atIndex:0];
  
  //Apply the date as the section header
  UILabel *headerText = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, tableView.frame.size.width/2, 50)];
  [headerText setBackgroundColor:[UIColor clearColor]];
  
  NSString *tempText = [self.sectionheadersarray objectAtIndex:section];
  tempText = [tempText stringByReplacingOccurrencesOfString:@"/" withString:@" / " ];
  
  if (section != 0) {
    tempText = [NSString stringWithFormat:@"%@   (%d tickets)", tempText, [[self.sectionrowsarray objectAtIndex:section] integerValue]];
  }
  
  [headerText setText:[NSString stringWithString:tempText]];
  [headerText setTextColor:[UIColor whiteColor]];
  [headerText setFont:[UIFont boldSystemFontOfSize:19.0]];
  [headerView addSubview:headerText];
  [headerText release];
  
  //Attach a tap recognizer for collapsing
  HeaderTap *myTap = [[HeaderTap alloc]initWithTarget:self action:@selector(tapAction:)];
  myTap.tag = section;
  [headerView addGestureRecognizer:myTap];
  [myTap release];
  
  return [headerView autorelease];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) {
    return 1;
  }
  
  NSNumber *collapseFlag = [sectioncollapseflags objectAtIndex:section];
  if ([collapseFlag boolValue]) {
    return 0;
  }
  
  else {
    return [[self.sectionrowsarray objectAtIndex:section] integerValue];
  }
}

- (CGFloat)tableView:(UITableView *)table heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    return 100.0; // Current ticket row height is 100.0
  } else {
    return 60.0; //All other ticket row heights are 60.0
  }
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  
  cell.imageView.image = nil;
  cell.detailTextLabel.text = nil;
  cell.detailTextLabel.numberOfLines = 1;
  
  int arrayindex = 0;
  for (int n = 0; n < indexPath.section; n++)
  {
    arrayindex += [[self.sectionrowsarray objectAtIndex:n]integerValue];
  }
  arrayindex += indexPath.row;
  
  DBLTicket *ticket = [self.ticketsarray objectAtIndex:arrayindex];
  if (ticket)
  {
    if (!ticket.projectID)
    {
      cell.textLabel.text = ticket.ticketNumber;
    }
    else
    {
      cell.textLabel.text = [ticket.ticketNumber stringByAppendingFormat:@" - %@",ticket.projectID];
    }
    cell.detailTextLabel.text = ticket.orderID;
    cell.imageView.image = [UIImage imageNamed:@"ticket-icon.png"];
  }
  
  return cell;
  [cell release];
}

//Returns tickets in the section header array.
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//  if(section < [[self sectionheadersarray] count]) {
//    return [self.sectionheadersarray objectAtIndex:section];
//  } else {
//    return @"Other Tickets";
//  }
//}


/////////////////////////
#pragma mark -
#pragma mark Table view delegate
/////////////////////////

//When a row is selected tickets a new view controller is created that shows the details of the ticket.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  //Calculate the index the ticket is stored at by adding the number of rows in each previous sections
  //and the row index of the current section.
  int arrayindex = 0;
  for (int n = 0; n < indexPath.section; n++)
  {
    arrayindex += [[self.sectionrowsarray objectAtIndex:n]integerValue];
  }
  arrayindex += indexPath.row;
  
  //Grab the ticket to display
  DBLTicket *item = [self.ticketsarray objectAtIndex:arrayindex];
  
  
  NSLog(@"arrayval--%@",[self.ticketsarray objectAtIndex:arrayindex]);
   NSLog(@"arrayval--%@",item);
  
  //Setup View Controller and Display it
  DBLTicketViewController *tVC = [[DBLTicketViewController alloc] initWithNibName:@"DBLTicketView" bundle:[NSBundle mainBundle]];
  tVC.ticket = item;
  [self.navigationController pushViewController:tVC animated:YES];
  [tVC release];
}

/////////////////////////
#pragma mark -
#pragma mark Memory Management
/////////////////////////

- (void)dealloc {
  [getLatestTicketButton release];
  [getAllTicketsButton release];
  [spinner release];
	[ticketsarray release];
  [sectionrowsarray release];
  [sectionheadersarray release];
  
  [expandAllButton release];
  [super dealloc];
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

//Toggles the editing state of tickets.
- (IBAction) Edit:(id)sender{
  if(self.editing) {
    
    [super setEditing:NO animated:YES];
    [self.tableView setEditing:NO animated:YES];
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(Edit:)];
    
    NSMutableArray *leftItems = [[NSMutableArray alloc]init];
    [leftItems addObject:editButton];
    [leftItems addObject:expandAllButton];
    [leftItems addObject:collapseAllButton];
    [self.navigationItem setLeftBarButtonItems:leftItems animated:YES];
    [editButton release];
    [leftItems release];
    
    
    //    NSArray *barButtons = [[NSArray alloc] initWithObjects:editButton, nil];
    //    [editButton release];
    //
    //    [[self navigationItem] setLeftBarButtonItems:barButtons animated:YES];
    //    [barButtons release];
  }
  else
  {
    [super setEditing:YES animated:YES];
    [self.tableView setEditing:YES animated:YES];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(Edit:)];
    
    UIBarButtonItem *clearTickets = [[UIBarButtonItem alloc] initWithTitle:@"Clear All"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(clearAllTicketsRequested:)];
    
    NSArray *barButtons = [[NSArray alloc] initWithObjects:doneButton, clearTickets, nil];
    [doneButton release];
    [clearTickets release];
    
    [[self navigationItem] setLeftBarButtonItems:barButtons animated:YES];
    [barButtons release];
  }
}

//Handles deleting a ticket from the local database and from the view controller's ticket array
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  
  NSLog(@"Deleteing Ticket at section: %d row: %d", [indexPath section], [indexPath row]);
  
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    
    //Calculate the index the ticket is stored at by adding the number of rows in each previous sections
    //and the row index of the current section.
    int ticketIndex= 0;
    for (int n = 0; n < indexPath.section; n++)
    {
      ticketIndex += [[self.sectionrowsarray objectAtIndex:n]integerValue];
    }
    ticketIndex += indexPath.row;
    
    //Delete ticket from core data.
    DBLTicket *item = [self.ticketsarray objectAtIndex:ticketIndex];
    
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLTicket" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ticketNumber = %@", item.ticketNumber];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    for (NSManagedObject *info in fetchedObjects) {
      [context deleteObject:info];
    }
    // Save
    
    if ([context save:&error] == NO) {
      // Handle Error.
    }
    
    //Delete ticket from managed objects.
    [self.ticketsarray removeObjectAtIndex:ticketIndex];
    [self.tableView reloadData];
  }
}


#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if([[alertView title] isEqualToString:CLEAR_ALL_TICKETS_ALERT_VIEW_TITLE]) {
    if(buttonIndex == CLEAR_ALL_TICKETS_NO_BUTTON_INDEX) {
      //DO NOTHING
    } else if (buttonIndex == CLEAR_ALL_TICKETS_YES_BUTTON_INDEX) {
      [self deleteAllTickets];
    }
  }
  
  if([[alertView title] isEqualToString:GET_ALL_TICKETS_ALERT_VIEW_TITLE]) {
    if(buttonIndex == GET_ALL_TICKETS_YES_BUTTON_INDEX) {
      [self getAllTicketsStart];
    }
  }
}

@end

