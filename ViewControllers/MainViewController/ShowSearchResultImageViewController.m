//
//  ShowSearchResultImageViewController.m
//  Surfing Doggo
//
//  Created by Karan Ghorai on 05/07/21.
//

#import "ShowSearchResultImageViewController.h"
#import <UserNotifications/UserNotifications.h>

@interface ShowSearchResultImageViewController ()
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation ShowSearchResultImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
}
- (IBAction)saveImageToPhotosAction:(id)sender {
    NSArray *visibleIndexPaths = [_collectionView indexPathsForVisibleItems];
    NSIndexPath *indexPathOfVisibleImage = [visibleIndexPaths objectAtIndex:0];
    
    NSURL *url = [[NSURL alloc] initWithString:[_imageURLs objectAtIndex:indexPathOfVisibleImage.row]];
    
    [[NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error){
            NSLog(@"Error while saving Image.");
        }
        else{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                UIImage *image = [UIImage imageWithData:data];
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                
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
                    content.title = @"Downloaded Successfully!";
                    content.subtitle = @"Image saved to photos";
                    content.body = [NSString stringWithFormat:@"Image Downloaded."];
                    content.sound = [UNNotificationSound defaultSound];
                    
                    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
                    
                    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"ImageDownloadedNotification" content:content trigger:trigger];
                    
                    [center addNotificationRequest:request withCompletionHandler:nil];
                }
            }];
        }
    }] resume];
}

- (NSString *)getBreedNameForURL:(NSString *)URL{
    
    NSString *subStringFromBreedName = [URL substringFromIndex:30];
    NSInteger endingPositionOfBreedName = [subStringFromBreedName rangeOfString:@"/"].location;
    NSString *breedName = [subStringFromBreedName substringToIndex:endingPositionOfBreedName];
    
    return breedName;
}

- (void)viewDidLayoutSubviews{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_chosenIndex inSection:0];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _imageURLs.count;
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"secondCell" forIndexPath:indexPath];
    
    UIImageView *imageView = [cell viewWithTag:1];
    UIActivityIndicatorView *activityIndicator = [cell viewWithTag:2];
    UILabel *label = [cell viewWithTag:3];
    
    [activityIndicator startAnimating];
    
    NSString *currentImageLink = [_imageURLs objectAtIndex:indexPath.row];
    
    label.text = [[self getBreedNameForURL:currentImageLink] uppercaseString];
    
    NSURL *url = [[NSURL alloc] initWithString:currentImageLink];
    
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(_collectionView.bounds.size.width - 4, _collectionView.bounds.size.height - 4);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 4;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 4;
}

@end
