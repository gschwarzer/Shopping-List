//
//  IGSViewController.m
//  Shopping List
//
//  Created by Gabe on 2/8/14.
//  Copyright (c) 2014 Gabe Schwarzer. All rights reserved.
//

#import "IGSViewController.h"
#import "IGSItemStore.h"
#import "IGSItem.h"
#import "IGSStores.h"
#import "IGSHistoryItem.h"
#import "IGSHistoryItemStore.h"


@interface IGSViewController ()
@property (weak, nonatomic) IBOutlet UITextField *addTextfield;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UILabel *itemAddedMessage;
@property (weak, nonatomic) IBOutlet UITableView *historyTableView;
@property (weak, nonatomic) IBOutlet UITableView *selectStoreTableView;

@end

@implementation IGSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	//Set dataSource and delegate for the UITableViews
	_historyTableView.dataSource = self;
	_historyTableView.delegate = self;
	_selectStoreTableView.dataSource = self;
	_selectStoreTableView.delegate = self;
	
	//Set the delegate for the UITextField
	_addTextfield.delegate = self;
	
	//Preselect the first row in the selectStoreTableView
	[self.selectStoreTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
										   animated:YES
									 scrollPosition:UITableViewScrollPositionTop];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Add item to list
- (IBAction)addItemToList:(id)sender
{
	if ([self.addTextfield.text length] > 0) {
		
		//Get selected store name
		NSIndexPath *selectedIndexPath = [self.selectStoreTableView indexPathForSelectedRow];
		//UITableViewCell *selectedCell = [self.selectStoreTableView cellForRowAtIndexPath:selectedIndexPath];
		
		NSString *selectedStoreName = [[[[IGSStores alloc] init] allStores] objectAtIndex:selectedIndexPath.row];
		
		//Get item name (with first letter capitalized) entered into textfield
		NSString *itemName = [self.addTextfield.text stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[self.addTextfield.text substringToIndex:1] capitalizedString]];
		
		//Add item and store to our internal data storage
		[[[IGSItemStore alloc] init] saveItem:itemName toStore:selectedStoreName];
		
		//Clear the textfield
		self.addTextfield.text = nil;
		
		//Set and animate fade in/out of itemAddedMessage label
		self.itemAddedMessage.alpha = 0.0;
		self.itemAddedMessage.text = [itemName stringByAppendingString:@" added to list!"];
		[UIView animateWithDuration:0.4
						 animations:^{self.itemAddedMessage.alpha = 1.0;}
						 completion:^(BOOL finished) {
							 [UIView animateWithDuration:0.4
												   delay:1.0
												 options:UIViewAnimationOptionOverrideInheritedOptions
											  animations:^{self.itemAddedMessage.alpha = 0.0;}
											  completion:NULL];
						 }];
		
		//Add item to history
		[[[IGSHistoryItemStore alloc] init] saveItem:itemName storeName:selectedStoreName];
		
		[self.historyTableView reloadData];
	}
}



#pragma mark - UITableView dataSource and delegate methods

//Put text labels into cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	
	if (tableView == self.selectStoreTableView) {
		//Set cell identifier for reusability
		static NSString *CellIdentifier = @"SelectStoreCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
		
		//Get an array of all stores
		NSArray *stores = [[[IGSStores alloc] init] allStores];

		//Return the store title for index row
		cell.textLabel.text = stores[indexPath.row];
		
		//Set custom selection background
		UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
		customView.backgroundColor = [[UIColor alloc] initWithRed:49.0/255.0 green:83.0/255.0 blue:127.0/255.0 alpha:0.05];
		cell.selectedBackgroundView = customView;
		if (cell.isSelected) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}
		
		return cell;
	
	}
	
	if (tableView == self.historyTableView) {
		//Set cell identifier for reusability
		static NSString *CellIdentifier = @"HistoryCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
		
		//Create a new array with all the items in the history
		IGSHistoryItemStore *historyItemStore = [[IGSHistoryItemStore alloc] init];
		NSSet *itemsHistory = historyItemStore.itemsHistory;
		NSMutableArray *historicalItems = [[NSMutableArray alloc] init];
		
		for (IGSHistoryItem *historicalItem in itemsHistory) {
			[historicalItems addObject:historicalItem.historicalItemName];
		}
		
		//Sort the array alphabetically and add it to the cell label
		cell.textLabel.text = [historicalItems sortedArrayUsingSelector:@selector(compare:)][indexPath.row];
		
		//Set custom selection background
		UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
		customView.backgroundColor = [[UIColor alloc] initWithRed:49.0/255.0 green:83.0/255.0 blue:127.0/255.0 alpha:0.05];
		cell.selectedBackgroundView = customView;
		
		return cell;
	}
	
	return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
}


//Set the number of rows in the table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (tableView == self.selectStoreTableView) {
		//Return the number of stores we have available
		return [[[[IGSStores alloc] init] allStores] count];
	}
	
	if (tableView == self.historyTableView) {
		IGSHistoryItemStore *historyItemStore = [[IGSHistoryItemStore alloc] init];
		NSSet *itemsHistory = historyItemStore.itemsHistory;
		
		return [itemsHistory count];
	}
	
	return 0;
}


//Add item title to addTextfield on selection; add checkmark to store selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView == self.selectStoreTableView) {
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		
		//Fix cell separator line glitch
		[tableView reloadData];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		[tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
	}
	
	if (tableView == self.historyTableView) {
		//Deselect the tapped row immediately
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		
		//Set addTextfield to the selected item
		self.addTextfield.text = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text];
		
		//Create a new array with all the items in the history
		IGSHistoryItemStore *historyItemStore = [[IGSHistoryItemStore alloc] init];
		NSSet *itemsHistory = historyItemStore.itemsHistory;
		NSMutableArray *historicalItems = [[NSMutableArray alloc] init];
		
		for (IGSHistoryItem *historicalItem in itemsHistory) {
			[historicalItems addObject:historicalItem];
		}
		
		//Sort the array alphabetically
		NSArray *sortedHistoricalItems = [historicalItems sortedArrayUsingSelector:@selector(compare:)];
		
		IGSHistoryItem *historyItem = [sortedHistoricalItems objectAtIndex:indexPath.row];
		
		NSString *storeNameForItem = historyItem.historicalStoreName;
		
		//Find the row number for that store
		NSUInteger storeRow = [[[[IGSStores alloc] init] allStores] indexOfObject:storeNameForItem];
		
		NSIndexPath *storeIndexPath = [NSIndexPath indexPathForRow:storeRow inSection:0];
		
		//Set the store selected cell to the one saved for the item
		if (storeRow != NSNotFound) {
			
			//Fix cell separator line glitch
			[self.selectStoreTableView reloadData];
			[self.selectStoreTableView deselectRowAtIndexPath:indexPath animated:YES];
			
			[self.selectStoreTableView selectRowAtIndexPath:storeIndexPath
												   animated:NO
											 scrollPosition:UITableViewScrollPositionMiddle];
			
			//Remove checkmarks from all the cells
			for (NSInteger i = 0; i < [self.selectStoreTableView numberOfRowsInSection:0]; i++) {
				UITableViewCell *anyCell = [self.selectStoreTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
				anyCell.accessoryType = UITableViewCellAccessoryNone;
			}
			
			//Set the checkmark on the cell we need
			UITableViewCell *storeCell = [self.selectStoreTableView cellForRowAtIndexPath:storeIndexPath];
			storeCell.accessoryType = UITableViewCellAccessoryCheckmark;
			
		}

	}
}


//Remove checkmark from store selection
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView == self.selectStoreTableView) {
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
}


//Turn off deleting of "Select Store" table cells
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.selectStoreTableView) {
		return NO;
	} else {
		return YES;
	}
	
}


// Deleting a history item
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	if (tableView == self.historyTableView) {
		if (editingStyle == UITableViewCellEditingStyleDelete) {
			
			//Create a new array with all the items in the history
			IGSHistoryItemStore *historyItemStore = [[IGSHistoryItemStore alloc] init];
			NSSet *itemsHistory = historyItemStore.itemsHistory;
			NSMutableArray *historicalItems = [[NSMutableArray alloc] init];
			
			for (IGSHistoryItem *historicalItem in itemsHistory) {
				[historicalItems addObject:historicalItem];
			}
			
			//Sort the array alphabetically
			NSArray *sortedHistoricalItems = [historicalItems sortedArrayUsingSelector:@selector(compare:)];
			
			IGSHistoryItem *historyItem = [sortedHistoricalItems objectAtIndex:indexPath.row];
			
			//Remove the item from the itemHistory set
			[historyItemStore removeItem:historyItem];
			
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
		}
	}
	
}


#pragma mark - UITextField delegate methods

//Make pressing the return key on the keyboard act as a button press, then hide keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[self addItemToList:nil];
	
	return [textField resignFirstResponder];
}

@end
