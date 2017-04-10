//
//  AppDelegate.m
//  TEDxVITPune
//
//  Created by Yash Gorana on 13/01/16.
//  Copyright © 2016 Yash Gorana. All rights reserved.
//

#import "AppDelegate.h"
#import "ScanDataTableViewController.h"

@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Global list of scanned attendees
    self.TEDxVITPuneAttendees = [self decodeDictionaryFromDocumentsDirectoryFile:kScannedAttendees];
    if (self.TEDxVITPuneAttendees == nil) {
        self.TEDxVITPuneAttendees = [[NSMutableDictionary alloc] init];
    }
    return YES;
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
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void) encodeDictionary:(NSMutableDictionary*)dict toDocumentsDirectoryFile:(NSString*)fileName {
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:fileName];
    [dict writeToFile:filePath atomically:NO];
}

- (NSMutableDictionary*) decodeDictionaryFromDocumentsDirectoryFile:(NSString*)fileName {
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:fileName];
    return [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
}

#pragma mark - Core Data stack
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSInteger) getScanCountForTEDxID:(NSString*)tedxID forScanType:(NSInteger)type {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"TEDxQRScan"];
    request.predicate = [NSPredicate predicateWithFormat:@"(tedxID) == %@ AND (type == %ld)", tedxID, type];
    NSError *error = nil;
    NSArray *result=[self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (error) {
        return -1;
    }
    return result.count;
}

- (NSInteger) enterDataWithAttendeeInfo:(NSDictionary*)info timestamp:(NSString*)timestamp scanType:(NSInteger)type {
    NSString *tedxID =[info objectForKey:@"id"];
    NSString *name = [info objectForKey:@"name"];
    NSString *surname = [info objectForKey:@"surname"];
    
    if (info == nil || tedxID == nil || name == nil || surname == nil) {
        return -1;
    }
    
    // Add to TEDxVITPuneAttendees mutable dictionary and persist it
    [self.TEDxVITPuneAttendees setObject:[NSString stringWithFormat:@"%@ %@", name, surname] forKey:tedxID];
    [self encodeDictionary:self.TEDxVITPuneAttendees toDocumentsDirectoryFile:kScannedAttendees];
    
    // Add to core data
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"TEDxQRScan" inManagedObjectContext:self.managedObjectContext];
    NSManagedObject *entry = [[NSManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    [entry setValue:tedxID forKey: @"tedxID"];
    [entry setValue:timestamp forKey: @"timestamp"];
    [entry setValue:[NSNumber numberWithInteger:type] forKey: @"type"];

    NSError *error = nil;
    if ( ![entry.managedObjectContext save:&error] ) {
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    } else {
        NSLog(@"Type-%ld scan for %@", type, [self.TEDxVITPuneAttendees objectForKey:tedxID]);
        [self saveContext];
    }
    
    return 0;
}

-(void) logData {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TEDxQRScan" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
        
    } else {
        if (result.count > 0) {
            for (NSManagedObject *entry in result) {
                NSLog(@"%@ -> %@ @ %@", [self.TEDxVITPuneAttendees objectForKey:[entry valueForKey:@"tedxID"]], [entry valueForKey:@"type"], [entry valueForKey:@"timestamp"]);
            }
        }
    }

}

- (void) resetCoreData {
    NSPersistentStore *store = [self.persistentStoreCoordinator.persistentStores lastObject];
    NSError *error;
    NSURL *storeURL = store.URL;
    NSPersistentStoreCoordinator *storeCoordinator = self.persistentStoreCoordinator;
    [storeCoordinator removePersistentStore:store error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
    //    Then, just add the persistent store back to ensure it is recreated properly.
    if (![self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *scannedAttendees = [documentsPath stringByAppendingPathComponent:kScannedAttendees];
    if([fileManager removeItemAtPath:scannedAttendees error:&error]) {
        NSLog(@"Could not delete %@ -:%@ ", kScannedAttendees, [error localizedDescription]);
    }
    error = nil;
    
    
    [NSThread sleepForTimeInterval:1];
    exit(0);
}


- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "edu.self.TEDxVITPune" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TEDxVITPune" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TEDxVITPune.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
