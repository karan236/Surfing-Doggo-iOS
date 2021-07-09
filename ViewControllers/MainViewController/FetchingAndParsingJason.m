//
//  FetchingAndParsingJason.m
//  Surfing Doggo
//
//  Created by Karan Ghorai on 30/06/21.
//

#import "FetchingAndParsingJason.h"

@implementation FetchingAndParsingJason

+ (void)fetchAllBreedNames :(void (^)(NSArray *breedNames, NSError *error))completion {
    
    NSMutableArray *breedNames = [[NSMutableArray alloc] init];
    
    NSURL *url = [[NSURL alloc] initWithString:@"https://dog.ceo/api/breeds/list/all"];
    
    [[NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                
            NSError *err;
            NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
        
        for (NSString *breedName in parsedData[@"message"]){
                [breedNames addObject:breedName];
            for (NSString *subBreedName in parsedData[@"message"][breedName]){
                [breedNames addObject:[NSString stringWithFormat:@"%@-%@", breedName, subBreedName]];
            }
        }
        
        completion(breedNames, err);
        
    }] resume];
    
}


+ (void)fetchURLsForBreedName:(NSString *)breedName :(void (^)(NSArray *arrayOfURLsForGivenBreedName, NSError *error))completion {
    
    NSMutableArray *arrayOfURLsForGivenBreedName = [[NSMutableArray alloc] init];
    
    NSMutableString *URLToFetchURLsForGivenBreedName = [[NSMutableString alloc] init];
    [URLToFetchURLsForGivenBreedName appendString: @"https://dog.ceo/api/breed/"];
    
    if ([breedName rangeOfString:@"-"].location == NSNotFound) {
        
        [URLToFetchURLsForGivenBreedName appendString:(NSMutableString *)breedName];
        
    }
    else {
        
        [URLToFetchURLsForGivenBreedName appendString:(NSMutableString *)[breedName substringToIndex: [breedName rangeOfString:@"-"].location]];
        [URLToFetchURLsForGivenBreedName appendString:@"/"];
        [URLToFetchURLsForGivenBreedName appendString:[breedName substringFromIndex:[breedName rangeOfString:@"-"].location + 1]];
        
    }
    
    [URLToFetchURLsForGivenBreedName appendString:@"/images"];
    
    NSURL *url = [[NSURL alloc] initWithString:URLToFetchURLsForGivenBreedName];
    
    [[NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                
        NSError *err;
        NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
        
        for (NSString *url in parsedData[@"message"]) {
            [arrayOfURLsForGivenBreedName addObject:url];
        }
        
        completion(arrayOfURLsForGivenBreedName, err);
        
    }] resume];
}

@end
