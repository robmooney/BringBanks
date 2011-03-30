//
//  BringBanksViewController.m
//  BringBanks
//
//  Created by Robert Mooney on 30/11/2010.
//  Copyright 2010 Robert Mooney. All rights reserved.
//

#import "BringBanksViewController.h"
#import "BringBank.h"
#import "ThreeOptionView.h"
#import <CoreLocation/CoreLocation.h>
#import <libxml/xmlreader.h>

@implementation BringBanksViewController

@synthesize mapView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *tempBringBanks = [[NSMutableArray alloc] initWithCapacity:0];
    
    BringBank *bringBank = nil;
    
    CLLocationCoordinate2D coord;
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Bring_Banks" withExtension:@"kml"]];
    
    xmlTextReaderPtr reader = xmlReaderForMemory([data bytes], [data length], NULL, NULL, (XML_PARSE_NOBLANKS | XML_PARSE_NOCDATA | XML_PARSE_NOERROR | XML_PARSE_NOWARNING));
	
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
							                      
                            bringBank.ID = atof((const char *)currentTagValue);
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
    
    bringBanks = [tempBringBanks copy];
    
    [tempBringBanks release];
	
	
	CLLocationDegrees minLat = 90.0;
	CLLocationDegrees maxLat = -90.0;
	CLLocationDegrees minLon = 180.0;
	CLLocationDegrees maxLon = -180.0;
	
	for (id <MKAnnotation> annotation in bringBanks) {
		if (annotation.coordinate.latitude != 0 && annotation.coordinate.longitude != 0) {
			if (annotation.coordinate.latitude < minLat) {
				minLat = annotation.coordinate.latitude;
			}		
			if (annotation.coordinate.longitude < minLon) {
				minLon = annotation.coordinate.longitude;
			}		
			if (annotation.coordinate.latitude > maxLat) {
				maxLat = annotation.coordinate.latitude;
			}		
			if (annotation.coordinate.longitude > maxLon) {
				maxLon = annotation.coordinate.longitude;
			}
		}
	}
	
	
	MKCoordinateSpan span = MKCoordinateSpanMake(maxLat - minLat, maxLon - minLon);
	CLLocationCoordinate2D center = CLLocationCoordinate2DMake(maxLat - span.latitudeDelta / 2, maxLon - span.longitudeDelta / 2);
	
	self.mapView.region = MKCoordinateRegionMake(center, span);
	
	[self.mapView addAnnotations:bringBanks];
    
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[BringBank class]]) {
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
		
        if (!pinView) {
			pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotation"] autorelease];
			pinView.animatesDrop = YES;
			pinView.canShowCallout = YES;
			
			ThreeOptionView *optionView = [[ThreeOptionView alloc] initWithFrame:CGRectMake(0.0, 0.0, 40.0, 33.0)];
			optionView.onImageView1.image = [UIImage imageNamed:@"GlassOn.png"];
			optionView.onImageView2.image = [UIImage imageNamed:@"CansOn.png"];			
			optionView.onImageView3.image = [UIImage imageNamed:@"TextilesOn.png"];
			
			optionView.offImageView1.image = [UIImage imageNamed:@"GlassOff.png"];
			optionView.offImageView2.image = [UIImage imageNamed:@"CansOff.png"];			
			optionView.offImageView3.image = [UIImage imageNamed:@"TextilesOff.png"];
			
			pinView.leftCalloutAccessoryView = optionView;
			[optionView release];
			
		} else {
			pinView.annotation = annotation;
		}
		
		BringBank *bringBank = (BringBank *)annotation;	
		
		ThreeOptionView *optionView = (ThreeOptionView *)pinView.leftCalloutAccessoryView;
		
		optionView.options = bringBank.materialTypes;
		
        return pinView;
    }
	
    return nil;
}

@end
