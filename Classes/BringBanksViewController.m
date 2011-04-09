//
//  BringBanksViewController.m
//  BringBanks
//
//  Created by Robert Mooney on 30/11/2010.
//  Copyright 2010 Robert Mooney. All rights reserved.
//

#import "BringBanksViewController.h"
#import "BringBankViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <libxml/xmlreader.h>

@implementation BringBanksViewController

@synthesize bringBanks = bringBanks_;

@synthesize mapView = mapView_;
@synthesize filterControl = filterControl_;
@synthesize allBringBanksRegion = allBringBanksRegion_;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStyleBordered target:nil action:nil];        
    self.navigationItem.backBarButtonItem = backBarButtonItem;        
    [backBarButtonItem release];
    
    UIBarButtonItem *allButton = [[UIBarButtonItem alloc] initWithTitle:@"All" 
                                                                  style:UIBarButtonItemStyleBordered 
                                                                 target:self 
                                                                 action:@selector(showAll:)];
    
    self.navigationItem.leftBarButtonItem = allButton;
    
    [allButton release];
    
    UIBarButtonItem *nearestButton = [[UIBarButtonItem alloc] initWithTitle:@"Nearest" 
                                                                      style:UIBarButtonItemStyleBordered 
                                                                     target:self 
                                                                     action:@selector(showNearest:)];
    nearestButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = nearestButton;
    
    [nearestButton release];
    
    
    UISegmentedControl *filterControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Any", @"Glass", @"Cans", @"Textiles", nil]];
    
    filterControl.segmentedControlStyle = UISegmentedControlStyleBar;
    filterControl.selectedSegmentIndex = 0;
    filterControl.tintColor = [UIColor colorWithRed:0.2f green:0.4f blue:0.2f alpha:1.0f];
    
    [filterControl addTarget:self action:@selector(filterChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.filterControl = filterControl; 
    
    [filterControl release];
    
    UIBarButtonItem *filterBarButton = [[[UIBarButtonItem alloc] initWithCustomView:self.filterControl] autorelease];        
    UIBarButtonItem *flexibleSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    
    /*UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    
    [infoButton addTarget:self action:@selector(showAboutScreen:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIBarButtonItem *infoBarButton = [[[UIBarButtonItem alloc] initWithCustomView:infoButton] autorelease];  */  
    
    self.toolbarItems = [NSArray arrayWithObjects:flexibleSpace, filterBarButton, flexibleSpace, nil];    
    
	self.mapView.region = self.allBringBanksRegion;
    
    [self showFilteredBringBanks];
}

#pragma mark - Rotation support

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return interfaceOrientation == UIInterfaceOrientationPortrait || 
        interfaceOrientation == UIInterfaceOrientationLandscapeLeft || 
        interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	self.mapView = nil;
}

- (void)dealloc {
    mapView_.delegate = nil;
    [mapView_ release];
    [filterControl_ release];
    [bringBanks_ release];
    [glassBringBanks_ release];
    [cansBringBanks_ release];
    [textilesBringBanks_ release];
    [super dealloc];
}

#pragma mark - Bring banks

- (void)setBringBanks:(NSArray *)bringBanks {    
    [bringBanks_ release];    
    bringBanks_ = [bringBanks copy];    
    
    NSMutableArray *tempGlassBringBanks = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *tempCansBringBanks = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *tempTextilesBringBanks = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (BringBank *bringBank in bringBanks_) {
        
        if (bringBank.materialTypes & BringBankMaterialTypeGlass) {
            [tempGlassBringBanks addObject:bringBank];
        }
        
        if (bringBank.materialTypes & BringBankMaterialTypeCans) {
            [tempCansBringBanks addObject:bringBank];
        }
        
        if (bringBank.materialTypes & BringBankMaterialTypeTextiles) {
            [tempTextilesBringBanks addObject:bringBank];
        }
        
    }
    
    [glassBringBanks_ release];
    [cansBringBanks_ release];
    [textilesBringBanks_ release];
    
    glassBringBanks_ = [tempGlassBringBanks copy];
    cansBringBanks_ = [tempCansBringBanks copy];
    textilesBringBanks_ = [tempTextilesBringBanks copy];
    
    [tempGlassBringBanks release];
    [tempCansBringBanks release];
    [tempTextilesBringBanks release];
    
    filteredBringBanks_ = bringBanks_;
    
    if ([self isViewLoaded]) {    
        [self showFilteredBringBanks];
    }
}

- (MKCoordinateRegion)allBringBanksRegion {    
    
    if (allBringBanksRegion_.span.latitudeDelta == 0.0 && allBringBanksRegion_.span.longitudeDelta == 0.0) {
        CLLocationDegrees minLat = 90.0;
        CLLocationDegrees maxLat = -90.0;
        CLLocationDegrees minLon = 180.0;
        CLLocationDegrees maxLon = -180.0;
        
        for (id <MKAnnotation> bringBank in bringBanks_) {
            if (bringBank.coordinate.latitude != 0 && bringBank.coordinate.longitude != 0) {
                if (bringBank.coordinate.latitude < minLat) {
                    minLat = bringBank.coordinate.latitude;
                }		
                if (bringBank.coordinate.longitude < minLon) {
                    minLon = bringBank.coordinate.longitude;
                }		
                if (bringBank.coordinate.latitude > maxLat) {
                    maxLat = bringBank.coordinate.latitude;
                }		
                if (bringBank.coordinate.longitude > maxLon) {
                    maxLon = bringBank.coordinate.longitude;
                }
            }
        }
        
        
        MKCoordinateSpan span = MKCoordinateSpanMake(maxLat - minLat, maxLon - minLon);
        
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake((maxLat - span.latitudeDelta / 2), maxLon - span.longitudeDelta / 2);
        
        // add a slight offset to make room for the map view pins
        center.latitude += 0.01;
        
        allBringBanksRegion_ = MKCoordinateRegionMake(center, span);
    }
	
	return allBringBanksRegion_;
}

- (void)selectBringBank:(BringBank *)bringBank {    
    [self.mapView selectAnnotation:bringBank animated:YES];
}

- (void)showFilteredBringBanks {
    
    NSMutableArray *annotationsToRemove = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (id <MKAnnotation> annotation in self.mapView.annotations) {
        if ([annotation isKindOfClass:[BringBank class]]) {
            if (![filteredBringBanks_ containsObject:annotation]) {
                [annotationsToRemove addObject:annotation];
            }
        }
    }
    
    NSMutableArray *annotationsToAdd = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (BringBank *bringBank in filteredBringBanks_) {
        if (![self.mapView.annotations containsObject:bringBank]) {
            [annotationsToAdd addObject:bringBank];
        }
    }
    
    [self.mapView removeAnnotations:annotationsToRemove];
    [self.mapView addAnnotations:annotationsToAdd];
    
    [annotationsToRemove release];
    [annotationsToAdd release];
}

#pragma mark - Map view delgate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        // enable "Nearest" button
        self.navigationItem.rightBarButtonItem.enabled = YES;
        return nil;
    }
	
    if ([annotation isKindOfClass:[BringBank class]]) {
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"PinAnnotationView"];
		
        if (!pinView) {
			pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"PinAnnotationView"] autorelease];
			pinView.canShowCallout = YES;
            pinView.animatesDrop = YES;
            pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		} else {
			pinView.annotation = annotation;
		}
				
        return pinView;
    }
	
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    BringBankViewController *detailViewController = [[BringBankViewController alloc] initWithNibName:nil bundle:nil];
    detailViewController.bringBank = (BringBank *)view.annotation;
    detailViewController.userLocation = self.mapView.userLocation.location;
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

#pragma mark - IBActions

- (IBAction)showNearest:(id)sender {
    if (self.mapView.userLocation.location) {
        CLLocationDistance closestDistance = MAXFLOAT;
        BringBank *closestBringBank = nil;
        
        CLLocation *userLocation = self.mapView.userLocation.location;
        
        for (id <MKAnnotation> bringBank in filteredBringBanks_) {
            CLLocation *location = [[CLLocation alloc] initWithLatitude:bringBank.coordinate.latitude 
                                                              longitude:bringBank.coordinate.longitude];
            CLLocationDistance distance = [location distanceFromLocation:userLocation];
            [location release];
            
            if (distance < closestDistance) {
                closestDistance = distance;
                closestBringBank = bringBank;
            }
        }
        
        [self.mapView setRegion:MKCoordinateRegionMake(closestBringBank.coordinate, 
                                                       MKCoordinateSpanMake(0.01, 0.01)) 
                       animated:YES];
        [self performSelector:@selector(selectBringBank:) withObject:closestBringBank afterDelay:0.5];
    }
   
}

- (IBAction)showAll:(id)sender {
    
    for (id <MKAnnotation> annotation in self.mapView.selectedAnnotations) {
        [self.mapView deselectAnnotation:annotation animated:YES];
    }
    
	[self.mapView setRegion:self.allBringBanksRegion animated:YES];
}

- (IBAction)filterChanged:(UISegmentedControl *)sender {    
    switch (sender.selectedSegmentIndex) {
        case 0: {
            filteredBringBanks_ = bringBanks_;
            break;
        }
        case 1: {
            filteredBringBanks_ = glassBringBanks_;
            break;
        }
        case 2: {
            filteredBringBanks_ = cansBringBanks_;
            break;
        }
        case 3: {
            filteredBringBanks_ = textilesBringBanks_;
            break;
        }
    }
    
    [self showFilteredBringBanks];
}

- (IBAction)showAboutScreen:(id)sender {
    aboutViewController_ = [[AboutViewController alloc] initWithNibName:nil bundle:nil];    
    aboutViewController_.view.frame = [[UIScreen mainScreen] applicationFrame];
    
    aboutViewController_.doneButton.target = self;
    aboutViewController_.doneButton.action = @selector(hideAboutScreen:);
    
    [UIView transitionFromView:self.navigationController.view 
                        toView:aboutViewController_.view 
                      duration:0.5 
                       options:UIViewAnimationOptionTransitionFlipFromRight 
                    completion:NULL];
}

- (IBAction)hideAboutScreen:(id)sender {    
    [UIView transitionFromView:aboutViewController_.view
                        toView:self.navigationController.view 
                      duration:0.5 
                       options:UIViewAnimationOptionTransitionFlipFromLeft 
                    completion:^ (BOOL finished) {
                        [aboutViewController_ release];
                    }];
}


@end
