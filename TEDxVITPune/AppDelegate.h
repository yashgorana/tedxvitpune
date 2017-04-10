//
//  AppDelegate.h
//  TEDxVITPune
//
//  Created by Yash Gorana on 13/01/16.
//  Copyright © 2016 Yash Gorana. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#define kScannedAttendees        @"scannedAttendees"

#define kTypeEntry                  0x00
#define kTypeBreakfast              0x01
#define kTypeLunch                  0x02
#define kTypeHightea                0x04

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSMutableDictionary *TEDxVITPuneAttendees;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (NSInteger) enterDataWithAttendeeInfo:(NSDictionary*)info timestamp:(NSString*)timestamp scanType:(NSInteger)type;
- (NSInteger) getScanCountForTEDxID:(NSString*)tedxID forScanType:(NSInteger)type;

- (void) logData;
- (void) resetCoreData;
@end

