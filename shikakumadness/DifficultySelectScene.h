//
//  DifficultySelectScene.h
//  shikakumadness
//
//  Created by Nathan Demick on 3/28/12.
//  Copyright 2012 Ganbaru Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "TitleScene.h"
#import "LevelSelectScene.h"
#import "GameSingleton.h"
#import "StoreKitSingleton.h"

@interface DifficultySelectScene : CCLayer 
{
    // Store local representations of product objects, to be passed to the StoreKitSingleton if necessary
    SKProduct *easyProduct, *mediumProduct, *hardProduct;
    
    // Store buttons in order to change their contents based on purchase
    CCMenuItemImage *easyButton, *mediumButton, *hardButton;
    
    // Helper vars to deal w/ iPad size diff
	NSString *iPadSuffix;
	int fontMultiplier;
    CGPoint iPadOffset;
    CGSize windowSize;
}

+ (CCScene *)scene;

@end
