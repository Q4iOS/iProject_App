//
//  DBLScheduleInfo.h
//  DBL
//
//  Created by Tobias O'Leary on 5/24/12.
//  Copyright (c) 2012 INMUnited. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface DBLScheduleInfo : NSManagedObject

@property (nonatomic, retain) NSNumber *completed;
@property (nonatomic, retain) NSString *customerName;
@property (nonatomic, retain) NSDate *endTime;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *locationCode;
@property (nonatomic, retain) NSString *locationName;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSString *orderID;
@property (nonatomic, retain) NSString *productID;
@property (nonatomic, retain) NSNumber *qty;
@property (nonatomic, retain) NSString *qtyType;
@property (nonatomic, retain) NSDate *startTime;

@end
