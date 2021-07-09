//
//  AppDelegate.h
//  Surfing Doggo
//
//  Created by Karan Ghorai on 29/06/21.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <UserNotifications/UserNotifications.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;
@property (strong, nonatomic) NSArray *BreedNames;
- (void)saveContext;


@end

