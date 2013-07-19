//
//  DBLScheduleViewController.m
//  DBL
//
//  Created by Ryan Emmons on 5/26/11.
//  Copyright 2011 Luck Stone. All rights reserved.
//

#import "DBLScheduleViewController.h"

#import "DBLAppDelegate.h"
#import "SDZTickets.h"
#import "DBLAssignmentCell.h"
#import "DBLScheduleInfo.h"

/////////////////////////
#pragma mark -
#pragma mark Interface
/////////////////////////
@interface DBLScheduleViewController ()
//loading functions
- (void)showLoading;
- (void)hideLoading;
- (void)showPopup:(NSString *)message;
//core data functions
- (void)getScheduleFromWebService;
- (void)addCoreDataScheduleToArray:(id)schedule;
- (void)fetchScheduleFromCoreData;
- (void)updateScheduleTable;
- (void)StoreScheduleinCoreData: (id)sched;
@end

/////////////////////////
#pragma mark -
#pragma mark Implementation
/////////////////////////
@implementation DBLScheduleViewController

/////////////////////////
#pragma mark -
#pragma mark Synthesize
/////////////////////////
@synthesize getLatestScheduleButton, spinner;
@synthesize managedObjectContext;
@synthesize schedulearray;
@synthesize sectionheadersarray;
@synthesize sectionrowsarray;
@synthesize disablingView;
@synthesize myDeviceID;

/////////////////////////
#pragma mark -
#pragma mark Property Overrides
/////////////////////////
- (NSArray *)schedulearray {
  if (!schedulearray) {
    self.schedulearray = [NSMutableArray array];
  }
  return schedulearray;
}


/////////////////////////
#pragma mark -
#pragma mark View Lifecycle
/////////////////////////
- (void)viewDidLoad {
	[super viewDidLoad];
  self.sectionheadersarray = [[NSMutableArray alloc]init];
  self.sectionrowsarray = [[NSMutableArray alloc]init];
  
  self.title = @"Schedule";
  self.navigationItem.title = @"Schedule";
  
  self.getLatestScheduleButton.title = @"Get Latest Schedule";
  self.navigationItem.rightBarButtonItem = self.getLatestScheduleButton;
  
  if (managedObjectContext == nil)
	{
    managedObjectContext = [(DBLAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
	}
  
  [self fetchScheduleFromCoreData];
  
  
}

- (void)viewDidUnload {
  // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
  // For example: self.myOutlet = nil;
  self.getLatestScheduleButton = nil;
  self.spinner = nil;
	self.schedulearray = nil;
  self.disablingView = nil;
  hostReach = nil;
  [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateScheduleTable)
                                               name:NOTIFICATION_reloadSchedule
                                             object:nil];
  
  [self updateScheduleTable];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:NOTIFICATION_reloadSchedule
                                                object:nil];
  
  [super viewWillDisappear:animated];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // Return YES for supported orientations.
  //return (interfaceOrientation == UIInterfaceOrientationPortrait);
  return YES;
}




/////////////////////////
#pragma mark -
#pragma mark Support Methods
/////////////////////////
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
  [self performSelector:@selector(stopLoading) withObject:nil afterDelay:0.0];
  self.navigationItem.titleView = nil;
}


- (void)fetchScheduleFromCoreData {
	NSManagedObjectContext *context = [self managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLScheduleInfo"
                                            inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortByDate]];
	[sortByDate release];
	
	NSError *error = nil;
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	//NSLog(@"fetchedObjects count: %d",[fetchedObjects count]);
  
	for (DBLScheduleInfo *schedule in fetchedObjects) {
    [self addCoreDataScheduleToArray:schedule];
	}
  if (![managedObjectContext save:&error]) {
    // Handle the error.
    NSLog(@"Failed To Save Deleting Schedule Stores: %@", [error localizedDescription]);
  }
  else {
    NSLog(@"Successfully Deleted Schedule Stores");
  }
  
	[fetchRequest release];
}

/////////////////////////
#pragma mark -
#pragma mark Update Refresh Functions
/////////////////////////
- (void)refresh {
  [self performSelector:@selector(getLatestScheduleButtonClick:) withObject:nil afterDelay:0.0];
}

//add core data ticket to temporary array
- (void)addCoreDataScheduleToArray:(DBLScheduleInfo *)schedule {
	[self.schedulearray addObject:schedule];
}

//UI clicks refresh button
- (void)getLatestScheduleButtonClick:(id)sender
{
  [self showLoading];
  //delete core data//
  NSManagedObjectContext *context = [self managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLScheduleInfo"
                                            inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	NSError *error = nil;
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
  
	for (DBLScheduleInfo *schedule in fetchedObjects) {
    [context deleteObject:schedule];
	}
  
  if (![managedObjectContext save:&error]) {
    // Handle the error.
    NSLog(@"Failed To Save Deleting Schedule Stores: %@", [error localizedDescription]);
  }
  else {
    NSLog(@"Successfully Deleted Schedule Stores");
  }
	[fetchRequest release];
  ////////////////////
  [self getScheduleFromWebService];
}

- (void)reloadScheduleData:(NSNotification*)notification
{
  [self updateScheduleTable];
}

- (void)updateScheduleTable {
	[self.schedulearray removeAllObjects];
	[self fetchScheduleFromCoreData];
	[self.tableView reloadData];
  [self hideLoading];
}

/////////////////////////
#pragma mark -
#pragma mark Web Service Interactions
/////////////////////////

- (void)getScheduleFromWebService {
  hostReach = [[Reachability reachabilityWithHostName: TICKETS_SERVICE_DOMAIN] retain];
  NetworkStatus remoteHostStatus = [hostReach currentReachabilityStatus];
  
  if (remoteHostStatus != NotReachable) {
    
    /////////////////////////////////
    //Gets Tickets From Web Service
    SDZTickets* service = [[SDZTickets alloc] init];
    [service GetSchedule:self
                  action:@selector(GetScheduleHandler:)
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

- (void)StoreScheduleinCoreData:(id)sched
{
  SDZScheduleInfo* result = (SDZScheduleInfo*)sched;
  
  NSError *error = nil;
	
	//TRY AND READ DATA//
	NSManagedObjectContext *context = [self managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLScheduleInfo"
                                            inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"startTime = %@", [result StartTime]];
	[fetchRequest setPredicate:predicate];
	
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
  
	if ([fetchedObjects count] > 0) {
		//found a ticket with that ticket number
		//NSLog(@"Found Already Existing Ticket");
    
	}
	else {
		//did not find a ticket insert is ok to store record in core data
		//LOAD INTO CORE DATA//
		DBLScheduleInfo *event = (DBLScheduleInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"DBLScheduleInfo"
                                                                              inManagedObjectContext:managedObjectContext];
    /////////////////////////
    [event setCustomerName:[result CustomerName]];
    [event setEndTime:[result EndTime]];
    [event setOrderID:[result OrderID]];
    [event setProductID:[result ProductID]];
    [event setQty:[result Qty]];
    [event setQtyType:[result QtyType]];
    [event setStartTime:[result StartTime]];
    [event setLocationCode:[NSNumber numberWithInt:[result LocationCode]]];
    [event setLocationName:[result LocationName]];
    [event setLatitude:[result Latitude]];
    [event setLongitude:[result Longitude]];
    [event setCompleted:[NSNumber numberWithBool:[result Completed]]];
    
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"Failed To Save New Schedule: %@", [error localizedDescription]);
		}
		else {
			//NSLog(@"Saved New Ticket");
		}
	}
	[fetchRequest release];
}

- (void) GetScheduleHandler: (id) value {
  
	// Handle errors
	if([value isKindOfClass:[NSError class]] || [value isKindOfClass:[SoapFault class]]) {
    NSLog(@"Get Schedule From Web Service Class Fault: %@", value);
    [self showPopup:@"Get Schedule Class Error.  Check Connection."];
    [self updateScheduleTable];
		return;
	}
  
  else if ([value isKindOfClass:[NSString class]]) {
    NSString *response = (NSString *) value;
    if ([response isEqualToString:SERVER_RESPONSE_FAILURE_VALUE]) {
      UIAlertView *newAlert = [[UIAlertView alloc]initWithTitle:FAILURE_ALERT_TITLE_SCHEDULE
                                                        message:FAILURE_ALERT_MESSAGE_SCHEDULE
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
      [newAlert show];
      [newAlert release];
    }
    
    else {
      NSLog(@"Error: schedule returned is not of type NSMutableArray");
      return;
    }
    
  }
  
  // Do something with the NSMutableArray* result
  NSMutableArray* result = (NSMutableArray*)value;
  
  if([result count]<=0)
  {
    [self showPopup:@"No Schedule Returned."];
  }
  
  for(SDZScheduleInfo* sched in result)
  {
    [self StoreScheduleinCoreData:sched];
  }
	[self updateScheduleTable];
}


/////////////////////////
#pragma mark -
#pragma mark Table view data source
/////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  if([self.schedulearray count] > 0)
  {
    [self.sectionrowsarray removeAllObjects];
    [self.sectionheadersarray removeAllObjects];
    
    NSString *comparedate = nil;
    int sectioncount = 0;
    int rowcount = 1;
    NSString *formattedDateString = nil;
    
    for (DBLScheduleInfo *sched in schedulearray)
    {
      NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
      [dateFormat setDateFormat:SERVICE_DATE_FORMAT];
      NSDate *date = [dateFormat dateFromString:[dateFormat stringFromDate:[sched startTime]]];
      [dateFormat setDateFormat:@"MM/dd/yyyy"];
      formattedDateString = [dateFormat stringFromDate:date];
      [dateFormat release];
      
      if ([formattedDateString isEqualToString:comparedate])
      {
        rowcount++;
      }
      else
      {
        if (comparedate == nil)
        {
          rowcount = 1;
        }
        else
        {
          [self.sectionrowsarray addObject:[NSNumber numberWithInteger:rowcount]];
          rowcount = 1;
          [self.sectionheadersarray addObject:comparedate];
          
        }
        comparedate = formattedDateString;
        sectioncount++;
      }
    }
    
    if(formattedDateString != nil)
    {
      [self.sectionheadersarray addObject:formattedDateString];
    }
    
    [self.sectionrowsarray addObject:[NSNumber numberWithInteger:rowcount]];
    return sectioncount;
  }
  else
  {
    return 0;
  }
  
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if(section < [[self sectionheadersarray] count]) {
    return [self.sectionheadersarray objectAtIndex:section];
  } else {
    return @"Other Schedules";
  }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [[self.sectionrowsarray objectAtIndex:section] integerValue];
}

- (CGFloat)tableView:(UITableView *)table heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"DBLAssignmentCell";
//  DBLAssignmentCell *cell = [[DBLAssignmentCell alloc]init];
	DBLAssignmentCell *cell = [table dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DBLAssignmentCell"
                                                 owner:self
                                               options:nil];
    
    cell = [nib objectAtIndex:0];
  }
  
  CGSize measureLabel;
  NSString *text;
  
  int arrayindex = 0;
  for (int n = 0; n < indexPath.section; n++)
  {
    arrayindex += [[self.sectionrowsarray objectAtIndex:n]integerValue];
  }
  arrayindex += indexPath.row;
  
  DBLScheduleInfo *schedule = [self.schedulearray objectAtIndex:arrayindex];
  if (schedule) {
      text = [schedule.locationName substringFromIndex:1];
    measureLabel = [text sizeWithFont:[UIFont boldSystemFontOfSize:23.0f] constrainedToSize:CGSizeMake(cell.infoView.frame.size.width-135, CGFLOAT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    
    text = schedule.productID;
    measureLabel.height = measureLabel.height + [text sizeWithFont:[UIFont systemFontOfSize:20.0f] constrainedToSize:CGSizeMake(cell.infoView.frame.size.width-97, CGFLOAT_MAX) lineBreakMode:NSLineBreakByCharWrapping].height;
    
    text = schedule.customerName;
    measureLabel.height = measureLabel.height + [text sizeWithFont:[UIFont systemFontOfSize:17.0f] constrainedToSize:CGSizeMake(cell.infoView.frame.size.width-96, CGFLOAT_MAX) lineBreakMode:NSLineBreakByCharWrapping].height;
    
    if (measureLabel.height+70 < 160) {
      return 160;
    }
    else {
      return measureLabel.height+70;
    }
  }

  else {
    return 160;
  }
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  static NSString *CellIdentifier = @"DBLAssignmentCell";
	
	DBLAssignmentCell *cell = [table dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DBLAssignmentCell"
                                                 owner:self
                                               options:nil];
    
    cell = [nib objectAtIndex:0];
  }
  
  for (UIView *subview in cell.infoView.subviews) {
    [subview removeFromSuperview];
  }
  
  int arrayindex = 0;
  for (int n = 0; n < indexPath.section; n++)
  {
    arrayindex += [[self.sectionrowsarray objectAtIndex:n]integerValue];
  }
  arrayindex += indexPath.row;
  
  DBLScheduleInfo *schedule = [self.schedulearray objectAtIndex:arrayindex];
  if (schedule)
  {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:SERVICE_DATE_FORMAT];
    NSString *startTimeDateString = [dateFormat stringFromDate:[schedule startTime]];
    
    CGSize measureLabel;
    NSString *text;
    
    ////// topmost line
    
    UILabel *lblLocationHeader = [[UILabel alloc]init];
    [lblLocationHeader setText:@"Location: "];
    [lblLocationHeader setFont:[UIFont boldSystemFontOfSize:24.0f]];
    [lblLocationHeader sizeToFit];
    [lblLocationHeader setFrame:CGRectMake(0, 4, lblLocationHeader.frame.size.width, lblLocationHeader.frame.size.height)];
    
    UILabel *lblCapital = [[UILabel alloc]init];
    [lblCapital setText:[NSString stringWithFormat:@"%C", [schedule.locationName characterAtIndex:0]]];
    [lblCapital setFont:[UIFont boldSystemFontOfSize:27.0f]];
    [lblCapital sizeToFit];
    [lblCapital setFrame:CGRectMake(lblLocationHeader.frame.origin.x+lblLocationHeader.frame.size.width, 2, lblCapital.frame.size.width, lblCapital.frame.size.height)];
    
  text = [schedule.locationName substringFromIndex:1];
    
    UILabel *lblLocationText = [[UILabel alloc]init];
    [lblLocationText setText:text];
    [lblLocationText setFont:[UIFont boldSystemFontOfSize:23.0f]];
    [lblLocationText setNumberOfLines:0];
    [lblLocationText setBackgroundColor:[UIColor clearColor]];
    
    measureLabel = [text sizeWithFont:[UIFont boldSystemFontOfSize:23.0f] constrainedToSize:CGSizeMake(cell.infoView.frame.size.width-(lblCapital.frame.size.width+lblCapital.frame.origin.x), CGFLOAT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    
    [lblLocationText setFrame:CGRectMake(lblCapital.frame.size.width+lblCapital.frame.origin.x, 6, measureLabel.width, measureLabel.height)];
    
    
    /////
    
    UILabel *lblProductHeader = [[UILabel alloc]init];
    [lblProductHeader setText:@"Product: "];
    [lblProductHeader setFont:[UIFont boldSystemFontOfSize:22.0f]];
    [lblProductHeader sizeToFit];
    [lblProductHeader setFrame:CGRectMake(0, lblLocationText.frame.size.height+3, lblProductHeader.frame.size.width, lblProductHeader.frame.size.height)];
    
    text = schedule.productID;
    
    UILabel *lblProduct = [[UILabel alloc]init];
    [lblProduct setText:text];
    [lblProduct setFont:[UIFont systemFontOfSize:20.0f]];
    [lblProduct setNumberOfLines:0];
    [lblProduct setBackgroundColor:[UIColor clearColor]];
    
    measureLabel = [text sizeWithFont:[UIFont systemFontOfSize:20.0f] constrainedToSize:CGSizeMake(cell.infoView.frame.size.width-lblProductHeader.frame.size.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    [lblProduct setFrame:CGRectMake(lblProductHeader.frame.size.width, lblProductHeader.frame.origin.y, measureLabel.width, measureLabel.height)];

    /////
    
    UILabel *lblQtyHeader = [[UILabel alloc]init];
    [lblQtyHeader setText:@"Qty: "];
    [lblQtyHeader setFont:[UIFont boldSystemFontOfSize:18.0f]];
    [lblQtyHeader sizeToFit];
    [lblQtyHeader setFrame:CGRectMake(0, lblProduct.frame.origin.y+lblProduct.frame.size.height, lblQtyHeader.frame.size.width, lblQtyHeader.frame.size.height)];
    
    UILabel *lblQty = [[UILabel alloc]init];
    [lblQty setText:[NSString stringWithFormat:@"%@ %@", schedule.qty, schedule.qtyType]];
    [lblQty setFont:[UIFont systemFontOfSize:17.0f]];
    [lblQty sizeToFit];
    [lblQty setFrame:CGRectMake(lblQtyHeader.frame.size.width, lblQtyHeader.frame.origin.y, lblQty.frame.size.width, lblQty.frame.size.height)];
    
    /////
    
    
    UILabel *lblTimeHeader = [[UILabel alloc]init];
    [lblTimeHeader setText:@"Time: "];
    [lblTimeHeader setFont:[UIFont boldSystemFontOfSize:18.0f]];
    [lblTimeHeader sizeToFit];
    [lblTimeHeader setFrame:CGRectMake(0, lblQtyHeader.frame.size.height+lblQtyHeader.frame.origin.y, lblTimeHeader.frame.size.width, lblTimeHeader.frame.size.height)];
    
    UILabel *lblTime = [[UILabel alloc]init];
    [lblTime setText:startTimeDateString];
    [lblTime setFont:[UIFont systemFontOfSize:17.0f]];
    [lblTime sizeToFit];
    [lblTime setFrame:CGRectMake(lblTimeHeader.frame.size.width+lblTimeHeader.frame.origin.x, lblTimeHeader.frame.origin.y, lblTime.frame.size.width, lblTime.frame.size.height)];
    
    
    /////
    
    UILabel *lblCustomerHeader = [[UILabel alloc]init];
    [lblCustomerHeader setText:@"Customer: "];
    [lblCustomerHeader setFont:[UIFont boldSystemFontOfSize:18.0f]];
    [lblCustomerHeader sizeToFit];
    [lblCustomerHeader setFrame:CGRectMake(0, lblTimeHeader.frame.size.height+lblTimeHeader.frame.origin.y, lblCustomerHeader.frame.size.width, lblCustomerHeader.frame.size.height)];
    
    text = schedule.customerName;
    
    measureLabel = [text sizeWithFont:[UIFont systemFontOfSize:17.0f] constrainedToSize:CGSizeMake(cell.infoView.frame.size.width-lblCustomerHeader.frame.size.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    
    UILabel *lblCustomer = [[UILabel alloc]init];
    [lblCustomer setText:text];
    [lblCustomer setFont:[UIFont systemFontOfSize:17.0f]];
    [lblCustomer setNumberOfLines:0];
    [lblCustomer setFrame:CGRectMake(lblCustomerHeader.frame.size.width, lblCustomerHeader.frame.origin.y, measureLabel.width, measureLabel.height)];
    
    //////
    
    UILabel *lblOrderIDHeader = [[UILabel alloc]init];
    [lblOrderIDHeader setText:@"Order ID: "];
    [lblOrderIDHeader setFont:[UIFont boldSystemFontOfSize:18.0f]];
    [lblOrderIDHeader sizeToFit];
    [lblOrderIDHeader setFrame:CGRectMake(0, lblCustomer.frame.size.height+lblCustomer.frame.origin.y, lblOrderIDHeader.frame.size.width, lblOrderIDHeader.frame.size.height)];
    
    UILabel *lblOrderID = [[UILabel alloc]init];
    [lblOrderID setText:schedule.orderID];
    [lblOrderID setFont:[UIFont systemFontOfSize:17.0f]];
    [lblOrderID sizeToFit];
    [lblOrderID setFrame:CGRectMake(lblOrderIDHeader.frame.size.width, lblOrderIDHeader.frame.origin.y, lblOrderID.frame.size.width, lblOrderID.frame.size.height)];
    
    [cell.infoView addSubview:lblLocationHeader];
    [cell.infoView addSubview:lblCapital];
    [cell.infoView addSubview:lblLocationText];
    
    [cell.infoView addSubview:lblProductHeader];
    [cell.infoView addSubview:lblProduct];
    
    [cell.infoView addSubview:lblQtyHeader];
    [cell.infoView addSubview:lblQty];
    
    [cell.infoView addSubview:lblCustomerHeader];
    [cell.infoView addSubview:lblCustomer];
    
    [cell.infoView addSubview:lblOrderIDHeader];
    [cell.infoView addSubview:lblOrderID];
    
    [cell.infoView addSubview:lblTimeHeader];
    [cell.infoView addSubview:lblTime];
    
    [cell setSchedule:schedule];
    [cell setCompleted:[(NSNumber*)[schedule valueForKey:@"completed"] boolValue]];
    
    [lblOrderID release];
    [lblOrderIDHeader release];
    [lblLocationText release];
    [lblLocationHeader release];
    [lblCustomer release];
    [lblCustomerHeader release];
    [lblProduct release];
    [lblProductHeader release];
    [lblQty release];
    [lblQtyHeader release];
    [lblTime release];
    [lblTimeHeader release];
    [lblCapital release];
    [dateFormat release];
  
  }
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  DBLMapViewController *tVC = [[DBLMapViewController alloc] initWithNibName:@"DBLMapView" bundle:[NSBundle mainBundle]];
  
  DBLScheduleInfo *schedule = [self.schedulearray objectAtIndex:indexPath.row];
  
  CLLocationCoordinate2D temp;
  if([[schedule latitude] doubleValue] == 0) {
    [self showPopup:@"No GPS Coordinates for Selected Schedule Item"];
  }
  else {
    temp.latitude = [[schedule latitude] doubleValue];
    temp.longitude = [[schedule longitude] doubleValue];
    tVC.ll1 = temp;
  }
	
  tVC.navigationItem.title = @"Map View";
  
  [self.navigationController pushViewController:tVC animated:YES];
  [tVC release];
}


/////////////////////////
#pragma mark -
#pragma mark Memory Management
/////////////////////////
- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)dealloc {
  [getLatestScheduleButton release];
  [spinner release];
	[schedulearray release];
  [super dealloc];
}


@end
