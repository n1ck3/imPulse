//
//  MainViewController.m
//  imPulse
//
//  Created by Niclas Helbro on 3/19/11.
//  Copyright 2011 Saddleback College. All rights reserved.
//

#import "MainViewController.h"
#import "SA_OAuthTwitterEngine.h"

#define kOAuthConsumerKey				@"aYYW3aVNyuOd0mZXwGvjQ"
#define kOAuthConsumerSecret			@"NeqlwlnT2NpS7ipQG3hBs6NnhLNJT2dEz4H43MVtM"


@implementation MainViewController

@synthesize managedObjectContext=_managedObjectContext;
@synthesize twitterText;
@synthesize musicPlayer;
@synthesize tweetButton;

//=============================================================================================================================
#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject: data forKey: @"authData"];
	[defaults synchronize];
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
	return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
}

//=============================================================================================================================
#pragma mark SA_OAuthTwitterControllerDelegate
- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username {
	NSLog(@"Authenicated for %@", username);
}

- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller {
	NSLog(@"Authentication Failed!");
}

- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller {
	NSLog(@"Authentication Canceled.");
}

//=============================================================================================================================
#pragma mark TwitterEngineDelegate
- (void) requestSucceeded: (NSString *) requestIdentifier {
	NSLog(@"Request %@ succeeded", requestIdentifier);
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
	NSLog(@"Request %@ failed with error: %@", requestIdentifier, error);
}

//=============================================================================================================================
#pragma mark ViewController Stuff

- (void) viewDidAppear: (BOOL)animated {
    
	if (_engine) return;
	_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
	_engine.consumerKey = kOAuthConsumerKey;
	_engine.consumerSecret = kOAuthConsumerSecret;
	
	UIViewController			*controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: _engine delegate: self];
	
	if (controller)
		[self presentModalViewController: controller animated: YES];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
 NSLog(@"viewDidLoad()");
 [tweetButton setEnabled: FALSE];
 
 musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
 
 // Set the start text..
 [self setTwitterTextAccordingToPlaybackState];
 
 // Subscribe for notifications of playback changes
 // TODO: Put this in a separate function.
 NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
 
 [notificationCenter
 addObserver: self
 selector:    @selector (handleNowPlayingItemChanged:)
 name:        MPMusicPlayerControllerNowPlayingItemDidChangeNotification
 object:      musicPlayer];
 
 
 [notificationCenter
 addObserver: self
 selector:    @selector (handlePlaybackStateChanged:)
 name:        MPMusicPlayerControllerPlaybackStateDidChangeNotification
 object:      musicPlayer];
 
 [musicPlayer beginGeneratingPlaybackNotifications];

}


- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)showInfo:(id)sender
{    
    FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
    controller.delegate = self;
    
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
    
    [controller release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name:           MPMusicPlayerControllerNowPlayingItemDidChangeNotification
     object:         musicPlayer];
	
	[[NSNotificationCenter defaultCenter]
	 removeObserver: self
	 name:           MPMusicPlayerControllerPlaybackStateDidChangeNotification
	 object:         musicPlayer];
	[musicPlayer endGeneratingPlaybackNotifications];
	
	[musicPlayer release];
	[twitterText release];
	
	[_engine release];
	[super dealloc];
    
    [_managedObjectContext release];
    [super dealloc];
}

// Sets the twitter text depending if a song is playing or not.
-(void)setTwitterText 
{
	MPMediaItem *currentItem = musicPlayer.nowPlayingItem;
	if(currentItem == nil)
	{
		twitterText.text = @"No song is currently playing. Please start a song and then start the program to tweet.";
		[tweetButton setEnabled: FALSE];
	}
	else 
	{
		[self composeTwitterText: currentItem];
		
	}
	
}

- (void) composeTwitterText: (MPMediaItem *) musicItem
{
	
	NSString *artistSpaces = [musicItem valueForProperty:MPMediaItemPropertyArtist];
	NSString *artistNoSpaces = [artistSpaces stringByReplacingOccurrencesOfString:@" " withString:@"+"];
	
	NSString *titleSpaces = [musicItem valueForProperty:MPMediaItemPropertyTitle];
	NSString *titleNoSpaces = [titleSpaces stringByReplacingOccurrencesOfString:@" " withString:@"+"];
	
	NSString *rating = [[musicItem valueForProperty:MPMediaItemPropertyRating] stringValue];
	
	NSString *longGoogleUrl = [NSString stringWithFormat:
                               @"http://tinyurl.com/api-create.php?url=http://google.com/search?btnI=1&q=youtube+%@+%@",
                               artistNoSpaces, titleNoSpaces];
	
	NSURL *tinyUrl = [NSURL URLWithString: longGoogleUrl];
	NSString *link = [NSString stringWithContentsOfURL:tinyUrl encoding:NSASCIIStringEncoding error:nil];
	
	[tweetButton setEnabled: TRUE];
	
	twitterText.text = [NSString stringWithFormat:
                        @"Listening to %@ by %@, %@/5. %@ #imPulse", 
                        titleSpaces, artistSpaces, rating, link];
}

// When the playback state changes, we get called here
- (void) handlePlaybackStateChanged: (id) notification 
{	
	[self setTwitterTextAccordingToPlaybackState];
}


- (void) setTwitterTextAccordingToPlaybackState
{
	MPMusicPlaybackState playbackState = [musicPlayer playbackState];
    
	if (playbackState == MPMusicPlaybackStatePlaying) 
	{
		[self setTwitterText];
	} 
	else if (playbackState == MPMusicPlaybackStateStopped ||
             playbackState == MPMusicPlaybackStatePaused ||
             playbackState == MPMusicPlaybackStateInterrupted) 
	{
		twitterText.text = @"No song is currently playing. Please start a song and then start the program to tweet.";
		[tweetButton setEnabled: FALSE];
	}
}

// When the now-playing item changes, update the media item artwork and the now-playing label.
- (void) handleNowPlayingItemChanged: (id) notification 
{
	[self setTwitterTextAccordingToPlaybackState]; 
}




@end
