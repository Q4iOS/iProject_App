//
//  DBLAssignmentCell.h
//  DBL
//
//  Created by Tobias O'Leary on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBLScheduleInfo;

@interface DBLAssignmentCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UILabel *textLabel;
@property (retain, nonatomic) IBOutlet UIButton *loadedButton;
@property (retain, nonatomic) DBLScheduleInfo *schedule;
@property (retain, nonatomic) IBOutlet UIView *infoView;

- (IBAction)loadedClicked:(id)sender;

//Updates Cell Style to make is look completed.
- (void)setCompleted:(BOOL)isCompleted;

@end