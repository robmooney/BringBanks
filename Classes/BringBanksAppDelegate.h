//
//  BringBanksAppDelegate.h
//  BringBanks
//
//  Created by Robert Mooney on 30/11/2010.
//  Copyright 2010 Robert Mooney. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BringBanksViewController;

@interface BringBanksAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    BringBanksViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet BringBanksViewController *viewController;

@end

