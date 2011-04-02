//
//  BringBanksAppDelegate.h
//  BringBanks
//
//  Created by Robert Mooney on 30/11/2010.
//  Copyright 2010 Robert Mooney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BringBanksLoader.h"

@class BringBanksViewController;

@interface BringBanksAppDelegate : NSObject <UIApplicationDelegate, BringBanksLoaderDelegate> {
@private    
    BringBanksLoader *bringBanksLoader_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet BringBanksViewController *bringBanksViewController;

@end

