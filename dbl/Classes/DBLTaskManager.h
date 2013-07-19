//
//  DBLTaskManager.h
//  DBL
//
//  Created by Tobias O'Leary on 2/14/12.
//  Copyright (c) 2012 LuckStone. All rights reserved.
//

#import <Foundation/Foundation.h>

/////////////////////////////////////////////////
// DBLTaskManager
@interface DBLTaskManager : NSObject {
  NSMutableArray *_delegates;
}

- (void)executeTaskNamed:(NSString *)taskName;

- (void)getTicket;
- (void)getTicketHandler:(id)value;

- (void)getMessage;
- (void)getMessageHandler:(id)value;

- (void)refreshAssignments;
- (void)refreshAssignmentsHandler:(id)value;

@end

/////////////////////////////////////////////////
// DBLTaskManagerDelegate Protocol
@class SDZMessageObject;
@class SDZTicket;

@protocol DBLTaskManagerDelegate <NSObject>

- (void)taskManager:(DBLTaskManager*)taskManager didGetTicket:(SDZTicket*)ticket;

- (void)taskManager:(DBLTaskManager*)taskManager didGetMessage:(SDZMessageObject*)message;

- (void)taskManager:(DBLTaskManager *)taskManager refreshAssignments:(NSArray*)assignments;

@end

/////////////////////////////////////////////////
// DBLTaskManager Interface for Delegates
@interface DBLTaskManager(DelegateManagement)

- (void)addDelegate:(id <DBLTaskManagerDelegate>)delegate;

- (void)removeDelegate:(id <DBLTaskManagerDelegate>)delegate;


@end