//
//  DBLLocationLocal.h
//  DBL
//
//  Created by Tobias O'Leary on 5/24/12.
//  Copyright (c) 2012 INMUnited. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface DBLLocationLocal : NSManagedObject

@property (nonatomic, retain) NSString *altitude;
@property (nonatomic, retain) NSString *course;
@property (nonatomic, retain) NSString *horizontalAccuracy;
@property (nonatomic, retain) NSString *latitude;
@property (nonatomic, retain) NSString *longitude;
@property (nonatomic, retain) NSString *reason;
@property (nonatomic, retain) NSString *result;
@property (nonatomic, retain) NSString *speed;
@property (nonatomic, retain) NSDate *timestamp;
@property (nonatomic, retain) NSString *truckNumber;
@property (nonatomic, retain) NSString *uniqueID;
@property (nonatomic, retain) NSString *verticalAccuracy;

@end
