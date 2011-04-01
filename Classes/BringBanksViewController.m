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
    
    self.toolbarItems = [NSArray arrayWithObjects:flexibleSpace, filterBarButton, flexibleSpace, nil];
    
    if (allBringBanks_ == nil) {
        [self loadBringBanks];
    }
    
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
    [allBringBanks_ release];
    [glassBringBanks_ release];
    [cansBringBanks_ release];
    [textilesBringBanks_ release];
    [super dealloc];
}

#pragma mark - Bring banks

- (void)loadBringBanks {
    
    NSMutableArray *tempBringBanks = [[NSMutableArray alloc] initWithCapacity:0];
    
    BringBank *bringBank = nil;
    
    CLLocationCoordinate2D coord;
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Bring_Banks" 
                                                                                 withExtension:@"kml"]];
    
    xmlTextReaderPtr reader = xmlReaderForMemory(
                                                 [data bytes], 
                                                 [data length], 
                                                 NULL, 
                                                 NULL, 
                                                 (XML_PARSE_NOBLANKS | XML_PARSE_NOCDATA | XML_PARSE_NOERROR | XML_PARSE_NOWARNING)
                                                 );
	
	if (reader) {
		
		xmlChar const *currentTagName = NULL;
		xmlChar const *currentTagValue = NULL;
		xmlChar *currentNameAttr = NULL;
		
		while (YES) {
			if (!xmlTextReaderRead(reader)) {
				break;
			}
			
			switch (xmlTextReaderNodeType(reader)) {
					
				case XML_READER_TYPE_ELEMENT:		
                    
					currentTagName = xmlTextReaderConstName(reader);
					
					if (xmlStrEqual(currentTagName, BAD_CAST "Placemark")) {
						bringBank = [[BringBank alloc] init];
					}
					
					if (xmlStrEqual(currentTagName, BAD_CAST "SimpleData")) {
						currentNameAttr = xmlTextReaderGetAttribute(reader, BAD_CAST "name");
					}
					continue;
					
				case XML_READER_TYPE_END_ELEMENT:		
                    
					currentTagName = xmlTextReaderConstName(reader);
					
					if (xmlStrEqual(currentTagName, BAD_CAST "Placemark")) {
                        bringBank.coordinate = coord;
                        [tempBringBanks addObject:bringBank];
                        [bringBank release];
                        bringBank = nil;
                    }
					
					if (currentNameAttr != NULL) {						
						xmlFree(currentNameAttr);
						currentNameAttr = NULL;
					}
					
					continue;
					
				case XML_READER_TYPE_TEXT:
					
					if (xmlStrEqual(currentTagName, BAD_CAST "SimpleData")) {	
						
						currentTagValue = xmlTextReaderConstValue(reader);
                        
                        if (xmlStrEqual(currentNameAttr, BAD_CAST "ID_")) {                            
                            bringBank.ID = [NSString stringWithUTF8String:(const char *)currentTagValue];
                        }
                        
                        if (xmlStrEqual(currentNameAttr, BAD_CAST "WEIGHT")) {                            
                            bringBank.weight = atof((const char *)currentTagValue);
                        }
                        
                        if (xmlStrEqual(currentNameAttr, BAD_CAST "GIS_ID")) {                            
                            bringBank.GISID = [NSString stringWithUTF8String:(const char *)currentTagValue];
                        }
                        
                        if (xmlStrEqual(currentNameAttr, BAD_CAST "ELECTORAL_Area")) {                            
                            bringBank.electoralArea = [NSString stringWithUTF8String:(const char *)currentTagValue];
                        } 
                        
                        if (xmlStrEqual(currentNameAttr, BAD_CAST "LOCATION")) {                            
                            bringBank.location = [NSString stringWithUTF8String:(const char *)currentTagValue];
                        } 
                        
                        if (xmlStrEqual(currentNameAttr, BAD_CAST "AREA")) {                            
                            bringBank.area = [NSString stringWithUTF8String:(const char *)currentTagValue];
                        }
                        
                        if (xmlStrEqual(currentNameAttr, BAD_CAST "GLASS_OPER")) {                            
                            bringBank.operatorName = [NSString stringWithUTF8String:(const char *)currentTagValue];
                        }
                        
                        if (xmlStrEqual(currentNameAttr, BAD_CAST "GLASS")) {
                            if (xmlStrEqual(currentTagValue, BAD_CAST "Y")) {
								bringBank.materialTypes += BringBankMaterialTypeGlass;
                            }
                        }    
                        
                        if (xmlStrEqual(currentNameAttr, BAD_CAST "CANS")) {
                            if (xmlStrEqual(currentTagValue, BAD_CAST "Y")) {
								bringBank.materialTypes += BringBankMaterialTypeCans;
                            }
                        }   
                        
                        if (xmlStrEqual(currentNameAttr, BAD_CAST "TEXTILE")) {
                            if (xmlStrEqual(currentTagValue, BAD_CAST "Y")) {
								bringBank.materialTypes += BringBankMaterialTypeTextiles;
                            }
                        }
                        
                        if (xmlStrEqual(currentNameAttr, BAD_CAST "LAT")) {
                            coord.latitude = atof((const char *)currentTagValue);
                        }                        
                        
                        if (xmlStrEqual(currentNameAttr, BAD_CAST "LONG")) {
                            coord.longitude = atof((const char *)currentTagValue);
                        }
                        
					}
					
					continue;					
			}
		}
	}		
	xmlTextReaderClose(reader);
    xmlFreeTextReader(reader);
    
    [data release];
    
    allBringBanks_ = [tempBringBanks copy];
    
    [tempBringBanks release];
    
    NSMutableArray *tempGlassBringBanks = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *tempCansBringBanks = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *tempTextilesBringBanks = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (BringBank *bringBank in allBringBanks_) {
        
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
    
    glassBringBanks_ = [tempGlassBringBanks copy];
    cansBringBanks_ = [tempCansBringBanks copy];
    textilesBringBanks_ = [tempTextilesBringBanks copy];
    
    [tempGlassBringBanks release];
    [tempCansBringBanks release];
    [tempTextilesBringBanks release];
    
	self.mapView.region = self.allBringBanksRegion;
    
    filteredBringBanks_ = allBringBanks_;
    
	[self.mapView addAnnotations:filteredBringBanks_];   
    
}

- (MKCoordinateRegion)allBringBanksRegion {
    
    if (allBringBanksRegion_.span.latitudeDelta == 0.0 && allBringBanksRegion_.span.longitudeDelta == 0.0) {
        CLLocationDegrees minLat = 90.0;
        CLLocationDegrees maxLat = -90.0;
        CLLocationDegrees minLon = 180.0;
        CLLocationDegrees maxLon = -180.0;
        
        for (id <MKAnnotation> bringBank in allBringBanks_) {
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
        
        for (id <MKAnnotation> bringBank in filteredBringBanks_) {
            CLLocation *location = [[CLLocation alloc] initWithLatitude:bringBank.coordinate.latitude 
                                                              longitude:bringBank.coordinate.longitude];
            CLLocationDistance distance = [location distanceFromLocation:self.mapView.userLocation.location];
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
            filteredBringBanks_ = allBringBanks_;
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


@end
