//
//  DBLWindow.h
//  DBL
//
//  Created by Tobias O'Leary on 2/8/12.
//  Copyright (c) 2012 Luck Stone. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DBLWindowDelegate <NSObject>



@end

@interface DBLWindow : UIWindow {
  
  int _locationIndex;
  double _calculatedSpeed;
  
}

@property (nonatomic, retain) UIView *disablingView;
@property (nonatomic, retain) UIView *availabilityDisablingView;
@property (nonatomic, retain) NSDate *lastShakeDate;
@property (nonatomic, retain) NSMutableArray *savedLocations;
@property (nonatomic, retain) UITextField *myDeviceID;

- (void)windowDidLoad;
-(void)disableForLoading;
- (void)enableInterface;

//- (void) updateWindowBasedOnAvailability:(BOOL)available;

@end
