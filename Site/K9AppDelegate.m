//
//  K9AppDelegate.m
//  Site
//
//  Created by Navigator on 4/28/15.
//  Copyright (c) 2015 OrangeSoft_Brest. All rights reserved.
//

#import "K9AppDelegate.h"
#import <CoreLocation/CoreLocation.h>

@interface K9AppDelegate ()

@end

@implementation K9AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
   
#ifdef DEBUG
//    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"first_run"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:@YES                        forKey:@"first_run"];
        [[NSUserDefaults standardUserDefaults] setValue:@"user"                     forKey:DEFAULTS_LOGIN];
        [[NSUserDefaults standardUserDefaults] setValue:@"pass"                     forKey:DEFAULTS_PASSWORD];
        [[NSUserDefaults standardUserDefaults] setValue:@"http://api.lk.yakimuk.name:8080,http://api.lk.yakimuk.name:8080" forKey:DEFAULTS_DOMAINS];
        [[NSUserDefaults standardUserDefaults] setValue:@"/settings/site-enable"    forKey:DEFAULTS_URL_ACTIVE];
        [[NSUserDefaults standardUserDefaults] setValue:@"/settings/user-enable"    forKey:DEFAULTS_URL_ACCESS];
        [[NSUserDefaults standardUserDefaults] setValue:@"/settings/status"         forKey:DEFAULTS_URL_STATUS];
    }
#endif
    
    [self getCityWithGeocoder];
    
    
    
    return YES;
}

- (void)getCityWithGeocoder
{
    CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
    CLLocation* currentLocation = [[CLLocation alloc] initWithLatitude:54.846255 longitude:32.772302];
    
    [reverseGeocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!error && placemarks.count > 0) {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             NSString* locality = placemark.locality;
             NSString* sublocality = placemark.subLocality;
             NSLog(@"%@ %@", locality, sublocality);
         }
    }];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
