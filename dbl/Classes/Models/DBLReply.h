//
//  DBLReply.h
//  DBL
//
//  Created by Kelvin Quiroz on 11/15/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DBLReply : NSManagedObject

@property (nonatomic, retain) NSManagedObject *attachedToMessage;

@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber *messageID;
@property (nonatomic, retain) NSDate* replydatetime;
@property (nonatomic, assign) BOOL sent;

@end
