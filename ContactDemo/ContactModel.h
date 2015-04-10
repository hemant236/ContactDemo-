//
//  ContactModel.h
//  ContactDemo
//
//  Created by Hemant on 2/24/15.
//  Copyright (c) 2015 SmartCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ContactModel : NSObject


@property (nonatomic, strong) NSString *strFirstName;
@property (nonatomic, strong) NSString *strLastName;
@property (nonatomic, strong) NSArray *arrEmails;
@property (nonatomic, strong) NSArray *arrPhoneNumbers;
@property (nonatomic, strong) UIImage *imgContact;

-(void)setPhoneNumber:(NSMutableArray *)arrPhones;
-(void)setEmails:(NSMutableArray *)arrEmail;

@end
