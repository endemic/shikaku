//
//  GameScene.h
//  shukakumadness
//
//  Created by Nathan Demick on 3/18/12.
//  Copyright Ganbaru Games 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "RoundRectNode.h"
#import "Clue.h"
#import "SimpleAudioEngine.h"
#import "TitleScene.h"
#import "GameSingleton.h"

// GameScene
@interface GameScene : CCLayer
{
    // This'll hold the loaded level
    NSDictionary *level;
    
    // Display/store player moves and puzzle clues
    NSMutableArray *squares, *clues;
    RoundRectNode *selection;
    
    // Stores info about grid
    int blockSize, gridSize;
    
    // Stores info about player input
    CGPoint touchStart, touchPrevious;
    int touchRow, touchCol, startRow, startCol, previousRow, previousCol;

    // Labels for giving player information
    CCLabelTTF *areaLabel, *timerLabel;
    
    // Stores amount of time taken
    int timer;
    
    // Store coord crap
    CGSize window;
    CGPoint offset;
    
    // Info about platform
    NSString *iPadSuffix;
    int fontMultiplier;
    CGPoint iPadOffset;
}

// returns a CCScene that contains the GameScene as the only child
+ (CCScene *)scene;
- (BOOL)checkSolution;
- (void)updateTimer:(ccTime)dt;

@end
