//
//  DBLScaleViewController.m
//  DBL
//
//  Created by Tobias O'Leary on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DBLScaleViewController.h"

#import "SDZTickets.h"

#import "DBLAppDelegate.h"
#import "NSData+Base64.h"
#import "DBLCLController.h"
#import "DBLTicket.h"

@interface DBLScaleViewController ()

- (void)startTareTicketInitialWithWeighingType:(DBLWeighingType)weighingType location:(CLLocation*)location;
- (void)completedTareTicketInitial:(id)value;

- (void)startTareWithPreferredScaleNumber:(NSString*)preferred selectedScaleNumber:(NSString*)selected location:(CLLocation*)location;
- (void)completedTare:(id)value;

- (void)startSelfTicketWithPreferredScaleNumber:(NSString*)preferred selectedScaleNumber:(NSString*)selected location:(CLLocation*)location;
- (void)completedSelfTicket:(id)value;

- (void)storeTicketInCoreData:(id)tkt;

@end

@implementation DBLScaleViewController

@synthesize priorityScaleNumber = _priorityScaleNumber;
@synthesize selectedWeighingType = _selectedWeighingType;
@synthesize plantNameLabel = _plantNameLabel;
@synthesize scaleNumberLabel = _scaleNumberLabel;
@synthesize scaleSegmentedControl = _scaleSegmentedControl;
@synthesize tareButton = _tareButton;
@synthesize ticketButton = _ticketButton;
@synthesize submitButton = _submitButton;
@synthesize resetButton = _resetButton;
@synthesize messageLabel = _messageLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _selectedWeighingType = DBLWeighingUnknown;
  }
  
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [[self plantNameLabel] setText:@"Undetermined Plant"];
  [[self scaleSegmentedControl] removeAllSegments];
  [[self scaleSegmentedControl] insertSegmentWithTitle:@"Undetermined Scales" atIndex:0 animated:NO];
  [[self scaleSegmentedControl] setEnabled:NO];
  
  [[self messageLabel] setText:@"Unable to determine your current plant"];
  
  [self setTitle:@"Scaling"];
  [[self navigationItem] setTitle:@"Self-Service Scaling"];
}

- (void)viewWillAppear:(BOOL)animated
{
  
  //Show Activity Indicator
  [[self messageLabel] setText:@"Select either Tare or Ticket."];
  [[self messageLabel] setTextColor:[UIColor whiteColor]];
  
  [self showWeighingTypeButton:YES];
  [self showSubmitInputs:NO];
  
}

- (void)showWeighingTypeButton:(BOOL)show
{
  [[self tareButton] setEnabled:show];
  [[self tareButton] setHidden:!show];
  [[self ticketButton] setEnabled:show];
  [[self ticketButton] setHidden:!show];
  
}

- (void)showSubmitInputs:(BOOL)show
{
  [[self plantNameLabel] setHidden:!show];
  
  [[self scaleNumberLabel] setHidden:!show];
  [[self scaleSegmentedControl] setEnabled:show];
  [[self scaleSegmentedControl] setHidden:!show];
  
  [[self submitButton] setEnabled:show];
  [[self submitButton] setHidden:!show];
  
  [[self resetButton] setEnabled:show];
  [[self resetButton] setHidden:!show];
}

- (void)viewDidUnload
{
  
  [self setPlantNameLabel:nil];
  [self setScaleSegmentedControl:nil];
  [self setTareButton:nil];
  [self setTicketButton:nil];
  [self setMessageLabel:nil];
  
  [self setSubmitButton:nil];
  [self setScaleNumberLabel:nil];
  [self setResetButton:nil];
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
  
  [_plantNameLabel release];
  [_scaleSegmentedControl release];
  [_tareButton release];
  [_ticketButton release];
  [_messageLabel release];
  
  [_submitButton release];
  [_scaleNumberLabel release];
  [_resetButton release];
  [super dealloc];
}

#pragma mark - Web Service Interaction Methods

- (void)startTareTicketInitialWithWeighingType:(DBLWeighingType)weighingType location:(CLLocation*)location
{
  SDZTickets* service = [SDZTickets service];
  
  [service TareTicket_Initial:self 
                       action:@selector(completedTareTicketInitial:) 
                     deviceid:[APP_DELEGATE deviceId] 
                         udid:[APP_DELEGATE UDID]
               tare_or_ticket:(int)weighingType
                     latitude:[NSString stringWithFormat:@"%f", [location coordinate].latitude] 
                    longitude:[NSString stringWithFormat:@"%f", [location coordinate].longitude]];
  
}

- (void) completedTareTicketInitial: (id) value 
{
  
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
    [[self messageLabel] setTextColor:[UIColor redColor]];
    [[self messageLabel] setText:[NSString stringWithFormat:@"Error: \"%@\"", value]];
		return;
	}
  
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
    [[self messageLabel] setTextColor:[UIColor redColor]];
    [[self messageLabel] setText:[NSString stringWithFormat:@"Error: \"%@\"", value]];
		return;
	}				
  
  NSString* result = (NSString*)value;
  if(result == nil) {
    NSString *message = @"Server Denied Access, Please make sure you have a Device ID";
    [[self messageLabel] setTextColor:[UIColor redColor]];
    [[self messageLabel] setText:message];
    [[self resetButton] setHidden:NO];
    [[self resetButton] setEnabled:YES];
    return;
  }
  
  NSRange commaRange = [result rangeOfString:@","];
  if(commaRange.location == NSNotFound) {
    NSString *message = result;
    [[self messageLabel] setTextColor:[UIColor redColor]];
    [[self messageLabel] setText:message];
    [[self resetButton] setHidden:NO];
    [[self resetButton] setEnabled:YES];
    return;
  }
  
  NSArray *resultComponents = [result componentsSeparatedByString:@","];
  
  if([resultComponents count] == 1) {
    [[self messageLabel] setText:result];
  }
  
  NSMutableArray *scaleNumbers = [[NSMutableArray alloc] initWithCapacity:[resultComponents count]-1];
  for(NSUInteger i = 0; i < [resultComponents count]-1; ++i) {
    NSString *scaleNumber = [[resultComponents objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [scaleNumbers addObject:scaleNumber];
  }
  
  NSString *plantName = [[resultComponents lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  if([plantName length] == 0) {
    plantName = @"Unknown Plant";
  }
  
  [[self plantNameLabel] setText:plantName];
  
  NSString *priorityScaleNumber = [scaleNumbers objectAtIndex:0];
  
  [scaleNumbers sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
  
  NSUInteger segmentIndex = 0;
  [[self scaleSegmentedControl] removeAllSegments];
  for(NSString *scaleNumber in scaleNumbers) {
    [[self scaleSegmentedControl] insertSegmentWithTitle:scaleNumber atIndex:segmentIndex animated:NO];
    if([scaleNumber isEqualToString:priorityScaleNumber]) {
      [[self scaleSegmentedControl] setSelectedSegmentIndex:segmentIndex];
      [self setPriorityScaleNumber:priorityScaleNumber];
    }
    segmentIndex++;
  }
  [[self scaleSegmentedControl] setEnabled:YES];
  
  [scaleNumbers release];
  
  [[self messageLabel] setText:@"Double-check your scale and tap \"Send Scale Number\""];
  [self showSubmitInputs:YES];
}

- (void)startTareWithPreferredScaleNumber:(NSString*)preferred selectedScaleNumber:(NSString*)selected location:(CLLocation*)location
{
  SDZTickets* service = [SDZTickets service];
  
  [service SelfTare:self 
             action:@selector(completedTare:) 
           deviceid:[APP_DELEGATE deviceId]
               udid:[APP_DELEGATE UDID]
   laneid_preferred:[preferred intValue]
    laneid_selected:[selected intValue]
           latitude:[NSString stringWithFormat:@"%f", [location coordinate].latitude]
          longitude:[NSString stringWithFormat:@"%f", [location coordinate].longitude]];
}

- (void)completedTare:(id)value
{
  // Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
    [[self messageLabel] setTextColor:[UIColor redColor]];
    [[self messageLabel] setText:[NSString stringWithFormat:@"Error: \"%@\"", value]];
    [[self resetButton] setHidden:NO];
    [[self resetButton] setEnabled:YES];
		return;
	}
  
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
    [[self messageLabel] setTextColor:[UIColor redColor]];
    [[self messageLabel] setText:[NSString stringWithFormat:@"Error: \"%@\"", value]];
    [[self resetButton] setHidden:NO];
    [[self resetButton] setEnabled:YES];
		return;
	}				
  
  
	// Do something with the NSString* result
  NSString* result = (NSString*)value;
	NSLog(@"Tare returned the value: %@", result);
  
  
  [[self messageLabel] setText:result];
  [[self resetButton] setHidden:NO];
  [[self resetButton] setEnabled:YES];
  
}

- (void)startSelfTicketWithPreferredScaleNumber:(NSString*)preferred selectedScaleNumber:(NSString*)selected location:(CLLocation*)location
{
  SDZTickets* service = [SDZTickets service];
  
  [service SelfTicket:self 
               action:@selector(completedSelfTicket:) 
             deviceid:[APP_DELEGATE deviceId]
                 udid:[APP_DELEGATE UDID]
     laneid_preferred:[preferred intValue]
      laneid_selected:[selected intValue]
             latitude:[NSString stringWithFormat:@"%f", [location coordinate].latitude]
            longitude:[NSString stringWithFormat:@"%f", [location coordinate].longitude]];
}

- (void)completedSelfTicket:(id)value
{
  
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
    [[self messageLabel] setTextColor:[UIColor redColor]];
    [[self messageLabel] setText:[NSString stringWithFormat:@"Error: \"%@\"", value]];
    [[self resetButton] setHidden:NO];
    [[self resetButton] setEnabled:YES];
		return;
	}
  
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
    [[self messageLabel] setTextColor:[UIColor redColor]];
    [[self messageLabel] setText:[NSString stringWithFormat:@"Error: \"%@\"", value]];
    [[self resetButton] setHidden:NO];
    [[self resetButton] setEnabled:YES];
		return;
	}				
  
  
	// Do something with the SDZTicketResponse* result
  SDZTicketResponse* result = (SDZTicketResponse*)value;
	NSLog(@"SelfTicket returned the value: %@", result);
  
  if([result IsTaring]) {
    [self completedTare:[result Message]];
    return;
  } else if([result Success] && ![result IsTaring] && [self selectedWeighingType] == DBLWeighingTicket) {
    [self storeTicketInCoreData:result.Ticket];

  }

  [[self messageLabel] setText:result.Message];
  
  if([result Success] == NO) {
    [[self messageLabel] setTextColor:[UIColor redColor]];
  }
  
  [[self resetButton] setHidden:NO];
  [[self resetButton] setEnabled:YES];
}

- (void)storeTicketInCoreData:(id)tkt
{
  SDZTicket* result = (SDZTicket*)tkt;
  
  NSError *error = nil;
	
	//TRY AND READ DATA//
	NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLTicket" 
                                            inManagedObjectContext:context];
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
  //gowri
  
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
    // Handle the error.
    NSLog(@"Failed To Save New Ticket: %@", [error localizedDescription]);
  }
  else {
    //NSLog(@"Saved New Ticket");
  }
  
  [fetchRequest release];
}

#pragma mark - Interface Event Handlers
- (IBAction)weighingButtonTapped:(id)sender {
  if(sender == [self tareButton]) {
    [self setSelectedWeighingType:DBLWeighingTare];
  } else if(sender == [self ticketButton]) {
    [self setSelectedWeighingType:DBLWeighingTicket];
  }
  [[self messageLabel] setText:@"Determining your Plant and Scale..."];
  
  [self showWeighingTypeButton:NO];
  
  
  [self startTareTicketInitialWithWeighingType:[self selectedWeighingType] 
                                      location:[[DBLCLController sharedCLController] lastLocation]];
  
}

- (IBAction)submitButtonTapped:(id)sender {
  
  [self showSubmitInputs:NO];
  [[self messageLabel] setText:@"Sending Scale Information and Weighing..."];
  
  NSString *preferredScaleNumber = [self priorityScaleNumber];
  NSString *selectedScaleNumber = [[self scaleSegmentedControl] titleForSegmentAtIndex:[[self scaleSegmentedControl] selectedSegmentIndex]];
  
  if([self selectedWeighingType] == DBLWeighingTare) {
    [self startTareWithPreferredScaleNumber:preferredScaleNumber
                        selectedScaleNumber:selectedScaleNumber
                                   location:[[DBLCLController sharedCLController] lastLocation]];
    
  } else if([self selectedWeighingType] == DBLWeighingTicket) {
    [self startSelfTicketWithPreferredScaleNumber:preferredScaleNumber
                              selectedScaleNumber:selectedScaleNumber
                                         location:[[DBLCLController sharedCLController] lastLocation]];
  }
  
  
}

- (IBAction)resetButtonTapped:(id)sender {
  
  [[self messageLabel] setText:@"Select either Tare or Ticket."];
  [[self messageLabel] setTextColor:[UIColor whiteColor]];
  
  [self showWeighingTypeButton:YES];
  [self showSubmitInputs:NO];
}
@end
