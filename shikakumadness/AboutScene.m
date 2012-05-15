//
//  AboutScene.m
//  shikakumadness
//
//  Created by Nathan Demick on 4/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AboutScene.h"


@implementation AboutScene
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an AboutScene object.
	AboutScene *layer = [AboutScene node];
	
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
            fontMultiplier = 2;
            iPadOffset = ccp(64, 32);
        }
        else 
        {
            fontMultiplier = 1;
            iPadOffset = ccp(0, 0);
        }
        
        // Add background
        CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
        background.position = ccp(windowSize.width / 2, windowSize.height / 2);
        [self addChild:background];
        
        // Set up "back" button
        CCMenuItemImageWithLabel *backButton = [CCMenuItemImageWithLabel itemWithText:@"BACK" size:@"small" block:^(id sender) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
            
            CCTransitionMoveInB *transition = [CCTransitionMoveInB transitionWithDuration:0.5 scene:[TitleScene scene]];
            [[CCDirector sharedDirector] replaceScene:transition];            
        }];
        
        CCMenu *topMenu = [CCMenu menuWithItems:backButton, nil];
        topMenu.position = ccp((55 * fontMultiplier) + iPadOffset.x, windowSize.height - (20 * fontMultiplier) - iPadOffset.y);
        [self addChild:topMenu];
        
        CCLabelBMFont *credits = [CCLabelBMFont labelWithString:@"Designed and Programmed by Nathan Demick\n\nShikaku rules\nby Nikolii" fntFile:@"insolent-24.fnt" width:windowSize.width / 1.2 alignment:CCTextAlignmentCenter];
        credits.position = ccp(windowSize.width / 2, windowSize.height / 1.5);
        [self addChild:credits];
        
        
        // Create "rate on App Store" button
        CCMenuItemImageWithLabel *rateButton = [CCMenuItemImageWithLabel itemWithText:@"RATE" block:^(id sender) {
			// Play SFX
			[[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
			
			// Create "go to App Store?" alert
			UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Rate on App Store?"
																 message:@"I appreciate your feedback. Thanks for playing my game!"
																delegate:self
													   cancelButtonTitle:@"Cancel"
													   otherButtonTitles:@"Rate", nil] autorelease];
			[alertView setTag:1];
			[alertView show];
        }];
		
		// Create "more games" button
        CCMenuItemImageWithLabel *moreGamesButton = [CCMenuItemImageWithLabel itemWithText:@"MORE GAMES" block:^(id sender) {
			// Play SFX
			[[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
			
			// Create "go to App Store?" alert
			UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Go to App Store?"
																 message:@"Check my other games!"
																delegate:self
													   cancelButtonTitle:@"Cancel"
													   otherButtonTitles:@"Go", nil] autorelease];
			[alertView setTag:2];
			[alertView show];            
        }];
        
        moreGamesButton.label.scale = 0.7;
        moreGamesButton.label.position = ccp(moreGamesButton.contentSize.width / 2.1, moreGamesButton.contentSize.height / 2.5);
        
        CCMenu *iTunesMenu = [CCMenu menuWithItems:rateButton, moreGamesButton, nil];
		[iTunesMenu alignItemsVerticallyWithPadding:10];
		iTunesMenu.position = ccp(windowSize.width / 2, rateButton.contentSize.height * 2);
		[self addChild:iTunesMenu z:1];
	}
	return self;
}

/**
 * Handle clicking of the alert view
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// "Rate" alert
	if (alertView.tag == 1)
	{
		switch (buttonIndex) 
		{
			case 0:
				// Do nothing - dismiss
				break;
			case 1:
#if TARGET_IPHONE_SIMULATOR
				CCLOG(@"App Store is not supported on the iOS simulator. Unable to open App Store page.");
#else
				// they want to rate it
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=467395560"]];
#endif
				break;
			default:
				break;
		}
	}
	// "More games" alert
	else if (alertView.tag == 2)
	{
		switch (buttonIndex) 
		{
			case 0:
				// Do nothing - dismiss
				break;
			case 1:
#if TARGET_IPHONE_SIMULATOR
				CCLOG(@"App Store is not supported on the iOS simulator. Unable to open App Store page.");
#else
				// they want to see more games
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.com/apps/ganbarugames"]];
#endif
				break;
			default:
				break;
		}
	}
}

@end
