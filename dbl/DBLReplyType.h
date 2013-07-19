//
//  DBLReplyType.h
//  DBL
//
//  Created by Kelvin Quiroz on 11/20/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DBLReplyType : NSManagedObject

@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSNumber * index;

@end
