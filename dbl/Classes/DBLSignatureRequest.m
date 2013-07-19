//
//  DBLSignatureRequest.m
//  DBL
//
//  Created by Tobias O'Leary on 6/5/12.
//  Copyright (c) 2012 INMUnited. All rights reserved.
//

#import "DBLSignatureRequest.h"
#import "DBLSignatureLocal.h"
#import "SDZTickets.h"

#import "DBLAppDelegate.h"
#import "NSData+Base64.h"

@interface DBLSignatureRequest()

- (void)StoreSignatureHandler:(id)value;

@end

@implementation DBLSignatureRequest

@synthesize complete = _complete;
@synthesize signature = _signature;
@synthesize delegate = _delegate;

- (id)init 
{
  self = [super init];
  if(self) {
    _complete = NO;
    _signature = nil;
  }
  return self;
}

- (void)dealloc
{
  [_signature release];

  [super dealloc];
}

- (void)sendSignatureToCorporate:(DBLSignatureLocal*)signature
{
  [self setComplete:NO];
  [self setSignature:signature];
  
  NSLog(@"Sending Signature:\n%@", [signature description]);
  
  SDZTickets* service = [[SDZTickets alloc] init];
  [service StoreSignature:self
                   action:@selector(StoreSignatureHandler:)
                signature:[[signature signatureData] base64Encoding]
             ticketnumber:[signature ticketNumber]
             locationcode:[NSString stringWithFormat:@"%d",[[signature locationCode] intValue]]
                 deviceid:[APP_DELEGATE deviceId] 
                     udid:[APP_DELEGATE UDID]
                timestamp:[signature timestamp]
                 latitude:[signature latitude]
                longitude:[signature longitude]];
  [service release];
  
}

- (void) StoreSignatureHandler: (id) value 
{
  [self setComplete:YES];
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);  
		return;
	}
  
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
		return;
	}				
  
  
	// Do something with the NSString* result
  NSString* result = (NSString*)value;
  
  //UPDATE Local Signature Sent To Corporate Stuff//
  NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLSignatureLocal" 
                                            inManagedObjectContext:context];
  [fetchRequest setEntity:entity];
  [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ticketNumber == %@", result]];
  
  [fetchRequest setFetchLimit:1];
  
  NSError *error = nil;
  NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
  
  for (DBLSignatureLocal *signature in fetchedObjects) {
    [signature setSentToCorporate:[NSNumber numberWithBool:YES]];
    
    if (![context save:&error]) {
      // Handle the error.
      NSLog(@"Failed To Update Signature: %@", [error localizedDescription]);
    }
    else {
      NSLog(@"Updated Signature");
    }
  }
  
  [fetchRequest release];
  
  [[self delegate] signatureRequestDidComplete:self];
}

@end
