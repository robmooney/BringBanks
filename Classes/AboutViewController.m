//
//  AboutViewController.m
//  BringBanks
//
//  Created by Robert Mooney on 04/04/2011.
//  Copyright 2011 Robert Mooney. All rights reserved.
//

#import "AboutViewController.h"


@implementation AboutViewController

@synthesize doneButton = doneButton_;
@synthesize versionLabel = versionLabel_;

- (void)dealloc {
    [doneButton_ release];
    [versionLabel_ release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSString *appVersion = nil;
    if (path) {
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
        appVersion = [[dict objectForKey:@"CFBundleVersion"] retain];
        [dict release];
    }
    self.versionLabel.text = [NSString stringWithFormat:self.versionLabel.text, appVersion]; 
    [appVersion release];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.doneButton = nil;
    self.versionLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
