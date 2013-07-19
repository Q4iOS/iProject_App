//
//  DBLAppDelegate.h
//  DBL
//
//  Created by Ryan Emmons on 3/4/11.
//  Copyright 2011 Luck Stone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "DBLSavedMessage.h"
#import "DBLActivity.h"
#import "DBLReplyType.h"
#import "DBLWindow.h"
#import "Reachability.h"

#define ALERT_MESSAGE 100
#define ALERT_SETUP 200

@interface MessageAlertView : UIAlertView {
  int messageID;
  int messageType;

}

@property (nonatomic, assign) int messageID;
@property (nonatomic, assign) int messageType;

@end

@class DBLTaskManager;
@class DBLSignatureManager;

@interface DBLAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UIAlertViewDelegate, UITextFieldDelegate> {
  UIWindow *window;
  UITabBarController *tabBarController;
	NSManagedObjectModel *managedObjectModel;
	NSManagedObjectContext *managedObjectContext;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
  Reachability* hostReach;
  
  BOOL hasNewMessage;
  BOOL isLoadingTickets;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain, readonly) DBLTaskManager *taskManager;
@property (nonatomic, retain) NSMutableArray *messages;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) UIAlertView *alertBeingDisplayed;
@property (nonatomic, retain) UIViewController *setupVC;
@property (nonatomic, retain) UITextField *deviceIDField;
@property (nonatomic, retain, readonly) DBLSignatureManager *signatureManager;
@property (nonatomic, retain) UIViewController *vcStartup;

@property (nonatomic, retain) NSArray *activitiesArray;
@property (nonatomic, retain) NSArray *responsesArray;

- (NSString *)applicationDocumentsDirectory;

- (BOOL)status;
- (void)setStatus:(BOOL)status;

- (NSString *)deviceId;
- (NSString *)UDID;
- (NSNumber *)speedLimit;

//-(NSDictionary*)getActivitiesAndResponses;

-(void)reloadStatusesFromServer;
-(void)reloadRepliesFromServer;
-(void)newMessageReceived;
-(void)setLoadingTickets: (BOOL) state;

@end

