//
//  DBLSavedMessage.h
//  DBL
//
//  Created by Kelvin Quiroz on 11/15/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DBLSavedMessage : NSManagedObject

@property (nonatomic, retain) NSManagedObject *userResponse;

@property (nonatomic, retain) NSNumber * accepted;
@property (nonatomic, retain) NSNumber * acknowledged;
@property (nonatomic, retain) NSNumber * closed;
@property (nonatomic, retain) NSNumber * hasRead;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * messageID;
@property (nonatomic, retain) NSNumber * messageType;
@property (nonatomic, retain) NSDate * received;
@property (nonatomic, retain) NSNumber * responded;
@property (nonatomic, retain) NSString * sender;

@end
