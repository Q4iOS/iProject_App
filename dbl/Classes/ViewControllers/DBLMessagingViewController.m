//
//  DBLMessagingView.m
//  DBL
//
//  Created by Ryan Emmons on 3/21/11.
//  Copyright 2011 Luck Stone. All rights reserved.
//

#import "DBLMessagingViewController.h"

@implementation ReplyTypeViewController

@synthesize replyTypeTable, replyTypes;

-(id)initWithFrameSize:(CGSize) mySize andReplies:(NSArray *)myReplies{
  [super init];
  self.replyTypeTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, mySize.width, mySize.height) style:UITableViewStylePlain];
  [self.replyTypeTable setDelegate:self];
  [self.replyTypeTable setDataSource:self];
  
  self.replyTypes = [[NSMutableArray alloc]initWithArray:myReplies];
  
  [self.view addSubview:self.replyTypeTable];
  [self.view setBackgroundColor:[UIColor whiteColor]];
  
  return self;
}

-(void)reloadReplyTypes: (NSArray*) newReplies {
  [self.replyTypes setArray:newReplies];
  [self.replyTypeTable reloadData];
}

-(void)viewDidUnload {
  [super viewDidUnload];
  
  [replyTypes release];
}

#pragma mark - table view lifecycle for ReplyTypeVC

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 50;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row != [self.replyTypes count]) {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.replyTypeTable dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    DBLReplyType *tempReply = [self.replyTypes objectAtIndex:indexPath.row];
    [cell.textLabel setText:tempReply.label];
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:22.0f]];
    
    return  cell;
  }
  
  else {
    static NSString *CellIdentifier = @"Back";
    UITableViewCell *cell = [self.replyTypeTable dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
      cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    [cell.textLabel setText:@"Back"];
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:22.0f]];
    [cell.textLabel setTextColor:[UIColor blueColor]];
    
    return cell;
  }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.replyTypes count]+1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row != [tableView numberOfRowsInSection:0]-1) {
    DBLReplyType *tempReply = [self.replyTypes objectAtIndex:indexPath.row];
    [self.delegate didSelectRow:tempReply];
  }
  else {
    [self.delegate didClickBack];
  }
}

@end

@implementation ReplyQueue

-(id) init {
  [super init];
  queue = [[NSMutableArray alloc]init];
  return self;
}

-(void)dealloc {
  [super dealloc];
  queue = nil;
}

-(int) count {
  return [queue count];
}

-(void) enqueueReply: (DBLReply *) reply {
  [queue addObject:reply];
}

-(DBLReply *) dequeueReply {
  DBLReply *reply = [queue objectAtIndex:0];
  [queue removeObjectAtIndex:0];
  return reply;
}

-(void) clearQueue {
  [queue removeAllObjects];
}

-(BOOL) isEmpty {
  if ([queue count] == 0)
    return YES;
  else
    return NO;
}

@end

@implementation TemporaryReply

-(id) init {
  [super init];
  messageID = [[NSNumber alloc]init];
  message = [[NSString alloc]init];
  replydatetime = [[NSDate alloc]init];
  return self;
}

@end

@implementation MessageCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  cellTitle = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.origin.x+30, self.frame.origin.y, self.frame.size.width-30, self.frame.size.height)];
  [cellTitle setFont:[UIFont boldSystemFontOfSize:20.0f]];
  [cellTitle setBackgroundColor:[UIColor clearColor]];
  [self addSubview:cellTitle];
  
  cellIcon = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.origin.x+2, self.frame.origin.y+2, 25, 24)];
  [cellIcon setImage:[UIImage imageNamed:@"note.png"]];
  [self addSubview:cellIcon];
  [cellIcon setHidden:YES];
  
  return self;
}

-(void) dealloc {
  [super dealloc];
  [cellTitle release];
  [cellIcon release];
}

-(void)displayIcon {
  [cellIcon setHidden:NO];
}

-(void)hideIcon {
  [cellIcon setHidden:YES];
}

-(void)setLabel: (NSString *) text {
  [cellTitle setText:text];
}

@end

@implementation DBLMessagingViewController

@synthesize popControl, myPopover, replyButton;
@synthesize responseMessage, responseType;
@synthesize messagesArray, repliesArray;
@synthesize isMessageSelected;
@synthesize replyTypes, replyTypeVC, activeReplyQueue;
@synthesize checkReachableOnce;

#pragma mark - Webservice functions

-(void)networkAccessChanged {
  hostReach = [[Reachability reachabilityWithHostName: TICKETS_SERVICE_DOMAIN] retain];
  NetworkStatus remoteHostStatus = [hostReach currentReachabilityStatus];
  
  if (remoteHostStatus != NotReachable) {
    
    //this method body gets called multiple times due to reachability checking multiple network statuses, want to check only ONCE
    if (!checkReachableOnce) {
      checkReachableOnce = YES;
      
      NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
      NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
      NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLReply" inManagedObjectContext:context];
      
      [fetchRequest setEntity:entity];
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sent == %@", [NSNumber numberWithBool:NO]];
      
      [fetchRequest setPredicate:predicate];
      
      NSError *error;
      NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
      [fetchRequest release];
      
      if ([fetchedObjects count] != 0) {
        
        for (DBLReply *storedReply in fetchedObjects) {
          
          if (remoteHostStatus != NotReachable) {
            
            SDZTickets *service = [[SDZTickets alloc]init];
            [service SendReply:self
                        action:@selector(SendReplyHandler:)
                      deviceid:[APP_DELEGATE deviceId]
                          udid:[APP_DELEGATE UDID]
                 replydatetime:storedReply.replydatetime
                     messageid:[storedReply.messageID intValue]
                       message:storedReply.message];
            
            [service release];
            
            //add the call to our temporary queue
            [self.activeReplyQueue enqueueReply:storedReply];
          }
        }
      }
    }
  }
  
  else {
    checkReachableOnce = NO;
  }
}

-(void)sendReplyToServer {
  //Grab the message we're replying to
  DBLSavedMessage *tempMessage = [self.messagesArray objectAtIndex:self.messageTable.indexPathForSelectedRow.row];
  
  NSString *replyToSend = [[NSString alloc]init];
  
  //tags are determined to see if the user selected a reply type/additional comment; 0 is no, 1 is yes
  if (myPopover.selectType.tag == 1) {
    replyToSend = myPopover.selectType.titleLabel.text;
  }
  if (myPopover.commentTextView.tag == 1) {
    replyToSend = [NSString stringWithFormat:@"%@-%@", replyToSend, myPopover.commentTextView.text];
  }
  
  self.responseMessage = replyToSend;
  [replyToSend release];
  
  hostReach = [[Reachability reachabilityWithHostName: TICKETS_SERVICE_DOMAIN] retain];
  NetworkStatus remoteHostStatus = [hostReach currentReachabilityStatus];
  
  if (remoteHostStatus != NotReachable) {
    
    SDZTickets *service = [[SDZTickets alloc]init];
    [service SendReply:self
                action:@selector(SendReplyHandler:)
              deviceid:[APP_DELEGATE deviceId]
                  udid:[APP_DELEGATE UDID]
         replydatetime:[NSDate date]
             messageid:[tempMessage.messageID intValue]
               message:replyToSend];
    
    [service release];
    
    //Store the reply temporarily in our queue so we can reference it later once it succeeds or fails
    DBLReply *newReply = [self createReply:replyToSend withID:tempMessage.messageID];
    [self.activeReplyQueue enqueueReply:newReply];
  }
  
  else {
    
    //no connection so save the reply to coredata
    [self createReply:replyToSend withID:tempMessage.messageID];
    
    NSError *error;
    if (![[APP_DELEGATE managedObjectContext] save:&error]) {
      NSLog(@"Error storing reply");
    }
  }
}

-(void)SendReplyHandler: (id) value {
  NSString *result = (NSString *) value;
  
  //check for success first since that should be the most frequent case
  if (!([value isKindOfClass:[NSError class]]) &&
      !([value isKindOfClass:[SoapFault class]]) &&
      !([result isEqualToString:SERVER_RESPONSE_FAILURE_VALUE]) ){
    UIAlertView *newAlert = [[UIAlertView alloc]initWithTitle:@"Replied successfully" message:@"You replied to this message" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [newAlert show];
    [newAlert release];
    
    //this reply request was a success so let's dequeue it and save it
    DBLReply *tempReply = [self.activeReplyQueue dequeueReply];
    [tempReply setSent:YES];
    
    NSError *error;
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLSavedMessage"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageID == %@", tempReply.messageID];
    
    [fetchRequest setPredicate:predicate];
    NSArray *fetchedMessage = [context executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    DBLSavedMessage *temp = [fetchedMessage objectAtIndex:0];
    [temp setUserResponse:tempReply];
    
    if (![context save:&error]) {
      NSLog(@"Error saving reply");
    }
    
    [self changeTextFields:self.messageTable.indexPathForSelectedRow.row];
  }
  
  else {
    
    if([value isKindOfClass:[NSError class]] || [value isKindOfClass:[SoapFault class]]) {
      NSLog(@"SendReply error: %@", value);
      return;
    }
    
    if ([result isEqualToString:SERVER_RESPONSE_FAILURE_VALUE]) {
      UIAlertView *newAlert = [[UIAlertView alloc]initWithTitle:FAILURE_ALERT_TITLE_REPLY
                                                        message:FAILURE_ALERT_MESSAGE_REPLY
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
      [newAlert show];
      [newAlert release];
      
    }
    
    //since we failed and don't want to store the failed reply at all, throw it away
    DBLReply *tempReply = [self.activeReplyQueue dequeueReply];
    
    //also need to grab the reply from coredata and delete it
    NSError *error;
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLReply"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageID == %@", tempReply.messageID];
    
    [fetchRequest setPredicate:predicate];
    NSArray *fetchedReply = [context executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    if ([fetchedReply count] != 0) {
      [context delete:[fetchedReply objectAtIndex:0]];
    }
    
    if (![context save:&error]) {
      NSLog(@"error deleting reply");
    }
    tempReply = nil;
  }
}


#pragma mark - Button clicks

- (IBAction)replyButtonClick:(id)sender {
  //Always check if there is a message selected
  
  if (self.isMessageSelected) {
    DBLSavedMessage *tempMessage = [self.messagesArray objectAtIndex:self.messageTable.indexPathForSelectedRow.row];
    
    NSError *error;
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLReply"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sent == %@ && messageID == %@", [NSNumber numberWithBool:NO], tempMessage.messageID];
    
    [fetchRequest setPredicate:predicate];
    NSArray *fetchedReply = [context executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    
    //Users are not allowed to reply to a message multiple time
    if (tempMessage.userResponse != nil){
      UIAlertView *newAlert = [[UIAlertView alloc]initWithTitle:@"Unable to reply"
                                                        message:@"You have already replied to this message."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
      [newAlert show];
      [newAlert release];
    }
    
    //There is a reply that was queued while offline so do not allow a second reply
    else if ([fetchedReply count] != 0) {
      UIAlertView *newAlert = [[UIAlertView alloc]initWithTitle:@"Unable to reply"
                                                        message:@"You have already replied to this message while offline. Please wait for your connection to re-establish."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
      [newAlert show];
      [newAlert release];
    }
    
    else {
      [self.popControl presentPopoverFromBarButtonItem:self.replyButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
  }
  
  //If no message is selected then they cannot reply to one
  else {
    UIAlertView *newAlert = [[UIAlertView alloc]initWithTitle:@"No message selected"
                                                      message:@"Please select a message to reply to"
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles: nil];
    [newAlert show];
    [newAlert release];
  }
}

- (IBAction)btnReloadClick:(id)sender {
  //Lock out button clicking until it's safe to
  [self.btnReload setEnabled:NO];
  [self.replyButton setEnabled:NO];
  [self.btnReload setTitle:@"Reloading..." forState:UIControlStateDisabled];
  
  //put the reload operation into a background thread so it runs faster
  [APP_DELEGATE reloadRepliesFromServer];
  
  [self performSelector:@selector(delayedReload) withObject:nil afterDelay:1.0];
  
}

- (IBAction)doneEditing:(id)sender {
  [self.messageTable setEditing:NO animated:YES];
  [self.navigationItem setLeftBarButtonItems:nil animated:YES];
  [self.navigationItem setLeftBarButtonItem:self.deleteButton animated:YES];
}

- (IBAction)deleteButtonClick:(id)sender {
  [self.messageTable setEditing:YES animated:YES];
  
  [self.doneEditing setStyle:UIBarButtonItemStyleDone];
  NSArray *leftBarButtons = [[NSArray alloc]initWithObjects:self.doneEditing, self.deleteAllButton, nil];
  
  [[self navigationItem] setLeftBarButtonItems:leftBarButtons animated:YES];
  [leftBarButtons release];
}

- (IBAction)deleteAllButtonClick:(id)sender {
  NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLSavedMessage"
                                            inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	NSError *error = nil;
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
  [fetchRequest release];
  
  //Make sure to delete both the message and the attached response if it is there
  for (DBLSavedMessage *delete in fetchedObjects) {
    if (delete.userResponse != nil) {
      [context deleteObject:delete.userResponse];
    }
    [context deleteObject:delete];
  }
  
  if (![[APP_DELEGATE managedObjectContext] save:&error]) {
    // Handle the errorr
    NSLog(@"Failed to Save Message Deletions: %@", [error localizedDescription]);
    return;
  }
  
  [self setNoMessages];
  
  [self hideCommentViews];
  [self hideReplyTypeViews];
  
  self.isMessageSelected = NO;
  [self.messagesArray removeAllObjects];
  [[self messageTable] reloadData];
}


#pragma mark - Core Data helpers

-(DBLReply *) createReply: (NSString *) message withID: (NSNumber *) ID {
  NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLReply" inManagedObjectContext: context];
  DBLReply *newReply = [[DBLReply alloc]initWithEntity:entity insertIntoManagedObjectContext: context];
  [newReply setMessage:message];
  [newReply setMessageID:ID];
  [newReply setSent:NO];
  [newReply setReplydatetime:[NSDate date]];
  
  return newReply;
}

-(void)initialMessageFetch {
  NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLSavedMessage"
                                            inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	NSError *error;
  
  [self.messagesArray removeAllObjects];
  
  self.messagesArray = [NSMutableArray arrayWithArray:[context executeFetchRequest:fetchRequest error:&error]];
  
	[fetchRequest release];
  
  //delete any tickets older than 90 days
  NSDate *today = [NSDate date];
  NSCalendar *myCal = [NSCalendar currentCalendar];
  
  //create our start and end day intervals
  NSDateComponents *temp = [[NSDateComponents alloc]init];
  [temp setDay:-90];
  NSDate *startDate = [myCal dateByAddingComponents:temp toDate:today options:0];
  
  NSMutableArray *deleteArray = [[NSMutableArray alloc]init];
  for (DBLSavedMessage *temp in self.messagesArray) {
    if (![self date:temp.received isBetween:startDate and:today]) {
      [deleteArray addObject:temp];
    }
  }
  
  [self.messagesArray removeObjectsInArray:deleteArray];
  
  for (DBLSavedMessage *temp in deleteArray) {
    [context deleteObject:temp];
  }
  
  [context save:&error];
  [deleteArray removeAllObjects];
  [deleteArray release];

  
  NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"received" ascending:NO];
  [self.messagesArray sortUsingDescriptors:[NSMutableArray arrayWithObject:sort]];
  [sort release];
}

-(void)fetchMessagesFromCoreData {
  NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLSavedMessage"
                                            inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	NSError *error;
  
  [self.messagesArray removeAllObjects];
  
  self.messagesArray = [NSMutableArray arrayWithArray:[context executeFetchRequest:fetchRequest error:&error]];
  
	[fetchRequest release];
  
  NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"received" ascending:NO];
  [self.messagesArray sortUsingDescriptors:[NSMutableArray arrayWithObject:sort]];
  [sort release];
}

-(void)messageDismissed {
  [[UIApplication sharedApplication] cancelAllLocalNotifications];
  
  [self fetchMessagesFromCoreData];
  [self.messageTable reloadData];
  
  [self selectNewestCell];
}

-(void)loadDefaultReplies {
  //Load stock reply types from coredata
  NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLReplyType" inManagedObjectContext:context];
  [fetchRequest setEntity:entity];
  NSError *error;
  
  [self.replyTypes removeAllObjects];
  self.replyTypes = [NSMutableArray arrayWithArray:[context executeFetchRequest:fetchRequest error:&error]];
  
  [fetchRequest release];
  
  NSSortDescriptor *sortDescriptor;
  sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"index"
                                                ascending:YES] autorelease];
  NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
  self.replyTypes = [NSMutableArray arrayWithArray:[self.replyTypes sortedArrayUsingDescriptors:sortDescriptors]];
}

-(void)delayedReload {
  [self loadDefaultReplies];
  
  [self.replyTypeVC reloadReplyTypes:self.replyTypes];
  
  [self.btnReload setEnabled:YES];
  [self.replyButton setEnabled:YES];
}


#pragma mark - helper functions

- (BOOL) date:(NSDate*)date isBetween:(NSDate*)beginDate and:(NSDate*)endDate {
  return (([date compare:beginDate] != NSOrderedAscending) && ([date compare:endDate] != NSOrderedDescending));
}

-(void)selectNewestCell {
  NSIndexPath *topIndex = [NSIndexPath indexPathForRow:0 inSection:0];
  
  [self.messageTable selectRowAtIndexPath:topIndex animated:NO scrollPosition:UITableViewScrollPositionTop];
  [self changeTextFields:0];
  
  DBLSavedMessage *tempMessage = [self.messagesArray objectAtIndex:topIndex.row];
  
  //mark as read if it was previously unread
  if (![[tempMessage valueForKey:@"hasRead"] boolValue]) {
    [tempMessage setValue:[NSNumber numberWithBool:YES] forKey:@"hasRead"];
    
    MessageCell *newestCell = (MessageCell *) [self.messageTable cellForRowAtIndexPath:topIndex];
    [newestCell hideIcon];
    
    NSError *error;
    if (![[APP_DELEGATE managedObjectContext] save:&error]) {
      NSLog(@"Error saving unread status");
    }
  }
}

-(void)setNoMessages {
  [self.messageTitle setText:@"No Messages"];
  [self.messageBody setHidden:YES];
  [self.messageBody setText:@""];
  [self.dateLabel setText:@""];
}

-(void)hideReplyTypeViews {
  [self.lblReplyType setText:@""];
  [self.txtReplyType setHidden:YES];
}

-(void)hideCommentViews {
  [self.lblComment setText:@""];
  [self.txtComment setHidden:YES];
}

-(void)revealReplyTypeViews {
  [self.lblReplyType setText:@"Reply type:"];
  [self.txtReplyType setHidden:NO];
}

-(void)revealCommentViews {
  [self.lblComment setText:@"Comment:"];
  [self.txtComment setHidden:NO];
}

-(void) changeTextFields: (int)index {
  DBLSavedMessage *tempMessage = [self.messagesArray objectAtIndex:self.messageTable.indexPathForSelectedRow.row];
  
  //Change the appropriate views for the message selected
  [self.messageTitle setText:[NSString stringWithFormat:@"From: %@", tempMessage.sender]];
  [self.messageBody setText:tempMessage.message];
  [self.messageBody setHidden:NO];
  
  NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
  [dateFormat setDateFormat:@"MM/dd/yyyy @ h:mm a"];
  NSString *receiveDate = [dateFormat stringFromDate:tempMessage.received];
  [dateFormat release];
  [self.dateLabel setText:[NSString stringWithFormat:@"Received on %@", receiveDate]];
  
  //Check if there's a reply attached to that message and if so, display it
  if (tempMessage.userResponse != nil) {
    [self.replyHeader setText:@"Your reply:"];
    
    DBLReply *tempReply = (DBLReply *) tempMessage.userResponse;
    
    NSArray *parse = [[NSArray alloc]initWithArray:[tempReply.message componentsSeparatedByString:@"-"]];
    NSRange findHyphen = [tempReply.message rangeOfString:@"-"];
    
    //Check if there was a reply type attached to this reply
    if (findHyphen.location > 0) {
      [self revealReplyTypeViews];
      [self.txtReplyType setText:[parse objectAtIndex:0]];
    }
    
    //nothing to display, hide the views
    else {
      [self hideReplyTypeViews];
    }
    
    //Check if there was an additional comment
    if ([tempReply.message length] > findHyphen.location) {
      [self revealCommentViews];
      [self.txtComment setText:[parse objectAtIndex:1]];
    }
    
    //nothing to display, hide the comment views
    else {
      [self hideCommentViews];
    }
    
    [parse release];
  }
  
  else {
    [self.replyHeader setText:@"You have not replied yet"];
    [self hideCommentViews];
    [self hideReplyTypeViews];
  }
}


#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if ([self.messagesArray count] > 0) {
    [self selectNewestCell];
    self.isMessageSelected = YES;
    
  }
  
  else {
    self.isMessageSelected = NO;
    [self.replyHeader setText:@""];
    [self hideReplyTypeViews];
    [self hideCommentViews];
  }
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  //Memory allocations
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(messageDismissed)
                                               name:NOTIFICATION_messageDismissed
                                             object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkAccessChanged) name:kReachabilityChangedNotification object:nil];
  
  self.messagesArray = [[NSMutableArray alloc]init];
  self.repliesArray = [[NSMutableArray alloc]init];
  self.replyTypes = [[NSMutableArray alloc]init];
  self.responseMessage = [[NSString alloc]init];
  self.activeReplyQueue = [[ReplyQueue alloc]init];
  
  self.checkReachableOnce = NO;
  
  //Grab replies and messages from coredata
  [self loadDefaultReplies];
  [self fetchMessagesFromCoreData];
  
  //Setup the view controllers for our popovers
  self.replyTypeVC = [[ReplyTypeViewController alloc]initWithFrameSize:REPLYTYPE_VC_CGSize andReplies:self.replyTypes];
  [replyTypeVC setDelegate:self];
  
  myPopover = [[DBLPopoverViewController alloc]init];
  myPopover.myReplyTypes = replyTypes;
  [myPopover setDelegate:self];
  [myPopover resetTags];
  
  popControl = [[UIPopoverController alloc]initWithContentViewController:myPopover];
  [popControl setPopoverContentSize:POPOVER_VC_CGSize];
  
  
  //UI setup
  self.title = @"Messages";
  
  [self.replyButton setTitle:@"Reply"];
  [self.navigationItem setRightBarButtonItem:self.replyButton];
  
  [self.deleteButton setTitle:@"Edit"];
  [self.navigationItem setLeftBarButtonItem:self.deleteButton];
  
  [self.txtComment.layer setCornerRadius:10.0f];
  [self.txtReplyType.layer setCornerRadius:10.0f];
  [self.messageBody.layer setCornerRadius:10.0f];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  
  [self setReplyButton:nil];
  [self setMessageTable:nil];
  
  self.responseMessage = nil;
  [self setMessagesArray:nil];
  [self setRepliesArray:nil];
  [self setReplyTypes:nil];
  [self setActiveReplyQueue:nil];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_messageDismissed object:nil] ;
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
  
  hostReach = nil;
  [self setMessageTitle:nil];
  [self setMessageBody:nil];
  [self setReplyHeader:nil];
  [self setDateLabel:nil];
  [self setDeleteButton:nil];
  [self setDeleteAllButton:nil];
  [self setDoneEditing:nil];
  [self setLblReplyType:nil];
  [self setTxtReplyType:nil];
  [self setLblComment:nil];
  [self setTxtComment:nil];
  [self setBtnReload:nil];
  
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  //return (interfaceOrientation == UIInterfaceOrientationPortrait);
  return YES;
  //return NO;
}

- (void)dealloc
{
  [replyButton release];
  
  [responseMessage release];
  [messagesArray release];
  [repliesArray release];
  
  [_messageTable release];
  [_messageTitle release];
  [_messageBody release];
  [_replyHeader release];
  [_dateLabel release];
  [_deleteButton release];
  [_deleteAllButton release];
  [_doneEditing release];
  [_lblReplyType release];
  [_txtReplyType release];
  [_lblComment release];
  [_txtComment release];
  [_btnReload release];
  [super dealloc];
}

- (void)didReceiveMemoryWarning
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}


#pragma mark - Table view delegate functions

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if ([messagesArray count] == 0) {
    [self setNoMessages];
    [self hideCommentViews];
    [self hideReplyTypeViews];
  }
  
  return [messagesArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  static NSString *CellIdentifier = @"MessageCell";
	
	MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[MessageCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  
  DBLSavedMessage *tempMessage = [self.messagesArray objectAtIndex:indexPath.row];
  
  NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
  [dateFormat setDateFormat:@"MM/dd, h:mm a"];
  NSString *receiveDate = [dateFormat stringFromDate:tempMessage.received];
  [dateFormat release];
  
  //Look for a space in the message sender's name so we can only put in first name
  NSString *shortName = tempMessage.sender;
  NSRange range = [shortName rangeOfString:@" "];
  
  //If it does have a space, truncate it
  if (range.location < [shortName length]) {
    shortName = [shortName substringToIndex:range.location];
  }
  
  [cell setLabel:[NSString stringWithFormat:@"%@, %@", shortName, receiveDate]];
  
  if (![[tempMessage valueForKey:@"hasRead"] boolValue]) {
    [cell displayIcon];
  }
  else {
    [cell hideIcon];
  }
  
  return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  self.isMessageSelected = YES;
  [self changeTextFields:indexPath.row];
  
  DBLSavedMessage *tempMessage = [self.messagesArray objectAtIndex:indexPath.row];
  
  //mark as read if it was previously unread
  if (![[tempMessage valueForKey:@"hasRead"] boolValue]) {
    [tempMessage setValue:[NSNumber numberWithBool:YES] forKey:@"hasRead"];
    
    MessageCell *cell = (MessageCell*)[self.messageTable cellForRowAtIndexPath:indexPath];
    [cell hideIcon];
    
    NSError *error;
    if (![[APP_DELEGATE managedObjectContext] save:&error]) {
      NSLog(@"Error saving unread status");
    }
  }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    
    DBLSavedMessage *message = [self.messagesArray objectAtIndex:indexPath.row];
    
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLSavedMessage" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageID = %@", message.messageID];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    //Make sure we delete any attached responses along with the message if there is one
    for (DBLSavedMessage *delete in fetchedObjects) {
      if (delete.userResponse != nil) {
        [context deleteObject:delete.userResponse];
      }
      [context deleteObject:delete];
    }
    
    if ([context save:&error] == NO) {
      // Handle Error.
    }
    self.isMessageSelected = NO;
    [self.messagesArray removeObjectAtIndex:indexPath.row];
    [self.messageTable reloadData];
  }
}


#pragma mark - popover delegate functions

-(void)didClickBack {
  [self.popControl setPopoverContentSize:POPOVER_VC_CGSize animated:YES];
  [popControl setContentViewController:self.myPopover];
}

-(void)didSelectRow: (DBLReplyType *)selectedReply {
  [self.popControl setPopoverContentSize:POPOVER_VC_CGSize animated:YES];
  [self.myPopover.selectType setTitle:[NSString stringWithString:selectedReply.label] forState:UIControlStateNormal];
  
  //Setting the button tag to determine whether a reply type has been selected or not
  [self.myPopover.selectType setTag:1];
  [popControl setContentViewController:self.myPopover];
}

-(void)didClickSendButton {
  if ([popControl isPopoverVisible]) {
    //If there was no selected response and no additional comment, don't bother sending
    if (myPopover.selectType.tag == 0 && [myPopover emptyText]) {
      UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Reply fields empty" message:@"Reply was not sent. Please select a reply type or add a comment." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
      [alert show];
      [alert release];
    }
    
    else {
      [self sendReplyToServer];
    }
    
    [popControl dismissPopoverAnimated:YES];
    
    //reset values for the popovers
    [self.myPopover resetView];
    [self.myPopover resetTags];
  }
}

-(void) didSelectType {
  [self.popControl setPopoverContentSize:REPLYTYPE_VC_CGSize animated:YES];
  [popControl setContentViewController:self.replyTypeVC];
}


@end
