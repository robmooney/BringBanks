//
//  BringBanksViewController.h
//  BringBanks
//
//  Created by Robert Mooney on 30/11/2010.
//  Copyright 2010 Robert Mooney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BringBanksLoader.h"
#import "BringBank.h"

@interface BringBanksViewController : UIViewController <MKMapViewDelegate> {
@private
    NSArray *glassBringBanks_;
    NSArray *cansBringBanks_;
    NSArray *textilesBringBanks_;
    NSArray *filteredBringBanks_;
}

@property (nonatomic, copy) NSArray *bringBanks;

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) UISegmentedControl *filterControl;
@property (nonatomic, readonly) MKCoordinateRegion allBringBanksRegion;

- (void)selectBringBank:(BringBank *)bringBank;
- (void)showFilteredBringBanks;

- (IBAction)showNearest:(id)sender;
- (IBAction)showAll:(id)sender;
- (IBAction)filterChanged:(UISegmentedControl *)sender;

@end

