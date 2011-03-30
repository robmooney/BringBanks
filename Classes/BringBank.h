//
//  BringBank.h
//  BringBanks
//
//  Created by Robert Mooney on 30/11/2010.
//  Copyright 2010 Robert Mooney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum {
    BringBankMaterialTypeGlass		= 1,
    BringBankMaterialTypeCans		= 2,
    BringBankMaterialTypeTextiles	= 4
} BringBankMaterialType;

@interface BringBank : NSObject <MKAnnotation> {
    NSString *ID;
    NSString *GISID;
    double weight;
    NSString *electoralArea;
    NSString *location;
    NSString *area;
    NSString *operatorName;
    CLLocationCoordinate2D coordinate;
	BringBankMaterialType materialTypes;
}

@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *GISID;
@property (nonatomic) double weight;
@property (nonatomic, copy) NSString *electoralArea;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *area;
@property (nonatomic, copy) NSString *operatorName;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) BringBankMaterialType materialTypes;

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *subtitle;

@end
