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
            previewBlockSize = 40;
            iPadOffset = ccp(64, 32);   // 64px gutters on left/right, 32px on top/bottom
        }
        else 
        {
            iPadSuffix = @"";
            fontMultiplier = 1;
            previewBlockSize = 20;
            iPadOffset = ccp(0, 0);
        }
        
        // Add background
        CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
        background.position = ccp(windowSize.width / 2, windowSize.height / 2);
        [self addChild:background];
        
        // Get list of levels!
        levels = [[NSMutableArray arrayWithArray:[self getDocumentsDirectoryContents]] retain];
                
        // Set up "back" button
        CCMenuItemImage *backButton = [CCMenuItemImage itemFromNormalImage:@"back-button.png" selectedImage:@"back-button.png" block:^(id sender) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
            
            CCTransitionMoveInT *transition = [CCTransitionMoveInT transitionWithDuration:0.5 scene:[TitleScene scene]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        
        // Set up "new" button
        CCMenuItemImage *newButton = [CCMenuItemImage itemFromNormalImage:@"new-button.png" selectedImage:@"new-button.png" block:^(id sender) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
            
            // Blanking out this var means the editor creates a new puzzle
            [GameSingleton sharedGameSingleton].levelToLoad = @"";
            
            CCTransitionMoveInT *transition = [CCTransitionMoveInT transitionWithDuration:0.5 scene:[EditorScene scene]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        
        CCMenu *topMenu = [CCMenu menuWithItems:backButton, newButton, nil];
        [topMenu alignItemsHorizontallyWithPadding:120 * fontMultiplier];
        topMenu.position = ccp(windowSize.width / 2, windowSize.height - (20 * fontMultiplier) - iPadOffset.y);
        [self addChild:topMenu];
        
        if ([levels count] > 0)
        {
            // Create an array of layers with level preview contents
            scrollLayer = [CCScrollLayer nodeWithLayers:[self createPreviewLayers] widthOffset:windowSize.width / 4];
            scrollLayer.delegate = self;
            scrollLayer.minimumTouchLengthToSlide = 5.0;
            scrollLayer.minimumTouchLengthToChangePage = 10.0;
            scrollLayer.marginOffset = windowSize.width / 2;   // Offset that can be used to let user see empty space over first or last page
            scrollLayer.stealTouches = NO;
            scrollLayer.showPagesIndicator = NO;
            [self addChild:scrollLayer z:4];
            
            // Set up previous/next buttons here to cycle thru files
            selectedLevelIndex = 0;
            [GameSingleton sharedGameSingleton].levelToLoad = [levels objectAtIndex:selectedLevelIndex];
            
            // Set up the solve/edit buttons
            CCMenuItemImage *solveButton = [CCMenuItemImage itemFromNormalImage:@"solve-button.png" selectedImage:@"solve-button.png" block:^(id sender) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
                
                CCTransitionMoveInB *transition = [CCTransitionMoveInB transitionWithDuration:0.5 scene:[GameScene scene]];
                [[CCDirector sharedDirector] replaceScene:transition];
            }];
            
            CCMenuItemImage *editButton = [CCMenuItemImage itemFromNormalImage:@"edit-button.png" selectedImage:@"edit-button.png" block:^(id sender) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
                
                CCTransitionMoveInB *transition = [CCTransitionMoveInB transitionWithDuration:0.5 scene:[EditorScene scene]];
                [[CCDirector sharedDirector] replaceScene:transition];
            }];
            
            CCMenuItemImage *shareButton = [CCMenuItemImage itemFromNormalImage:@"share-button.png" selectedImage:@"share-button.png" block:^(id sender) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
                
                // Load level dictionary
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                
                // TODO: Store the documents directory string so you don't have to keep getting it here
                NSString *pathToFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/%@", [GameSingleton sharedGameSingleton].difficulty, [GameSingleton sharedGameSingleton].levelToLoad]];
                
                [self shareLevel:pathToFile];
            }];
            
            CCMenuItemImage *deleteButton = [CCMenuItemImage itemFromNormalImage:@"delete-button.png" selectedImage:@"delete-button.png" block:^(id sender) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
                
                // TODO: put in confirmation window here
                
                // Load level dictionary
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                
                NSString *pathToFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/%@", [GameSingleton sharedGameSingleton].difficulty, [GameSingleton sharedGameSingleton].levelToLoad]];
                [[NSFileManager defaultManager] removeItemAtPath:pathToFile error:nil];
                
                // Remove the layer
                [scrollLayer removePageWithNumber:selectedLevelIndex];
                
                // Reset the "index" & scroll to previous layer if possible
                if (selectedLevelIndex > 0)
                {
                    selectedLevelIndex--;
                }
                
                [scrollLayer selectPage:selectedLevelIndex];
            }];
            
            CCMenu *leftMenu = [CCMenu menuWithItems:editButton, deleteButton, nil];
            [leftMenu alignItemsVerticallyWithPadding:10.0 * fontMultiplier];
            leftMenu.position = ccp(85 * fontMultiplier + iPadOffset.x, 100 * fontMultiplier + iPadOffset.y);
            [self addChild:leftMenu];
            
            CCMenu *rightMenu = [CCMenu menuWithItems:solveButton, shareButton, nil];
            [rightMenu alignItemsVerticallyWithPadding:10.0 * fontMultiplier];
            rightMenu.position = ccp(235 * fontMultiplier + iPadOffset.x, 100 * fontMultiplier + iPadOffset.y);
            [self addChild:rightMenu];
        }
        else 
        {
            CCShadowLabelTTF *noLevelsLabel = [CCShadowLabelTTF labelWithString:@"YOU HAVEN'T CREATED ANY PUZZLES YET!" dimensions:CGSizeMake(windowSize.width - 20 * fontMultiplier, windowSize.height / 2) alignment:CCTextAlignmentLeft fontName:@"insolent.otf" fontSize:32.0 * fontMultiplier];
            noLevelsLabel.position = ccp(windowSize.width / 2, windowSize.height / 2);
            [self addChild:noLevelsLabel];
        }
	}
	return self;
}


/**
 * Depending on the selected level, a "minimap" or preview or something will be updated here
 */
/*
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
    NSString *pathToFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/%@", [GameSingleton sharedGameSingleton].difficulty, [GameSingleton sharedGameSingleton].levelToLoad]];
    
    // Get JSON data out of file, and parse into dictionary
    NSData *json = [NSData dataWithContentsOfFile:pathToFile];
    NSError *error = nil;
    NSDictionary *level = [NSDictionary dictionaryWithJSONData:json error:&error];
    
    if (error != nil)
    {
        CCLOG(@"Error deserializing JSON data: %@", error);
    }
    
    //    NSDictionary *level = [NSDictionary dictionaryWithContentsOfFile:pathToFile];
    
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
*/

/**
 * Depending on the selected level, a "minimap" or preview or something will be updated here
 */
- (NSArray *)createPreviewLayers
{
    // Load level dictionary
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:[GameSingleton sharedGameSingleton].difficulty];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    NSMutableArray *returnArray = [NSMutableArray array];
    
    for (int i = 0; i < [directoryContent count]; i++)
    {
        // Create a layer
        CCLayer *layer = [CCLayer node];
        
        CCSprite *previewBackground = [CCSprite spriteWithFile:@"preview-background.png"];
        previewBackground.position = ccp(windowSize.width / 2, windowSize.height - 180 * fontMultiplier - iPadOffset.y);
        [layer addChild:previewBackground];
        
        NSString *pathToFile = [documentsDirectory stringByAppendingPathComponent:[directoryContent objectAtIndex:i]];
        
        // Get JSON data out of file, and parse into dictionary
        NSData *json = [NSData dataWithContentsOfFile:pathToFile];
        NSDictionary *level = [NSDictionary dictionaryWithJSONData:json error:nil];
        
        // Get out the "clue" objects
        NSArray *c = [level objectForKey:@"clues"];
        
        // Iterate and draw
        for (int j = 0; j < [c count]; j++)
        {
            NSArray *val = [c objectAtIndex:j];
            
            int value = [(NSNumber *)[val objectAtIndex:2] intValue],
                x = [(NSNumber *)[val objectAtIndex:0] intValue],
                y = [(NSNumber *)[val objectAtIndex:1] intValue];
            
            Clue *c = [Clue clueWithNumber:value];
            c.position = ccp(x * previewBlockSize + previewBlockSize / 2, y * previewBlockSize + previewBlockSize / 2);
            c.scale = 0.625;
            [previewBackground addChild:c];
        }
        
        [returnArray addObject:layer];
    }
    
    return returnArray;
}

/**
 * Returns an array of all files in the "Documents" directory
 */
- (NSArray *)getDocumentsDirectoryContents
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:[GameSingleton sharedGameSingleton].difficulty];
    
    NSError *error;
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    
//    NSLog(@"%@", documentsDirectory);
    return directoryContent;
}

/*! 
 @method shareLevel:(NSString *)filename
 @abstract Sends a level to a web service
 @result Whether the request was successful or not
 */
- (void)shareLevel:(NSString *)filename
{
    NSURL *url = [NSURL URLWithString:@"http://localhost:3000/puzzles.json"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    [request setHTTPBody:[NSData dataWithContentsOfFile:filename]];
    NSError *error = nil;
    NSString *body = [NSString stringWithFormat:@"puzzle[data]=%@", [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:&error]];
    
    CCLOG(@"Request body: %@", body);
    if (error != nil)
    {
        CCLOG(@"Error! %@", error);
    }
    
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Init var that will store response
    responseData = [[NSMutableData data] retain];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
}

#pragma mark -
#pragma mark CCScrollLayer delegate methods

- (void)scrollLayerScrollingStarted:(CCScrollLayer *)sender
{
    CCLOG(@"Started scrolling");
}

- (void)scrollLayer:(CCScrollLayer *)sender scrolledToPageNumber:(int)page
{
    CCLOG(@"Scrolled to page %i", page);
    selectedLevelIndex = page;
    [GameSingleton sharedGameSingleton].levelToLoad = [levels objectAtIndex:selectedLevelIndex];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
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
    // TODO: allow user to decide to share via email or twitter
//    CCLOG(@"Connection finished! %@", connection);
//    CCLOG(@"Reponse from server: %@", responseData);
    NSString *responseString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
    CCLOG(@"Response from server: %@", responseString);
    
    // Parse the response string
    NSDictionary *json = [NSDictionary dictionaryWithJSONData:responseData error:nil];
    
    NSString *urlToLevel = [NSString stringWithFormat:@"http://shikaku.ganbarugames.com/%@", [json objectForKey:@"id"]];
    
    if ([TWTweetComposeViewController class] && false)
    {
        if ([TWTweetComposeViewController canSendTweet])
        {
            TWTweetComposeViewController *tweetSheet = [[[TWTweetComposeViewController alloc] init] autorelease];
            [tweetSheet setInitialText: @"Try solving the puzzle I just created in #shikakumadness!"];
            [tweetSheet addURL:[NSURL URLWithString:urlToLevel]];
            
            // Create an additional UIViewController to attach the TWTweetComposeViewController to
			myViewController = [[[UIViewController alloc] init] autorelease];
			
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
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[[MFMailComposeViewController alloc] init] autorelease];
        
        mailer.mailComposeDelegate = self;
        
        [mailer setSubject:@"Try solving this shikaku puzzle!"];
        
//        NSArray *toRecipients = [NSArray arrayWithObjects:@"fisrtMail@example.com", @"secondMail@example.com", nil];
//        [mailer setToRecipients:toRecipients];
        
        NSString *emailBody = [NSString stringWithFormat:@"I created a puzzle in Shikaku Madness for you to solve. Tap this link to play it! %@", urlToLevel];
        [mailer setMessageBody:emailBody isHTML:NO];
        
        myViewController = [[[UIViewController alloc] init] autorelease];
        
        // Add the temporary UIViewController to the main OpenGL view
        [[[CCDirector sharedDirector] openGLView] addSubview:myViewController.view];
        
        if ([GameSingleton sharedGameSingleton].isPad)
        {
            mailer.modalPresentationStyle = UIModalPresentationPageSheet;
        }
        
        [myViewController presentModalViewController:mailer animated:YES];
    }
    else 
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Can't Send Email!" message:@"You can't send an email right now, make sure your device has an internet connection!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark -
#pragma mark MFMailComposeViewController delegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    
    // Remove the mail view
    [myViewController dismissModalViewControllerAnimated:YES];
}

- (void)dealloc
{
    [levels release];
//    [clues release];
    [responseData release];
    
    [super dealloc];
}

@end
