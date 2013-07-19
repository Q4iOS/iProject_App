//
//  DBLSignatureRequest.h
//  DBL
//
//  Created by Tobias O'Leary on 6/5/12.
//  Copyright (c) 2012 INMUnited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBLSignatureLocal;

@protocol DBLSignatureRequestDelegate;

@interface DBLSignatureRequest : NSObject

@property (nonatomic, assign) BOOL complete;
@property (nonatomic, retain) DBLSignatureLocal *signature;
@property (nonatomic, assign) id<DBLSignatureRequestDelegate> delegate;

- (void)sendSignatureToCorporate:(DBLSignatureLocal*)signature;

@end


@protocol DBLSignatureRequestDelegate <NSObject>

- (void)signatureRequestDidComplete:(DBLSignatureRequest*)completedRequest;

@end
