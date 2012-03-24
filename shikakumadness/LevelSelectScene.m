//
//  LevelSelectScene.m
//  shikakumadness
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
        }
        else 
        {
            iPadSuffix = @"";
            fontMultiplier = 1;
        }
        
        // Add background
        CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
        background.position = ccp(windowSize.width / 2, windowSize.height / 2);
        [self addChild:background];
        
        // Add button/menu to take player to game scene
        CCMenuItemImage *playButton = [CCMenuItemImage itemFromNormalImage:@"play-button.png" selectedImage:@"play-button.png" block:^(id sender) {
            CCTransitionMoveInB *transition = [CCTransitionMoveInB transitionWithDuration:0.5 scene:[GameScene scene]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        
        CCMenu *menu = [CCMenu menuWithItems:playButton, nil];
        menu.position = ccp(windowSize.width / 2, windowSize.height / 3);
        [self addChild:menu];
	}
	return self;
}
@end
