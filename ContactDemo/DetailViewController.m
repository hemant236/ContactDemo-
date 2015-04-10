//
//  DetailViewController.m
//  ContactDemo
//
//  Created by Hemant on 2/24/15.
//  Copyright (c) 2015 SmartCloud. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property NSMutableArray *objects;
@property(strong)  NSIndexPath* lastIndexPath;


@end

@implementation DetailViewController

#pragma mark - Managing the detail item


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    ContactHelper *contactHelperObj = [ContactHelper sharedInstance];
    contactHelperObj.contactDelegate = self;
    [contactHelperObj getAllContacts];

    self.cellSelected = [NSMutableArray array];

   // NSString *CellIdentifier = @"contactCellIdentifier";

    //[self.tblView registerClass:[ContactTableViewCell class] forCellReuseIdentifier:CellIdentifier];


}


-(void)contactFetchedSuccesfully:(NSMutableArray *)arrContacts
{

    self.objects = arrContacts;
    [self.tblView reloadData];


}
-(void)failedToFetchContact:(NSError *)error{

    //NSLog(@"Error %@",[error localizedDescription]);

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *simpleTableIdentifier = @"contactCellIdentifier";

    ContactTableViewCell *cell = (ContactTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ContactTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

    ContactModel *contact = [ContactModel new];
    contact = [self.objects objectAtIndex:indexPath.row];



    cell.lblName.text = [NSString stringWithFormat:@"%@ %@",contact.strFirstName,contact.strLastName];
    if (contact.arrPhoneNumbers.count !=0) {
        cell.lblPhone.text = [NSString stringWithFormat:@"%@",[contact.arrPhoneNumbers objectAtIndex:0]];
    }

    //NSLog(@"indexPath cell %@",indexPath );
    cell.imgSelected.tag = 1000+indexPath.row;

    if ([self.cellSelected containsObject:indexPath])
    {
        cell.imgSelected.image = [UIImage imageNamed:@"Check_mark.png"];

    }
    else
    {
        cell.imgSelected.image = [UIImage imageNamed:@""];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath   *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if ([self.cellSelected containsObject:indexPath])
    {
        [self.cellSelected removeObject:indexPath];
    }
    else
    {
        [self.cellSelected addObject:indexPath];
    }
    [tableView reloadData];
}


-(IBAction)donePress:(id)sender{

    for (int i=0; i<self.cellSelected.count; i++) {
        NSIndexPath *cellSelcted = [self.cellSelected objectAtIndex:i];
        ContactModel *contact = [ContactModel new];
        contact = [self.objects objectAtIndex:cellSelcted.row];
        NSLog(@"Phone number%@ ",contact.arrPhoneNumbers.count!=0?[contact.arrPhoneNumbers objectAtIndex:0]:@"No Contact");

    }
}

@end
