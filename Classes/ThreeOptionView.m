//
//  ThreeOptionView.m
//  BringBanks
//
//  Created by Robert Mooney on 01/12/2010.
//  Copyright 2010 Robert Mooney. All rights reserved.
//

#import "ThreeOptionView.h"


@implementation ThreeOptionView

@synthesize onImageView1;
@synthesize onImageView2;
@synthesize onImageView3;
@synthesize offImageView1;
@synthesize offImageView2;
@synthesize offImageView3;

@synthesize options;


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {		
        offImageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(frame), CGRectGetHeight(frame) / 3.0)];
        offImageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, CGRectGetHeight(frame) / 3.0, CGRectGetWidth(frame), CGRectGetHeight(frame) / 3.0)];
        offImageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, (CGRectGetHeight(frame) / 3.0) * 2, CGRectGetWidth(frame), CGRectGetHeight(frame) / 3.0)];
		
		[self addSubview:offImageView1];
		[self addSubview:offImageView2];
		[self addSubview:offImageView3];
		
        onImageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(frame), CGRectGetHeight(frame) / 3)];
        onImageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, CGRectGetHeight(frame) / 3, CGRectGetWidth(frame), CGRectGetHeight(frame) / 3)];
        onImageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, (CGRectGetHeight(frame) / 3) * 2, CGRectGetWidth(frame), CGRectGetHeight(frame) / 3)];
		
		onImageView1.hidden = YES;
		onImageView2.hidden = YES;
		onImageView3.hidden = YES;
		
		[self addSubview:onImageView1];
		[self addSubview:onImageView2];
		[self addSubview:onImageView3];
	}
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)setOptions:(ThreeOptionViewOption)newOptions {
	options = newOptions;
	
	self.onImageView1.hidden = !((options & ThreeOptionViewOption1) == ThreeOptionViewOption1);
	self.onImageView2.hidden = !((options & ThreeOptionViewOption2) == ThreeOptionViewOption2);
	self.onImageView3.hidden = !((options & ThreeOptionViewOption3) == ThreeOptionViewOption3);
}


@end
