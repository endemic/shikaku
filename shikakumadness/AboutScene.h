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

@interface AboutScene : CCLayer 
{
    // String to be appended to sprite filenames if running on iPad
	NSString *iPadSuffix;
	int fontMultiplier;
    
    CGSize windowSize;
    CGPoint iPadOffset;
}

+(CCScene *) scene;

@end
