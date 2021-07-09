//
//  ShowImageViewController.h
//  Surfing Doggo
//
//  Created by Karan Ghorai on 03/07/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShowImageViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) NSMutableArray *URLsOfImagesToShow;
@property NSInteger chosenIndex;
@end

NS_ASSUME_NONNULL_END
