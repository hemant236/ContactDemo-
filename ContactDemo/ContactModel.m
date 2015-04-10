//
//  ContactModel.m
//  ContactDemo
//
//  Created by Hemant on 2/24/15.
//  Copyright (c) 2015 SmartCloud. All rights reserved.
//

#import "ContactModel.h"

@implementation ContactModel

@synthesize  strFirstName;
@synthesize strLastName;
@synthesize arrEmails;
@synthesize arrPhoneNumbers;


-(void)setPhoneNumber:(NSMutableArray *)ArrContacts{
    self.arrPhoneNumbers = ArrContacts;

}
-(void)setEmails:(NSMutableArray *)arrEmail{
    self.arrEmails = arrEmails;

}

@end
