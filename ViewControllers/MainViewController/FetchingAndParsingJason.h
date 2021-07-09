//
//  FetchingAndParsingJason.h
//  Surfing Doggo
//
//  Created by Karan Ghorai on 30/06/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FetchingAndParsingJason : NSObject

+ (void)fetchAllBreedNames :(void(^)(NSArray *breedNames, NSError *error))completion;

+ (void)fetchURLsForBreedName:(NSString *)breedName :(void (^)(NSArray *arrayOfURLsForGivenBreedName, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
