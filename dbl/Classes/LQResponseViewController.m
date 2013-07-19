//
//  LQResponseViewController.m
//  Logiq
//
//  Created by Kelvin Quiroz on 5/17/13.
//  Copyright (c) 2013 LuckCompanies. All rights reserved.
//

#define DEFAULT_TEXT_FIELD_STRING @"Enter additional comment here"

#import "LQResponseViewController.h"

@interface LQResponseListViewController ()

@end

@implementation LQResponseListViewController

-(id)initWithResponses:(NSArray *)responses {
    self = [super init];
    if (self) {
        myResponses = [[NSArray alloc]initWithArray:responses];
        
    }
    return self;
}

-(void)setResponses:(NSArray *)responses {
    myResponses = [NSArray arrayWithArray:responses];
}

-(int)getArrayLength {
    return [myResponses count];
}

#pragma mark - table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != [myResponses count]) {
        [self.delegate didSelectRow];
    }
    
    else {
        [self.delegate didSelectCancel];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [myResponses count] + 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < [myResponses count]) {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        DBLActivity *temp =[myResponses objectAtIndex:indexPath.row];
        [cell.textLabel setText:temp.label];
        
        return cell;
    }
    
    else {
        static NSString *CellIdentifier = @"CustomCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        [cell.textLabel setText:@"Cancel"];
        [cell.textLabel setTextColor:[UIColor blueColor]];
        
        return cell;
    }
}

@end


@interface LQResponseViewController ()

@end

@implementation LQResponseViewController

@synthesize delegate;

-(void)setSelectedType: (NSString*) label {
    [btnSelectType setTag:1];
    [btnSelectType setTitle:label forState:UIControlStateNormal];
}

-(NSString*)getFullResponse {
    NSString *response = [[NSString alloc]init];;
    if (btnSelectType.tag != 0) {
        response = btnSelectType.titleLabel.text;
        
        if (txtComment.tag != 0) {
            response = [response stringByAppendingString:@" - "];
            response = [response stringByAppendingString:txtComment.text];
        }
    }
    
    else {
        response = txtComment.text;
    }
    
    return response;
}

-(void) resetView {
    [btnSelectType setTitle:strTypeTitle forState:UIControlStateNormal];
    [self resetText];
}

-(void) resetText {
    [txtComment setText:DEFAULT_TEXT_FIELD_STRING];
    [txtComment setTextColor:[UIColor lightGrayColor]];
    [txtComment setTag:0];
}

-(void) resetTags {
    [txtComment setTag:0];
    [btnSelectType setTag:0];
}

-(BOOL) emptyText {
    return ([txtComment.text length] == 0 || [txtComment.text isEqualToString: DEFAULT_TEXT_FIELD_STRING]);
}

-(BOOL) statusFieldIsEmpty {
    if (txtComment.tag == 0 || [txtComment.text length] == 0) {
        if (btnSelectType.tag == 0) {
            return YES;
        }
        else {
            return NO;
        }
    }
    else {
        return NO;
    }
}

-(int)getArrayLength {
    return [arrTypes count];
}

#pragma mark - lifecycle

-(id)initWithPopoverSize:(CGSize)size typeArray:(NSArray*)types typeTitle:(NSString*)typestring andDoneTitle:(NSString*)donestring {
    self = [super init];
    if (self) {
        [self setContentSizeForViewInPopover:size];
        [self.view setBackgroundColor:[UIColor whiteColor]];
        
        strTypeTitle = [[NSString alloc]initWithString:typestring];
        
        btnSelectType = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [btnSelectType.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
    //  [btnSelectType setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [btnSelectType addTarget:self action:@selector(selectTypeClick) forControlEvents:UIControlEventTouchUpInside];
        [btnSelectType setFrame:CGRectMake(10, 10, 430, 50)];
        [btnSelectType setTitle:typestring forState:UIControlStateNormal];
       // [btnSelectType setupButtonWithGreenGradient];
        
        btnDone = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [btnDone addTarget:self action:@selector(didClickDoneNotes) forControlEvents:UIControlEventTouchUpInside];
        [btnDone setFrame:CGRectMake(10, 215, 430, 50)];
       // [btnDone setupButtonWithGreenGradient];
        [btnDone setTitle:donestring forState:UIControlStateNormal];
        [btnDone.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
        
        txtComment = [[UITextView alloc]initWithFrame:CGRectMake(10, 70, 430, 140)];
        [txtComment.layer setBorderColor:[UIColor darkGrayColor].CGColor];
        [txtComment.layer setBorderWidth:3.0f];
        [txtComment setFont:[UIFont systemFontOfSize:20.0f]];
        [txtComment setDelegate:self];
        
        arrTypes = [[NSArray alloc]initWithArray:types];
        
        [self.view addSubview:btnDone];
        [self.view addSubview:btnSelectType];
        [self.view addSubview:txtComment];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - reponse delegate

-(void)selectTypeClick {
    [self.delegate didClickSelect];
}

-(void)didClickDoneNotes {
    [self.delegate didClickDoneNotes];
}

#pragma mark - textview delegate

-(void)textViewDidBeginEditing:(UITextView *)textView {
    if ([self emptyText]) {
        [txtComment setText:@""];
        [txtComment setTextColor:[UIColor blackColor]];
        [txtComment setTag:1];
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    if ([txtComment.text length] == 0) {
        [self resetText];
    }
}

-(void) setTextField: (NSString*)text {
  [txtComment setTag:1];
  [txtComment setText:text];
}


@end
