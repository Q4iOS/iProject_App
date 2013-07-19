//
//  DBLSignatureManager.m
//  DBL
//
//  Created by Tobias O'Leary on 6/5/12.
//  Copyright (c) 2012 INMUnited. All rights reserved.
//

#import "DBLSignatureManager.h"
#import "DBLSignatureLocal.h"
#import "NSData+Base64.h"
#import "DBLAppDelegate.h"
#import "SDZTickets.h"

@interface DBLSignatureManager()


@end

@implementation DBLSignatureManager

- (id)init 
{
  self = [super init];
  if(self) {
    _signatureRequests = [[NSMutableArray alloc] initWithCapacity:8];
  }
  return self;
}

- (void)dealloc
{
  [_signatureRequests release];
  
  [super dealloc];
}

- (void)sendSignatureToCorporate:(DBLSignatureLocal*)signature
{
  
  
  for(DBLSignatureRequest *request in _signatureRequests) {
    if([signature isEqualToSignature:[request signature]]) {
      return; //Signature is already being processed. 
    }
  }
  
  DBLSignatureRequest *request = [[DBLSignatureRequest alloc] init];
  [_signatureRequests addObject:request];
  [request setDelegate:self];
  [request sendSignatureToCorporate:signature];
  [request release];
}

//Implementation of DBLSignatureRequestDelegate
- (void)signatureRequestDidComplete:(DBLSignatureRequest*)completedRequest
{
  [_signatureRequests removeObject:completedRequest];
}

- (void)cleanSignatureQueue
{
  //Fetch Local Signatures
  NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLSignatureLocal" 
                                            inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	NSError *error = nil;
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
  
#if DEBUG
  NSLog(@"All Signatures Count: %d", [fetchedObjects count]);
#endif  

  //Process Each Signature
	for (DBLSignatureLocal *signature in fetchedObjects) {
    
#if DEBUG
    NSLog(@"Signature:\n%@", [signature description]);
#endif

    //Find if waiting for response for signature from the server.
    BOOL signatureIsPending = NO;
    for(DBLSignatureRequest *request in _signatureRequests) {
      signatureIsPending = [signature isEqualToSignature:[request signature]];
      if(signatureIsPending) {
        break;
      }
    }
    if(signatureIsPending) {
      continue; //skip this signature doesn't need processing
    }
    
    
    if ([[signature sentToCorporate] boolValue]) {
      //Delete local signatures that have been SentToCorporate
      NSLog(@"Deleting Signature from Queue with TruckNumber (%@) and TicketNumber (%@)", 
            [signature truckNumber], 
            [signature ticketNumber]);
      
      [context deleteObject:signature];
    } else {
      //Send Signatures To Corporate that haven't been sent.
      [self sendSignatureToCorporate:signature];
    }
	}    
  
  //Save Processing Results
  if (![context save:&error]) {
    // Handle the error.
    NSLog(@"Failed To Save Updating Signatures: %@", [error localizedDescription]);
  }
  else {
    NSLog(@"Successfully Update Signatures");
  }
  
	[fetchRequest release];
}


@end
