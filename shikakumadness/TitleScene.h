//
//  TitleLayer.h
//  shukakumadness
//
//  Created by Nathan Demick on 3/21/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameSingleton.h"
#import "GameScene.h"
#import "EditorScene.h"
#import "LevelSelectScene.h"
#import "PlayerLevelSelectScene.h"
#import "DifficultySelectScene.h"
#import "AboutScene.h"
#import "CCMenuItemImageWithLabel.h"

@interface TitleScene : CCLayer 
{
    // String to be appended to sprite filenames if running on iPad
	int fontMultiplier;
    
    CGSize windowSize;
    CGPoint iPadOffset;
}

+(CCScene *) scene;

@end
