//
//  DBLSignatureLocal.m
//  DBL
//
//  Created by Tobias O'Leary on 5/24/12.
//  Copyright (c) 2012 INMUnited. All rights reserved.
//

#import "DBLSignatureLocal.h"

@implementation DBLSignatureLocal

@dynamic latitude;
@dynamic locationCode;
@dynamic longitude;
@dynamic sentToCorporate;
@dynamic signatureData;
@dynamic ticketNumber;
@dynamic timestamp;
@dynamic truckNumber;
@dynamic id;
@dynamic index;

- (NSString*)description
{
  NSMutableString *retVal = [[NSMutableString alloc] initWithCapacity:128];
  [retVal appendFormat:@"Truck Numbers: %@\n", [self truckNumber]];
  [retVal appendFormat:@"Ticket Number: %@\n", [self ticketNumber]];
  [retVal appendFormat:@"Location Code: %d\n", [[self locationCode] intValue]];
  [retVal appendFormat:@"Location: (%@, %@)\n", [self latitude], [self longitude]];
  [retVal appendFormat:@"Sent to Corporate: %@\n", [[self sentToCorporate] boolValue] ? @"YES" : @"NO"];

  return [[retVal description] autorelease];
  [retVal release];
}

- (BOOL)isEqualToSignature:(DBLSignatureLocal*)object
{
  if([object isKindOfClass:[DBLSignatureLocal class]]) {
    DBLSignatureLocal *other = (DBLSignatureLocal*)object;
    
    return [[self truckNumber] isEqualToString:[other truckNumber]] 
    && [[self ticketNumber] isEqualToString:[other ticketNumber]] 
    && [[self timestamp] isEqualToDate:[other timestamp]]
    && [[self latitude] isEqualToString:[other latitude]]
    && [[self longitude] isEqualToString:[other longitude]]
    && [[self locationCode] isEqualToNumber:[other locationCode]]
    && [[self sentToCorporate] isEqualToNumber:[other sentToCorporate]];
  }
  
  return false;
}

@end
