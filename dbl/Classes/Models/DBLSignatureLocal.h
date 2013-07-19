//
//  DBLSignatureLocal.h
//  DBL
//
//  Created by Tobias O'Leary on 5/24/12.
//  Copyright (c) 2012 INMUnited. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface DBLSignatureLocal : NSManagedObject

@property (nonatomic, retain) NSString *latitude;
@property (nonatomic, retain) NSNumber *locationCode;
@property (nonatomic, retain) NSString *longitude;
@property (nonatomic, retain) NSNumber *sentToCorporate;
@property (nonatomic, retain) NSData *signatureData;
@property (nonatomic, retain) NSString *ticketNumber;
@property (nonatomic, retain) NSDate *timestamp;
@property (nonatomic, retain) NSString *truckNumber;

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * index;



- (BOOL)isEqualToSignature:(DBLSignatureLocal*)object;

-(void)setTicketNumber:(NSString *)ticketNumber;


@end
