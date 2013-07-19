//
//  MyCLController.m
//  DBL
//
//  Created by Ryan Emmons on 3/11/11.
//  Copyright 2011 Luck Stone. All rights reserved.
//

#import "DBLCLController.h"
#import "Reachability.h"
#import "DBLAppDelegate.h"
#import "DBLTaskManager.h"
#import "DBLLocationLocal.h"

CLLocationDistance kLocationManagerDistanceFilter = 0.1; //In Meters
NSTimeInterval kTimeIntervalToSendLocationData = 30.0; //In Seconds

@implementation DBLCLController

@synthesize locationManager, locationManagerStartDate, lastLocationStoreTimeStamp;
@synthesize managedObjectContext;
@synthesize locationsarray;
@synthesize lastLocation;

/////////////////////////
#pragma mark -
#pragma mark Constants
/////////////////////////
static NSString * const kReachServerAddress = TICKETS_SERVICE_DOMAIN;
NSString * storereason = @"";
NSString * storeresult = @"";
NSTimer *myTimer;

- (id) init {
  self = [super init];
  if (self != nil) {
    //Setup Location Manager
    CLLocationManager *locManager = [[CLLocationManager alloc] init];
    [locManager setDelegate:self];
    [locManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locManager setDistanceFilter:kLocationManagerDistanceFilter]; 
    [self setLocationManager:locManager];
    [locManager release];
    
    [self setLocationManagerStartDate: [NSDate date]];
    [self setLastLocationStoreTimeStamp:[NSDate date]];
    
    //Setup Reachability Changed Notification
    lostconnection = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(reachabilityChanged:) 
                                                 name:kReachabilityChangedNotification 
                                               object:nil];
    hostReach = [[Reachability reachabilityWithHostName: kReachServerAddress] retain];
    [hostReach startNotifier];
    
    //Setup CoreData
    
    if (managedObjectContext == nil) 
    { 
      [self setManagedObjectContext:[(DBLAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]]; 
    }
    
    //Setup Timer to Control Rate at which location information is sent to the server.
    firststore = YES;
    myTimer = [NSTimer scheduledTimerWithTimeInterval:kTimeIntervalToSendLocationData 
                                               target:self 
                                             selector:@selector(fetchAndStoreLocationsFromCoreData) 
                                             userInfo:nil 
                                              repeats:YES];
    [myTimer retain];
  }
  return self;
}

- (NSMutableArray *)locationsarray {
  if (!locationsarray) {
    self.locationsarray = [NSMutableArray array];
  }
  return locationsarray;
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
  hostReach = [[Reachability reachabilityWithHostName: kReachServerAddress] retain];
  NetworkStatus remoteHostStatus = [hostReach currentReachabilityStatus];
  switch(remoteHostStatus) {
    case ReachableViaWiFi:
    case ReachableViaWWAN: {
      lostconnection = NO;
      break;
    }
    case NotReachable:
    default: {
      lostconnection = YES;
    }
  }
}


- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
  
  [self setLastLocation:newLocation];
  
  NSDictionary *locationChangedDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       manager, @"Manager", 
                                       newLocation, @"NewLocation", 
                                       oldLocation, @"OldLocation", nil];
  [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_locationChanged
                                                      object:nil
                                                    userInfo:locationChangedDict];
  [locationChangedDict release];
  
  //store gps data to local core data//
  //NSLog(@"Location Updated. Storing Locally.");  
  if([self isValidLocation:newLocation withOldLocation:oldLocation]) {
    storeresult = @"YES";
    //NSLog(@"GOOD LOCAL STORE LOCATION");
  } else {
    storeresult = @"NO";
    //NSLog(@"BAD STORE");
  }
  
  if ([storereason isEqualToString:@"Location Was Not Valid.  Last Store was Less than 3 seconds ago."] == NO) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *latitude = [[NSString alloc] initWithFormat:@"%g", newLocation.coordinate.latitude];
    NSString *longitude = [[NSString alloc] initWithFormat:@"%g", newLocation.coordinate.longitude];
    NSString *speed = [[NSString alloc] initWithFormat:@"%g",newLocation.speed];
    NSString *verticalAccuracy = [[NSString alloc] initWithFormat:@"%g",newLocation.verticalAccuracy];
    NSString *horizontalAccuracy = [[NSString alloc] initWithFormat:@"%g",newLocation.horizontalAccuracy];
    NSString *course = [[NSString alloc] initWithFormat:@"%g",newLocation.course];
    NSString *altitude = [[NSString alloc] initWithFormat:@"%g",newLocation.altitude];
    
    NSString *uniqueIdentifier = [defaults objectForKey:@"name_preference"];
    
    NSError *error = nil;
    
    NSManagedObjectContext *context = [self managedObjectContext];
    DBLLocationLocal *insertedLocation = [NSEntityDescription
                                          insertNewObjectForEntityForName:@"DBLLocationLocal" 
                                          inManagedObjectContext:context];
    [insertedLocation setLatitude:latitude];
    [insertedLocation setLongitude:longitude];
    [insertedLocation setSpeed:speed];
    [insertedLocation setVerticalAccuracy:verticalAccuracy];
    [insertedLocation setHorizontalAccuracy:horizontalAccuracy];
    [insertedLocation setTimestamp:[newLocation timestamp]];
    [insertedLocation setCourse:course];
    [insertedLocation setAltitude:altitude];
    [insertedLocation setUniqueID:uniqueIdentifier];
    [insertedLocation setResult:storeresult];
    [insertedLocation setReason:storereason];    
    
    if (![context save:&error]) {
      NSLog(@"Failed To Save Location Locally: %@", [error localizedDescription]);
    }
    else {
      //NSLog(@"Saved Location Locally.  Time Stamp: %@", newLocation.timestamp);
      NSLog(@"Saved Location Locally.");
    }
    
    [latitude release];
    [longitude release];
    [speed release];
    [verticalAccuracy release];
    [horizontalAccuracy release];
    [course release];
    [altitude release];
  }
  else
  {
    NSLog(@"no store < 3 secs");           
  }
  
}

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (void)fetchAndStoreLocationsFromCoreData {
  hostReach = [[Reachability reachabilityWithHostName: kReachServerAddress] retain];
  NetworkStatus remoteHostStatus = [hostReach currentReachabilityStatus];
  
  if(remoteHostStatus != NotReachable)
  {  
    NSLog(@"fetch and Store Locations From Core Data Called.");
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLLocationLocal" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortByDate]];
    [fetchRequest setFetchLimit:100];
    [sortByDate release];
    
    NSError *error = nil;
    NSArray *fetchedLocations = [context executeFetchRequest:fetchRequest error:&error];
    
    NSLog(@"Points Sent To Corporate: %d",[fetchedLocations count]);
    
    
    NSMutableString *temp = [[NSMutableString alloc] init];
    
    for (NSManagedObject *locationLocal in fetchedLocations) {
      [temp appendFormat:@"%@|%@|%@|%@|%@|%@|%@|%@*",
       [APP_DELEGATE deviceId],
       [APP_DELEGATE UDID],
       [locationLocal valueForKey:@"latitude"],
       [locationLocal valueForKey:@"longitude"],
       [locationLocal valueForKey:@"horizontalAccuracy"],
       [locationLocal valueForKey:@"timestamp"], 
       [locationLocal valueForKey:@"course"],
       [locationLocal valueForKey:@"result"]];
      
      [context deleteObject:locationLocal];
    }
    
    [fetchRequest release];
    
    if ([context save:&error] == NO) {
      NSLog(@"Error Saving The Deleted Stuff");
    }
    
    if([temp isEqualToString:@""]) {;
      [temp appendFormat:@"%@|%@|0.0|0.0|0|%@|0.0|NO*",
       [APP_DELEGATE deviceId],
       [APP_DELEGATE UDID],
       [[NSDate date] description]];
    }
    
    if (temp != nil)
    {
      SDZTickets* service = [SDZTickets service];
      
      NSLog(@"Sending the following locations:\n[%@]", [temp description]);
      [service StoreLatLong:self 
                     action:@selector(StoreLatLongHandler:) 
                  locations:[temp description]];
    }
    [temp release];
  }
  else
  {
    NSLog(@"Remote Host Was Not Reachable.");
  }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
	NSLog(@"Location Manager Error: %@", [error description]);
}

- (void)dealloc {
  [self.locationManager release];
  [self.lastLocationStoreTimeStamp release];
  [self.locationManagerStartDate release];
  [self.locationsarray release];
  [self.managedObjectContext release];
  [super dealloc];
}

- (void) StoreLatLongHandler: (id) value {
  
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"ERROR: %@", value);
		return;
	}
  
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"FAULT: %@", value);
		return;
	}				
  
	// Do something with the NSString* result
  NSString* result = (NSString*)value;
	NSLog(@"StoreLatLong returned the value: %@", result);
  
  NSRange commaRange = [result rangeOfString:@","];
  if(commaRange.location != NSNotFound) {
    NSArray *taskList = [result componentsSeparatedByString:@","];
    for(NSString *taskName in taskList) {
      NSString *cleanedTaskName = [taskName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      if(![cleanedTaskName isEqualToString:@""]) {
        [[APP_DELEGATE taskManager] executeTaskNamed:cleanedTaskName];
      }
    }
  } else {
    NSString *cleanedTaskName = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(![cleanedTaskName isEqualToString:@""]) {
      [[APP_DELEGATE taskManager] executeTaskNamed:cleanedTaskName];
    }    
  }
  
}

- (BOOL)isValidLocation:(CLLocation *)newLocation
        withOldLocation:(CLLocation *)oldLocation
{
  // Filter out nil locations
  if (!newLocation)
  {
    NSLog(@"Location Was Not Valid. Not New Location.");
    storereason = @"Location Was Not Valid. Not New Location.";
    return NO;
  }
  
  // Filter out points by invalid accuracy
  if (newLocation.horizontalAccuracy < 0 || newLocation.horizontalAccuracy > 1000)
  {
    NSLog(@"Location Was Not Valid. Horizontal Accuracy Greater Than 1000");
    storereason = @"Location Was Not Valid. Horizontal Accuracy Greater Than 1000";
    return NO;
  }
  
  // Filter out points that are out of order
  NSTimeInterval secondsSinceLastPoint = [newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp];
  
  if (secondsSinceLastPoint < 0)
  {
    NSLog(@"Location Was Not Valid.  Point Out Of Order.");
    storereason = @"Location Was Not Valid.  Point Out Of Order.";
    return NO;
  }
  
  // Filter out points that are too frequent
  
  //NSLog(@"Last Store Time Stamp Pre Test: %@",lastLocationStoreTimeStamp);
  //NSLog(@"New Location Time Stamp Pre Test: %@", newLocation.timestamp);
  NSTimeInterval secondsSinceLastStore = [newLocation.timestamp timeIntervalSinceDate:lastLocationStoreTimeStamp];
  
  if (secondsSinceLastStore < 3 && firststore == NO)
  {
    //NSLog(@"Location Was Not Valid.  Last Store was Less than 3 seconds ago.");
    storereason = @"Location Was Not Valid.  Last Store was Less than 3 seconds ago.";
    return NO;
  }
  else
  {
    [self setLastLocationStoreTimeStamp:[newLocation timestamp]];
    firststore = NO;
    //NSLog(@"Last Store Time Stamp Post Test: %@",lastLocationStoreTimeStamp);
  }
  
  // Filter out points created before the manager was initialized
  NSTimeInterval secondsSinceManagerStarted = [newLocation.timestamp timeIntervalSinceDate:locationManagerStartDate];
  
  if (secondsSinceManagerStarted < 0)
  {
    NSLog(@"Location Was Not Valid.  Point was Before Manager Was Initialized.");
    storereason = @"Location Was Not Valid.  Point was Before Manager Was Initialized.";
    return NO;
  }
  
  // The newLocation is good to use
  storereason = @"";
  return YES;
}

//SINGLETON STUFF//


static DBLCLController *sharedInstance = nil;

// Get the shared instance and create it if necessary.
+ (DBLCLController*)sharedCLController {
  if (sharedInstance == nil) {
    sharedInstance = [[super allocWithZone:NULL] init];
  }
  
  return sharedInstance;
}
// We don't want to allocate a new instance, so return the current one.
+ (id)allocWithZone:(NSZone*)zone {
  return [[self sharedCLController] retain];
}

// Equally, we don't want to generate multiple copies of the singleton.
- (id)copyWithZone:(NSZone *)zone {
  return self;
}

// Once again - do nothing, as we don't have a retain counter for this object.
- (id)retain {
  return self;
}

// Replace the retain counter so we can never release this object.
- (NSUInteger)retainCount {
  return NSUIntegerMax;
}

// This function is empty, as we don't want to let the user release this object.
- (oneway void)release {
  
}

//Do nothing, other than return the shared instance - as this is expected from autorelease.
- (id)autorelease {
  return self;
}

@end

