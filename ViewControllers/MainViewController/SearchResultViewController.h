//
//  SearchResultViewController.h
//  Surfing Doggo
//
//  Created by Karan Ghorai on 05/07/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchResultViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) NSString *breedNameSelected;
@end

NS_ASSUME_NONNULL_END
