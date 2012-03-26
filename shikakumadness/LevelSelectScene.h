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
//    CCLabelTTF *selectedLevelLabel;
    
    // Helper vars to deal w/ iPad size diff
	NSString *iPadSuffix;
	int fontMultiplier;
    CGPoint iPadOffset;
    CGSize windowSize;
    
    // Grid size for showing the level preview
    int previewBlockSize;
    CGPoint gridOffset;
    NSMutableArray *clues;  // Store preview clues
}

+ (CCScene *)scene;
- (NSArray *)getDocumentsDirectoryContents;
- (void)updateLevelPreview;

@end
