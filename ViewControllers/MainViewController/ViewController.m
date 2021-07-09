//
//  ViewController.m
//  Surfing Doggo
//
//  Created by Karan Ghorai on 29/06/21.
//

#import "ViewController.h"
#import "FetchingAndParsingJason.h"
#import "ShowImageViewController.h"
#import "PassBreedNames.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *mainActivityIndicator;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *breedNames;
@property (strong, nonatomic) NSMutableArray *imageURLsToLoad;
@property (strong, nonatomic) UIRefreshControl *refresh;
@property (strong, nonatomic) NSString *URLToPassToShowImageViewController;
@property NSInteger chosenIndex;
@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    [_mainActivityIndicator startAnimating];

    _imageURLsToLoad = [[NSMutableArray alloc] init];
    
    __block long URLsFetchedForNoOfBreeds = 0;
    
    void (^URLsFetchedHandler)(void) = ^void() {
        
        URLsFetchedForNoOfBreeds++;
        
//        NSLog(@"%li %lu", URLsFetchedForNoOfBreeds, (unsigned long)[self->_breedNames count]);
        
        if (URLsFetchedForNoOfBreeds == (long)[self->_breedNames count]) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                PassBreedNames *passBreedNames = [PassBreedNames passBreednames];
                passBreedNames.breedNames = self->_breedNames;
                [self suffleImageURLsFetched];
                passBreedNames.allURLS = self->_imageURLsToLoad;
                
                if ([[NSUserDefaults standardUserDefaults] stringForKey:@"HomePagePreference"] == nil) {
                    [[NSUserDefaults standardUserDefaults] setObject:@"all" forKey:@"HomePagePreference"];
                }
                [self preferenceChanged];
            }];
        }
        
    };
    
    _breedNames = [[NSMutableArray alloc] init];
    
    [FetchingAndParsingJason fetchAllBreedNames:^void (NSArray * _Nonnull breedNames, NSError * _Nonnull error) {
        self->_breedNames = [[NSMutableArray alloc] initWithArray:breedNames];
    for (int i = 0; i<[breedNames count]; i++) {
        
        [FetchingAndParsingJason fetchURLsForBreedName:[breedNames objectAtIndex:i] :^(NSArray * _Nonnull arrayOfURLsForGivenBreedName, NSError * _Nonnull error) {
            
            if (error){
                NSLog(@"Error while fetching Url");
            }
            else{
                self->_imageURLsToLoad = (NSMutableArray *)[self->_imageURLsToLoad arrayByAddingObjectsFromArray:arrayOfURLsForGivenBreedName];
                self->_imageURLsToLoad = [self->_imageURLsToLoad mutableCopy];
            }
            URLsFetchedHandler();
            
        }];
    }
    }];
    
    [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(preferenceChanged) name:@"PreferenceChangedNotification" object:nil];
}


- (void)preferenceChanged {
    _mainActivityIndicator.hidden = NO;
    
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"HomePagePreference"] isEqualToString:@"all"]) {
        PassBreedNames *passBreedNames = [PassBreedNames passBreednames];
        _imageURLsToLoad = [passBreedNames.allURLS mutableCopy];
        [self suffleImageURLsFetched];
        [self->_mainActivityIndicator stopAnimating];
        self->_mainActivityIndicator.hidden = YES;
        [_collectionView reloadData];
    }
    else{
        
        [FetchingAndParsingJason fetchURLsForBreedName:[[NSUserDefaults standardUserDefaults] stringForKey:@"HomePagePreference"]:^(NSArray * _Nonnull arrayOfURLsForGivenBreedName, NSError * _Nonnull error) {
            
            if (error){
                NSLog(@"Error while fetching Url");
            }
            else{
                self->_imageURLsToLoad = [arrayOfURLsForGivenBreedName mutableCopy];
            }
            
            [self suffleImageURLsFetched];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [self->_mainActivityIndicator stopAnimating];
                            self->_mainActivityIndicator.hidden = YES;
                            [self->_collectionView reloadData];
            }];
        }];
        
    }
    self.navigationItem.title = [[[NSUserDefaults standardUserDefaults] stringForKey:@"HomePagePreference"] uppercaseString];
}


- (void)viewDidAppear:(BOOL)animated {
    if(![self.refresh isDescendantOfView:self.collectionView]) {
        _refresh = [[UIRefreshControl alloc] init];
        [_refresh addTarget:self action:@selector(refreshCollectionView) forControlEvents:UIControlEventValueChanged];
        [_collectionView addSubview:_refresh];
    }
}


- (NSArray *)getAllBreedNames{
    return  _breedNames;
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


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"ShowImageSegue"]){
        ShowImageViewController *showImageViewController = [segue destinationViewController];
        showImageViewController.URLsOfImagesToShow = [_imageURLsToLoad mutableCopy];
        showImageViewController.chosenIndex = _chosenIndex;
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
    [self performSegueWithIdentifier:@"ShowImageSegue" sender:self];
}

@end
