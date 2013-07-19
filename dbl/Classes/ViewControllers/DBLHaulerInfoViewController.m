//
//  DBLHaulerInfoViewController.m
//  DBL
//
//  Created by Ryan Emmons on 3/21/11.
//  Copyright 2011 Luck Stone. All rights reserved.
//

#import "DBLHaulerInfoViewController.h"
#import "DBLTicket.h"

@implementation MonthlyPopover

-(id)initWithFrameSize:(CGSize) size {
  [super init];
  monthPicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height - 40)];
  [monthPicker setCalendar:[NSCalendar currentCalendar]];
  [monthPicker setDatePickerMode:UIDatePickerModeDate];
   [monthPicker setDate:[NSDate date]];
  
  btnSelect = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [btnSelect addTarget:self action:@selector(selectClick) forControlEvents:UIControlEventTouchUpInside];
  [btnSelect setFrame:CGRectMake(size.width/2, size.height - 45, (size.width/2) - 10, 40)];
  [btnSelect setTitle:@"Select Month" forState:UIControlStateNormal];
  
  btnCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [btnCancel addTarget:self action:@selector(selectCancel) forControlEvents:UIControlEventTouchUpInside];
  [btnCancel setFrame:CGRectMake(5, size.height - 45, (size.width/2) - 10, 40)];
  [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
  
  [self.view addSubview:monthPicker];
  [self.view addSubview:btnSelect];
  [self.view addSubview:btnCancel];
  
  return self;
}

-(void)setPickerDate: (NSDate *)newDate {
  [monthPicker setDate:newDate];
}

-(void)selectClick {
  [self.delegate clickedSelect:monthPicker.date];
}

-(void)selectCancel {
  [self.delegate clickedCancel];
}

-(void)dealloc {
  [super dealloc];
  
  [monthPicker release];
  [btnSelect release];
  [btnCancel release];
}

@end

@interface DBLHaulerInfoViewController ()

- (void)loadHaulerInfo:(NSDate *)date;
- (NSString*) formatCurrencyValue:(double)value;
//loading functions
- (void)showLoading;
- (void)hideLoading;

@end


@implementation DBLHaulerInfoViewController

@synthesize spinner, refreshButton, totalTonsToday, totalHaulRate, totalFSCToday;
@synthesize myCalendar, selectedDate, previousIndex;

- (void)dealloc
{
  [_sgmntSelectType release];
  [_lblSelectedDate release];
  [_lblDateHeader release];
  [super dealloc];
  [spinner release];
  [totalHaulRate release];
  [totalTonsToday release];
  [refreshButton release];
  [totalFSCToday release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  self.navigationItem.rightBarButtonItem = self.refreshButton;
  
  self.selectedDate = [NSDate date];
  [self loadHaulerInfo:self.selectedDate];
  
  [self createCalendar];
  
  //adjust UI
  [self.totalFSCToday.layer setCornerRadius:10.0f];
  [self.totalHaulRate.layer setCornerRadius:10.0f];
  [self.totalTonsToday.layer setCornerRadius:10.0f];

  //create our popover
  CGSize popoverSize = CGSizeMake(300, 260);
  self.myMonthlyPopover = [[MonthlyPopover alloc]initWithFrameSize:popoverSize];
  [self.myMonthlyPopover setDelegate:self];
  self.popControl = [[UIPopoverController alloc]initWithContentViewController:self.myMonthlyPopover];
  [self.popControl setDelegate:self];
  [self.popControl setPopoverContentSize:popoverSize];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  
  [self setSgmntSelectType:nil];
  [self setLblSelectedDate:nil];
  [self setLblDateHeader:nil];
  
  self.selectedDate = nil;
  self.spinner = nil;
  self.totalHaulRate = nil;
  self.totalTonsToday = nil;
  self.refreshButton = nil;
  self.totalFSCToday = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark -
#pragma mark Loading Functions
-(void)createCalendar {
  //create the calendar
  self.myCalendar = [[CKCalendarView alloc]initWithFrame:CGRectMake(self.sgmntSelectType.frame.origin.x, self.sgmntSelectType.frame.origin.y + self.sgmntSelectType.frame.size.height + 10, self.sgmntSelectType.frame.size.width, 420)];
  self.myCalendar.delegate = self;
  self.myCalendar.selectedDate = self.selectedDate;
  [self.myCalendar setShouldFillCalendar:YES];
  self.myCalendar.adaptHeightToNumberOfWeeksInMonth = NO;
  
  if (self.sgmntSelectType.selectedSegmentIndex != 1){
    [self.myCalendar setHighlightFollowingWeek:NO];
  }
  else  {
    [self.myCalendar setHighlightFollowingWeek:YES];
  }  
  [self.view addSubview:self.myCalendar];
}

- (void)loadHaulerInfo: (NSDate*) date
{
  [self showLoading];
  
  NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBLTicket"
                                            inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"ticketDate" ascending:NO];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortByDate]];
	[sortByDate release];
	
	NSError *error = nil;
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
  
  double totalhaulcharge = 0;
  double totaltonshauled = 0;
  double totalfsc = 0;
  
  NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
  [dateFormat setDateFormat:@"MM/dd/yyyy"];
  NSString *selectedDateString = [dateFormat stringFromDate:date];
  
  //day mode is selected so only grab one day
  if (self.sgmntSelectType.selectedSegmentIndex == 0) {
    
    for (DBLTicket *ticket in fetchedObjects) {
      [dateFormat setDateFormat:SERVICE_DATE_FORMAT];
      NSDate *date = [dateFormat dateFromString:[ticket ticketDate]];
      [dateFormat setDateFormat:@"MM/dd/yyyy"];
      NSString *formattedDateString = [dateFormat stringFromDate:date];
      
      if ([formattedDateString isEqualToString:selectedDateString])
      {
        if ([[ticket haulIndicator] isEqualToString:@"L"]) {
          double temp_haulrate = [[ticket haulRate] doubleValue];
          double temp_nettons = [[ticket netTons] doubleValue];
          double temp_fsc = [[ticket fuelSurcharge] doubleValue];
          totalhaulcharge += temp_haulrate;
          totaltonshauled += temp_nettons;
          totalfsc += temp_fsc;
        }
        else
        {
          //add haul rate * tons to total
          //NSLog(@"Haul Rate: %@",temp_ticket.HaulRate);
          double temp_haulrate = [[ticket haulRate] doubleValue];
          double temp_nettons = [[ticket netTons] doubleValue];
          double temp_haulcharge = temp_nettons * temp_haulrate;
          double temp_fsc = [[ticket fuelSurcharge] doubleValue];
          totalhaulcharge += temp_haulcharge;
          totaltonshauled += temp_nettons;
          totalfsc += temp_fsc;
        }
      }
    }
    [dateFormat release];
    [fetchRequest release];
    
    [self.lblDateHeader setText:@"Information for the day of"];
    [self.lblSelectedDate setText:selectedDateString];
  }
  
  //otherwise they're in week mode
  else if (self.sgmntSelectType.selectedSegmentIndex == 1) {
    NSCalendar *myCal = [NSCalendar currentCalendar];
    
    //create our start and end day intervals
    NSDateComponents *temp = [[[NSDateComponents alloc]init]autorelease];
    [temp setDay:7];
    NSDate *nextWeek = [myCal dateByAddingComponents:temp toDate:date options:0];
  
    //strip out the hour/minute elements from the NSDates
    NSDateComponents *start = [[[NSDateComponents alloc]init]autorelease];
    start = [myCal components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:date];
    NSDate *startDate = [myCal dateFromComponents:start];
    
    NSDateComponents *end = [[[NSDateComponents alloc]init]autorelease];
    end = [myCal components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:nextWeek];
    NSDate *endDate = [myCal dateFromComponents:end];
    
    for (DBLTicket *ticket in fetchedObjects) {
      [dateFormat setDateFormat:SERVICE_DATE_FORMAT];
      NSDate *targetDate = [dateFormat dateFromString:[ticket ticketDate]];
      
      if ([self date:targetDate isBetweenDate:startDate andDate:endDate]) {
        if ([[ticket haulIndicator] isEqualToString:@"L"]) {
          double temp_haulrate = [[ticket haulRate] doubleValue];
          double temp_nettons = [[ticket netTons] doubleValue];
          double temp_fsc = [[ticket fuelSurcharge] doubleValue];
          totalhaulcharge += temp_haulrate;
          totaltonshauled += temp_nettons;
          totalfsc += temp_fsc;
        }
        else
        {
          //add haul rate * tons to total
          //NSLog(@"Haul Rate: %@",temp_ticket.HaulRate);
          double temp_haulrate = [[ticket haulRate] doubleValue];
          double temp_nettons = [[ticket netTons] doubleValue];
          double temp_haulcharge = temp_nettons * temp_haulrate;
          double temp_fsc = [[ticket fuelSurcharge] doubleValue];
          totalhaulcharge += temp_haulcharge;
          totaltonshauled += temp_nettons;
          totalfsc += temp_fsc;
        }
      }
    }
    [dateFormat release];
    [fetchRequest release];
    
    [self.lblDateHeader setText:@"Information for the week following"];
    [self.lblSelectedDate setText:selectedDateString];
  }
  
  //month mode
  else {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *selectedComp = [[[NSDateComponents alloc]init] autorelease];
    selectedComp = [cal components:(NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:date];
    
    NSDateFormatter *monthYear = [[NSDateFormatter alloc]init];
    NSString *monthName = [[monthYear monthSymbols] objectAtIndex:[selectedComp month]-1];
    
    
    for (DBLTicket *ticket in fetchedObjects) {
      [dateFormat setDateFormat:SERVICE_DATE_FORMAT];
      NSDate *targetDate = [dateFormat dateFromString:[ticket ticketDate]];
      NSDateComponents *targetComp = [[[NSDateComponents alloc]init]autorelease];
      targetComp = [cal components:(NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:targetDate];
      
      if ([targetComp month] == [selectedComp month] && [targetComp year] == [selectedComp year]) {
        if ([[ticket haulIndicator] isEqualToString:@"L"]) {
          double temp_haulrate = [[ticket haulRate] doubleValue];
          double temp_nettons = [[ticket netTons] doubleValue];
          double temp_fsc = [[ticket fuelSurcharge] doubleValue];
          totalhaulcharge += temp_haulrate;
          totaltonshauled += temp_nettons;
          totalfsc += temp_fsc;
        }
        else
        {
          //add haul rate * tons to total
          //NSLog(@"Haul Rate: %@",temp_ticket.HaulRate);
          double temp_haulrate = [[ticket haulRate] doubleValue];
          double temp_nettons = [[ticket netTons] doubleValue];
          double temp_haulcharge = temp_nettons * temp_haulrate;
          double temp_fsc = [[ticket fuelSurcharge] doubleValue];
          totalhaulcharge += temp_haulcharge;
          totaltonshauled += temp_nettons;
          totalfsc += temp_fsc;
        }
      }
    }
    [dateFormat release];
    [fetchRequest release];
    
    
    [self.lblDateHeader setText:@"Information for the month of"];
    [self.lblSelectedDate setText:[NSString stringWithFormat:@"%@, %d", monthName, [selectedComp year]]];
    
    [monthYear release];
  }
  
  //set labels here//
  self.totalHaulRate.text = [self formatCurrencyValue:totalhaulcharge];
  self.totalTonsToday.text = [NSString stringWithFormat: @"%.2lf", totaltonshauled];
  self.totalFSCToday.text = [self formatCurrencyValue:totalfsc];
  ///////////////////
  [self hideLoading];
  
}

//UI clicks refresh button
- (void)refreshButtonClick:(id)sender
{
  [self loadHaulerInfo:self.selectedDate];
  
  //refresh can also be used to wipe the calendar in case it highlights everything
  [self.myCalendar removeFromSuperview];
  self.myCalendar = nil;
  [self createCalendar];
}

- (IBAction)sgmntValueChanged:(id)sender {
  UISegmentedControl *temp = sender;
  
  //day mode
  if (temp.selectedSegmentIndex == 0) {
    [self loadHaulerInfo:self.selectedDate];
    self.previousIndex = temp.selectedSegmentIndex;
    [self.myCalendar setHighlightFollowingWeek:NO];
    [self.myCalendar layoutSubviews];
  }
  
  //week mode
  else if (temp.selectedSegmentIndex == 1) {
    [self loadHaulerInfo:self.selectedDate];
    self.previousIndex = temp.selectedSegmentIndex;
    [self.myCalendar setHighlightFollowingWeek:YES];
    [self.myCalendar layoutSubviews];
  }
  
  //month mode
  else {
    [self.myCalendar setHighlightFollowingWeek:NO];
    [self.myMonthlyPopover setPickerDate:self.selectedDate];
    [self.popControl presentPopoverFromRect:CGRectMake(temp.frame.origin.x+((temp.frame.size.width/3)*2), temp.frame.origin.y, temp.frame.size.width/3, temp.frame.size.height) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
  }
}

-(NSString*) formatCurrencyValue:(double)value
{
  NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
  [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
  [numberFormatter setCurrencySymbol:@"$"];
  [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
  NSNumber *c = [NSNumber numberWithFloat:value];
  NSString *currencyValue =  [numberFormatter stringFromNumber:c];
  [numberFormatter release];
  
  return currencyValue;
}

#pragma mark -
#pragma mark Support Methods

- (void)handleError:(NSError *)error {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                  message:[error description]
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
  [alert show];
  [alert release];
}

- (void)showLoading {
  self.navigationItem.titleView = self.spinner;
  [self.spinner startAnimating];
}

- (void)hideLoading {
  [self.spinner stopAnimating];
  self.navigationItem.titleView = nil;
}

- (BOOL) date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate {
  return (([date compare:beginDate] != NSOrderedAscending) && ([date compare:endDate] != NSOrderedDescending));
}

#pragma mark - CKCalendar Delegate function

- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date {
  self.selectedDate = date;
  [self loadHaulerInfo:date];
}

-(void)calendar:(CKCalendarView *)calendar didChangeMonth:(int)month {
  
  if (self.sgmntSelectType.selectedSegmentIndex == 2) {
    NSDateComponents* comps = [[[NSDateComponents alloc] init] autorelease];
    NSCalendar *cal = [NSCalendar currentCalendar];
    [comps setMonth:month];
    self.selectedDate = [cal dateByAddingComponents:comps toDate:self.selectedDate options:0];
    [self loadHaulerInfo:self.selectedDate];
    [self.myCalendar setSelectedDate:self.selectedDate];
    [self.myCalendar layoutSubviews];
  }
}

#pragma mark - popover delegate functions

-(void)clickedSelect: (NSDate*) newDate {
  self.selectedDate = newDate;
  [self loadHaulerInfo:newDate];
  [self.popControl dismissPopoverAnimated:YES];
  [self.myCalendar setSelectedDate:newDate];
}

-(void)clickedCancel {
  [self.sgmntSelectType setSelectedSegmentIndex:self.previousIndex];
  [self.popControl dismissPopoverAnimated:YES];
  
  if (self.previousIndex == 1) {
    [self.myCalendar setHighlightFollowingWeek:YES];
  }
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
  [self.sgmntSelectType setSelectedSegmentIndex:self.previousIndex];
  
  if (self.previousIndex == 1) {
    [self.myCalendar setHighlightFollowingWeek:YES];
  }
}

@end
