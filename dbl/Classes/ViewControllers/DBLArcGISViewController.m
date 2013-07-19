//
//  DBLArcGISViewController.m
//  DBL
//
//  Created by Kelvin Quiroz on 2/21/13.
//
//

typedef enum {
  Bealeton = 0,
  Berkley,
  Boscobel,
  BullRun,
  Burkeville,
  Caroline,
  Charlottesville,
  Culpeper,
  Fairfax,
  Gilmerton,
  GooseCreek,
  Greene,
  Leesburg,
  Massaponax,
  Pittsboro,
  Powhatan,
  Rockville,
  SouthRichmond,
  Specialty,
  Spotsylvania,
  Toano
}PlantName;

#import "DBLArcGISViewController.h"

@implementation PlantLocationsViewController

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 50;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return Toano+1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.delegate didSelectPlant:indexPath.row];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
  }
  
  switch (indexPath.row) {
    case Rockville:
      [cell.textLabel setText:@"Rockville"];
      break;
      
    case SouthRichmond:
      [cell.textLabel setText:@"South Richmond"];
      break;
      
    case Specialty:
      [cell.textLabel setText:@"Specialty"];
      break;
      
    case Spotsylvania:
      [cell.textLabel setText:@"Spotsylvania"];
      break;
      
    case Toano:
      [cell.textLabel setText:@"Toano"];
      break;
      
    case Greene:
      [cell.textLabel setText:@"Greene"];
      break;
      
    case Leesburg:
      [cell.textLabel setText:@"Leesburg"];
      break;
      
    case Massaponax:
      [cell.textLabel setText:@"Massaponax"];
      break;
      
    case Pittsboro:
      [cell.textLabel setText:@"Pittsboro"];
      break;
      
    case Powhatan:
      [cell.textLabel setText:@"Powhatan"];
      break;
      
    case Charlottesville:
      [cell.textLabel setText:@"Charlottesville"];
      break;
      
    case Culpeper:
      [cell.textLabel setText:@"Culpeper"];
      break;
      
    case Fairfax:
      [cell.textLabel setText:@"Fairfax"];
      break;
      
    case Gilmerton:
      [cell.textLabel setText:@"Gilmerton"];
      break;
      
    case GooseCreek:
      [cell.textLabel setText:@"Goose Creak"];
      break;
      
    case Burkeville:
      [cell.textLabel setText:@"Burkeville"];
      break;
      
    case Caroline:
      [cell.textLabel setText:@"Caroline"];
      
    case Berkley:
      [cell.textLabel setText:@"Berkley"];
      break;
      
    case BullRun:
      [cell.textLabel setText:@"Bull Run"];
      break;
      
    case Bealeton:
      [cell.textLabel setText:@"Bealeton"];
      break;
      
    case Boscobel:
      [cell.textLabel setText:@"Boscobel"];
      break;
      
    default:
      break;
  }
  
  return cell;
}

@end


@interface DBLArcGISViewController ()

@end

@implementation DBLArcGISViewController

@synthesize mapView;

#pragma mark - helper functions

-(void)loadPlantLocations {
  AGSSpatialReference *sr = [AGSSpatialReference webMercatorSpatialReference];
  
  AGSEnvelope *bealeton = [AGSEnvelope envelopeWithXmin:-77.7719019174394 ymin:38.5555912951024 xmax:-77.7641770567257 ymax:38.5605307261123 spatialReference:sr];
  AGSEnvelope *berkley = [AGSEnvelope envelopeWithXmin:-76.2715320832389 ymin:36.8339514004369 xmax:-76.2700872908956 ymax:36.8360168994605 spatialReference:sr];
  AGSEnvelope *boscobel = [AGSEnvelope envelopeWithXmin:-77.7196717418573 ymin:37.5929764823789 xmax:-77.7108990396588 ymax:37.5957930879808 spatialReference:sr];
  AGSEnvelope *bullrun = [AGSEnvelope envelopeWithXmin:-77.5441235595545 ymin:38.8508819784207 xmax:-77.5393125517327 ymax:38.8541090103228 spatialReference:sr];
  AGSEnvelope *burkeville = [AGSEnvelope envelopeWithXmin:-78.1991320131318 ymin:37.1917629694856 xmax:-78.193477210105 ymax:37.1982322911875 spatialReference:sr];
  AGSEnvelope *caroline = [AGSEnvelope envelopeWithXmin:-77.3542333561843 ymin:37.9924904016109 xmax:-77.3504474289056 ymax:37.9942605677712 spatialReference:sr];
  AGSEnvelope *charlottesville = [AGSEnvelope envelopeWithXmin:-78.4100165731062 ymin:38.0117566083809 xmax:-78.3968710208808 ymax:38.0151568820846 spatialReference:sr];
  AGSEnvelope *culpeper = [AGSEnvelope envelopeWithXmin:-77.9225015877779 ymin:38.4374248101071 xmax:-77.9174312469543 ymax:38.4410752014596 spatialReference:sr];
  AGSEnvelope *fairfax = [AGSEnvelope envelopeWithXmin:-77.4952925694963 ymin:38.8204062358593 xmax:-77.4874716548928 ymax:38.8285662937996 spatialReference:sr];
  AGSEnvelope *gilmerton = [AGSEnvelope envelopeWithXmin:-76.2957907576372 ymin:36.7662307074813 xmax:-76.292583052166 ymax:36.7675892224648 spatialReference:sr];
  AGSEnvelope *goosecreek = [AGSEnvelope envelopeWithXmin:-77.5234624215533 ymin:39.0766529029093 xmax:-77.5161618088202 ymax:39.0834811611268 spatialReference:sr];
  AGSEnvelope *greene = [AGSEnvelope envelopeWithXmin:-78.3715497138481 ymin:38.2438220641371 xmax:-78.3660038510967 ymax:38.2518847156073 spatialReference:sr];
  AGSEnvelope *leesburg = [AGSEnvelope envelopeWithXmin:-77.5230285742092 ymin:39.0602721970045 xmax:-77.5146075500982 ymax:39.0667651699768 spatialReference:sr];
  AGSEnvelope *massaponax = [AGSEnvelope envelopeWithXmin:-77.5339968659624 ymin:38.1819289663489 xmax:-77.5272417064394 ymax:38.1852763437284 spatialReference:sr];
  AGSEnvelope *pittsboro = [AGSEnvelope envelopeWithXmin:-79.1738722195271 ymin:35.6614370201025 xmax:-79.1679851530922 ymax:35.6650275975458 spatialReference:sr];
  AGSEnvelope *powhatan = [AGSEnvelope envelopeWithXmin:-77.7753433180395 ymin:37.5189856261858 xmax:-77.7715468722902 ymax:37.5224131583407 spatialReference:sr];
  AGSEnvelope *rockville = [AGSEnvelope envelopeWithXmin:-77.6571740514412 ymin:37.6898844097379 xmax:-77.6497579684553 ymax:37.6961523075831 spatialReference:sr];
  AGSEnvelope *southrichmond = [AGSEnvelope envelopeWithXmin:-77.4291792348337 ymin:37.4937678086376 xmax:-77.4246633701183 ymax:37.4978935195704 spatialReference:sr];
  AGSEnvelope *specialty = [AGSEnvelope envelopeWithXmin:-78.3683601701856 ymin:38.2508923892725 xmax:-78.3644967384336 ymax:38.2520002515106 spatialReference:sr];
  AGSEnvelope *spotsylvania = [AGSEnvelope envelopeWithXmin:-77.5568098639839 ymin:38.20546013148 xmax:-77.5516296484894 ymax:38.2146341948124 spatialReference:sr];
  AGSEnvelope *toano = [AGSEnvelope envelopeWithXmin:-76.7897302982145 ymin:37.3784059700596 xmax:-76.7843786098848 ymax:37.3796236224324 spatialReference:sr];
  
  myPlants = [[NSArray alloc]initWithObjects:bealeton, berkley, boscobel, bullrun, burkeville, caroline, charlottesville, culpeper, fairfax, gilmerton, goosecreek, greene, leesburg, massaponax, pittsboro, powhatan, rockville, southrichmond, specialty, spotsylvania, toano, nil];
}

#pragma mark - button actions

-(void)plantsClick {
  [myPopoverController setContentViewController:myTableVC];
  [myPopoverController setPopoverContentSize:myTableVC.contentSizeForViewInPopover];
  [myPopoverController presentPopoverFromBarButtonItem:self.navigationItem.leftBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void)startTrackClick {
  self.mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeDefault;
  self.mapView.locationDisplay.wanderExtentFactor = 0.75;
  [self.navigationItem setRightBarButtonItem:btnStopTrack];
}

-(void)stopTrackClick {
  self.mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeOff;
  [self.navigationItem setRightBarButtonItem:btnStartTrack];
}

#pragma mark - popover delegate functions

-(void)didSelectPlant:(int)row {
  [myPopoverController dismissPopoverAnimated:YES];
  
  [self.mapView zoomToEnvelope:(AGSEnvelope*) [myPlants objectAtIndex:row] animated:YES];
}

#pragma mark AGSMapViewLayer delegate functions

-(void)layerDidLoad:(AGSLayer *)layer {
  AGSDynamicLayer *dynamic = (AGSDynamicLayer*)layer;
  NSLog(@"layer envelope: %@",   dynamic.fullEnvelope);
}

#pragma mark AGSMapViewTouchDelegate functions

-(void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics {
}


#pragma mark - life cycle functions

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self loadPlantLocations];
  self.arrPoints = [[NSMutableArray alloc]init];
  
  myLastPoint = [[AGSPoint alloc]initWithSpatialReference:[AGSSpatialReference spatialReferenceWithWKID:4326 WKT:nil]];
  
  myTableVC = [[PlantLocationsViewController alloc]init];
  [myTableVC setContentSizeForViewInPopover:CGSizeMake(400, 700)];
  [myTableVC setDelegate:self];
  
  myPopoverController = [[UIPopoverController alloc]initWithContentViewController:myTableVC];
  
  //navigation bar setup
  UIBarButtonItem *btnPlants = [[UIBarButtonItem alloc]initWithTitle:@"Plant Locations" style:UIBarButtonItemStyleBordered target:self action:@selector(plantsClick)];
  [self.navigationItem setLeftBarButtonItem:btnPlants];
  [btnPlants release];
  
  btnStartTrack = [[UIBarButtonItem alloc]initWithTitle:@"Begin Tracking" style:UIBarButtonItemStyleBordered target:self action:@selector(startTrackClick)];
  btnStopTrack = [[UIBarButtonItem alloc]initWithTitle:@"Stop Tracking" style:UIBarButtonItemStyleBordered target:self action:@selector(stopTrackClick)];
    [self.navigationItem setRightBarButtonItem:btnStopTrack];
  
  [self.navigationItem setTitle:@"ArcGIS Map"];
  
  self.mapView = [[AGSMapView alloc]initWithFrame:self.view.bounds];
  [self.mapView setLayerDelegate:self];
  
  //base map
  AGSTiledMapServiceLayer *tiledLayer = [AGSTiledMapServiceLayer
                                         tiledMapServiceLayerWithURL:[NSURL URLWithString:@"http://server.arcgisonline.com/ArcGIS/rest/services/ESRI_Imagery_World_2D/MapServer"]];
  [self.mapView addMapLayer:tiledLayer withName:@"Tiled Layer"];
  
  //luckstone arcgis server
  NSURL* luckstoneMapServer = [NSURL URLWithString:@"http://gis.luckstone.com/ArcGIS/rest/services/plant_maps/plant_maps_EOY2012/MapServer"];
  AGSDynamicMapServiceLayer *luckstoneLayer = [AGSDynamicMapServiceLayer dynamicMapServiceLayerWithURL:luckstoneMapServer];
  [luckstoneLayer setDelegate:self];
  [self.mapView addMapLayer:luckstoneLayer withName:@"Luckstone Plants"];
  
  //drawing layer
  mySketchLayer = [[AGSSketchGraphicsLayer alloc] initWithGeometry:nil];
	[self.mapView addMapLayer:mySketchLayer withName:@"Sketch layer"];
  [self.mapView setTouchDelegate:self];
  
  //center map on user at start
  
  [self.view addSubview:self.mapView];
  
  //center the map
  [self.mapView.locationDisplay startDataSource];
  self.mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeDefault;
  self.mapView.locationDisplay.navigationPointHeightFactor = 0.5;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  
  [myTableVC release];
  [myPopoverController release];
  [self.mapView release];
}

@end
