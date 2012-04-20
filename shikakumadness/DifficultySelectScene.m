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
            iPadSuffix = @"-hd";
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
//        [CCMenuItemFont setFontName:@"insolent.otf"];
//        [CCMenuItemFont setFontSize:24.0];
        
        // Add background
        CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
        background.position = ccp(windowSize.width / 2, windowSize.height / 2);
        [self addChild:background];
        
        // Set up "back" & "restore" buttons
        CCMenuItemImage *backButton = [CCMenuItemImage itemFromNormalImage:@"back-button.png" selectedImage:@"back-button.png" block:^(id sender) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
            
            CCTransitionMoveInB *transition = [CCTransitionMoveInB transitionWithDuration:0.5 scene:[TitleScene scene]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        
        CCMenuItemImage *restoreButton = [CCMenuItemImage itemFromNormalImage:@"restore-button.png" selectedImage:@"restore-button.png" block:^(id sender) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
            
            // Init restoreCompletedTransactions
            [[StoreKitSingleton sharedStoreKitSingleton] restore];
        }];
        
        CCMenu *topMenu = [CCMenu menuWithItems:backButton, restoreButton, nil];
        [topMenu alignItemsHorizontallyWithPadding:120 * fontMultiplier];
        topMenu.position = ccp(windowSize.width / 2, windowSize.height - (20 * fontMultiplier) - iPadOffset.y);
        [self addChild:topMenu];
        
        // Add a title graphic
        CCSprite *title = [CCSprite spriteWithFile:[NSString stringWithFormat:@"difficulty-title%@.png", iPadSuffix]];
        title.position = ccp(windowSize.width / 2, windowSize.height - (100 * fontMultiplier) - iPadOffset.y);
        [self addChild:title];
        
        // Set up a menu based on products returned from the StoreKit singleton
        CCMenuItemImage *beginnerButton = [CCMenuItemImage itemFromNormalImage:@"beginner-button.png" selectedImage:@"beginner-button.png" block:^(id sender) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
            
            // Set difficulty in singleton
            [GameSingleton sharedGameSingleton].difficulty = @"beginner";
            
            CCTransitionMoveInB *transition = [CCTransitionMoveInB transitionWithDuration:0.5 scene:[LevelSelectScene scene]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        
        // Iterate through the products to assign to local variables
        for (SKProduct *product in [StoreKitSingleton sharedStoreKitSingleton].products)
        {
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [numberFormatter setLocale:product.priceLocale];
//            NSString *formattedString = [numberFormatter stringFromNumber:product.price];
            
            if ([[product productIdentifier] isEqualToString:@"com.ganbarugames.shikakumadness.easy"])
            {
                easyProduct = product;
                easyPrice = [numberFormatter stringFromNumber:product.price];
            }
            else if ([[product productIdentifier] isEqualToString:@"com.ganbarugames.shikakumadness.medium"])
            {
                mediumProduct = product;
                mediumPrice = [numberFormatter stringFromNumber:product.price];
            }
            else if ([[product productIdentifier] isEqualToString:@"com.ganbarugames.shikakumadness.hard"])
            {
                hardProduct = product;
                hardPrice = [numberFormatter stringFromNumber:product.price];
            }
        }
        
        // Check for IAP receipts to "unlock" buttons
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        easyButton = [CCMenuItemImage itemFromNormalImage:@"easy-button-locked.png" selectedImage:@"easy-button-locked.png" block:^(id sender) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
            
            if ([defaults objectForKey:@"com.ganbarugames.shikakumadness.easy.receipt"])
            {
                // Set difficulty in singleton
                [GameSingleton sharedGameSingleton].difficulty = @"easy";
                
                CCTransitionMoveInB *transition = [CCTransitionMoveInB transitionWithDuration:0.5 scene:[LevelSelectScene scene]];
                [[CCDirector sharedDirector] replaceScene:transition];
            }
            else
            {
                [[StoreKitSingleton sharedStoreKitSingleton] addToPaymentQueue:easyProduct];
            }
        }];
        
        mediumButton = [CCMenuItemImage itemFromNormalImage:@"medium-button-locked.png" selectedImage:@"medium-button-locked.png" block:^(id sender) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
            
            if ([defaults objectForKey:@"com.ganbarugames.shikakumadness.medium.receipt"])
            {
                // Set difficulty in singleton
                [GameSingleton sharedGameSingleton].difficulty = @"medium";
                
                CCTransitionMoveInB *transition = [CCTransitionMoveInB transitionWithDuration:0.5 scene:[LevelSelectScene scene]];
                [[CCDirector sharedDirector] replaceScene:transition];
            }
            else
            {
                [[StoreKitSingleton sharedStoreKitSingleton] addToPaymentQueue:mediumProduct];
            }
        }];
        
        hardButton = [CCMenuItemImage itemFromNormalImage:@"hard-button-locked.png" selectedImage:@"hard-button-locked.png" block:^(id sender) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
            
            if ([defaults objectForKey:@"com.ganbarugames.shikakumadness.hard.receipt"])
            {
                // Set difficulty in singleton
                [GameSingleton sharedGameSingleton].difficulty = @"hard";
                
                CCTransitionMoveInB *transition = [CCTransitionMoveInB transitionWithDuration:0.5 scene:[LevelSelectScene scene]];
                [[CCDirector sharedDirector] replaceScene:transition];
            }
            else
            {
                [[StoreKitSingleton sharedStoreKitSingleton] addToPaymentQueue:hardProduct];
            }
        }];
        
        // Try to add text onto buttons here
        beginnerLabel = [CCLabelTTF labelWithString:@"0/30\ncomplete" dimensions:CGSizeMake(beginnerButton.contentSize.width / 2, beginnerButton.contentSize.height / 2) alignment:CCTextAlignmentRight fontName:@"insolent.otf" fontSize:14.0];
        beginnerLabel.color = ccc3(0, 0, 0);
        beginnerLabel.position = ccp(beginnerButton.contentSize.width - (95 * fontMultiplier), 27 * fontMultiplier);
        [beginnerButton addChild:beginnerLabel];
        
        beginnerLabel.string = [NSString stringWithFormat:@"%i/30\ncomplete", [self getCompleteCountForDifficulty:@"beginner"]];
        
        easyLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@\ntap to buy", easyPrice] dimensions:CGSizeMake(easyButton.contentSize.width / 2, easyButton.contentSize.height / 2) alignment:CCTextAlignmentRight fontName:@"insolent.otf" fontSize:14.0];
        easyLabel.color = ccc3(0, 0, 0);
        easyLabel.position = ccp(easyButton.contentSize.width - (95 * fontMultiplier), 27 * fontMultiplier);
        [easyButton addChild:easyLabel];
        
        mediumLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@\ntap to buy", mediumPrice] dimensions:CGSizeMake(mediumButton.contentSize.width / 2, mediumButton.contentSize.height / 2) alignment:CCTextAlignmentRight fontName:@"insolent.otf" fontSize:14.0];
        mediumLabel.color = ccc3(0, 0, 0);
        mediumLabel.position = ccp(easyButton.contentSize.width - (95 * fontMultiplier), 27 * fontMultiplier);
        [mediumButton addChild:mediumLabel];
        
        hardLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@\ntap to buy", hardPrice] dimensions:CGSizeMake(hardButton.contentSize.width / 2, hardButton.contentSize.height / 2) alignment:CCTextAlignmentRight fontName:@"insolent.otf" fontSize:14.0];
        hardLabel.color = ccc3(0, 0, 0);
        hardLabel.position = ccp(hardButton.contentSize.width - (95 * fontMultiplier), 27 * fontMultiplier);
        [hardButton addChild:hardLabel];
        
        if ([defaults objectForKey:@"com.ganbarugames.shikakumadness.easy.receipt"])
        {
            CCLOG(@"User has easy receipt!");
            CCSprite *s = [CCSprite spriteWithFile:@"easy-button.png"];
            [easyButton setNormalImage:s];
            easyLabel.string = [NSString stringWithFormat:@"%i/30\ncomplete", [self getCompleteCountForDifficulty:@"easy"]];
        }
        
        if ([defaults objectForKey:@"com.ganbarugames.shikakumadness.medium.receipt"])
        {
            CCLOG(@"User has medium receipt!");
            CCSprite *s = [CCSprite spriteWithFile:@"medium-button.png"];
            [mediumButton setNormalImage:s];
            mediumLabel.string = [NSString stringWithFormat:@"%i/30\ncomplete", [self getCompleteCountForDifficulty:@"medium"]];
        }
        
        if ([defaults objectForKey:@"com.ganbarugames.shikakumadness.hard.receipt"])
        {
            CCLOG(@"User has hard receipt!");
            CCSprite *s = [CCSprite spriteWithFile:@"hard-button.png"];
            [hardButton setNormalImage:s];
            hardLabel.string = [NSString stringWithFormat:@"%i/30\ncomplete", [self getCompleteCountForDifficulty:@"hard"]];
        }
        
        CCMenu *difficultyMenu = [CCMenu menuWithItems:beginnerButton, easyButton, mediumButton, hardButton, nil];
        difficultyMenu.position = ccp(windowSize.width / 2 + (3 * fontMultiplier), windowSize.height / 3);
        [difficultyMenu alignItemsVerticallyWithPadding:15.0];
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
            CCSprite *s = [CCSprite spriteWithFile:@"easy-button.png"];
            [easyButton setNormalImage:s];
            easyLabel.string = [NSString stringWithFormat:@"%i/30\ncomplete", 0];
        }
        else if ([productId isEqualToString:@"com.ganbarugames.shikakumadness.medium"])
        {
            // Change graphic on the "medium" button
            CCSprite *s = [CCSprite spriteWithFile:@"medium-button.png"];
            [mediumButton setNormalImage:s];
            mediumLabel.string = [NSString stringWithFormat:@"%i/30\ncomplete", 0];
        }
        else if ([productId isEqualToString:@"com.ganbarugames.shikakumadness.hard"])
        {
            // Change graphic on the "hard" button
            CCSprite *s = [CCSprite spriteWithFile:@"hard-button.png"];
            [hardButton setNormalImage:s];
            hardLabel.string = [NSString stringWithFormat:@"%i/30\ncomplete", 0];
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

// Return 
- (int)getCompleteCountForDifficulty:(NSString *)difficulty
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *completeCount = [defaults objectForKey:@"completeCount"];
    
    return [(NSNumber *)[completeCount objectForKey:difficulty] intValue];
}

#pragma mark -

- (void)dealloc
{
    // Stop this layer from receiving notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

@end
