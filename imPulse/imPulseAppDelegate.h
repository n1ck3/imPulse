//
//  imPulseAppDelegate.h
//  imPulse
//
//  Created by Niclas Helbro on 3/19/11.
//  Copyright 2011 Saddleback College. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;

@interface imPulseAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property (nonatomic, retain) IBOutlet MainViewController *mainViewController;

@end
