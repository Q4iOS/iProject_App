//
//  DBLMessage.h
//  DBL
//
//  Created by Tobias O'Leary on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#pragma mark - depracated; use DBLSavedMessage

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DBLMessage : NSObject

@property (nonatomic, assign) int accepted;
@property (nonatomic, assign) int acknowledged;
@property (nonatomic, assign) BOOL closed;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, assign) int messageId;
@property (nonatomic, assign) int messageType;
@property (nonatomic, retain) NSString *sender;

@property (nonatomic, retain) UIAlertView *alertView;

@end
