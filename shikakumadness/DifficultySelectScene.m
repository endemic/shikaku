//
//  DifficultySelectScene.m
//  shikakumadness
//
//  Created by Nathan Demick on 3/28/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "DifficultySelectScene.h"


@implementation DifficultySelectScene

+(CCScene *) scene
{
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];
    
    // 'layer' is an autorelease object.
    DifficultySelectScene *layer = [DifficultySelectScene node];
    
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
            iPadOffset = ccp(64, 32);   // 64px gutters on left/right, 32px on top/bottom
        }
        else 
        {
            iPadSuffix = @"";
            fontMultiplier = 1;
            iPadOffset = ccp(0, 0);
        }
        
        // Subscribe to notifications from NSNotificationCenter
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeKitSuccess:) name:@"StoreKitSuccess" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeKitFailure:) name:@"StoreKitFailure" object:nil];
        
        // Set up text-based menu items
        [CCMenuItemFont setFontName:@"insolent.otf"];
        [CCMenuItemFont setFontSize:24.0];
        
        // Add background
        CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
        background.position = ccp(windowSize.width / 2, windowSize.height / 2);
        [self addChild:background];
        
        // Set up a "back" button
        CCMenuItemFont *backButton = [CCMenuItemFont itemFromString:@"back" block:^(id sender) {
            CCTransitionMoveInB *transition = [CCTransitionMoveInB transitionWithDuration:0.5 scene:[TitleScene scene]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        CCMenu *backMenu = [CCMenu menuWithItems:backButton, nil];
        backMenu.position = ccp(backButton.contentSize.width / 2, windowSize.height - backButton.contentSize.height / 2);
        [self addChild:backMenu];
        
        // TODO: Set up a menu based on products returned from the StoreKit singleton
        // A "beginner" option will always be available
        
        CCMenuItemFont *beginnerButton = [CCMenuItemFont itemFromString:@"Beginner" block:^(id sender) {
            CCTransitionMoveInB *transition = [CCTransitionMoveInB transitionWithDuration:0.5 scene:[LevelSelectScene scene]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        
        // Iterate through the products to assign to local variables
        for (SKProduct *product in [StoreKitSingleton sharedStoreKitSingleton].products)
        {
            if ([[product productIdentifier] isEqualToString:@"com.ganbarugames.shikakumadness.easy"])
            {
                easyProduct = product;
            }
            else if ([[product productIdentifier] isEqualToString:@"com.ganbarugames.shikakumadness.medium"])
            {
                mediumProduct = product;
            }
            else if ([[product productIdentifier] isEqualToString:@"com.ganbarugames.shikakumadness.hard"])
            {
                hardProduct = product;
            }
        }
        
        // Check for IAP receipts to "unlock" buttons
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        easyButton = [CCMenuItemFont itemFromString:@"Easy (locked)" block:^(id sender) {
            if ([defaults objectForKey:@"com.ganbarugames.shikakumadness.easy.receipt"])
            {
                CCTransitionMoveInB *transition = [CCTransitionMoveInB transitionWithDuration:0.5 scene:[LevelSelectScene scene]];
                [[CCDirector sharedDirector] replaceScene:transition];
            }
            else
            {
                [[StoreKitSingleton sharedStoreKitSingleton] addToPaymentQueue:easyProduct];
            }
        }];
        
        mediumButton = [CCMenuItemFont itemFromString:@"Medium (locked)" block:^(id sender) {
            if ([defaults objectForKey:@"com.ganbarugames.shikakumadness.medium.receipt"])
            {
                CCTransitionMoveInB *transition = [CCTransitionMoveInB transitionWithDuration:0.5 scene:[LevelSelectScene scene]];
                [[CCDirector sharedDirector] replaceScene:transition];
            }
            else
            {
                [[StoreKitSingleton sharedStoreKitSingleton] addToPaymentQueue:mediumProduct];
            }
        }];
        
        hardButton = [CCMenuItemFont itemFromString:@"Hard (locked)" block:^(id sender) {
            if ([defaults objectForKey:@"com.ganbarugames.shikakumadness.hard.receipt"])
            {
                CCTransitionMoveInB *transition = [CCTransitionMoveInB transitionWithDuration:0.5 scene:[LevelSelectScene scene]];
                [[CCDirector sharedDirector] replaceScene:transition];
            }
            else
            {
                [[StoreKitSingleton sharedStoreKitSingleton] addToPaymentQueue:hardProduct];
            }
        }];
        
        if ([defaults objectForKey:@"com.ganbarugames.shikakumadness.easy.receipt"])
        {
            CCLOG(@"User has easy receipt!");
            easyButton.label.string = @"Easy";
        }
        
        if ([defaults objectForKey:@"com.ganbarugames.shikakumadness.medium.receipt"])
        {
            CCLOG(@"User has medium receipt!");
            mediumButton.label.string = @"Medium";
        }
        
        if ([defaults objectForKey:@"com.ganbarugames.shikakumadness.hard.receipt"])
        {
            CCLOG(@"User has hard receipt!");
            hardButton.label.string = @"Hard";
        }
        
        CCMenu *difficultyMenu = [CCMenu menuWithItems:beginnerButton, easyButton, mediumButton, hardButton, nil];
        difficultyMenu.position = ccp(windowSize.width / 2, windowSize.height / 2);
        [difficultyMenu alignItemsVerticallyWithPadding:20.0];
        [self addChild:difficultyMenu];
	}
	return self;
}

/*! 
 @method storeKitSuccess:(NSNotification *)notification
 @abstract Called when the StoreKitSingleton posts a "success" message
 @result The contents of the menu item that corresponds to the purchased item is updated
 */
- (void)storeKitSuccess:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"StoreKitSuccess"])
    {
        // Modify the UI so that the "locked" menu options appear "unlocked" and can be tapped to access content
        NSDictionary *userInfo = notification.userInfo;
        SKPaymentTransaction *transaction = [userInfo objectForKey:@"transaction"];
        
        NSString *productId = transaction.payment.productIdentifier;
        
        if ([productId isEqualToString:@"com.ganbarugames.shikakumadness.easy"])
        {
            // Change graphic on the "easy" button
            easyButton.label.string = @"Easy";
        }
        else if ([productId isEqualToString:@"com.ganbarugames.shikakumadness.medium"])
        {
            // Change graphic on the "medium" button
            mediumButton.label.string = @"Medium";
        }
        else if ([productId isEqualToString:@"com.ganbarugames.shikakumadness.hard"])
        {
            // Change graphic on the "hard" button
            hardButton.label.string = @"Hard";
        }
        
    }
}

/*! 
 @method storeKitFailure:(NSNotification *)notification
 @abstract Called when the StoreKitSingleton posts a "failure" message
 @result A modal window appears that informs the user there was an error
 */
- (void)storeKitFailure:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"StoreKitFailure"])
    {
        CCLOG(@"Failed purchase!");
        // TODO: Create UIAlertView to inform user of failure
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry, there was a problem completing your purchase. Please try again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)dealloc
{
    // Stop this layer from receiving notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

@end
