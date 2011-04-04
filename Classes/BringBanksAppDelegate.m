//
//  BringBanksAppDelegate.m
//  BringBanks
//
//  Created by Robert Mooney on 30/11/2010.
//  Copyright 2010 Robert Mooney. All rights reserved.
//

#import "BringBanksAppDelegate.h"
#import "BringBanksViewController.h"

@implementation BringBanksAppDelegate

@synthesize window = window_;
@synthesize bringBanksViewController = bringBanksViewController_;

#pragma mark - Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {   
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];    
    NSString *applicationDocumentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];    
    NSString *configFilePath = [applicationDocumentsDirectory stringByAppendingPathComponent:@"BringBanksKMLConfig.plist"];
    
    if (![fileManager fileExistsAtPath:configFilePath]) {
        NSString *bundledConfigFilePath = [[NSBundle mainBundle] pathForResource:@"BringBanksKMLConfig" ofType:@"plist"];
        NSError *error = nil;
        
        if (![fileManager copyItemAtPath:bundledConfigFilePath toPath:configFilePath error:&error]) {
            NSLog(@"%@", error);
        }
        
    }
    
    NSString *KMLFilePath = [applicationDocumentsDirectory stringByAppendingPathComponent:@"Bring_Banks.kml"];
    
    if (![fileManager fileExistsAtPath:KMLFilePath]) {
        NSString *bundledKMLFilePath = [[NSBundle mainBundle] pathForResource:@"Bring_Banks" ofType:@"kml"];        
        NSError *error = nil;
        
        if (![fileManager copyItemAtPath:bundledKMLFilePath toPath:KMLFilePath error:&error]) {
            NSLog(@"%@", error);
        }
    }
    
    [fileManager release];
    
    NSURL *configFileURL = [NSURL fileURLWithPath:configFilePath];    
    
    bringBanksLoader_ = [[BringBanksLoader alloc] initWithConfigFileURL:configFileURL];    
    bringBanksLoader_.delegate = self;
    [bringBanksLoader_ load];
    
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    [bringBanksLoader_ checkForUpdate];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window_ release];
    [bringBanksViewController_ release];   
    [bringBanksLoader_ release];
    [super dealloc];
}

#pragma mark - Bring banks loader delegate

- (void)bringBanksLoaderDidStartUpdate:(BringBanksLoader *)bringBanksLoader {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)bringBanksLoader:(BringBanksLoader *)bringBanksLoader didLoadBringBanks:(NSArray *)bringBanks {    
    bringBanksViewController_.bringBanks = bringBanks; 
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}



@end
