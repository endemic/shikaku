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
        
        CCMenuItemFont *easyButton = [CCMenuItemFont itemFromString:@"Easy" block:^(id sender) {
            // TODO: Check user defaults for receipt to see if we need to purchase when user taps
            [[StoreKitSingleton sharedStoreKitSingleton] addToPaymentQueue:easyProduct];
        }];
        
        CCMenuItemFont *mediumButton = [CCMenuItemFont itemFromString:@"Medium" block:^(id sender) {
            // TODO: Check user defaults for receipt to see if we need to purchase when user taps
            [[StoreKitSingleton sharedStoreKitSingleton] addToPaymentQueue:mediumProduct];
        }];
        
        CCMenuItemFont *hardButton = [CCMenuItemFont itemFromString:@"Hard" block:^(id sender) {
            // TODO: Check user defaults for receipt to see if we need to purchase when user taps
            [[StoreKitSingleton sharedStoreKitSingleton] addToPaymentQueue:hardProduct];
        }];
        
        
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
 @result A modal window is presented that informs the user that their purchase was successful, then the
         contents of the menu item that corresponds to the purchased item is updated
 */
- (void)storeKitSuccess:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"StoreKitSuccess"])
    {
        // Modify the UI so that the "locked" menu options appear "unlocked" and can be tapped to access content
        NSDictionary *userInfo = notification.userInfo;
        SKPaymentTransaction *transaction = [userInfo objectForKey:@"transaction"];
        CCLOG(@"Transaction data: %@", transaction);
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
    }
}

- (void)dealloc
{
    // Stop this layer from receiving notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

@end
