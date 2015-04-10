//
//  ContactTableViewCell.m
//  ContactDemo
//
//  Created by Hemant on 2/24/15.
//  Copyright (c) 2015 SmartCloud. All rights reserved.
//

#import "ContactTableViewCell.h"

@implementation ContactTableViewCell
@synthesize lblPhone;
@synthesize lblName;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
