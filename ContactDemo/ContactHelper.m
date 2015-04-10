//
//  ContactHelper.m
//  ContactDemo
//
//  Created by Hemant on 2/24/15.
//  Copyright (c) 2015 SmartCloud. All rights reserved.
//

#import "ContactHelper.h"

@implementation ContactHelper

static ContactHelper *sharedInstance = nil;

// Get the shared instance and create it if necessary.
+ (ContactHelper *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super alloc] init];
    }

    return sharedInstance;
}

-(void )getAllContacts
{

    CFErrorRef *error = nil;


    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);

    __block BOOL accessGranted = NO;
    if (&ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }

    if (accessGranted) {

#ifdef DEBUG
        NSLog(@"Fetching contact info ----> ");
#endif


        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName);
        CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
        NSMutableArray* items = [NSMutableArray arrayWithCapacity:nPeople];


        for (int i = 0; i < nPeople; i++)
        {
            ContactModel *contacts = [ContactModel new];

            ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);

            //get First Name and Last Name

            contacts.strFirstName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);

            contacts.strLastName =  (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);

            if (!contacts.strFirstName) {
                contacts.strFirstName = @"";
            }
            if (!contacts.strLastName) {
                contacts.strLastName = @"";
            }


            // get contacts picture, if pic doesn't exists, show standart one

            NSData  *imgData = (__bridge NSData *)ABPersonCopyImageData(person);
            contacts.imgContact = [UIImage imageWithData:imgData];
            if (!contacts.imgContact) {
                contacts.imgContact = [UIImage imageNamed:@"NOIMG.png"];
            }

            //get Phone Numbers

            NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];

            ABMultiValueRef multiPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for(CFIndex i=0;i<ABMultiValueGetCount(multiPhones);i++) {

                CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
                NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;
                [phoneNumbers addObject:phoneNumber];

                //NSLog(@"All numbers %@", phoneNumbers);

            }


            [contacts setPhoneNumber:phoneNumbers];

            //get Contact email

            NSMutableArray *contactEmails = [NSMutableArray new];
            ABMultiValueRef multiEmails = ABRecordCopyValue(person, kABPersonEmailProperty);

            for (CFIndex i=0; i<ABMultiValueGetCount(multiEmails); i++) {
                CFStringRef contactEmailRef = ABMultiValueCopyValueAtIndex(multiEmails, i);
                NSString *contactEmail = (__bridge NSString *)contactEmailRef;

                [contactEmails addObject:contactEmail];
                // NSLog(@"All emails are:%@", contactEmails);

            }

            [contacts setEmails:contactEmails];



            [items addObject:contacts];

#ifdef DEBUG
            //NSLog(@"Person is: %@", contacts.firstNames);
            //NSLog(@"Phones are: %@", contacts.numbers);
            //NSLog(@"Email is:%@", contacts.emails);
#endif

        }

        if ([_contactDelegate respondsToSelector:@selector(contactFetchedSuccesfully:)]) {
            [_contactDelegate contactFetchedSuccesfully:items];
        }

    }
    else {
#ifdef DEBUG
        NSLog(@"Cannot fetch Contacts :( ");
        if ([_contactDelegate respondsToSelector:@selector(failedToFetchContact:)]) {
            [_contactDelegate failedToFetchContact:(__bridge NSError *)((CFErrorRef)error)];
        }
#endif
        
    }
    
}
@end
