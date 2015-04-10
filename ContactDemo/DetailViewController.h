//
//  DetailViewController.h
//  ContactDemo
//
//  Created by Hemant on 2/24/15.
//  Copyright (c) 2015 SmartCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactHelper.h"
#import "ContactTableViewCell.h"

@interface DetailViewController : UIViewController <contactHelperDelegate>

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property(nonatomic, strong)  NSMutableArray* cellSelected;
@end

