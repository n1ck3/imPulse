//
//  MainViewController.h
//  imPulse
//
//  Created by Niclas Helbro on 3/19/11.
//  Copyright 2011 Saddleback College. All rights reserved.
//

#import "FlipsideViewController.h"

#import <CoreData/CoreData.h>

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate> {

}


- (IBAction)showInfo:(id)sender;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
