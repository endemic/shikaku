//
//  EditorScene.h
//  Shikaku Madness
//
//  Created by Nathan Demick on 3/22/12.
//  Copyright 2012 Ganbaru Games. All rights reserved.
//

#import "RoundRectNode.h"
#import "Clue.h"
#import "SimpleAudioEngine.h"
#import "TitleScene.h"
#import "GameSingleton.h"

// For JSON serializing/deserializing
#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"
#import "NSDictionary_JSONExtensions.h"

#define kToolSquare 1
#define kToolClue 2

@interface EditorScene : CCLayer 
{
    // This'll hold the loaded level
    NSDictionary *level;
    
    // Display/store player moves and puzzle clues
    NSMutableArray *squares, *clues;
    RoundRectNode *selection;
    
    // Variables for use w/ editor
    NSString *levelDifficulty;
    int selectedTool;
    
    // Stores info about grid
    int blockSize, gridSize;
    
    // Stores info about player input
    CGPoint touchStart, touchPrevious;
    int touchRow, touchCol, startRow, startCol, previousRow, previousCol;
    
    // Labels for giving player information
    CCLabelTTF *areaLabel, *timerLabel;
    
    // Store coord crap
    CGSize window;
    CGPoint offset;
    
    // Info about platform
    NSString *iPadSuffix;
    int fontMultiplier;
}

// returns a CCScene that contains the GameScene as the only child
+ (CCScene *)scene;
- (BOOL)saveLevel;
- (NSString *)createUUID;
- (BOOL)checkSolution;

@end
