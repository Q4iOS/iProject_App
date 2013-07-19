//
//  LQResponseViewController.h
//  Logiq
//
//  Created by Kelvin Quiroz on 5/17/13.
//  Copyright (c) 2013 LuckCompanies. All rights reserved.
//

#define DEFAULT_POPOVER_SIZE CGSizeMake(450, 275)

#import <UIKit/UIKit.h>
#import "DBLAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@protocol ResponseListDelegate <NSObject>
-(void)didSelectRow;
-(void)didSelectCancel;
@end

@interface LQResponseListViewController : UITableViewController {
    NSArray *myResponses;
}

@property (retain, nonatomic) id<ResponseListDelegate> delegate;

-(id)initWithResponses:(NSArray*)responses;
-(void)setResponses:(NSArray *)responses;
-(int)getArrayLength;

@end


@protocol ResponseDelegate <NSObject>

-(void)didClickDoneNotes;
-(void)didClickSelect;

@end

@interface LQResponseViewController : UIViewController <UITextViewDelegate> {
    UIButton *btnSelectType;
    UIButton *btnDone;
    UITextView *txtComment;
    NSArray *arrTypes;
    NSString *strTypeTitle;
}

@property (nonatomic, assign) id<ResponseDelegate> delegate;


-(void)selectTypeClick;
-(void)doneClick;
-(void)setSelectedType:(NSString*)label;

-(int)getArrayLength;
-(NSString*) getFullResponse;
-(void) resetView;
-(void) resetTags;
-(BOOL) emptyText;
-(BOOL) statusFieldIsEmpty;
-(void) setTextField: (NSString*)text;


-(id)initWithPopoverSize:(CGSize)size typeArray:(NSArray*)types typeTitle:(NSString*)typestring andDoneTitle:(NSString*)donestring;

@end
