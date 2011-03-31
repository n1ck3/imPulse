//
//  MainViewController.h
//  imPulse
//
//  Created by Niclas Helbro on 3/19/11.
//  Copyright 2011 Saddleback College. All rights reserved.
//

#import "FlipsideViewController.h"
#import "SA_OAuthTwitterController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MediaPlayer/MPMediaItem.h>
#import <CoreData/CoreData.h>

@class SA_OAuthTwitterEngine;

@interface MainViewController : UIViewController <SA_OAuthTwitterControllerDelegate, FlipsideViewControllerDelegate, MPMediaPickerControllerDelegate> {
	SA_OAuthTwitterEngine *_engine;
    IBOutlet UITextView *twitterText;
	IBOutlet UIButton *tweetButton;
	MPMusicPlayerController *musicPlayer; 

}


- (IBAction)showInfo:(id)sender;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UITextView *twitterText;
@property (nonatomic, retain) UIButton *tweetButton;
@property (nonatomic, retain) MPMusicPlayerController *musicPlayer;

// When button is pressed
-(IBAction) buttonClicked: (id) sender;
-(IBAction) chooseSongButtonClicked: (id) sender;
-(IBAction) unlinkTwitterButtonClicked:(id) sender;
-(void) setTwitterTextAccordingToPlaybackState; // TODO: this could probably be removed?

@end
