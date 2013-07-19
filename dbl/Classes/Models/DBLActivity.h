//
//  DBLActivity.h
//  DBL
//
//  Created by Kelvin Quiroz on 11/19/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DBLActivity : NSManagedObject

@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSNumber * index;

@end
