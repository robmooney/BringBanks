//
//  ThreeOptionView.h
//  BringBanks
//
//  Created by Robert Mooney on 01/12/2010.
//  Copyright 2010 Robert Mooney. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ThreeOptionViewOption1	= 1,
    ThreeOptionViewOption2	= 2,
    ThreeOptionViewOption3	= 4
} ThreeOptionViewOption;


@interface ThreeOptionView : UIView {
	UIImageView *onImageView1;
	UIImageView *onImageView2;
	UIImageView *onImageView3;
	UIImageView *offImageView1;
	UIImageView *offImageView2;
	UIImageView *offImageView3;
	
	ThreeOptionViewOption options;
}

@property (nonatomic, readonly) UIImageView *onImageView1;
@property (nonatomic, readonly) UIImageView *onImageView2;
@property (nonatomic, readonly) UIImageView *onImageView3;
@property (nonatomic, readonly) UIImageView *offImageView1;
@property (nonatomic, readonly) UIImageView *offImageView2;
@property (nonatomic, readonly) UIImageView *offImageView3;

@property (nonatomic) ThreeOptionViewOption options;

@end
