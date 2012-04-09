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
            iPadSuffix = @"-ipad";
            fontMultiplier = 2;
            iPadOffset = ccp(64, 32);
        }
        else 
        {
            iPadSuffix = @"";
            fontMultiplier = 1;
            iPadOffset = ccp(0, 0);
        }
        
        // Add background
        CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
        background.position = ccp(windowSize.width / 2, windowSize.height / 2);
        [self addChild:background];
        
        // Set up "back" button
        CCMenuItemImage *backButton = [CCMenuItemImage itemFromNormalImage:@"back-button.png" selectedImage:@"back-button.png" block:^(id sender) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
            
            CCTransitionMoveInT *transition = [CCTransitionMoveInT transitionWithDuration:0.5 scene:[TitleScene scene]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        
        CCMenu *topMenu = [CCMenu menuWithItems:backButton, nil];
        topMenu.position = ccp((55 * fontMultiplier) + iPadOffset.x, windowSize.height - (20 * fontMultiplier) - iPadOffset.y);
        [self addChild:topMenu];
        
        CCShadowLabelTTF *credits = [CCShadowLabelTTF labelWithString:@"Designed and Programmed by Nathan Demick\n\nShikaku concept by Nikoli" dimensions:CGSizeMake(windowSize.width / 1.5, windowSize.height / 2) alignment:CCTextAlignmentCenter fontName:@"insolent.otf" fontSize:20.0];
        credits.position = ccp(windowSize.width / 2, windowSize.height / 2);
        [self addChild:credits];
	}
	return self;
}

@end
