/*
	SDZScheduleInfo.h
	The implementation of properties and methods for the SDZScheduleInfo object.
	Generated by SudzC.com
*/
#import "SDZScheduleInfo.h"

@implementation SDZScheduleInfo
	@synthesize Completed = _Completed;
	@synthesize CustomerName = _CustomerName;
	@synthesize EndTime = _EndTime;
	@synthesize Latitude = _Latitude;
	@synthesize LocationCode = _LocationCode;
	@synthesize LocationName = _LocationName;
	@synthesize Longitude = _Longitude;
	@synthesize OrderID = _OrderID;
	@synthesize ProductID = _ProductID;
	@synthesize Qty = _Qty;
	@synthesize QtyType = _QtyType;
	@synthesize StartTime = _StartTime;

	- (id) init
	{
		if(self = [super init])
		{
			self.CustomerName = nil;
			self.EndTime = nil;
			self.Latitude = nil;
			self.LocationName = nil;
			self.Longitude = nil;
			self.OrderID = nil;
			self.ProductID = nil;
			self.Qty = nil;
			self.QtyType = nil;
			self.StartTime = nil;

		}
		return self;
	}

	+ (SDZScheduleInfo*) createWithNode: (CXMLNode*) node
	{
		if(node == nil) { return nil; }
		return (SDZScheduleInfo*)[[[SDZScheduleInfo alloc] initWithNode: node] autorelease];
	}

	- (id) initWithNode: (CXMLNode*) node {
		if(self = [super initWithNode: node])
		{
			self.Completed = [[Soap getNodeValue: node withName: @"Completed"] boolValue];
			self.CustomerName = [Soap getNodeValue: node withName: @"CustomerName"];
			self.EndTime = [Soap dateFromString: [Soap getNodeValue: node withName: @"EndTime"]];
			self.Latitude = [NSDecimalNumber decimalNumberWithString: [Soap getNodeValue: node withName: @"Latitude"]];
			self.LocationCode = [[Soap getNodeValue: node withName: @"LocationCode"] intValue];
			self.LocationName = [Soap getNodeValue: node withName: @"LocationName"];
			self.Longitude = [NSDecimalNumber decimalNumberWithString: [Soap getNodeValue: node withName: @"Longitude"]];
			self.OrderID = [Soap getNodeValue: node withName: @"OrderID"];
			self.ProductID = [Soap getNodeValue: node withName: @"ProductID"];
			self.Qty = [NSDecimalNumber decimalNumberWithString: [Soap getNodeValue: node withName: @"Qty"]];
			self.QtyType = [Soap getNodeValue: node withName: @"QtyType"];
			self.StartTime = [Soap dateFromString: [Soap getNodeValue: node withName: @"StartTime"]];
		}
		return self;
	}

	- (NSMutableString*) serialize
	{
		return [self serialize: @"ScheduleInfo"];
	}
  
	- (NSMutableString*) serialize: (NSString*) nodeName
	{
		NSMutableString* s = [NSMutableString string];
		[s appendFormat: @"<%@", nodeName];
		[s appendString: [self serializeAttributes]];
		[s appendString: @">"];
		[s appendString: [self serializeElements]];
		[s appendFormat: @"</%@>", nodeName];
		return s;
	}
	
	- (NSMutableString*) serializeElements
	{
		NSMutableString* s = [super serializeElements];
		[s appendFormat: @"<Completed>%@</Completed>", (self.Completed)?@"true":@"false"];
		if (self.CustomerName != nil) [s appendFormat: @"<CustomerName>%@</CustomerName>", [[self.CustomerName stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.EndTime != nil) [s appendFormat: @"<EndTime>%@</EndTime>", [Soap getDateString: self.EndTime]];
		if (self.Latitude != nil) [s appendFormat: @"<Latitude>%@</Latitude>", [NSString stringWithFormat: @"%@", self.Latitude]];
		[s appendFormat: @"<LocationCode>%@</LocationCode>", [NSString stringWithFormat: @"%i", self.LocationCode]];
		if (self.LocationName != nil) [s appendFormat: @"<LocationName>%@</LocationName>", [[self.LocationName stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.Longitude != nil) [s appendFormat: @"<Longitude>%@</Longitude>", [NSString stringWithFormat: @"%@", self.Longitude]];
		if (self.OrderID != nil) [s appendFormat: @"<OrderID>%@</OrderID>", [[self.OrderID stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.ProductID != nil) [s appendFormat: @"<ProductID>%@</ProductID>", [[self.ProductID stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.Qty != nil) [s appendFormat: @"<Qty>%@</Qty>", [NSString stringWithFormat: @"%@", self.Qty]];
		if (self.QtyType != nil) [s appendFormat: @"<QtyType>%@</QtyType>", [[self.QtyType stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.StartTime != nil) [s appendFormat: @"<StartTime>%@</StartTime>", [Soap getDateString: self.StartTime]];

		return s;
	}
	
	- (NSMutableString*) serializeAttributes
	{
		NSMutableString* s = [super serializeAttributes];

		return s;
	}
	
	-(BOOL)isEqual:(id)object{
		if(object != nil && [object isKindOfClass:[SDZScheduleInfo class]]) {
			return [[self serialize] isEqualToString:[object serialize]];
		}
		return NO;
	}
	
	-(NSUInteger)hash{
		return [Soap generateHash:self];

	}
	
	- (void) dealloc
	{
		self.CustomerName = nil;
		self.EndTime = nil;
		self.Latitude = nil;
		self.LocationName = nil;
		self.Longitude = nil;
		self.OrderID = nil;
		self.ProductID = nil;
		self.Qty = nil;
		self.QtyType = nil;
		self.StartTime = nil;
		[super dealloc];
	}

@end
