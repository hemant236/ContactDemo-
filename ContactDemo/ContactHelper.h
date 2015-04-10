//
//  ContactHelper.h
//  ContactDemo
//
//  Created by Hemant on 2/24/15.
//  Copyright (c) 2015 SmartCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "ContactModel.h"


@protocol contactHelperDelegate <NSObject>


-(void)contactFetchedSuccesfully:(NSMutableArray *)arrContacts;
-(void)failedToFetchContact:(NSError *)error;


@end

@interface ContactHelper : NSObject

@property (nonatomic,weak) id <contactHelperDelegate> contactDelegate;

//@property NSString * addressBookNum;

+ (ContactHelper *)sharedInstance;

-(void )getAllContacts;
@end
