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
        
        // Add title image
        CCSprite *title = [CCSprite spriteWithFile:@"logo.png"];
        title.position = ccp(windowSize.width / 2, windowSize.height - title.contentSize.height);
        [self addChild:title];
        
        // Add button/menu to take player to game scene
        CCMenuItemImage *playButton = [CCMenuItemImage itemFromNormalImage:@"play-button.png" selectedImage:@"play-button.png" block:^(id sender) {
            CCTransitionMoveInB *transition = [CCTransitionMoveInB transitionWithDuration:0.5 scene:[DifficultySelectScene scene]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        
        CCMenuItemImage *editorButton = [CCMenuItemImage itemFromNormalImage:@"editor-button.png" selectedImage:@"editor-button.png" block:^(id sender) {
            [GameSingleton sharedGameSingleton].levelToLoad = @"";  // Reset this value so user can always create new puzzles
            
            CCTransitionMoveInB *transition = [CCTransitionMoveInB transitionWithDuration:0.5 scene:[EditorScene scene]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        
        CCMenu *menu = [CCMenu menuWithItems:playButton, editorButton, nil];
        [menu alignItemsVerticallyWithPadding:20.0];
        menu.position = ccp(windowSize.width / 2, windowSize.height / 3);
        [self addChild:menu];
	}
	return self;
}
@end
