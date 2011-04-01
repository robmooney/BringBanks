//
//  BringBankViewController.h
//  BringBanks
//
//  Created by Robert Mooney on 31/03/2011.
//  Copyright 2011 Robert Mooney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BringBank.h"

@interface BringBankViewController : UIViewController <UIActionSheetDelegate> {
    
}

@property (nonatomic, retain) BringBank *bringBank;
@property (nonatomic, retain) CLLocation *userLocation;

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *locationLabel;
@property (nonatomic, retain) IBOutlet UILabel *operatorLabel;

@property (nonatomic, retain) IBOutlet UIImageView *glassView;
@property (nonatomic, retain) IBOutlet UIImageView *cansView;
@property (nonatomic, retain) IBOutlet UIImageView *textilesView;

@property (nonatomic, retain) IBOutlet UILabel *glassLabel;
@property (nonatomic, retain) IBOutlet UILabel *cansLabel;
@property (nonatomic, retain) IBOutlet UILabel *textilesLabel;

@property (nonatomic, retain) IBOutlet UIButton *directionsButton;

@property (nonatomic, retain) IBOutlet UIScrollView *contentView;

- (IBAction)showDirections:(id)sender;

@end
