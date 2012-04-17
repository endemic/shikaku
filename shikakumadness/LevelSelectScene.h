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
#import "CCScrollLayer.h"

@interface LevelSelectScene : CCLayer <CCScrollLayerDelegate>
{
    // Array to store level filenames
    NSMutableArray *levels;
    
    // Current position in the level array
    int selectedLevelIndex;
    
    // Helper vars to deal w/ iPad size diff
	NSString *iPadSuffix;
	int fontMultiplier;
    CGPoint iPadOffset;
    CGSize windowSize;
    
    // Grid size for showing the level preview
    int previewBlockSize;
    CCScrollLayer *scrollLayer;
    
    // Show level #, best time, etc.
    NSDictionary *levelStatus;
    CCLabelBMFont *statusLabel;
    
//    CGPoint gridOffset;
//    NSMutableArray *clues;  // Store preview clues
    
}

+ (CCScene *)scene;
//- (NSArray *)getDocumentsDirectoryContents;
//- (void)updateLevelPreview;
- (NSArray *)createPreviewLayers;
- (void)updateStatusForPage:(int)page;

@end
