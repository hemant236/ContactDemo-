//
//  ContactsHelper.h
//
//  Created by Hemant on 15/10/15.
//  Copyright (c) 2015 SmartCloud. All rights reserved.
//

#import "ContactsModel.h"
#import <Foundation/Foundation.h>

@import Contacts;

@protocol ContactHelperDelegate <NSObject>
- (void)phoneNumberFetchedSuccesfully:(NSMutableArray *)arrPhoneNumber;
- (void)EmailFetchedSuccesfully:(NSMutableArray *)arrEmailId;
@end

@interface ContactsHelper : NSObject

@property(nonatomic, weak) id<ContactHelperDelegate> contactDelegate;
@property(assign) BOOL shouldFormatPhoneNumber; // this boolean can be set to
// get the formatted phone number
@property(assign)
BOOL skipInvalidEmailId; // this boolean can be set to skip invalid email id

+ (CACContactsHelper *)sharedInstance;

/**
 *  This method can be used to get phone number from contacts
 */
- (void)getAllPhoneNumbersFromContacts;
/**
 *  This method can be used to get email-ids from contacts
 */
- (void)getAllEmailIdsFromContacts;
@end
