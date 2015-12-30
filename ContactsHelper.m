//
//  ContactsHelper.m
//
//  Created by Hemant on 15/10/15.
//  Copyright (c) 2015 SmartCloud. All rights reserved.
//

#import "ContactsHelper.h"

/**
 *  OS Related Macros
 */
#define SYSTEM_VERSION_EQUAL_TO(v)                                             \
([[[UIDevice currentDevice] systemVersion] compare:v                         \
options:NSNumericSearch] ==       \
NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)                                         \
([[[UIDevice currentDevice] systemVersion] compare:v                         \
options:NSNumericSearch] ==       \
NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)                             \
([[[UIDevice currentDevice] systemVersion] compare:v                         \
options:NSNumericSearch] !=       \
NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                                            \
([[[UIDevice currentDevice] systemVersion] compare:v                         \
options:NSNumericSearch] ==       \
NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)                                \
([[[UIDevice currentDevice] systemVersion] compare:v                         \
options:NSNumericSearch] !=       \
NSOrderedDescending)

@implementation ContactsHelper
@synthesize shouldFormatPhoneNumber;
@synthesize skipInvalidEmailId;
static ContactsHelper *sharedInstance = nil;

// Get the shared instance and create it if necessary.
+ (ContactsHelper *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super alloc] init];
    }

    return sharedInstance;
}
- (void)getAllEmailIdsFromContacts {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        NSMutableArray *items = [[NSMutableArray alloc] init];
        // ios 9+

        NSArray *keysToFetch = @[
                                 CNContactEmailAddressesKey,
                                 CNContactGivenNameKey,
                                 CNContactThumbnailImageDataKey
                                 ];
        CNContactStore *store = [[CNContactStore alloc] init];
        [store
         requestAccessForEntityType:CNEntityTypeContacts
         completionHandler:^(BOOL granted, NSError *_Nullable error) {
             if (granted == YES) {
                 NSPredicate *predicate = nil;
                 NSError *error;
                 NSArray *cnContacts =
                 [store unifiedContactsMatchingPredicate:predicate
                                             keysToFetch:keysToFetch
                                                   error:&error];
                 if (error) {
                     NSLog(@"error fetching contacts %@", error);
                 } else {

                     NSLog(@"contact count %lu",
                           (unsigned long)cnContacts.count);
                     for (CNContact *contact in cnContacts) {
                         if (contact.givenName.length != 0) {

                             NSMutableArray *arrayEmails =
                             [[NSMutableArray alloc] init];

                             for (CNLabeledValue *label in contact
                                  .emailAddresses) {
                                 if ([label.value length] == 0)
                                     return;
                                 NSLog(@"Email %@", label.value);

                                 if (skipInvalidEmailId) {
                                     if ([self validateEmail:label.value]) {
                                         [arrayEmails addObject:label.value];
                                     }
                                 } else {
                                     [arrayEmails addObject:label.value];
                                 }
                             }

                             CACContactsModel *contactModel =
                             [CACContactsModel new];
                             NSString *nameString = contact.givenName;
                             NSLog(@"Name %@", nameString);

                             contactModel.personEmailID = arrayEmails;
                             contactModel.personName = nameString;
                             UIImage *image = [UIImage
                                               imageWithData:contact.thumbnailImageData];
                             if (image == nil) {
                                 image = [UIImage imageNamed:@"NOIMG.png"];
                             }
                             contactModel.personImage = image;
                             if (arrayEmails.count > 0) {
                                 [items addObject:contactModel];
                             }
                         }
                     }
                 }

                 if ([_contactDelegate
                      respondsToSelector:
                      @selector(EmailFetchedSuccesfully:)]) {
                     [_contactDelegate EmailFetchedSuccesfully:items];
                 }
             } else {

                 [[[UIAlertView alloc]
                   initWithTitle:nil
                   message:@"This app requires access to your "
                   @"contacts to "
                   @"function properly. Please visit "
                   @"to the "
                   @"\"Privacy\" section in the iPhone "
                   @"Settings " @"app."
                   delegate:nil
                   cancelButtonTitle:@"OK"
                   otherButtonTitles:nil] show];
             }

         }];
    } else {

        ABAddressBookRef
        addressBook; // = ABAddressBookCreateWithOptions(NULL, NULL);
        __block BOOL accessGranted = NO;
        CFErrorRef *error = nil;

        if (ABAddressBookGetAuthorizationStatus() ==
            kABAuthorizationStatusNotDetermined ||
            ABAddressBookGetAuthorizationStatus() ==
            kABAuthorizationStatusAuthorized) {
            addressBook = ABAddressBookCreateWithOptions(NULL, error);
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(
                                                     addressBook, ^(bool granted, CFErrorRef error) {
                                                         accessGranted = granted;
                                                         dispatch_semaphore_signal(sema);
                                                     });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        } else {
            if (ABAddressBookGetAuthorizationStatus() ==
                kABAuthorizationStatusDenied ||
                ABAddressBookGetAuthorizationStatus() ==
                kABAuthorizationStatusRestricted) {
                // Display an error.
                [[[UIAlertView alloc]
                  initWithTitle:nil
                  message:@"This app requires access to your contacts to "
                  @"function properly. Please visit to the "
                  @"\"Privacy\" section in the iPhone Settings app."
                  delegate:nil
                  cancelButtonTitle:@"OK"
                  otherButtonTitles:nil] show];
            }
        }

        if (accessGranted) {
            ABAddressBookRef addressBook =
            ABAddressBookCreateWithOptions(NULL, error);
            ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
            CFArrayRef allPeople =
            ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(
                                                                      addressBook, source, kABPersonSortByFirstName);
            CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
            NSMutableArray *items = [NSMutableArray arrayWithCapacity:nPeople];

            for (int i = 0; i < nPeople; i++) {

                NSLog(@"Count %d", i);
                CACContactsModel *contact = [CACContactsModel new];

                ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);

                // fetch contact person Email's
                NSMutableArray *contactEmails = [NSMutableArray new];

                ABMultiValueRef multiEmails =
                ABRecordCopyValue(person, kABPersonEmailProperty);

                for (CFIndex i = 0; i < ABMultiValueGetCount(multiEmails); i++) {
                    CFStringRef contactEmailRef =
                    ABMultiValueCopyValueAtIndex(multiEmails, i);
                    NSString *contactEmail = (__bridge NSString *)contactEmailRef;
                    if (skipInvalidEmailId) {
                        if ([self validateEmail:contactEmail]) {
                            [contactEmails addObject:contactEmail];
                        }
                    } else {
                        [contactEmails addObject:contactEmail];
                    }
                }
                contact.personEmailID = contactEmails;

                // fetch contact person name
                NSString *personName;
                if ((__bridge NSString *)ABRecordCopyValue(
                                                           person, kABPersonLastNameProperty) != NULL) {
                    personName = [(__bridge NSString *)ABRecordCopyValue(
                                                                         person, kABPersonFirstNameProperty)
                                  stringByAppendingFormat:@" %@",
                                  (__bridge NSString *)ABRecordCopyValue(
                                                                         person, kABPersonLastNameProperty)];
                } else
                    personName = (__bridge NSString *)ABRecordCopyValue(
                                                                        person, kABPersonFirstNameProperty);

                contact.personName = personName;

                // fetch contact person image
                NSData *imgData = (__bridge NSData *)ABPersonCopyImageData(person);
                contact.personImage = [UIImage imageWithData:imgData];
                if (!contact.personImage) {
                    contact.personImage = [UIImage imageNamed:@"NOIMG.png"];
                }
                if (contactEmails.count > 0) {
                    [items addObject:contact];
                }
            }

            if ([_contactDelegate
                 respondsToSelector:@selector(EmailFetchedSuccesfully:)]) {
                [_contactDelegate EmailFetchedSuccesfully:items];
            }
        }
    }
}
- (BOOL)validateEmail:(NSString *)stringToBeChecked {
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest =
    [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    return [emailTest evaluateWithObject:stringToBeChecked];
}
- (NSString *)formatPhoneNumber:(NSString *)numberToBeFormatted {
    NSString *stringPhoneNumber = [[NSString alloc] init];
    stringPhoneNumber =
    [numberToBeFormatted stringByReplacingOccurrencesOfString:@"("
                                                   withString:@""];
    stringPhoneNumber =
    [stringPhoneNumber stringByReplacingOccurrencesOfString:@")"
                                                 withString:@""];
    stringPhoneNumber =
    [stringPhoneNumber stringByReplacingOccurrencesOfString:@"-"
                                                 withString:@""];
    stringPhoneNumber =
    [stringPhoneNumber stringByReplacingOccurrencesOfString:@" "
                                                 withString:@""];
    stringPhoneNumber =
    [stringPhoneNumber stringByReplacingOccurrencesOfString:@"+91"
                                                 withString:@""];
    return stringPhoneNumber;
}
- (void)getAllPhoneNumbersFromContacts {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        NSMutableArray *items = [[NSMutableArray alloc] init];
        // ios 9+

        NSArray *keysToFetch = @[
                                 CNContactPhoneNumbersKey,
                                 CNContactGivenNameKey,
                                 CNContactThumbnailImageDataKey
                                 ];
        CNContactStore *store = [[CNContactStore alloc] init];
        [store
         requestAccessForEntityType:CNEntityTypeContacts
         completionHandler:^(BOOL granted, NSError *_Nullable error) {
             if (granted == YES) {
                 NSPredicate *predicate = nil;
                 NSError *error;
                 NSArray *cnContacts =
                 [store unifiedContactsMatchingPredicate:predicate
                                             keysToFetch:keysToFetch
                                                   error:&error];
                 if (error) {
                     NSLog(@"error fetching contacts %@", error);
                 } else {

                     NSLog(@"contact count %lu",
                           (unsigned long)cnContacts.count);
                     for (CNContact *contact in cnContacts) {
                         if (contact.givenName.length != 0) {

                             NSMutableArray *arrayNumbers =
                             [[NSMutableArray alloc] init];

                             for (CNLabeledValue *label in contact.phoneNumbers) {
                                 if ([[label.value stringValue] length] == 0)
                                     return;
                                 NSString *phoneNumber;
                                 if (shouldFormatPhoneNumber) {
                                     phoneNumber = [self
                                                    formatPhoneNumber:[label.value stringValue]];
                                 } else {
                                     phoneNumber = [label.value stringValue];
                                 }

                                 [arrayNumbers addObject:phoneNumber];
                             }

                             CACContactsModel *contactModel =
                             [CACContactsModel new];
                             NSString *nameString = contact.givenName;

                             contactModel.personContacts = arrayNumbers;
                             contactModel.personName = nameString;
                             UIImage *image = [UIImage
                                               imageWithData:contact.thumbnailImageData];
                             if (image == nil) {
                                 image = [UIImage imageNamed:@"NOIMG.png"];
                             }
                             contactModel.personImage = image;
                             if (arrayNumbers.count > 0) {
                                 [items addObject:contactModel];
                             }
                         }
                     }
                 }

                 if ([_contactDelegate
                      respondsToSelector:
                      @selector(phoneNumberFetchedSuccesfully:)]) {
                     [_contactDelegate phoneNumberFetchedSuccesfully:items];
                 }
             } else {

                 [[[UIAlertView alloc]
                   initWithTitle:nil
                   message:@"This app requires access to your "
                   @"contacts to "
                   @"function properly. Please visit "
                   @"to the "
                   @"\"Privacy\" section in the iPhone "
                   @"Settings " @"app."
                   delegate:nil
                   cancelButtonTitle:@"OK"
                   otherButtonTitles:nil] show];
             }

         }];
    } else {
        // NSMutableArray *personsArray = [[NSMutableArray alloc]init];

        ABAddressBookRef
        addressBook; // = ABAddressBookCreateWithOptions(NULL, NULL);
        __block BOOL accessGranted = NO;
        CFErrorRef *error = nil;

        if (ABAddressBookGetAuthorizationStatus() ==
            kABAuthorizationStatusNotDetermined ||
            ABAddressBookGetAuthorizationStatus() ==
            kABAuthorizationStatusAuthorized) {
            addressBook = ABAddressBookCreateWithOptions(NULL, error);
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(
                                                     addressBook, ^(bool granted, CFErrorRef error) {
                                                         accessGranted = granted;
                                                         dispatch_semaphore_signal(sema);
                                                     });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        } else {
            if (ABAddressBookGetAuthorizationStatus() ==
                kABAuthorizationStatusDenied ||
                ABAddressBookGetAuthorizationStatus() ==
                kABAuthorizationStatusRestricted) {
                // Display an error.
                [[[UIAlertView alloc]
                  initWithTitle:nil
                  message:@"This app requires access to your contacts to "
                  @"function properly. Please visit to the "
                  @"\"Privacy\" section in the iPhone Settings app."
                  delegate:nil
                  cancelButtonTitle:@"OK"
                  otherButtonTitles:nil] show];
            }
        }

        if (accessGranted) {
            ABAddressBookRef addressBook =
            ABAddressBookCreateWithOptions(NULL, error);
            ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
            CFArrayRef allPeople =
            ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(
                                                                      addressBook, source, kABPersonSortByFirstName);
            CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
            NSMutableArray *items = [NSMutableArray arrayWithCapacity:nPeople];

            for (int i = 0; i < nPeople; i++) {

                NSLog(@"Count %d", i);
                CACContactsModel *contact = [CACContactsModel new];

                ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);

                // fetch contact person name

                NSString *personName;
                if ((__bridge NSString *)ABRecordCopyValue(
                                                           person, kABPersonLastNameProperty) != NULL) {
                    personName = [(__bridge NSString *)ABRecordCopyValue(
                                                                         person, kABPersonFirstNameProperty)
                                  stringByAppendingFormat:@" %@",
                                  (__bridge NSString *)ABRecordCopyValue(
                                                                         person, kABPersonLastNameProperty)];
                } else
                    personName = (__bridge NSString *)ABRecordCopyValue(
                                                                        person, kABPersonFirstNameProperty);

                contact.personName = personName;

                // fetch contact person Phone Number
                NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];

                ABMultiValueRef multiPhones =
                ABRecordCopyValue(person, kABPersonPhoneProperty);

                for (CFIndex i = 0; i < ABMultiValueGetCount(multiPhones); i++) {

                    CFStringRef phoneNumberRef =
                    ABMultiValueCopyValueAtIndex(multiPhones, i);
                    NSString *phoneNumber = (__bridge NSString *)phoneNumberRef;
                    phoneNumber = [CACCommonUtils removePhoneNumberSeperator:phoneNumber];

                    [phoneNumbers addObject:phoneNumber];
                }
                contact.personContacts = phoneNumbers;

                // fetch contact person image
                NSData *imgData = (__bridge NSData *)ABPersonCopyImageData(person);
                contact.personImage = [UIImage imageWithData:imgData];
                if (!contact.personImage) {
                    contact.personImage = [UIImage imageNamed:@"NOIMG.png"];
                }

                [items addObject:contact];
            }

            if ([_contactDelegate
                 respondsToSelector:@selector(phoneNumberFetchedSuccesfully:)]) {
                [_contactDelegate phoneNumberFetchedSuccesfully:items];
            }
        }
    }
}

@end
