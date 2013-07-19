//
//  DBLWindow.m
//  DBL
//
//  Created by Tobias O'Leary on 2/8/12.
//  Copyright (c) 2012 Luck Stone. All rights reserved.
//

#import "DBLWindow.h"

#import <CoreLocation/CoreLocation.h>

#import "DBLAppDelegate.h"

@interface DBLWindow()

- (void)enableInterface;
- (void)disableInterface;

- (void)locationDidChange:(NSNotification*)notification;
- (double)calculateSpeed:(CLLocation*)newLocation;

@end

@implementation DBLWindow

@synthesize disablingView;
@synthesize lastShakeDate;
@synthesize savedLocations;
@synthesize availabilityDisablingView;
@synthesize myDeviceID;

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if(self) {

  }
    
  return self;
}


- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:NOTIFICATION_statusChange
                                                object:nil];

  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:NOTIFICATION_locationChanged
                                                object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:NOTIFICATION_locationServicesOff
                                                object:nil];
  
  [super dealloc];
}

- (void)windowDidLoad
{
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(locationDidChange:)
                                               name:NOTIFICATION_locationChanged
                                             object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(handleStatusChanged:)
                                               name:NOTIFICATION_statusChange
                                             object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(disableForLocations)
                                               name:NOTIFICATION_locationServicesOff
                                             object:nil];
  
  _locationIndex = 0;
  savedLocations = [[NSMutableArray alloc] initWithCapacity:5];
}


- (void)locationDidChange:(NSNotification*)notification
{
  CLLocation *newLocation = [[notification userInfo] objectForKey:@"NewLocation"];
  
  double speed = [self calculateSpeed:newLocation];
  _calculatedSpeed = speed;
  
  if([APP_DELEGATE status] == YES) { //Only disable interface if driver is present
    NSNumber *speedLimit = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_speedLimit];
    
    if(_calculatedSpeed > [speedLimit intValue]) {
      [self disableInterface];
    }
    else {
      [self enableInterface];
    }
  }
}

- (double)calculateSpeed:(CLLocation *)newLocation
{
  double avgSpeed = 0.0;
  
  if(newLocation != nil && newLocation.horizontalAccuracy >= 0.0 && newLocation.horizontalAccuracy <= 10 && [newLocation.timestamp timeIntervalSinceNow] < 60) {
    
    if([savedLocations count] < 3) {
      [savedLocations addObject:newLocation];
    } else {
      [savedLocations replaceObjectAtIndex:_locationIndex withObject:newLocation];
      _locationIndex++;
      _locationIndex %= 3;
    }
  }
  
  double totalSpeed = 0.0;
  for(CLLocation *location in savedLocations) {
    totalSpeed += [location speed];
  }
  
  
  avgSpeed = totalSpeed / (double)[savedLocations count];
  avgSpeed = 2.23693629 * avgSpeed; //convert meters per second to miles per hour
  
  return avgSpeed;
}

/// Uncomment to see screen on shake
//- (void)sendEvent:(UIEvent *)event
//{
//  if([event type] == UIEventTypeMotion && 
//     [event subtype] == UIEventSubtypeMotionShake &&
//     ([self lastShakeDate] == nil ||
//      ABS([[self lastShakeDate] timeIntervalSinceNow]) > 1.0))
//  {
//    NSLog(@"Shake Detected");
//    NSDate *now = [[NSDate alloc] init];
//    [self setLastShakeDate:now];
//    [now release];
//    
//    if(disablingView == nil) {
//      [self disableInterface];
//    } else {
//      [self enableInterface];
//    }
//  }
//  
//  [super sendEvent:event];
//}

- (void)enableInterface
{
  if(disablingView != nil) {
    [[self disablingView] removeFromSuperview];
    [self setDisablingView:nil];
  }
}


-(void)disableForLoading {
  if(disablingView == nil) {
    
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    
    UIView *aDisablingView = [[UIView alloc] initWithFrame:appFrame];
    UIColor *backgroundColor = [UIColor colorWithRed:0.0
                                               green:0.0
                                                blue:0.0
                                               alpha:0.7];
    [aDisablingView setBackgroundColor:backgroundColor];
    
    CGRect messageFrame = CGRectMake(0, 0, appFrame.size.width, appFrame.size.height);
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]init];
    [indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicator setFrame:CGRectMake((messageFrame.size.width-indicator.frame.size.width)/2, (messageFrame.size.height-indicator.frame.size.height)/2, indicator.frame.size.width, indicator.frame.size.width)];
    
    [aDisablingView addSubview:indicator];
    
    [indicator startAnimating];
    [indicator release];
    
    [self addSubview:aDisablingView];
    [self setDisablingView:aDisablingView];
    [aDisablingView release];
  }
}

-(void)disableForLocations {
  if(disablingView == nil) {
    
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    
    UIView *aDisablingView = [[UIView alloc] initWithFrame:appFrame];
    UIColor *backgroundColor = [UIColor colorWithRed:0.0
                                               green:0.0
                                                blue:0.0
                                               alpha:0.7];
    [aDisablingView setBackgroundColor:backgroundColor];
    
    CGRect messageFrame = CGRectMake(0, 0, appFrame.size.width, appFrame.size.height);
    UILabel *disabledMessage = [[UILabel alloc] initWithFrame:messageFrame];
    
    [disabledMessage setText:@" Location services are off. \n Please turn them on to use this app. "];
    [disabledMessage setFont:[UIFont fontWithName:@"Helvetica-Bold" size:32.0]];
    [disabledMessage setTextAlignment:UITextAlignmentCenter];
    [disabledMessage setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
    [disabledMessage setTextColor:[UIColor whiteColor]];
    [disabledMessage setShadowColor:[UIColor blackColor]];
    [disabledMessage setShadowOffset:CGSizeMake(2, 2)];
    [disabledMessage setNumberOfLines:0];
    [disabledMessage sizeToFit];
    
    [disabledMessage setFrame:CGRectMake(0, messageFrame.size.height/2 - disabledMessage.frame.size.height/2, messageFrame.size.width, disabledMessage.frame.size.height)];
    
//    [disabledMessage setFrame:CGRectMake(messageFrame.size.width/2 - disabledMessage.frame.size.width/2, messageFrame.size.height/2 - disabledMessage.frame.size.height/2, disabledMessage.frame.size.width, disabledMessage.frame.size.height)];
    
    [aDisablingView addSubview:disabledMessage];
    [disabledMessage release];
    
    [self addSubview:aDisablingView];
    [self setDisablingView:aDisablingView];
    [aDisablingView release];
  }
}

- (void)disableInterface
{
  if(disablingView == nil) {  
    
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    
    UIView *aDisablingView = [[UIView alloc] initWithFrame:appFrame];
    UIColor *backgroundColor = [UIColor colorWithRed:0.0 
                                               green:0.0 
                                                blue:0.0 
                                               alpha:0.1];
    [aDisablingView setBackgroundColor:backgroundColor];
    
    CGRect messageFrame = CGRectMake(0, appFrame.size.height - 48.0, appFrame.size.width, 48.0);
    UILabel *disabledMessage = [[UILabel alloc] initWithFrame:messageFrame];
    
    [disabledMessage setText:@"Reduce speed before using application"];
    [disabledMessage setFont:[UIFont fontWithName:@"Helvetica-Bold" size:32.0]];
    [disabledMessage setTextAlignment:UITextAlignmentCenter];
    [disabledMessage setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
    [disabledMessage setTextColor:[UIColor whiteColor]];
    [disabledMessage setShadowColor:[UIColor blackColor]];
    [disabledMessage setShadowOffset:CGSizeMake(2, 2)];
    
    [aDisablingView addSubview:disabledMessage];
    [disabledMessage release];
    
// Don't show calculated speed
//    CGRect speedFrame = CGRectMake((appFrame.size.width - 300.0)/2.0, (appFrame.size.height - 50.0)/2.0, 300.0, 50.0);
//    UILabel *speedLabel = [[UILabel alloc] initWithFrame:speedFrame];
//    
//    [speedLabel setText:[NSString stringWithFormat:@"%f", _calculatedSpeed]];
//    [speedLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:32.0]];
//    [speedLabel setTextAlignment:UITextAlignmentCenter];
//    [speedLabel setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
//    [speedLabel setTextColor:[UIColor whiteColor]];
//    [speedLabel setShadowColor:[UIColor blackColor]];
//    [speedLabel setShadowOffset:CGSizeMake(2, 2)];
//    
//    [aDisablingView addSubview:speedLabel];
//    [speedLabel release];
    
    [self addSubview:aDisablingView];
    [self setDisablingView:aDisablingView];
    [aDisablingView release];
  }
}


@end
