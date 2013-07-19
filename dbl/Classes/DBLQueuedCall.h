//
//  DBLQueuedCall.h
//  DBL
//
//  Created by Kelvin Quiroz on 11/27/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DBLQueuedCall : NSManagedObject

@property (nonatomic, retain) NSDate * datetime;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSNumber * startstop;
@property (nonatomic, retain) NSNumber * messageID;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * available;
@property (nonatomic, retain) NSNumber * tag;

@end
