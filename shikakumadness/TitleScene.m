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
        
        // Add title image
        CCSprite *title = [CCSprite spriteWithFile:@"logo.png"];
        title.position = ccp(windowSize.width / 2, windowSize.height - title.contentSize.height);
        [self addChild:title];
        
        // Create some buttons
        CCMenuItemImageWithLabel *playButton = [CCMenuItemImageWithLabel itemWithText:@"PLAY" block:^(id sender) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
            
            CCTransitionMoveInT *transition = [CCTransitionMoveInT transitionWithDuration:0.5 scene:[DifficultySelectScene scene]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        
//        CCMenuItemImage *editorButton = [CCMenuItemImage itemFromNormalImage:@"editor-button.png" selectedImage:@"editor-button.png" block:^(id sender) {
//            [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
//            
//            CCTransitionMoveInB *transition = [CCTransitionMoveInB transitionWithDuration:0.5 scene:[PlayerLevelSelectScene scene]];
//            [[CCDirector sharedDirector] replaceScene:transition];
//        }];
        
        CCMenuItemImageWithLabel *helpButton = [CCMenuItemImageWithLabel itemWithText:@"HELP" block:^(id sender) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
            
            [GameSingleton sharedGameSingleton].levelToLoad = @"tutorial"; // Load the tutorial
            
            CCTransitionMoveInT *transition = [CCTransitionMoveInT transitionWithDuration:0.5 scene:[GameScene scene]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];

        CCMenuItemImageWithLabel *aboutButton = [CCMenuItemImageWithLabel itemWithText:@"ABOUT" block:^(id sender) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
            
            CCTransitionMoveInT *transition = [CCTransitionMoveInT transitionWithDuration:0.5 scene:[AboutScene scene]];
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
        CCLabelBMFont *copyright = [CCLabelBMFont labelWithString:@"(c)2012 GANBARU GAMES" fntFile:@"insolent-24.fnt" width:windowSize.width alignment:CCTextAlignmentCenter];
//        CCSprite *copyright = [CCSprite spriteWithFile:[NSString stringWithFormat:@"copyright%@.png", iPadSuffix]];
        copyright.position = ccp(windowSize.width / 2, copyright.contentSize.height + iPadOffset.y);
        [self addChild:copyright];
	}
	return self;
}
@end
