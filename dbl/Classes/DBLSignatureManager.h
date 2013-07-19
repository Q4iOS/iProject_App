//
//  DBLSignatureManager.h
//  DBL
//
//  Created by Tobias O'Leary on 6/5/12.
//  Copyright (c) 2012 INMUnited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBLSignatureRequest.h"

@class DBLSignatureLocal;

@interface DBLSignatureManager : NSObject <DBLSignatureRequestDelegate> {
  NSMutableArray *_signatureRequests;
}

//Sends a single signature to corporate using the StoreSignature service
//If the signature is already in the process of being sent it'll be ignored.
- (void)sendSignatureToCorporate:(DBLSignatureLocal*)signature;

//Cleans the DBLSignatureLocal Entities from CoreData
//This entities act as a queue for sending signatures to corporate.
- (void)cleanSignatureQueue;


@end
