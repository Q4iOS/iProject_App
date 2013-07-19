//
//  DBLMapViewController.m
//  DBL
//
//  Created by Ryan Emmons on 2/23/11.
//  Copyright 2011 Luck Stone. All rights reserved.
//

#import "DBLMapViewController.h"
#import "SDZTickets.h"
#import "DBLCLController.h"
#import "DBLAppDelegate.h"
#import "DBLTicket.h"

/////////////////////////
#pragma mark -
#pragma mark Interface
/////////////////////////
@interface DBLMapViewController ()
//loading functions
- (void)showPopup:(NSString *)message;
@end

@implementation DBLMapViewController
@synthesize btnMaps;
//@synthesize btnLocation;

@synthesize DBLMap, ll1, openInGoogleMapsButton, updateCurrentLocationButton, mapViewNavigationBar;
@synthesize managedObjectContext;

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

/////////////////////////
#pragma mark -
#pragma mark View lifecycle
/////////////////////////

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  
  [super viewDidLoad];
  
  // Configure mapView
  self.DBLMap.mapType = MKMapTypeStandard;
  
  self.navigationItem.rightBarButtonItem = self.btnMaps;
  
  if (managedObjectContext == nil)
  {
    [self setManagedObjectContext:[(DBLAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]];
  }
  
	[self updateCurrentLocation:self];
  
}

- (void)viewDidUnload {
  //    [self setBtnLocation:nil];
  [self setBtnMaps:nil];
  
	self.DBLMap = nil;
  self.openInGoogleMapsButton = nil;
  self.updateCurrentLocationButton = nil;
  self.mapViewNavigationBar = nil;
  self.managedObjectContext = nil;
  
  NSLog(@"Map View Unloaded");
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

/////////////////////////
#pragma mark -
#pragma mark Object lifecycle
/////////////////////////


- (void)dealloc {
	[DBLMap release];
  [openInGoogleMapsButton release];
  [updateCurrentLocationButton release];
  [mapViewNavigationBar release];
  [managedObjectContext release];
  
  [btnMaps release];
  //    [btnLocation release];
  [super dealloc];
}

- (IBAction)openInGoogleMaps:(id)sender {
  //	NSLog(@"Lat Long: %f, %f",ll1.latitude, ll1.longitude);
  
  NSString *latlong = [NSString stringWithFormat: @"%f,%f",ll1.latitude,ll1.longitude ];
  NSString *url = [NSString stringWithFormat: @"http://maps.google.com/maps?daddr=%@",
                   [latlong stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (IBAction)openMaps:(id)sender {
  //Check for iOS 6 to run Apple Maps
  Class mapItemClass = [MKMapItem class];
  if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
  {
    // Create an MKMapItem to pass to the Maps app
    CLLocationCoordinate2D coordinate =
    CLLocationCoordinate2DMake(ll1.latitude, ll1.longitude);
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                   addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem setName:@"My location"];
    
    //Set launch options to get directions
    NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
    MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
    [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem]
                   launchOptions:launchOptions];
  }
  
  //Otherwise just use Google maps
  else {
    CLLocationCoordinate2D current = self.DBLMap.userLocation.location.coordinate;
    NSString *start = [NSString stringWithFormat: @"%f,%f", current.latitude, current.longitude];
    NSString *latlong = [NSString stringWithFormat: @"%f,%f",ll1.latitude,ll1.longitude ];
    NSString *url = [NSString stringWithFormat: @"http://maps.google.com/?saddr=%@&daddr=%@",
                     [start stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                     [latlong stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    
  }
}

- (IBAction)updateCurrentLocation:(id)sender {
  [self.DBLMap setShowsUserLocation:YES];
	NSLog(@"Update Current Location Pushed");
	
	//show destination//
	//ll1.latitude = 37.59853018;
	//ll1.longitude = -78.71583919;
  if (ll1.latitude == 0)
  {
    [self showPopup:@"Retrieving GPS Coordinates From Most Recent Ticket"];
    
    //get most recent ticket and assign lat long//
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLTicket"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"ticketDate" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortByDate]];
    [fetchRequest setFetchLimit:1];
    [sortByDate release];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if(error) {
      //TODO: Handle Error
    } else {
      for (DBLTicket *ticket in fetchedObjects) {
        ll1.latitude = [[ticket latitude] doubleValue];
        ll1.longitude = [[ticket longitude] doubleValue];
      }
    }
    [fetchRequest release];
    
  }
  
  if (ll1.latitude != 0 && [DBLCLController sharedCLController].locationManager.location.coordinate.latitude != 0)
  {
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    topLeftCoord.longitude = fmin([DBLCLController sharedCLController].locationManager.location.coordinate.longitude, ll1.longitude);
    topLeftCoord.latitude = fmax([DBLCLController sharedCLController].locationManager.location.coordinate.latitude, ll1.latitude);
    
    bottomRightCoord.longitude = fmax([DBLCLController sharedCLController].locationManager.location.coordinate.longitude, ll1.longitude);
    bottomRightCoord.latitude = fmin([DBLCLController sharedCLController].locationManager.location.coordinate.latitude, ll1.latitude);
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides
    
    region = [self.DBLMap regionThatFits:region];
    
    [self.DBLMap setRegion:region animated:YES];
    
    MKPlacemark *m_currentLocation = [[MKPlacemark alloc]initWithCoordinate:ll1 addressDictionary:nil];
    [self.DBLMap addAnnotation:m_currentLocation];
    [m_currentLocation release];
	}
}


- (MKAnnotationView *) DBLMap: (MKMapView *) mapView viewForAnnotation: (id<MKAnnotation>) annotation
{
  
  MKPinAnnotationView *pin = (MKPinAnnotationView *) [self.DBLMap dequeueReusableAnnotationViewWithIdentifier: @"currentloc"];
  if (pin == nil)
  {
    pin = [[[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"currentloc"] autorelease];
  }
  else
  {
    pin.annotation = annotation;
  }
  pin.pinColor = MKPinAnnotationColorRed;
  pin.animatesDrop = YES;
  return pin;
}

@end