//
//  BringBanksLoader.h
//  BringBanks
//
//  Created by Robert Mooney on 02/04/2011.
//  Copyright 2011 Robert Mooney. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BringBanksLoaderDelegate;

@interface BringBanksLoader : NSObject {
@private
    NSURL *configFileURL_;
    NSURL *remoteFileURL_;
    NSURL *localFileURL_;
    NSMutableData *receivedData_;
    NSString *lastModified_;
    NSString *etag_;
}

@property (nonatomic, assign) id <BringBanksLoaderDelegate> delegate;

- (id)initWithConfigFileURL:(NSURL *)configFileURL;

- (void)load;
- (void)checkForUpdate;

@end

@protocol BringBanksLoaderDelegate <NSObject>

// this may be called multiple times if there is an online update
- (void)bringBanksLoader:(BringBanksLoader *)bringBanksLoader didLoadBringBanks:(NSArray *)bringBanks;

@optional

// called when newer data is being downloaded from the server
- (void)bringBanksLoaderDidStartUpdate:(BringBanksLoader *)bringBanksLoader;

@end
