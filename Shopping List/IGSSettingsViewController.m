//
//  IGSSettingsViewController.m
//  Shopping List
//
//  Created by Gabe on 2/19/14.
//  Copyright (c) 2014 Gabe Schwarzer. All rights reserved.
//

#import "IGSSettingsViewController.h"
#import "IGSStores.h"

@interface IGSSettingsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *addStoreButton;
@property (weak, nonatomic) IBOutlet UITextField *addStoreTextfield;
@property (weak, nonatomic) IBOutlet UITableView *storesTableView;


@end

@implementation IGSSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	//Set dataSource and delegate for the UITableView
	_storesTableView.dataSource = self;
	_storesTableView.delegate = self;
	
	//Set the delegate for the UITextField
	_addStoreTextfield.delegate = self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//Add store entered into textfield to data storage
- (IBAction)addStore:(id)sender
{
	if ([self.addStoreTextfield.text length] > 0) {
		IGSStores *storesArr = [[IGSStores alloc] init];
		
		[storesArr addStore:[self.addStoreTextfield.text capitalizedString]];
		
		//Clear the textfield
		self.addStoreTextfield.text = nil;
		
		//Reload the tableView
		[self.storesTableView reloadData];
	}
}


#pragma mark - UITableView dataSource and delegate methods

//When a row is tapped
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	//Deselect the tapped row immediately
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


//Put text labels into cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//Set cell identifier for reusability
	static NSString *CellIdentifier = @"StoresCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	
	//Create a new array with all the stores
	NSArray *allStores = [[[IGSStores alloc] init] allStores];
	
	//Set the cell label for each store in the array
	cell.textLabel.text = allStores[indexPath.row];
	
	return cell;
}


//Set the number of rows in the table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSArray *stores = [[[IGSStores alloc] init] allStores];
	
	return [stores count];
}


// Deleting a history item
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
		//Create a new array with all the stores
		IGSStores *stores = [[IGSStores alloc] init];
		NSArray *allStores = [stores allStores];
		
		//Get the store name from the table row number
		NSString *storeName = allStores[indexPath.row];
		
		//Remove the store
		[stores removeStore:storeName];
		
		if ([[stores allStores][0] isEqualToString:stores.genericStoreName]) {
			[tableView reloadData];
		} else {
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
		}
		
    }
}


#pragma mark - UITextField delegate methods

//Make pressing the return key on the keyboard act as a button press, then hide keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[self addStore:nil];
	
	return [textField resignFirstResponder];
}

@end
