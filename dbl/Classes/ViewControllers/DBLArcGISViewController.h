//
//  DBLArcGISViewController.h
//  DBL
//
//  Created by Kelvin Quiroz on 2/21/13.
//
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import <CoreLocation/CoreLocation.h>
#import "DBLAppDelegate.h"
#import "DBLCLController.h"

@protocol PlantLocationsDelegate <NSObject>

-(void)didSelectPlant: (int) row;

@end

@interface PlantLocationsViewController : UITableViewController

@property (nonatomic, retain) id<PlantLocationsDelegate> delegate;

@end

@interface DBLArcGISViewController : UIViewController <AGSMapViewLayerDelegate, AGSLayerDelegate, AGSMapViewTouchDelegate, UIPopoverControllerDelegate, PlantLocationsDelegate> {
  UIPopoverController *myPopoverController;
  PlantLocationsViewController *myTableVC;
  AGSSketchGraphicsLayer *mySketchLayer;
  AGSPoint *myLastPoint;
  NSArray *myPlants;
  
  UIBarButtonItem *btnStartTrack;
  UIBarButtonItem *btnStopTrack;
}

@property (nonatomic, retain) AGSMapView *mapView;
@property (nonatomic, retain) NSMutableArray *arrPoints;

@end
