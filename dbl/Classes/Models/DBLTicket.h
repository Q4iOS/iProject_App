//
//  DBLTicket.h
//  DBL
//
//  Created by Tobias O'Leary on 5/24/12.
//  Copyright (c) 2012 INMUnited. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface DBLTicket : NSManagedObject

@property (nonatomic, retain) NSNumber *addressID;
@property (nonatomic, retain) NSString *copyString;
@property (nonatomic, retain) NSString *customerAccountNumber;
@property (nonatomic, retain) NSString *customerAddress;
@property (nonatomic, retain) NSString *deliveryInstructions;
@property (nonatomic, retain) NSNumber *fuelSurcharge;
@property (nonatomic, retain) NSNumber *grossWeight;
@property (nonatomic, retain) NSNumber *haulCharge;
@property (nonatomic, retain) NSString *haulerName;
@property (nonatomic, retain) NSString *haulerNumber;
@property (nonatomic, retain) NSString *haulIndicator;
@property (nonatomic, retain) NSNumber *haulRate;
@property (nonatomic, retain) NSString *jobContractor;
@property (nonatomic, retain) NSString *jobPhone;
@property (nonatomic, retain) NSString *latitude;
@property (nonatomic, retain) NSNumber *locationCode;
@property (nonatomic, retain) NSString *locationName;
@property (nonatomic, retain) NSString *longitude;
@property (nonatomic, retain) NSString *lotSample;
@property (nonatomic, retain) NSNumber *maxGross;
@property (nonatomic, retain) NSNumber *metricTonsLoadsToday;
@property (nonatomic, retain) NSNumber *metricTonsQtyDelivered;
@property (nonatomic, retain) NSNumber *metricTonsQtyDeliveryToday;
@property (nonatomic, retain) NSNumber *metricTonsQtyOrdered;
@property (nonatomic, retain) NSNumber *netTons;
@property (nonatomic, retain) NSString * notes;

@property (nonatomic, retain) NSNumber *netTonsMetric;
@property (nonatomic, retain) NSNumber *netWeight;
@property (nonatomic, retain) NSString *orderID;
@property (nonatomic, retain) NSString *plant;
@property (nonatomic, retain) NSString *productCertification;
@property (nonatomic, retain) NSString *productCertificationDefault;
@property (nonatomic, retain) NSString *productCode;
@property (nonatomic, retain) NSString *productDescription;
@property (nonatomic, retain) NSString *projectDescription;
@property (nonatomic, retain) NSString *projectID;
@property (nonatomic, retain) NSString *purchaseOrder;
@property (nonatomic, retain) NSNumber *salesTax;
@property (nonatomic, retain) NSNumber *shortTonsLoadsToday;
@property (nonatomic, retain) NSNumber *shortTonsQtyDelivered;
@property (nonatomic, retain) NSNumber *shortTonsQtyDeliveryToday;
@property (nonatomic, retain) NSNumber *shortTonsQtyOrdered;
//@property (nonatomic, retain) NSData *signature;
@property (nonatomic, retain) NSString *specialInstructions;
@property (nonatomic, retain) NSNumber *stonePrice;
@property (nonatomic, retain) NSNumber *stoneRate;
@property (nonatomic, retain) NSNumber *tareWeight;
@property (nonatomic, retain) NSString *ticketDate;
@property (nonatomic, retain) NSString *ticketNumber;
@property (nonatomic, retain) NSString *ticketTime;
@property (nonatomic, retain) NSNumber *total;
@property (nonatomic, retain) NSString *truckNumber;
@property (nonatomic, retain) NSString *warning1;
@property (nonatomic, retain) NSString *warning2;
@property (nonatomic, retain) NSString *weighmaster;

@property (nonatomic, retain) NSData * signature1;
@property (nonatomic, retain) NSData * signature2;
@property (nonatomic, retain) NSData * signature3;
@property (nonatomic, retain) NSData * signature4;

@end
