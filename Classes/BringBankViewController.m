//
//  BringBankViewController.m
//  BringBanks
//
//  Created by Robert Mooney on 31/03/2011.
//  Copyright 2011 Robert Mooney. All rights reserved.
//

#import "BringBankViewController.h"


@implementation BringBankViewController

@synthesize bringBank = bringBank_;
@synthesize userLocation = userLocation_;

@synthesize nameLabel = nameLabel_;
@synthesize locationLabel = locationLabel_;
@synthesize operatorLabel = operatorLabel_;

@synthesize glassView = glassView_;
@synthesize cansView = cansView_;
@synthesize textilesView = textilesView_;

@synthesize glassLabel = glassLabel_;
@synthesize cansLabel = cansLabel_;
@synthesize textilesLabel = textilesLabel_;

@synthesize directionsButton = directionsButton_;

@synthesize contentView = contentView_;

- (void)dealloc {
    [bringBank_ release];
    [userLocation_ release];
    
    [nameLabel_ release];
    [locationLabel_ release];
    [operatorLabel_ release];
    [glassView_ release];
    [cansView_ release];
    [textilesView_ release];
    [glassLabel_ release];
    [cansLabel_ release];
    [textilesLabel_ release];
    [directionsButton_ release];
    
    [contentView_ release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Bring Bank";
    
    self.contentView.contentSize = CGSizeMake(320.0f, 372.0f);
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background.png"]];
    
    self.nameLabel.text = self.bringBank.area;
    self.locationLabel.text = self.bringBank.location;
    
    if (self.bringBank.operatorName) {
        self.operatorLabel.text = [NSString stringWithFormat:@"Operated by %@", self.bringBank.operatorName];
    } else {
        self.operatorLabel.text = @"";
    }
    
    if (self.bringBank.materialTypes & BringBankMaterialTypeGlass) {
        self.glassView.image = [UIImage imageNamed:@"Glass.png"];
        self.glassLabel.textColor = [UIColor colorWithRed:0.2f green:0.4f blue:0.2f alpha:1.0f];
    }
    
    if (self.bringBank.materialTypes & BringBankMaterialTypeCans) {
        self.cansView.image = [UIImage imageNamed:@"Cans.png"];
        self.cansLabel.textColor = [UIColor colorWithRed:0.2f green:0.4f blue:0.2f alpha:1.0f];        
    }
    
    if (self.bringBank.materialTypes & BringBankMaterialTypeTextiles) {
        self.textilesView.image = [UIImage imageNamed:@"Textiles.png"];
        self.textilesLabel.textColor = [UIColor colorWithRed:0.2f green:0.4f blue:0.2f alpha:1.0f];        
    }
    
    if (self.userLocation == nil) {
        self.directionsButton.enabled = NO;
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.nameLabel = nil;
    self.locationLabel = nil;
    self.operatorLabel = nil;
    self.glassView = nil;
    self.cansView = nil;
    self.textilesView = nil;
    self.glassLabel = nil;
    self.cansLabel = nil;
    self.textilesLabel = nil;
    self.directionsButton = nil;
    self.contentView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return interfaceOrientation == UIInterfaceOrientationPortrait || 
        interfaceOrientation == UIInterfaceOrientationLandscapeLeft || 
        interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (IBAction)showDirections:(id)sender {	
	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:@"Open Maps?" 
															  delegate:self 
													 cancelButtonTitle:@"Cancel"
												destructiveButtonTitle:nil 
													 otherButtonTitles:@"Show Directions in Maps", nil] autorelease];
	[actionSheet showInView:self.view.window];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != actionSheet.cancelButtonIndex) {
		NSString *userLocationString = [NSString stringWithFormat:@"%f,%f", self.userLocation.coordinate.latitude, self.userLocation.coordinate.longitude];
		NSString *bringBankLocationString = [NSString stringWithFormat:@"%f,%f", self.bringBank.coordinate.latitude, self.bringBank.coordinate.longitude];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%@&daddr=%@", userLocationString, bringBankLocationString]]];
	}
}


@end
