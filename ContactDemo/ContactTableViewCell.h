//
//  ContactTableViewCell.h
//  ContactDemo
//
//  Created by Hemant on 2/24/15.
//  Copyright (c) 2015 SmartCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactTableViewCell : UITableViewCell

@property(nonatomic, weak)IBOutlet UILabel *lblName;
@property(nonatomic, weak)IBOutlet UILabel *lblPhone;
@property(nonatomic, weak)IBOutlet UIImageView *imgSelected;

@end
