//
//  IGSTableViewController.m
//  Shopping List
//
//  Created by Gabe on 2/9/14.
//  Copyright (c) 2014 Gabe Schwarzer. All rights reserved.
//

#import "IGSTableViewController.h"
#import "IGSItemStore.h"
#import "IGSItem.h"
#import "IGSStores.h"

@interface IGSTableViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *clearButton;

@end

@implementation IGSTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.tableView reloadData];
	
	[self updateViewTitle];
	
	//Show the toolbar at the bottom
	[self.navigationController setToolbarHidden:NO animated:NO];
	
	//Set the color for the toolbar and navigation bar
	UIColor *barColor = [[UIColor alloc] initWithRed:49.0/255.0 green:83.0/255.0 blue:127.0/255.0 alpha:1];
	
	self.navigationController.navigationBar.barTintColor = barColor;
	self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
	self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil];
	self.navigationController.toolbar.barTintColor = barColor;
	self.navigationController.toolbar.tintColor = [UIColor whiteColor];
	
}

- (void)viewWillDisappear:(BOOL)animated
{
	//Hide the toolbar at the bottom
	[self.navigationController setToolbarHidden:YES animated:NO];
}


//Update the view title
- (void)updateViewTitle
{
	NSUInteger totalNumberOfItems = [[[IGSItemStore alloc] init] totalNumberOfItems:NO];
	NSUInteger totalNumberOfNonCompletedItems = [[[IGSItemStore alloc] init] totalNumberOfItems:YES];
	
	//Don't show the clear button and edit button and turn off edit mode when we don't have any items
	if (totalNumberOfItems == 0) {
		[self setEditing:NO animated:YES];
		[self.navigationItem.leftBarButtonItem setEnabled:NO];
		[self.clearButton setEnabled:NO];
	} else {
		[self.navigationItem.leftBarButtonItem setEnabled:YES];
		self.navigationItem.leftBarButtonItem = self.editButtonItem;
		[self.clearButton setEnabled:YES];
	}
    
	//Set the view title
	NSString *viewTitle = @"Shopping List (";
	viewTitle = [viewTitle stringByAppendingString:[[NSNumber numberWithUnsignedInteger:totalNumberOfNonCompletedItems] stringValue]];
	viewTitle = [viewTitle stringByAppendingString:@")"];
	
	self.navigationController.navigationBar.topItem.title = viewTitle;
	
	//Set the icon badge to the number of items on the list
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:totalNumberOfNonCompletedItems];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//Show action sheet when clear button is pressed
- (IBAction)clearItemsFromList:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:@"Clear checked items"
													otherButtonTitles:@"Clear all items", nil];
	
	[actionSheet showFromBarButtonItem:self.clearButton animated:YES];
}


//Action sheet actions when a button is pressed
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	//If the cancel button wasn't pressed
	if (buttonIndex != 3) {
		IGSItemStore *itemStore = [[IGSItemStore alloc] init];
	
		if (buttonIndex == 0) {
			//Delete checked items only (YES refers to checkedItemsOnly)
			[itemStore removeAllItems:YES];
		
		} else if (buttonIndex == 1) {
			//Delete all items (NO refers to checkedItemsOnly)
			[itemStore removeAllItems:NO];
		}
		
		//Reload the table view
		[self.tableView reloadData];
		
		//Refresh the view title
		[self updateViewTitle];
	}
}

#pragma mark - Table view data source

//Return total number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	IGSItemStore *itemStore = [[IGSItemStore alloc] init];
	NSUInteger numberOfStores = [itemStore.storesDict count];
	return numberOfStores;
}


//Return the title for each section header
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSArray *stores = [[[IGSItemStore alloc] init] storeNamesInStoresDict];
	NSString *storeName = stores[section];
	
	return storeName;
}


//Return number of rows for each section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	IGSItemStore *itemStore = [[IGSItemStore alloc] init];
	NSArray *stores = [itemStore storeNamesInStoresDict];
	NSString *storeName = stores[section];
	
	NSUInteger numberOfItems = [[itemStore itemsInStore:storeName] count];
	
	return numberOfItems;
}


//Fill cell with item name
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Set cell identifier for reusability
	static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	IGSItemStore *itemStore = [[IGSItemStore alloc] init];
	NSArray *stores = [itemStore storeNamesInStoresDict];
	NSString *storeName = stores[indexPath.section];
	
	IGSItem *item = [itemStore itemsInStore:storeName][indexPath.row];
	
	//Change style of item if it is completed
	if (item.completed) {
		NSDictionary *attributes = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
		
		NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:item.itemName attributes:attributes];
		
		cell.textLabel.attributedText = attrText;
		cell.textLabel.textColor = [UIColor grayColor];
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	
	} else {
		cell.textLabel.text = item.itemName;
		cell.textLabel.textColor = [UIColor blackColor];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	//Set custom selection background
	UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
	customView.backgroundColor = [[UIColor alloc] initWithRed:49.0/255.0 green:83.0/255.0 blue:127.0/255.0 alpha:0.05];
	cell.selectedBackgroundView = customView;
	
    return cell;
}


//Selecting an item
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	//Deselect the tapped row immediately
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	IGSItemStore *itemStore = [[IGSItemStore alloc] init];
	NSArray *stores = [itemStore storeNamesInStoresDict];
	NSString *storeName = stores[indexPath.section];
	
	IGSItem *item = [itemStore itemsInStore:storeName][indexPath.row];
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	//If item is marked as completed
	if (item.completed) {
		
		//Set item to uncompleted
		item.completed = NO;
		
		//Change its style back to normal
		cell.textLabel.text = item.itemName;
		cell.textLabel.textColor = [UIColor blackColor];
		cell.accessoryType = UITableViewCellAccessoryNone;
	
	} else {
		
		//Set item as completed
		item.completed = YES;
	
		NSDictionary* attributes = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
	
		NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:cell.textLabel.text attributes:attributes];
		
		//Change its style to completed
		cell.textLabel.attributedText = attrText;
		cell.textLabel.textColor = [UIColor grayColor];
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	
	//Save changes to data storage
	[itemStore saveStoresDictOnDisk];
	
	//Refresh the view title
	[self updateViewTitle];
	
}


// Deleting an item
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
		[tableView beginUpdates];
		
		IGSItemStore *itemStore = [[IGSItemStore alloc] init];
		NSArray *stores = [itemStore storeNamesInStoresDict];
		NSString *storeName = stores[indexPath.section];
		
		IGSItem *item = [itemStore itemsInStore:storeName][indexPath.row];
		
		//Remove the item from its corresponding array
		[itemStore removeItem:item fromStore:storeName];
		
		//Update the title of the view
		[self updateViewTitle];
		
		//If we only had one item in the section, remove the entire section. Otherwise, only remove the row
		if ([tableView numberOfRowsInSection:indexPath.section] == 1) {
			[tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
		} else {
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
		}
		
		[tableView endUpdates];
		
    }
}


// Moving an item
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	//Get section titles
	NSString *fromSectionTitle = [[[tableView headerViewForSection:fromIndexPath.section] textLabel] text];
	NSString *toSectionTitle = [[[tableView headerViewForSection:toIndexPath.section] textLabel] text];
	
	//Move the item in the dictionary
	IGSItemStore *itemStore = [[IGSItemStore alloc] init];
	[itemStore moveItem:fromIndexPath toIndexPath:toIndexPath fromSectionTitle:fromSectionTitle toSectionTitle:toSectionTitle];
	
	//If we only had one item in the section and we're moving the item out of that section, remove the entire section
	dispatch_async(dispatch_get_main_queue(), ^{
		if (fromIndexPath.section != toIndexPath.section && [tableView numberOfRowsInSection:fromIndexPath.section] == 0) {
			[tableView deleteSections:[NSIndexSet indexSetWithIndex:fromIndexPath.section] withRowAnimation:UITableViewRowAnimationTop];
		}
	});
}



@end
