//
//  BringBank.m
//  BringBanks
//
//  Created by Robert Mooney on 30/11/2010.
//  Copyright 2010 Robert Mooney. All rights reserved.
//

#import "BringBank.h"

@implementation BringBank

@synthesize ID = ID_;
@synthesize GISID = GISID_;
@synthesize weight = weight_;
@synthesize electoralArea = electoralArea_;
@synthesize location = location_;
@synthesize area = area_;
@synthesize operatorName = operatorName_;
@synthesize coordinate = coordinate_;
@synthesize materialTypes = materialTypes_;

@synthesize title;
@synthesize subtitle;

- (void)setID:(NSString *)ID {
    [ID_ release];
    ID_ = [ID copy];
    [description_ release];
    description_ = nil;
}

- (void)setGISID:(NSString *)GISID {
    [GISID_ release];
    GISID_ = [GISID copy];
    [description_ release];
    description_ = nil;    
}

- (void)setWeight:(double)weight {
    weight_ = weight;    
    [description_ release];
    description_ = nil;    
}

- (void)setElectoralArea:(NSString *)electoralArea {
    [electoralArea_ release];
    electoralArea_ = [electoralArea copy];
    [description_ release];
    description_ = nil;        
}

- (void)setLocation:(NSString *)location {
    [location_ release];
    location_ = [location copy];
    [description_ release];
    description_ = nil;   
}

- (void)setArea:(NSString *)area {    
    [area_ release];
    area_ = [area copy];
    [description_ release];
    description_ = nil;   
}

- (void)setOperatorName:(NSString *)operatorName {    
    [operatorName_ release];
    operatorName_ = [operatorName copy];
    [description_ release];
    description_ = nil;   
}

- (void)setMaterialTypes:(BringBankMaterialType)materialTypes {    
    materialTypes_ = materialTypes;    
    [description_ release];
    description_ = nil;    
}

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate {
    coordinate_ = coordinate;   
    [description_ release];
    description_ = nil;    
}


- (NSString *)description {	
    if (description_ == nil) {
        description_ = [[NSString alloc] initWithFormat:@"%@ %@ %f %@ %@ %@ %@ %d (%f, %f)", 
                 self.ID, 
                 self.GISID, 
                 self.weight, 
                 self.electoralArea, 
                 self.location, 
                 self.area, 
                 self.operatorName, 
                 self.materialTypes, 
                 self.coordinate.latitude, 
                 self.coordinate.longitude];

    }
    return description_;
}

- (NSString *)title {
    return self.area;
}

- (NSString *)subtitle {
    NSMutableArray *materials = [NSMutableArray arrayWithCapacity:0];
    
    if (self.materialTypes & BringBankMaterialTypeGlass) {
        [materials addObject:@"Glass"];
    }
    
    if (self.materialTypes & BringBankMaterialTypeCans) {
        [materials addObject:@"Cans"];
    }    
    
    if (self.materialTypes & BringBankMaterialTypeTextiles) {
        [materials addObject:@"Textiles"];
    }
    
    return [materials componentsJoinedByString:@", "];
}

- (void)dealloc {
    [ID_ release];
    [GISID_ release];
    [electoralArea_ release];
    [location_ release];
    [area_ release];
    [operatorName_ release];
    [description_ release];
    [super dealloc];
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }
    if ([object isKindOfClass:[self class]]) {
        return [[object description] isEqualToString:[self description]];
    }
    return NO;
}

- (NSUInteger)hash {
    return [[self description] hash];
}

@end
