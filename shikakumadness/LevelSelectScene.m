//
//  LevelSelectScene.m
//  Shikaku Madness
//
//  Created by Nathan Demick on 3/24/12.
//  Copyright 2012 Ganbaru Games. All rights reserved.
//

#import "LevelSelectScene.h"

@implementation LevelSelectScene

+(CCScene *) scene
{
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];

    // 'layer' is an autorelease object.
    LevelSelectScene *layer = [LevelSelectScene node];

    // add layer as a child to scene
    [scene addChild:layer];

    // return the scene
    return scene;
}

// on "init" you need to initialize your instance
- (id)init
{
	// always call "super" init
	if ((self = [super init]))
	{
        // Get window size
        windowSize = [CCDirector sharedDirector].winSize;
        
        // Determine offset of grid
        if ([GameSingleton sharedGameSingleton].isPad)
        {
            iPadSuffix = @"-ipad";
            fontMultiplier = 2;
            previewBlockSize = 52;
            iPadOffset = ccp(64, 32);   // 64px gutters on left/right, 32px on top/bottom
        }
        else 
        {
            iPadSuffix = @"";
            fontMultiplier = 1;
            previewBlockSize = 26;
            iPadOffset = ccp(0, 0);
        }
        
        // Add background
        CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
        background.position = ccp(windowSize.width / 2, windowSize.height / 2);
        [self addChild:background];
        
        // Add the background for the level preview
        CCSprite *previewBackground = [CCSprite spriteWithFile:@"preview-background.png"];
        previewBackground.position = ccp(windowSize.width / 2, windowSize.height / 1.5);
        [self addChild:previewBackground];
        
        // Determine the (0, 0) offset for the grid
        gridOffset = ccp(previewBackground.position.x - previewBackground.contentSize.width / 2, previewBackground.position.y - previewBackground.contentSize.height / 2);
        
        // Get list of levels!
        levels = [[NSMutableArray arrayWithArray:[self getDocumentsDirectoryContents]] retain];
        
        // Create array to store clues that are displayed w/ level preview
        clues = [[NSMutableArray array] retain];
        
        // Set up previous/next buttons here to cycle thru files
        selectedLevelIndex = 0;
        [GameSingleton sharedGameSingleton].levelToLoad = [levels objectAtIndex:selectedLevelIndex];
        
        // Immediately update the label's contents
        [self updateLevelPreview];
        
        CCMenuItemImage *prevButton = [CCMenuItemImage itemFromNormalImage:@"prev-button.png" selectedImage:@"prev-button.png" block:^(id sender) {
            if (selectedLevelIndex > 0)
            {
                // Decrement the "selected" index, update the singleton to know which level to load, then show the user
                selectedLevelIndex--;
                [GameSingleton sharedGameSingleton].levelToLoad = [levels objectAtIndex:selectedLevelIndex];
                [self updateLevelPreview];
                
                [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
            }
        }];
        
        CCMenuItemImage *nextButton = [CCMenuItemImage itemFromNormalImage:@"next-button.png" selectedImage:@"next-button.png" block:^(id sender) {
            if (selectedLevelIndex < [levels count] - 1)
            {
                // Increment the "selected" index, update the singleton to know which level to load, then show the user
                selectedLevelIndex++;
                [GameSingleton sharedGameSingleton].levelToLoad = [levels objectAtIndex:selectedLevelIndex];
                [self updateLevelPreview];
                
                [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
            }
        }];
        
        CCMenu *navMenu = [CCMenu menuWithItems:prevButton, nextButton, nil];
        navMenu.position = ccp(windowSize.width / 2, nextButton.contentSize.height / 1.5);
        [navMenu alignItemsHorizontallyWithPadding:20.0];
        [self addChild:navMenu];
        
        // Set up the solve/edit buttons
        CCMenuItemImage *solveButton = [CCMenuItemImage itemFromNormalImage:@"solve-button.png" selectedImage:@"solve-button.png" block:^(id sender) {
            CCTransitionMoveInB *transition = [CCTransitionMoveInB transitionWithDuration:0.5 scene:[GameScene scene]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        
        CCMenuItemImage *editButton = [CCMenuItemImage itemFromNormalImage:@"edit-button.png" selectedImage:@"edit-button.png" block:^(id sender) {
            CCTransitionMoveInB *transition = [CCTransitionMoveInB transitionWithDuration:0.5 scene:[EditorScene scene]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        
        CCMenu *actionsMenu = [CCMenu menuWithItems:solveButton, editButton, nil];
        actionsMenu.position = ccp(windowSize.width / 2, navMenu.position.y + solveButton.contentSize.height * 2);
        [actionsMenu alignItemsVertically];
        [self addChild:actionsMenu];
        
        // Set up a "back" button
        [CCMenuItemFont setFontName:@"insolent.otf"];
        [CCMenuItemFont setFontSize:24.0];
        CCMenuItemFont *backButton = [CCMenuItemFont itemFromString:@"back" block:^(id sender) {
            CCTransitionMoveInB *transition = [CCTransitionMoveInB transitionWithDuration:0.5 scene:[TitleScene scene]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        CCMenu *backMenu = [CCMenu menuWithItems:backButton, nil];
        backMenu.position = ccp(backButton.contentSize.width / 2, windowSize.height - backButton.contentSize.height / 2);
        [self addChild:backMenu];
	}
	return self;
}

/*! 
 @method shareLevel:(NSString *)filename
 @abstract Sends a level to a web service
 @result Whether the request was successful or not
 */
- (void)shareLevel:(NSString *)filename
{
    NSURL *url = [NSURL URLWithString:@"http://ganbarugames.com/shikaku-madness/post.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSData dataWithContentsOfFile:filename]];
    
    // Init var that will store response
    responseData = [[NSMutableData data] retain];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
    CCLOG(@"NSURLConnection didReceiveResponse!");
    [responseData setLength:0]; 
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
    CCLOG(@"NSURLConnection didReceiveData!");
    [responseData appendData:data];
}

/*! 
 @method connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
 @abstract NSURLConnection delegate methdo
 @result Executes when "sharing" connection fails
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    CCLOG(@"Connection failed! %@", error);
}

/*! 
 @method connectionDidFinishLoading:(NSURLConnection *)connection
 @abstract NSURLConnection delegate method
 @result Executes when "sharing" connection completes
 */
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    CCLOG(@"Connection finished! %@", connection);
    
    if ([TWTweetComposeViewController class])
    {
        if ([TWTweetComposeViewController canSendTweet])
        {
            CCLOG(@"Reponse from server: %@", responseData);
            
            TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
            [tweetSheet setInitialText: @"Try solving the puzzle I just created in #shikakumadness! "];
            
            // Create an additional UIViewController to attach the TWTweetComposeViewController to
			myViewController = [[UIViewController alloc] init];
			
			// Add the temporary UIViewController to the main OpenGL view
			[[[CCDirector sharedDirector] openGLView] addSubview:myViewController.view];
			
            [myViewController presentModalViewController:tweetSheet animated:YES];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Can't Send Tweet!" message:@"You can't send a tweet right now, make sure your device has an internet connection and you have  at least one Twitter account setup" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }
}

/**
 * Depending on the selected level, a "minimap" or preview or something will be updated here
 */
- (void)updateLevelPreview
{
    // Clear out previous clues
    for (int i = 0; i < [clues count]; i++)
    {
        [self removeChild:[clues objectAtIndex:i] cleanup:YES];
    }
    [clues removeAllObjects];
    
    // Load level dictionary
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // TODO: Store the documents directory string so you don't have to keep getting it here
    NSString *pathToFile = [documentsDirectory stringByAppendingPathComponent:[GameSingleton sharedGameSingleton].levelToLoad];
    
    NSDictionary *level = [NSDictionary dictionaryWithContentsOfFile:pathToFile];
    
    // Get out the "clue" objects
    NSArray *c = [level objectForKey:@"clues"];
    
    // Iterate and draw
    for (int i = 0; i < [c count]; i++)
    {
        NSArray *val = [c objectAtIndex:i];
        
        int value = [(NSNumber *)[val objectAtIndex:2] intValue],
            x = [(NSNumber *)[val objectAtIndex:0] intValue],
            y = [(NSNumber *)[val objectAtIndex:1] intValue];
        
        Clue *c = [Clue clueWithNumber:value];
        c.position = ccp(x * previewBlockSize + gridOffset.x + previewBlockSize / 2, y * previewBlockSize + gridOffset.y + previewBlockSize / 2);
        c.scale = 0.8125;
        [self addChild:c z:2];
        
        [clues addObject:c];
    }
}

/**
 * Returns an array of all files in the "Documents" directory
 */
- (NSArray *)getDocumentsDirectoryContents
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSError *error;
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    
    NSLog(@"%@", documentsDirectory);
    return directoryContent;
}

- (void)dealloc
{
    [levels release];
    [clues release];
    [responseData release];
    
    [super dealloc];
}

@end
