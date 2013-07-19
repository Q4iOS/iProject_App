//
//  DBLMapViewController.h
//  DBL
//
//  Created by Ryan Emmons on 2/23/11.
//  Copyright 2011 Luck Stone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MKAnnotation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MKReverseGeocoder.h>


@interface DBLMapViewController : UIViewController <UIAlertViewDelegate> {
	MKMapView *DBLMap;
	CLLocationCoordinate2D ll1;
}
@property CLLocationCoordinate2D ll1;
@property (nonatomic, retain) IBOutlet MKMapView *DBLMap;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UIButton *openInGoogleMapsButton;
@property (nonatomic, retain) IBOutlet UIButton *updateCurrentLocationButton;
@property (nonatomic, retain) IBOutlet UINavigationBar *mapViewNavigationBar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *btnMaps;
//@property (retain, nonatomic) IBOutlet UIBarButtonItem *btnLocation;
- (IBAction)openMaps:(id)sender;

- (IBAction)updateCurrentLocation:(id)sender;
- (IBAction)openInGoogleMaps:(id)sender;


@end

