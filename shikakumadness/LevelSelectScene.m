//
//  LevelSelectScene.m
//  Shikaku Madness
//
//  Created by Nathan Demick on 3/24/12.
//  Copyright 2012 Ganbaru Games. All rights reserved.
//

#import "LevelSelectScene.h"

@implementation LevelSelectScene

+(CCScene *) scene
{
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];

    // 'layer' is an autorelease object.
    LevelSelectScene *layer = [LevelSelectScene node];

    // add layer as a child to scene
    [scene addChild:layer];

    // return the scene
    return scene;
}

// on "init" you need to initialize your instance
- (id)init
{
	// always call "super" init
	if ((self = [super init]))
	{
        // Get window size
        windowSize = [CCDirector sharedDirector].winSize;
        
        // Determine offset of grid
        if ([GameSingleton sharedGameSingleton].isPad)
        {
            iPadSuffix = @"-ipad";
            fontMultiplier = 2;
            previewBlockSize = 40;
            iPadOffset = ccp(64, 32);   // 64px gutters on left/right, 32px on top/bottom
        }
        else 
        {
            iPadSuffix = @"";
            fontMultiplier = 1;
            previewBlockSize = 20;
            iPadOffset = ccp(0, 0);
        }
        
        // Add background
        CCSprite *background = [CCSprite spriteWithFile:[NSString stringWithFormat:@"background%@.png", iPadSuffix]];
        background.position = ccp(windowSize.width / 2, windowSize.height / 2);
        [self addChild:background];
        
        // Get list of levels!
        NSString *filename = [NSString stringWithFormat:@"%@-puzzles", [GameSingleton sharedGameSingleton].difficulty];
        levels = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"plist"]];
        [levels retain];
        
        // Get a dictionary of puzzle times, completion status, etc.
        levelStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"levelStatus"];
        if (!levelStatus)
        {
            levelStatus = [NSDictionary dictionary];
        }
        [levelStatus retain];
        
        // Set up "back" button
        CCMenuItemImage *backButton = [CCMenuItemImage itemFromNormalImage:[NSString stringWithFormat:@"back-button%@.png", iPadSuffix] selectedImage:[NSString stringWithFormat:@"back-button%@.png", iPadSuffix] block:^(id sender) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
            
            CCTransitionMoveInT *transition = [CCTransitionMoveInT transitionWithDuration:0.5 scene:[TitleScene scene]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];

        CCMenu *topMenu = [CCMenu menuWithItems:backButton, nil];
        topMenu.position = ccp((backButton.contentSize.width / 2) + 10 * fontMultiplier + iPadOffset.x, windowSize.height - (20 * fontMultiplier) - iPadOffset.y);
        [self addChild:topMenu];
        
        // Create "status" label
        statusLabel = [CCLabelBMFont labelWithString:@"" fntFile:[NSString stringWithFormat:@"insolent-24%@.fnt", iPadSuffix] width:windowSize.width / 1.2 alignment:CCTextAlignmentLeft];
        statusLabel.position = ccp(windowSize.width / 2, windowSize.height / 4);
        [self addChild:statusLabel];
        
        // Create an array of layers with level preview contents
        scrollLayer = [CCScrollLayer nodeWithLayers:[self createPreviewLayers] widthOffset:windowSize.width / 4];
        scrollLayer.delegate = self;
        scrollLayer.minimumTouchLengthToSlide = 5.0;
        scrollLayer.minimumTouchLengthToChangePage = 10.0;
        scrollLayer.marginOffset = windowSize.width / 2;   // Offset that can be used to let user see empty space over first or last page
        scrollLayer.stealTouches = NO;
        scrollLayer.showPagesIndicator = NO;
        [self addChild:scrollLayer z:4];
        
        // Try to find the previously selected level if coming back to this scene from the "solve" scene
        if ([[GameSingleton sharedGameSingleton].levelToLoad isEqualToString:@""] == NO)
        {
            for (int i = 0; i < [levels count]; i++)
            {
                if ([[levels objectAtIndex:i] isEqualToString:[GameSingleton sharedGameSingleton].levelToLoad])
                {
                    selectedLevelIndex = i;
                    [scrollLayer selectPage:i];
                    break;
                }
            }
        }
        else 
        {
            // Set up previous/next buttons here to cycle thru files
            selectedLevelIndex = 0;
            [GameSingleton sharedGameSingleton].levelToLoad = [levels objectAtIndex:selectedLevelIndex];
        }
        
        [self updateStatusForPage:selectedLevelIndex];
        
        // Set up the solve button
        CCMenuItemImageWithLabel *solveButton = [CCMenuItemImageWithLabel buttonWithText:@"SOLVE" block:^(id sender) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
            
            CCTransitionMoveInB *transition = [CCTransitionMoveInB transitionWithDuration:0.5 scene:[GameScene scene]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        
        CCMenu *rightMenu = [CCMenu menuWithItems:solveButton, nil];
        rightMenu.position = ccp(windowSize.width / 2, 50 * fontMultiplier + iPadOffset.y);
        [self addChild:rightMenu];

	}
	return self;
}


/**
 * Depending on the selected level, a "minimap" or preview or something will be updated here
 */
/*
- (void)updateLevelPreview
{
    // Clear out previous clues
    for (int i = 0; i < [clues count]; i++)
    {
        [self removeChild:[clues objectAtIndex:i] cleanup:YES];
    }
    [clues removeAllObjects];
    
    // Load level dictionary
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *pathToFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/%@", [GameSingleton sharedGameSingleton].difficulty, [GameSingleton sharedGameSingleton].levelToLoad]];
    
    // Get JSON data out of file, and parse into dictionary
    NSData *json = [NSData dataWithContentsOfFile:pathToFile];
    NSError *error = nil;
    NSDictionary *level = [NSDictionary dictionaryWithJSONData:json error:&error];
    
    if (error != nil)
    {
        CCLOG(@"Error deserializing JSON data: %@", error);
    }
    
    //    NSDictionary *level = [NSDictionary dictionaryWithContentsOfFile:pathToFile];
    
    // Get out the "clue" objects
    NSArray *c = [level objectForKey:@"clues"];
    
    // Iterate and draw
    for (int i = 0; i < [c count]; i++)
    {
        NSArray *val = [c objectAtIndex:i];
        
        int value = [(NSNumber *)[val objectAtIndex:2] intValue],
        x = [(NSNumber *)[val objectAtIndex:0] intValue],
        y = [(NSNumber *)[val objectAtIndex:1] intValue];
        
        Clue *c = [Clue clueWithNumber:value];
        c.position = ccp(x * previewBlockSize + gridOffset.x + previewBlockSize / 2, y * previewBlockSize + gridOffset.y + previewBlockSize / 2);
        c.scale = 0.8125;
        [self addChild:c z:2];
        
        [clues addObject:c];
    }
}
*/

/**
 * Depending on the selected level, a "minimap" or preview or something will be updated here
 */
- (NSArray *)createPreviewLayers
{
    // Load level dictionary
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:[GameSingleton sharedGameSingleton].difficulty];
//    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
//    
    NSMutableArray *returnArray = [NSMutableArray array];
    
    for (int i = 0; i < [levels count]; i++)
    {
        // Create a layer
        CCLayer *layer = [CCLayer node];
        
        CCSprite *previewBackground = [CCSprite spriteWithFile:[NSString stringWithFormat:@"preview-background%@.png", iPadSuffix]];
        previewBackground.position = ccp(windowSize.width / 2, windowSize.height - 180 * fontMultiplier - iPadOffset.y);
        [layer addChild:previewBackground];
        
//        NSString *pathToFile = [documentsDirectory stringByAppendingPathComponent:[directoryContent objectAtIndex:i]];
        
        // Get JSON data out of file, and parse into dictionary
        NSString *filename = [levels objectAtIndex:i];
        NSData *json = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"json"]];
        NSDictionary *level = [NSDictionary dictionaryWithJSONData:json error:nil];
        
        // Get out the "clue" objects
        NSArray *c = [level objectForKey:@"clues"];
        
        // Iterate and draw
        for (int j = 0; j < [c count]; j++)
        {
            NSArray *val = [c objectAtIndex:j];
            
            int value = [(NSNumber *)[val objectAtIndex:2] intValue],
                x = [(NSNumber *)[val objectAtIndex:0] intValue],
                y = [(NSNumber *)[val objectAtIndex:1] intValue];
            
            Clue *c = [Clue clueWithNumber:value];
            c.position = ccp(x * previewBlockSize + previewBlockSize / 2, y * previewBlockSize + previewBlockSize / 2);
            c.scale = 0.625;
            [previewBackground addChild:c];
        }
        
        [returnArray addObject:layer];
    }
    
    return returnArray;
}

- (void)updateStatusForPage:(int)page
{
    NSDictionary *status = [levelStatus objectForKey:[GameSingleton sharedGameSingleton].levelToLoad];
    if (status)
    {
        int time = [(NSNumber *)[status objectForKey:@"time"] intValue];
        int attempts = [(NSNumber *)[status objectForKey:@"attempts"] intValue];
        statusLabel.string = [NSString stringWithFormat:@"PUZZLE #%i\nBEST TIME: %02i:%02i\nATTEMPTS: %i\n             ", page + 1, time / 60, time % 60, attempts];
    }
    else 
    {
        statusLabel.string = [NSString stringWithFormat:@"PUZZLE #%i\nBEST TIME: --:--\nATTEMPTS: 0\n             ", page + 1];
    }
}

#pragma mark -
#pragma mark CCScrollLayer delegate methods

- (void)scrollLayerScrollingStarted:(CCScrollLayer *)sender
{
    CCLOG(@"Started scrolling");
}

- (void)scrollLayer:(CCScrollLayer *)sender scrolledToPageNumber:(int)page
{
    CCLOG(@"Scrolled to page %i", page);
    selectedLevelIndex = page;
    [GameSingleton sharedGameSingleton].levelToLoad = [levels objectAtIndex:selectedLevelIndex];
    
    [self updateStatusForPage:page];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
}

- (void)dealloc
{
    [levels release];
//    [clues release];
    [levelStatus release];
    
    [super dealloc];
}

@end
