<b>Contact Helper Class</b>

Class can be used to fetch contacts in iOS.
Class uses CNContact for iOS 9 and ABAddressBook for lower versions.

<b>Phone Number</b>

Below method can be used to fetch phone numbers along with the name and profile picture of the contact.

- (void)getAllPhoneNumbersFromContacts

Example code

    CACContactsHelper *contactHelperObj = [CACContactsHelper sharedInstance];
    contactHelperObj.contactDelegate = self;
    contactHelperObj.shouldFormatPhoneNumber = TRUE;
    [contactHelperObj getAllPhoneNumbersFromContacts];

shouldFormatPhoneNumber: This boolean can be set to get the formatted phone number.

You need to implement this delegate method in your code to get the phone number in your view controller class.

Array contain model class object on the indexes.
- (void)phoneNumberFetchedSuccesfully:(NSMutableArray *)arrPhoneNumber

<b>Email id</b>

Below method can be used to fetch email-ids along with the name and profile picture of the contact.

- (void)getAllEmailIdsFromContacts

Example code

    CACContactsHelper *contactHelperObj = [CACContactsHelper sharedInstance];
    contactHelperObj.contactDelegate = self;
    contactHelperObj.skipInvalidEmailId = TRUE;
    [contactHelperObj getAllEmailIdsFromContacts];
    
skipInvalidEmailId: This boolean can be set to get the skip the invaild email-id.

You need to implement this delegate method in your code to get the email-id in your view controller class.

Array contain model class object on the indexes.
- (void)phoneNumberFetchedSuccesfully:(NSMutableArray *)arrPhoneNumber
