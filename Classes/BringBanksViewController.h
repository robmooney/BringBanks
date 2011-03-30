//
//  BringBanksViewController.h
//  BringBanks
//
//  Created by Robert Mooney on 30/11/2010.
//  Copyright 2010 Robert Mooney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BringBank.h"

@interface BringBanksViewController : UIViewController <MKMapViewDelegate> {
@private
    NSArray *bringBanks_;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, readonly) MKCoordinateRegion allBringBanksRegion;

- (void)loadBringBanks;
- (void)selectBringBank:(BringBank *)bringBank;

- (IBAction)showNearest:(id)sender;
- (IBAction)showAll:(id)sender;

@end

