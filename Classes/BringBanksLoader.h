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

- (void)start;

@end

@protocol BringBanksLoaderDelegate <NSObject>

- (void)bringBanksLoader:(BringBanksLoader *)bringBanksLoader didLoadBringBanks:(NSArray *)bringBanks;

@optional
// called before data is loaded
- (void)bringBanksLoaderDidStart:(BringBanksLoader *)bringBanksLoader;

// called when there is a newer data being downloaded from the server
- (void)bringBanksLoaderDidStartUpdate:(BringBanksLoader *)bringBanksLoader;

@end
