//
//  LevelSelectScene.h
//  shikakumadness
//
//  Created by Nathan Demick on 3/24/12.
//  Copyright 2012 Ganbaru Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameScene.h"

@interface LevelSelectScene : CCLayer 
{
    // Array to store level filenames
    NSMutableArray *levels;
    
    // Current position in the level array
    int selectedLevelIndex;
    
    // TEMP: string to show currently chosen level
    CCLabelTTF *selectedLevelLabel;
    
    // String to be appended to sprite filenames if running on iPad
	NSString *iPadSuffix;
	int fontMultiplier;
    CGSize windowSize;
}

+ (CCScene *)scene;
- (NSArray *)getDocumentsDirectoryContents;
- (void)updateLevelPreview;

@end
