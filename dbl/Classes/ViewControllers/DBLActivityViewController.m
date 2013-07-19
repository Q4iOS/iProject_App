//
//  DBLActivityViewController.m
//  DBL
//
//  Created by Kelvin Quiroz on 11/19/12.
//
//

#import "DBLActivityViewController.h"

@interface DBLActivityViewController ()

@end

@implementation DBLActivityViewController

@synthesize myActivities;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

-(void)viewDidLoad {
  [self.activitiesTable setFrame:self.view.frame];
  //  [self.activitiesTable setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.activitiesTable.frame.size.width, self.activitiesTable.frame.size.height)];
}

- (void)dealloc {
  [_activitiesTable release];
  [self.myActivities release];
  self.delegate = nil;
  [super dealloc];
}
- (void)viewDidUnload {
  [self setActivitiesTable:nil];
  [myActivities release];
  [super viewDidUnload];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row != [self.myActivities count]) {
    [self.delegate didSelectRow];
  }
  
  else {
    [self.delegate selectedCustomRow];
  }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSLog(@"self.myActivities count: %d", [self.myActivities count]);
  return [self.myActivities count] + 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row < [self.myActivities count]) {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    DBLActivity *temp =[self.myActivities objectAtIndex:indexPath.row];
    [cell.textLabel setText:temp.label];
    
    return cell;
  }
  
  else {
    static NSString *CellIdentifier = @"CustomCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    [cell.textLabel setText:@"Use custom status message"];
    [cell.textLabel setTextColor:[UIColor blueColor]];
    
    return cell;
  }
}

@end
