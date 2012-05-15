//
//  LogoScene.h
//  nonogrammadness
//
//  Created by Nathan Demick on 8/31/11.
//  Copyright 2011 Ganbaru Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface LogoScene : CCLayer 
{
	// String to be appended to sprite filenames if required to use a high-rez file (e.g. iPhone 4 assests on iPad)
	int fontMultiplier;
}

// returns a CCScene that contains the GameScene as the only child
+ (CCScene *)scene;
- (void)goToTitle;

@end
