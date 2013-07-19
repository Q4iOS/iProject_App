//
//  DBLTaskManager.m
//  DBL
//
//  Created by Tobias O'Leary on 2/14/12.
//  Copyright (c) 2012 Luck Stone. All rights reserved.
//

#import "DBLTaskManager.h"
#import "SDZTickets.h"
#import "DBLMessage.h"
#import "DBLAppDelegate.h"
#import "NSData+Base64.h"
#import "DBLScheduleInfo.h"
#import "DBLTicket.h"

@interface DBLTaskManager()

- (void)storeTicketinCoreData:(id)tkt;
- (void)storeScheduleinCoreData:(id)schedule;

@end

@implementation DBLTaskManager

#pragma mark -
#pragma mark Object lifecycle

- (id)init
{
  self = [super init];
  if(self) {
    _delegates = [[NSMutableArray alloc] initWithCapacity:8];
  }
  return self;
}

- (void)dealloc
{
  [_delegates release];
  [super dealloc];
}


#pragma mark -
#pragma mark Delegate Management

- (void)addDelegate:(id<DBLTaskManagerDelegate>)delegate
{
  if([_delegates containsObject:delegate] == NO) {
    [_delegates addObject:delegate];
  }
}

- (void)removeDelegate:(id<DBLTaskManagerDelegate>)delegate
{
  [_delegates removeObject:delegate];
}


#pragma mark -
#pragma mark Task Execution
- (void)executeTaskNamed:(NSString *)taskName
{
  NSRange poundRange = [taskName rangeOfString:@"#"];
  
  NSLog(@"server command is: %@", taskName);
  
  if([taskName isEqualToString:@"GetTicket"]) {
    [self getTicket];
  } else if([taskName isEqualToString:@"GetMessage"]) {
    [self getMessage];
  } else if([taskName isEqualToString:@"RefreshAssignments"]){
    [self refreshAssignments];
  }
  
  //Check if there's a # sign to see if it's a delete message
  else if (poundRange.location != NSNotFound) {
    [self deleteTicket:taskName];
  }
  else {
    NSAssert1(NO, @"Unknown Task: %@", taskName);
  }
  
}

-(void)deleteTicket: (NSString*) command{
  //command is still separated by # so let's parse it
  NSArray *parsed = [command componentsSeparatedByString:@"#"];
  NSString *ticketID = [parsed objectAtIndex:1];
  NSString *locationID = [parsed objectAtIndex:2];
  
  NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLTicket" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
  
	NSPredicate *ticketPredicate = [NSPredicate predicateWithFormat:@"ticketNumber = %@", ticketID];
  NSPredicate *locationPredicate = [NSPredicate predicateWithFormat:@"locationCode = %@", locationID];
  NSArray *subPredicates = [NSArray arrayWithObjects:ticketPredicate, locationPredicate, nil];
  NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
  [fetchRequest setPredicate:compoundPredicate];
  
  NSError *error;
  NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
  
  //found the right ticket
  if ([fetchedObjects count] != 0) {
    NSLog(@"I found a ticket that I want to delete: \n ticketNumber: %@ \n locationCode: %@", ticketID, locationID);
    [context deleteObject:[fetchedObjects objectAtIndex:0]];
    
    if (![context save:&error]) {
      // Handle the error.
      NSLog(@"Failed To Delete Ticket: %@", [error localizedDescription]);
      
    }
    else {
      //Successful
#pragma mark - Test environment; post a notification to force ticketVC to reload
      [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_reloadTickets object:nil];
    }
  }
  else {
    NSLog(@"Did not find the ticket");
  }
  
  [fetchRequest release];
  fetchedObjects = nil;
  parsed = nil;
  subPredicates = nil;
}

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (void)getTicket
{
  
  SDZTickets* service = [[SDZTickets alloc] init];
  [service GetTicket:self
              action:@selector(getTicketHandler:)
            deviceid:[APP_DELEGATE deviceId]
                udid:[APP_DELEGATE UDID]
           automated:1];
  [service release];
}

- (void)getTicketHandler:(id)value {
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"Get Ticket From Web Service Class Fault: %@", value);
		return;
	}
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"Get Ticket From Web Service Soap Fault: %@", value);
		return;
	}
	
	SDZTicket* result = (SDZTicket*)value;
	if (result.TicketNumber == nil) {
		NSLog(@"No Ticket Returned");
		return;
	}
	
	[self storeTicketinCoreData:result];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_updateTicket
                                                      object:nil];
}

- (void)storeTicketinCoreData:(id)tkt
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
    NSString *signatureResult = [[NSString alloc] initWithData:result.Signature2
                                                      encoding:NSUTF8StringEncoding];
    
    NSData *signatureData = [[NSData alloc] initWithBase64EncodedString:signatureResult];
    event.signature2 = signatureData;
  }
  if(result.Signature3) {
    NSString *signatureResult = [[NSString alloc] initWithData:result.Signature3
                                                      encoding:NSUTF8StringEncoding];
    
    NSData *signatureData = [[NSData alloc] initWithBase64EncodedString:signatureResult];
    event.Signature3 = signatureData;
  }
  if(result.Signature4) {
    NSString *signatureResult = [[NSString alloc] initWithData:result.Signature4
                                                      encoding:NSUTF8StringEncoding];
    
    NSData *signatureData = [[NSData alloc] initWithBase64EncodedString:signatureResult];
    event.Signature4 = signatureData;
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


- (void)getMessage
{
  
  SDZTickets* service = [[SDZTickets alloc] init];
  [service GetMessage:self
               action:@selector(getMessageHandler:)
             deviceid:[APP_DELEGATE deviceId]
                 udid:[APP_DELEGATE UDID]];
  [service release];
}

- (void)getMessageHandler:(id)value {
  
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
  
  SDZMessageObject* result = (SDZMessageObject*)value;
  //Store the SDZMessageObject immediately into coredata
  NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
  DBLSavedMessage *storeMessage = [NSEntityDescription insertNewObjectForEntityForName:@"DBLSavedMessage" inManagedObjectContext:context];
  NSError *error;
  
  NSDictionary *userInfo = [[NSDictionary alloc]initWithObjectsAndKeys:
                            [NSNumber numberWithInt:result.Accepted], @"accepted",
                            [NSNumber numberWithInt:result.Acknowledged], @"acknowledged",
                            [NSNumber numberWithBool:result.Closed], @"closed",
                            [NSNumber numberWithBool:NO], @"hasRead",
                            result.Message, @"message",
                            [NSNumber numberWithInt:result.MessageID], @"messageID",
                            result.Sender, @"sender",
                            [NSNumber numberWithInt:result.MessageType], @"messageType",
                            nil];
  
  [storeMessage setValuesForKeysWithDictionary:userInfo];
  [storeMessage setValue:[NSNumber numberWithBool:NO] forKey:@"responded"];
  [storeMessage setValue:[NSDate date] forKey:@"received"];
  
  if (![context save:&error]) {
    NSLog(@"Error saving message");
  }
  
  UILocalNotification *localNotification = [[UILocalNotification alloc] init];
  [localNotification setFireDate:[NSDate dateWithTimeIntervalSinceNow:5]];
  
  [localNotification setAlertBody:[result Message]];
  [localNotification setAlertAction:@"Ok"];
  [localNotification setSoundName:UILocalNotificationDefaultSoundName];
  [localNotification setUserInfo:userInfo];
  [userInfo release];
  [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
  
  if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
    [APP_DELEGATE newMessageReceived];
  }
  
  [localNotification release];
}

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (void)refreshAssignments
{
  
  NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLScheduleInfo"
                                            inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	NSError *error = nil;
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
  
	for (DBLScheduleInfo *schedule in fetchedObjects) {
    [context deleteObject:schedule];
	}
  
  if (![context save:&error]) {
    // Handle the error.
    NSLog(@"Failed To Save Deleting Schedule Stores: %@", [error localizedDescription]);
  }
  else {
    NSLog(@"Successfully Deleted Schedule Stores");
  }
	[fetchRequest release];
  
  SDZTickets* service = [[SDZTickets alloc] init];
  [service GetSchedule:self
                action:@selector(refreshAssignmentsHandler:)
              deviceid:[APP_DELEGATE deviceId]
                  udid:[APP_DELEGATE UDID]];
  [service release];
}

- (void)refreshAssignmentsHandler:(id)value
{
  // Handle errors
	if([value isKindOfClass:[NSError class]]) {
    NSLog(@"Get Schedule From Web Service Class Fault: %@", value);
		return;
	}
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
    NSLog(@"Get Schedule From Web Service Soap Fault: %@", value);
		return;
	}
  
  
  // Do something with the NSMutableArray* result
  NSLog(@"Refresh Assignments %@", [value description]);
  NSMutableArray* result = (NSMutableArray*)value;
  
  NSLog(@"Result Count: %d", [result count]);
  
  for(SDZScheduleInfo* sched in result)
  {
    [self storeScheduleinCoreData:sched];
  }
  
  [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_reloadSchedule object:nil];
}

- (void)storeScheduleinCoreData: (id)sched
{
  SDZScheduleInfo* result = (SDZScheduleInfo*)sched;
  
  NSError *error = nil;
	
	//TRY AND READ DATA//
	NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLScheduleInfo"
                                            inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"startTime = %@", result.StartTime];
	[fetchRequest setPredicate:predicate];
	
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
  
	if ([fetchedObjects count] > 0) {
		//found a ticket with that ticket number
		//NSLog(@"Found Already Existing Ticket");
    
	}
	else {
		//did not find a ticket insert is ok to store record in core data
    
		//LOAD INTO CORE DATA//
		DBLScheduleInfo *event = [NSEntityDescription insertNewObjectForEntityForName:@"DBLScheduleInfo"
                                                           inManagedObjectContext:context];
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
    [event setAllowselfticket:[NSNumber numberWithBool:result.AllowSelfTicket]];
    
		if (![context save:&error]) {
			// Handle the error.
			NSLog(@"Failed To Save New Schedule: %@", [error localizedDescription]);
		}
		else {
			NSLog(@"Saved Assignment for %@", [result CustomerName]);
		}
	}
	[fetchRequest release];
}

@end
