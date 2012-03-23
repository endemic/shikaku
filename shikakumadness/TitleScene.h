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

@interface TitleScene : CCLayer 
{
    // String to be appended to sprite filenames if required to use a high-rez file (e.g. iPhone 4 assests on iPad)
	NSString *hdSuffix;
	int fontMultiplier;
}

+(CCScene *) scene;

@end
