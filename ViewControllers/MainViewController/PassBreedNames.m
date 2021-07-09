//
//  PassBreedNames.m
//  Surfing Doggo
//
//  Created by Karan Ghorai on 04/07/21.
//

#import "PassBreedNames.h"

@implementation PassBreedNames
id selfInstance;

+ (PassBreedNames *)passBreednames{
    
    if (selfInstance == nil){
        selfInstance = [[PassBreedNames alloc] init];
    }
    
    return selfInstance;
}
@end
