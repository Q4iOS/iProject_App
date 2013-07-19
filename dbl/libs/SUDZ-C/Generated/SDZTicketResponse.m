/*
	SDZTicketResponse.h
	The implementation of properties and methods for the SDZTicketResponse object.
	Generated by SudzC.com
*/
#import "SDZTicketResponse.h"

#import "SDZTicket.h"
@implementation SDZTicketResponse
	@synthesize IsTaring = _IsTaring;
	@synthesize Message = _Message;
	@synthesize Success = _Success;
	@synthesize Ticket = _Ticket;

	- (id) init
	{
		if(self = [super init])
		{
			self.Message = nil;
			self.Ticket = nil; // [[SDZTicket alloc] init];

		}
		return self;
	}

	+ (SDZTicketResponse*) createWithNode: (CXMLNode*) node
	{
		if(node == nil) { return nil; }
		return (SDZTicketResponse*)[[[SDZTicketResponse alloc] initWithNode: node] autorelease];
	}

	- (id) initWithNode: (CXMLNode*) node {
		if(self = [super initWithNode: node])
		{
			self.IsTaring = [[Soap getNodeValue: node withName: @"IsTaring"] boolValue];
			self.Message = [Soap getNodeValue: node withName: @"Message"];
			self.Success = [[Soap getNodeValue: node withName: @"Success"] boolValue];
			self.Ticket = [[SDZTicket createWithNode: [Soap getNode: node withName: @"Ticket"]] object];
		}
		return self;
	}

	- (NSMutableString*) serialize
	{
		return [self serialize: @"TicketResponse"];
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
		[s appendFormat: @"<IsTaring>%@</IsTaring>", (self.IsTaring)?@"true":@"false"];
		if (self.Message != nil) [s appendFormat: @"<Message>%@</Message>", [[self.Message stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		[s appendFormat: @"<Success>%@</Success>", (self.Success)?@"true":@"false"];
		if (self.Ticket != nil) [s appendString: [self.Ticket serialize: @"Ticket"]];

		return s;
	}
	
	- (NSMutableString*) serializeAttributes
	{
		NSMutableString* s = [super serializeAttributes];

		return s;
	}
	
	-(BOOL)isEqual:(id)object{
		if(object != nil && [object isKindOfClass:[SDZTicketResponse class]]) {
			return [[self serialize] isEqualToString:[object serialize]];
		}
		return NO;
	}
	
	-(NSUInteger)hash{
		return [Soap generateHash:self];

	}
	
	- (void) dealloc
	{
		self.Message = nil;
		self.Ticket = nil;
		[super dealloc];
	}

@end
