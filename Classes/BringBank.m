//
//  BringBank.m
//  BringBanks
//
//  Created by Robert Mooney on 30/11/2010.
//  Copyright 2010 Robert Mooney. All rights reserved.
//

#import "BringBank.h"

@implementation BringBank

@synthesize ID;
@synthesize GISID;
@synthesize weight;
@synthesize electoralArea;
@synthesize location;
@synthesize area;
@synthesize operatorName;
@synthesize coordinate;
@synthesize materialTypes;

@synthesize title;
@synthesize subtitle;

- (NSString *)description {	
    return [NSString stringWithFormat:@"%@ <%f, %f>", self.location, self.coordinate.latitude, self.coordinate.longitude];
}

- (NSString *)title {
    return self.location;
	//return @" ";
}

- (NSString *)subtitle {
    return self.area;
	//return @" ";
}

- (void)dealloc {
    [GISID release];
    [electoralArea release];
    [location release];
    [area release];
    [operatorName release];
    [super dealloc];
}

@end
