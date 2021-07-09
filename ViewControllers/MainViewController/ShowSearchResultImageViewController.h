//
//  ShowSearchResultImageViewController.h
//  Surfing Doggo
//
//  Created by Karan Ghorai on 05/07/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShowSearchResultImageViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) NSArray *imageURLs;
@property NSInteger chosenIndex;

@end

NS_ASSUME_NONNULL_END
