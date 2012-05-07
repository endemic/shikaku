//
//  AboutScene.h
//  shikakumadness
//
//  Created by Nathan Demick on 4/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameSingleton.h"
#import "TitleScene.h"

@interface AboutScene : CCLayer <UIAlertViewDelegate>
{
    CGSize windowSize;
    
    // Adjust font sizes/UI placement based on if iPad/iPhone
	int fontMultiplier;
    CGPoint iPadOffset;
}

+(CCScene *) scene;

@end
