//
//  SearchResultViewController.m
//  Surfing Doggo
//
//  Created by Karan Ghorai on 05/07/21.
//

#import "SearchResultViewController.h"
#import "FetchingAndParsingJason.h"
#import "ShowSearchResultImageViewController.h"
#import "PassBreedNames.h"
#import <UserNotifications/UserNotifications.h>

@interface SearchResultViewController ()
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *mainActivityIndicator;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *imageURLsToLoad;
@property (strong, nonatomic) UIRefreshControl *refresh;
@property (strong, nonatomic) NSString *URLToPassToShowImageViewController;
@property NSInteger chosenIndex;
@end

@implementation SearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    [_mainActivityIndicator startAnimating];
    
    self.navigationItem.title = [_breedNameSelected uppercaseString];
    
    if ([_breedNameSelected isEqualToString:@"all"]){
        PassBreedNames *passBreedNames = [PassBreedNames passBreednames];
        _imageURLsToLoad = [passBreedNames.allURLS mutableCopy];
        [self->_mainActivityIndicator stopAnimating];
        self->_mainActivityIndicator.hidden = YES;
        [self->_collectionView reloadData];
    }
    
    else{
        [FetchingAndParsingJason fetchURLsForBreedName:_breedNameSelected :^(NSArray * _Nonnull arrayOfURLsForGivenBreedName, NSError * _Nonnull error) {
            
            if (error){
                NSLog(@"Error while fetching Url");
            }
            else{
                self->_imageURLsToLoad = [arrayOfURLsForGivenBreedName mutableCopy];
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self->_mainActivityIndicator stopAnimating];
                    self->_mainActivityIndicator.hidden = YES;
                    [self->_collectionView reloadData];
                }];
            }
            
        }];
    }
}


- (void)viewDidAppear:(BOOL)animated {
    _refresh = [[UIRefreshControl alloc] init];
    [_refresh addTarget:self action:@selector(refreshCollectionView) forControlEvents:UIControlEventValueChanged];
    [_collectionView addSubview:_refresh];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"SearchResultImageSegue"]){
        ShowSearchResultImageViewController *showSearchResultImageViewController = [segue destinationViewController];
        showSearchResultImageViewController.imageURLs = _imageURLsToLoad;
        showSearchResultImageViewController.chosenIndex = _chosenIndex;
    }
}

- (IBAction)changeHomePagePreferenceButtonAction:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"NotificationPermission"] == NO) {
        
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        
        UNAuthorizationOptions options = UNAuthorizationOptionAlert + UNAuthorizationOptionSound;
        
        [center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
            [[NSUserDefaults standardUserDefaults] setBool:granted forKey:@"NotificationPermission"];
        }];
        
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"NotificationPermission"] == YES) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = @"Home Page prefrence Changed";
        content.subtitle = [_breedNameSelected uppercaseString];
        content.body = [NSString stringWithFormat:@"Home Screen Preference Changed to %@", [_breedNameSelected uppercaseString]];
        content.sound = [UNNotificationSound defaultSound];
        
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
        
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"HomePagePreferenceChangedNotification" content:content trigger:trigger];
        
        [center addNotificationRequest:request withCompletionHandler:nil];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:_breedNameSelected forKey:@"HomePagePreference"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PreferenceChangedNotification" object:nil];
    
    
}

- (void)refreshCollectionView {
//    NSLog(@"Refreshing....");
    [self suffleImageURLsFetched];
    [_collectionView reloadData];
    [_refresh endRefreshing];
}


- (void)suffleImageURLsFetched {
    NSUInteger count = [_imageURLsToLoad count];
    for (long i = 0; i < count; i++) {
        long nElements = count - i;
        long n = (arc4random() % nElements) + i;
        [_imageURLsToLoad exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    NSLog(@"%lu", _imageURLsToLoad.count);
    return _imageURLsToLoad.count;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(collectionView.bounds.size.width/2 - 1, collectionView.bounds.size.width/2);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}



- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    UIImageView *imageView = [cell viewWithTag:1];
    
    UIActivityIndicatorView *activityIndicator = [cell viewWithTag:2];
    activityIndicator.hidden = NO;
    [activityIndicator startAnimating];
    
    NSString *currentImageLink = [_imageURLsToLoad objectAtIndex:indexPath.row];
    
    NSURL *url = [[NSURL alloc] initWithString:currentImageLink];
    
//    NSLog(@"%@", currentImageLink);
    
    [[NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [activityIndicator stopAnimating];
            activityIndicator.hidden = YES;
        }];
        
        if (error){
            NSLog(@"Error while fetching image for url %@", currentImageLink);
        }
        else{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                imageView.image = [UIImage imageWithData:data];
            }];
        }
        
    }] resume];
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [_refresh removeFromSuperview];
    _chosenIndex = indexPath.row;
    [self performSegueWithIdentifier:@"SearchResultImageSegue" sender:self];
}


@end
