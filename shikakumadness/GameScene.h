//
//  GameScene.h
//  Shikaku Madness
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
#import "CCMenuItemImageWithLabel.h"
#import "ModalAlert.h"

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
    CCLabelBMFont *areaLabel, *timerLabel;
    
    // Stores amount of time taken
    int timer;
    
	// A sprite used as a background for a popup text window
	CCSprite *textWindowBackground;
	
	// Text that appears on popup text window
	CCLabelTTF *textWindowLabel;
	
	// Simple bool to check whether the tutorial is happening
	BOOL isTutorial;
	
	// Tracks the progress of the in-game tutorial
	int tutorialStep;
	
	// Allows player to progress through the tutorial instructions
	CCMenu *tutorialMenu;
	CCMenuItemImageWithLabel *tutorialButton;
	
	// Highlights correct answers to progress thru tutorial
	CCSprite *tutorialHighlight;
    
    // Store coord crap
    CGSize windowSize;
    CGPoint offset;
    
    // Info about platform
    int fontMultiplier;
    CGPoint iPadOffset;
}

// returns a CCScene that contains the GameScene as the only child
+ (CCScene *)scene;
- (BOOL)checkSolution;
- (void)win;
- (void)updateTimer:(ccTime)dt;

- (void)removeNodeFromParent:(CCNode *)node;

- (void)showTutorial;
- (void)showTextWindowAt:(CGPoint)position withText:(NSString *)text;
- (void)dismissTextWindow;

@end
