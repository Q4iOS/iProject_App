//
//  LQTicketNote.h
//  Logiq
//
//  Created by Kelvin Quiroz on 5/20/13.
//  Copyright (c) 2013 LuckCompanies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LQTicketNote : NSManagedObject

@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSString * label;

@end
