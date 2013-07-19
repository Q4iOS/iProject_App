//
//  MyCLController.h
//  DBL
//
//  Created by Ryan Emmons on 3/11/11.
//  Copyright 2011 Luck Stone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import "DBLAppDelegate.h"
#import "SDZTickets.h"

@class Reachability;

@interface DBLCLController : NSObject <CLLocationManagerDelegate> {
  Reachability* hostReach;
  BOOL lostconnection;
  BOOL firststore;
}

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSDate *locationManagerStartDate;
@property (nonatomic, retain) NSDate *lastLocationStoreTimeStamp;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray* locationsarray;
@property (nonatomic, retain) CLLocation *lastLocation;

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;

- (BOOL)isValidLocation:(CLLocation *)newLocation
        withOldLocation:(CLLocation *)oldLocation;

- (void)fetchAndStoreLocationsFromCoreData;

+ (DBLCLController*)sharedCLController;

@end