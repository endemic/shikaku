//
//  TitleLayer.m
//  shukakumadness
//
//  Created by Nathan Demick on 3/21/12.
//  Copyright 2012 Ganbaru Games. All rights reserved.
//

#import "TitleScene.h"


@implementation TitleScene
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	TitleScene *layer = [TitleScene node];
	
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
            iPadOffset = ccp(64, 32);
        }
        else 
        {
            iPadSuffix = @"";
            fontMultiplier = 1;
            iPadOffset = ccp(0, 0);
        }
        
        // Add background
        CCSprite *background = [CCSprite spriteWithFile:[NSString stringWithFormat:@"background%@.png", iPadSuffix]];
        background.position = ccp(windowSize.width / 2, windowSize.height / 2);
        [self addChild:background];
        
        // Add title image
        CCSprite *title = [CCSprite spriteWithFile:[NSString stringWithFormat:@"logo%@.png", iPadSuffix]];
        title.position = ccp(windowSize.width / 2, windowSize.height - title.contentSize.height);
        [self addChild:title];
        
        // Create some buttons
        CCMenuItemImage *playButton = [CCMenuItemImage itemFromNormalImage:[NSString stringWithFormat:@"play-button%@.png", iPadSuffix] selectedImage:[NSString stringWithFormat:@"play-button%@.png", iPadSuffix] block:^(id sender) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
            
            CCTransitionMoveInB *transition = [CCTransitionMoveInB transitionWithDuration:0.5 scene:[DifficultySelectScene scene]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        
//        CCMenuItemImage *editorButton = [CCMenuItemImage itemFromNormalImage:@"editor-button.png" selectedImage:@"editor-button.png" block:^(id sender) {
//            [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
//            
//            CCTransitionMoveInB *transition = [CCTransitionMoveInB transitionWithDuration:0.5 scene:[PlayerLevelSelectScene scene]];
//            [[CCDirector sharedDirector] replaceScene:transition];
//        }];
        
        CCMenuItemImage *helpButton = [CCMenuItemImage itemFromNormalImage:[NSString stringWithFormat:@"help-button%@.png", iPadSuffix] selectedImage:[NSString stringWithFormat:@"help-button%@.png", iPadSuffix] block:^(id sender) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
            
            [GameSingleton sharedGameSingleton].levelToLoad = @"tutorial.json"; // Load the tutorial
            
            CCTransitionMoveInB *transition = [CCTransitionMoveInB transitionWithDuration:0.5 scene:[GameScene scene]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        
        CCMenuItemImage *aboutButton = [CCMenuItemImage itemFromNormalImage:[NSString stringWithFormat:@"about-button%@.png", iPadSuffix] selectedImage:[NSString stringWithFormat:@"about-button%@.png", iPadSuffix] block:^(id sender) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
            
            CCTransitionMoveInB *transition = [CCTransitionMoveInB transitionWithDuration:0.5 scene:[AboutScene scene]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        
        CCMenu *menu = [CCMenu menuWithItems:playButton, helpButton, aboutButton, nil];
        [menu alignItemsVerticallyWithPadding:10.0 * fontMultiplier];
        menu.position = ccp(windowSize.width / 2, windowSize.height / 3);
        [self addChild:menu];
        
//        CCMenu *leftMenu = [CCMenu menuWithItems:playButton, helpButton, nil];
//        [leftMenu alignItemsVerticallyWithPadding:10.0 * fontMultiplier];
//        leftMenu.position = ccp(85 * fontMultiplier + iPadOffset.x, windowSize.height / 3);
//        [self addChild:leftMenu];
//        
//        CCMenu *rightMenu = [CCMenu menuWithItems:editorButton, aboutButton, nil];
//        [rightMenu alignItemsVerticallyWithPadding:10.0 * fontMultiplier];
//        rightMenu.position = ccp(235 * fontMultiplier + iPadOffset.x, windowSize.height / 3);
//        [self addChild:rightMenu];
        
        // Add copyright text
        CCSprite *copyright = [CCSprite spriteWithFile:[NSString stringWithFormat:@"copyright%@.png", iPadSuffix]];
        copyright.position = ccp(windowSize.width / 2, copyright.contentSize.height + iPadOffset.y);
        [self addChild:copyright];
	}
	return self;
}
@end
