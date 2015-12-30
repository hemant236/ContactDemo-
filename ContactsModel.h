//
//  Contacts.h
//
//  Created by Hemant on 12/10/15.
//  Copyright (c) 2015 Smartcloud Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ContactsModel : NSObject

@property(nonatomic, copy) NSString *personName;
@property(nonatomic, copy) NSArray *personEmailID;
@property(nonatomic, copy) NSArray *personContacts;
@property(nonatomic, strong) UIImage *personImage;

@end
