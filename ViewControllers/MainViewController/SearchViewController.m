//
//  SearchViewController.m
//  Surfing Doggo
//
//  Created by Karan Ghorai on 04/07/21.
//

#import "SearchViewController.h"
#import "PassBreedNames.h"
#import "SearchResultViewController.h"

@interface SearchViewController ()
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *allBreedNames;
@property (strong, nonatomic) NSMutableArray *itemsToDisplay;
@property (strong, nonatomic) NSString *breedNameToPass;
@end

@implementation SearchViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    PassBreedNames *passBreedNames = [PassBreedNames passBreednames];
    _allBreedNames = [passBreedNames.breedNames mutableCopy];
    [_allBreedNames insertObject:@"all" atIndex:0];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _searchBar.delegate = self;
    
    [_tableView setFrame:self.view.bounds];
    
    _itemsToDisplay = [_allBreedNames mutableCopy];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardAppeared:) name: UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDisappeared:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"SearchResultSegue"]) {
        SearchResultViewController *searchResultViewController = [segue destinationViewController];
        searchResultViewController.breedNameSelected = _breedNameToPass;
    }
}


- (void)keyboardAppeared:(NSNotification *)note{
    CGRect keyboardFrame;
    [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    CGRect tableViewFrame = self.view.bounds;
    tableViewFrame.size.height -= keyboardFrame.size.height;
    [_tableView setFrame:tableViewFrame];
}

- (void)keyboardDisappeared:(NSNotification *)note{
    [_tableView setFrame:self.view.bounds];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length == 0) {
        _itemsToDisplay = [_allBreedNames mutableCopy];
    }
    else {
        _itemsToDisplay = [[NSMutableArray alloc] init];
        
        for(NSString *currentBreedName in _allBreedNames) {
            NSRange rangeOfCurrentSearchTextInCurrentBreedName = [currentBreedName rangeOfString:[searchText lowercaseString]];
            if (rangeOfCurrentSearchTextInCurrentBreedName.location != NSNotFound){
                [_itemsToDisplay addObject:currentBreedName];
            }
            
        }
    }
    [_tableView reloadData];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [_searchBar resignFirstResponder];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _itemsToDisplay.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    cell.textLabel.text = [_itemsToDisplay objectAtIndex:indexPath.row];
//    cell.backgroundColor = [UIColor blackColor];
//    cell.textLabel.textColor = [UIColor whiteColor];
//    tableView.separatorColor = [UIColor grayColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _breedNameToPass = [_itemsToDisplay objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"SearchResultSegue" sender:self];
}


@end
