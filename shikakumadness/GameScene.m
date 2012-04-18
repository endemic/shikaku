//
//  GameScene.m
//  Shikaku Madness
//
//  Created by Nathan Demick on 3/18/12.
//  Copyright Ganbaru Games 2012. All rights reserved.
//


// Import the interfaces
#import "GameScene.h"

// GameScene implementation
@implementation GameScene

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameScene *layer = [GameScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	if ((self = [super init])) {
        // Get window size
        windowSize = [CCDirector sharedDirector].winSize;
        
        // Determine offset of grid
        if ([GameSingleton sharedGameSingleton].isPad)
        {
            iPadOffset = ccp(32, 16);
            offset = ccp(32, 66);   // Determine offset of grid
            blockSize = 64;
            iPadSuffix = @"-ipad";
            fontMultiplier = 2;
        }
        else 
        {
            iPadOffset = ccp(0, 0);
            offset = ccp(0, 25);
            blockSize = 32;
            iPadSuffix = @"";
            fontMultiplier = 1;
        }
        
        gridSize = 10;
        
        [self setIsTouchEnabled:YES];
        
        // Set up the array that will hold player "moves"
        squares = [[[NSMutableArray alloc] init] retain];
        clues = [[[NSMutableArray alloc] init] retain];
        
        // Set up the sprite that will show the player's current move
        selection = [RoundRectNode initWithRectSize:CGSizeMake(blockSize, blockSize)];
        [self addChild:selection z:1];
        selection.visible = NO;
        
        // Add background
		CCSprite *background = [CCSprite spriteWithFile:[NSString stringWithFormat:@"background%@.png", iPadSuffix]];
        background.position = ccp(windowSize.width / 2, windowSize.height / 2);
        [self addChild:background z:0];
        
        // Add grid
        CCSprite *grid = [CCSprite spriteWithFile:[NSString stringWithFormat:@"grid%@.png", iPadSuffix]];
        grid.position = ccp(windowSize.width / 2, grid.contentSize.height / 2 + iPadOffset.y + (25 * fontMultiplier));
        [self addChild:grid z:0];
        
        // Add "reset" and "quit" buttons
        CCMenuItemImageWithLabel *resetButton = [CCMenuItemImageWithLabel buttonWithText:@"RESET" block:^(id sender) {
            // TODO: Show confirmation popup here
            // Remove squares from layer
            for (int i = 0; i < [squares count]; i++) 
            {
                RoundRectNode *r = [squares objectAtIndex:i];
                [self removeChild:r cleanup:YES];
            }
            
            // Remove from organizational array
            [squares removeAllObjects];
            
            [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
        }];
        
        CCMenuItemImageWithLabel *quitButton = [CCMenuItemImageWithLabel buttonWithText:@"QUIT" block:^(id sender) {
            // TODO: Show confirmation popup here
            
            [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
            
            CCTransitionMoveInT *transition = [CCTransitionMoveInT transitionWithDuration:0.5 scene:[LevelSelectScene scene]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        
        CCMenu *menu = [CCMenu menuWithItems:quitButton, resetButton, nil];
        menu.position = ccp(windowSize.width / 2, windowSize.height - quitButton.contentSize.height / 1.5);
        [menu alignItemsHorizontallyWithPadding:20.0];
        [self addChild:menu];
        
        // Add "area" label
        areaLabel = [CCLabelBMFont labelWithString:@"AREA:\n   -" fntFile:[NSString stringWithFormat:@"insolent-24%@.fnt", iPadSuffix] width:windowSize.width / 2 alignment:CCTextAlignmentLeft];
        areaLabel.position = ccp(60 * fontMultiplier + iPadOffset.x, 380 * fontMultiplier + iPadOffset.y);
        [self addChild:areaLabel];
        
        // Add "timer" label
        timerLabel = [CCLabelBMFont labelWithString:@"TIME:    \n   00:00" fntFile:[NSString stringWithFormat:@"insolent-24%@.fnt", iPadSuffix] width:windowSize.width / 2 alignment:CCTextAlignmentLeft];
        timerLabel.position = ccp(235 * fontMultiplier + iPadOffset.x, 380 * fontMultiplier + iPadOffset.y);
        [self addChild:timerLabel];
        
        // Schedule update method for timer
        timer = 0;
        [self schedule:@selector(updateTimer:) interval:1.0];
        
        // Load level dictionary
        NSString *filename = [GameSingleton sharedGameSingleton].levelToLoad;
        NSData *json = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"json"]];
        NSError *e = nil;
        
        level = [NSDictionary dictionaryWithJSONData:json error:&e];
        
        if (e != nil)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not load puzzle." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            
            [[CCDirector sharedDirector] replaceScene:[LevelSelectScene scene]];
        }
        
        // Determine if the level is the tutorial or not
        if ([[GameSingleton sharedGameSingleton].levelToLoad isEqualToString:@"tutorial.json"])
        {
            isTutorial = YES;
			tutorialStep = 1;
            
			// Set up the "next" button that progresses thru tutorial steps
			tutorialButton = [CCMenuItemImage itemFromNormalImage:[NSString stringWithFormat:@"tutorial-next-button%@.png", iPadSuffix] selectedImage:[NSString stringWithFormat:@"tutorial-next-button-selected%@.png", iPadSuffix] block:^(id sender) {
				// Play SFX
				[[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
				
				[self dismissTextWindow];
				
				// Show tutorial text on steps that don't require action
				// i.e. the steps here all require the player to mark or fill certain rows/columns
				// The corresponding step increment code is in the update: method
				if (tutorialStep != 6 && 
					tutorialStep != 10 && 
					tutorialStep != 13 && tutorialStep != 14 && tutorialStep != 15 && tutorialStep != 17 && tutorialStep != 18 && tutorialStep != 19)
				{
					// Show current instructions
					[self showTutorial];
					
					// Increment counter
					tutorialStep++;
				}
				else
				{
					// Hide the button and set it to inactive
					tutorialButton.isEnabled = YES;
					tutorialButton.opacity = 255;
				}
			}];
			
			tutorialButton.opacity = 0;
			
			tutorialMenu = [CCMenu menuWithItems:tutorialButton, nil];
			tutorialMenu.position = ccp(windowSize.width - tutorialButton.contentSize.width / 1.5 - iPadOffset.x, windowSize.height / 2.5);
			[self addChild:tutorialMenu z:3];
			
			// Show current instructions + "next" button after a slight delay
			[self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0], [CCCallBlock actionWithBlock:^(void) {
				[self showTutorial];
				
				[tutorialButton runAction:[CCFadeIn actionWithDuration:0.2]];
				
				// Increment counter
				tutorialStep++;
			}], nil]];
        }
        
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
            c.position = ccp(x * blockSize + offset.x + blockSize / 2, y * blockSize + offset.y + blockSize / 2);
            [self addChild:c z:2];
            
            // Add clue to the organization array
            [clues addObject:c];
        }
        
        // Increment the "attempts" counter and save to NSUserDefaults
        NSMutableDictionary *levelStatus = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"levelStatus"]];
        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:[levelStatus objectForKey:[GameSingleton sharedGameSingleton].levelToLoad]];
        
        if ([d objectForKey:@"attempts"] != nil)
        {
            int attempts = [(NSNumber *)[d objectForKey:@"attempts"] intValue];
            [d setObject:[NSNumber numberWithInt:attempts + 1] forKey:@"attempts"];
        }
        else 
        {
            d = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"attempts"];
        }
        
        // Re-save the current level's data into the main dictionary
        [levelStatus setObject:d forKey:[GameSingleton sharedGameSingleton].levelToLoad];

        // Sync the main dictionary back into NSUserDefaults
        [[NSUserDefaults standardUserDefaults] setObject:levelStatus forKey:@"levelStatus"];
        [[NSUserDefaults standardUserDefaults] synchronize];
	}
	return self;
}

/**
 * Method that gets called every second, to update the "timer" label
 */
- (void)updateTimer:(ccTime)dt
{
    timer++;
    timerLabel.string = [NSString stringWithFormat:@"TIME:    \n   %02i:%02i", timer / 60, timer % 60];
    
    // This method also checks to progress through the tutorial
    if (isTutorial)
	{
		switch (tutorialStep) 
		{
			case 6:
            {
                // Check whether the first column is filled
                BOOL success = YES;
                for (int i = 0; i < gridSize * gridSize; i += gridSize)
                {
                    // If any one of the blocks isn't filled, the check fails
//                    if ([[gridStatus objectAtIndex:i] intValue] != kBlockFilled)
                    {
                        success = NO;
                    }
                }
                
                // However, if the check passes, go to the next step
                if (success)
                {
                    // Show instructional text
                    [self showTutorial];
                    
                    // Increment step counter
                    tutorialStep++;
                    
                    // Enable/show button
                    tutorialButton.isEnabled = YES;
                    tutorialButton.opacity = 255;
                }
            }
				break;
			default:
				break;
		}
	}
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Get the touch coords
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
    
	// Only register the touch as "valid" if it's within the allowed indices of the grid
    CGRect gridBounds = CGRectMake(offset.x, offset.y, gridSize * blockSize, gridSize * blockSize);
    CGRect touchBounds = CGRectMake(touchPoint.x, touchPoint.y, 1, 1);		// 1x1 square
    
	if (CGRectIntersectsRect(gridBounds, touchBounds))
	{
        touchStart = touchPrevious = touchPoint;
        
        // Figure out the row/column that was touched
        touchRow = startRow = previousRow = (touchPoint.y - offset.y) / blockSize;
        touchCol = startCol = previousCol = (touchPoint.x - offset.x) / blockSize;
  
        // Determine if we need to delete a square here
        for (int i = 0; i < [squares count]; i++)
        {
            RoundRectNode *r = [squares objectAtIndex:i];
            
            // RoundRectNode origin is upper left
            // CGRect origin is lower left
            
            int width = r.size.width, height = r.size.height;
            CGRect rectBounds = CGRectMake(r.position.x, r.position.y - height, width, height);
            CGRect touchBounds = CGRectMake(touchPoint.x, touchPoint.y, 1, 1);		// 1x1 square
            
            // If the touch point is inside the bounds of an existing square, remove it
            if (CGRectIntersectsRect(rectBounds, touchBounds))
            {
                [self removeChild:r cleanup:NO];
                [squares removeObjectAtIndex:i];
                i--;
                [[SimpleAudioEngine sharedEngine] playEffect:@"hit.caf"];
            }
        }
        
//        selection.visible = YES;
        selection.size = CGSizeMake(blockSize, blockSize);  // Default size
        selection.position = ccp((touchCol * blockSize) + offset.x, (touchRow * blockSize) + (offset.y + blockSize));
	}
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Get the touch coords
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
    
    // Figure out the row/column that was touched
	touchRow = (touchPoint.y - offset.y) / blockSize;
	touchCol = (touchPoint.x - offset.x) / blockSize;
    
    // Limit movement to within the grid
    if (touchRow > gridSize - 1)
    {
        touchRow = gridSize - 1;
    }
    
    if (touchRow < 0)
    {
        touchRow = 0;
    }
    
    if (touchCol > gridSize - 1)
    {
        touchCol = gridSize - 1;
    }
    
    if (touchCol < 0)
    {
        touchCol = 0;
    }
    
    // Determine the width/height of the selection by subtracting the start from the current touch row/col
    int width = abs(startCol - touchCol) + 1,
        height = abs(startRow - touchRow) + 1;
    
    // If touches move out of the initial square, determine direction and scale appropriately
    // y-axis
    if (touchRow != previousRow)
    {
        selection.visible = YES;
        BOOL overlap = NO;
        
        // Determine if new size would overlap an existing square
        CGRect selectionBounds = CGRectMake(selection.position.x, selection.position.y - (height * blockSize), selection.size.width, height * blockSize);
        if (touchRow >= startRow)
        {
            selectionBounds = CGRectMake(selection.position.x, (touchRow * blockSize) + offset.y + blockSize - (height * blockSize), selection.size.width, height * blockSize);
        }
        
        for (int i = 0; i < [squares count]; i++)
        {
            RoundRectNode *r = [squares objectAtIndex:i];
            
            CGRect rectBounds = CGRectMake(r.position.x, r.position.y - r.size.height, r.size.width, r.size.height);
            if (CGRectIntersectsRect(selectionBounds, rectBounds))
            {
                overlap = YES;
            }
        }
        
        if (overlap == NO)
        {
            
            // Change height
            selection.size = CGSizeMake(selection.size.width, height * blockSize);
            
            // Determine if necessary to just draw (normal) or draw & move up (upwards movement)
            if (touchRow >= startRow)
            {
                selection.position = ccp(selection.position.x, 
                                         (touchRow * blockSize) + offset.y + blockSize);
            }
            
            // Play SFX
            [[SimpleAudioEngine sharedEngine] playEffect:@"mark.caf"];
        }
    }
    
    // x-axis
    if (touchCol != previousCol)
    {
        selection.visible = YES;
        BOOL overlap = NO;
        
        // Determine if new size would overlap an existing square
        CGRect selectionBounds = CGRectMake(selection.position.x, selection.position.y - (height * blockSize), width * blockSize, selection.size.height);
        if (touchCol <= startCol)
        {
            selectionBounds = CGRectMake((touchCol * blockSize) + offset.x, selection.position.y - (height * blockSize), width * blockSize, selection.size.height);
        }
        
        for (int i = 0; i < [squares count]; i++)
        {
            RoundRectNode *r = [squares objectAtIndex:i];
            
            CGRect rectBounds = CGRectMake(r.position.x, r.position.y - r.size.height, r.size.width, r.size.height);
            if (CGRectIntersectsRect(selectionBounds, rectBounds))
            {
                overlap = YES;
            }
        }
        
        if (overlap == NO)
        {
            selection.size = CGSizeMake(width * blockSize, selection.size.height);
            
            // Determine if necessary to just draw (normal) or draw & move left (left movement)
            if (touchCol <= startCol)
            {
                selection.position = ccp((touchCol * blockSize) + offset.x, 
                                         selection.position.y);
            }
            
            // Play SFX
            [[SimpleAudioEngine sharedEngine] playEffect:@"mark.caf"];
        }
    }
    
    // Update the "area" label
    areaLabel.string = [NSString stringWithFormat:@"AREA:\n   %i", width * height];
    
    // Store the "previous" value for each row/col
    previousCol = touchCol;
    previousRow = touchRow;
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    UITouch *touch = [touches anyObject];
//	CGPoint touchPoint = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
    
    // Create new roundrect w/ same props as "selection"
    RoundRectNode *r = [RoundRectNode initWithRectSize:CGSizeMake(selection.size.width, selection.size.height)];
    r.position = selection.position;
    
    // "Eat" any squares that overlap the newly created one
//    CGRect newRect = CGRectMake(r.position.x, r.position.y - r.size.height, r.size.width, r.size.height);
//    for (int i = 0; i < [squares count]; i++) 
//    {
//        RoundRectNode *o = [squares objectAtIndex:i]; 
//        CGRect oldRect = CGRectMake(o.position.x, o.position.y - o.size.height, o.size.width, o.size.height);
//        
//        // Remove old squares that overlap
//        if (CGRectIntersectsRect(newRect, oldRect))
//        {
//            [self removeChild:o cleanup:NO];
//            [squares removeObjectAtIndex:i];
//            i--;
//        }
//    }
    
    // If player just tapped, simply remove the tapped square
//    if (CGPointEqualToPoint(touchStart, touchPoint) == NO)
    if (selection.visible == YES)
    {
        // Add new square to layer
        [self addChild:r z:1];
        
        // Store it in the "squares" array
        [squares addObject:r];
        
        // Determine if the square overlaps a clue, and the square's area is equal to the clue, change the color of the sprite
        
        areaLabel.string = @"AREA:\n   -";
    } 
    
    // Hide the original "selection" roundrect
    selection.visible = NO;
    
    // Check to see if the puzzle was completed successfully
    if ([self checkSolution])
    {
        [self win];
    }
}

/**
 * Determine if a puzzle has been completed by checking player-placed squares against clue objects
 */
- (BOOL)checkSolution
{
    /*
     Psuedo-code steps to check solution
     1. Iterate through player squares
     2. Iterate through clues
     3. Check to make sure that 
        A. a square's CGRect only contains one clue and
        B. the square's area is equal to that clue's value
     4. If those conditions are not met at any point, return false
     5. Otherwise, return true
     6. This (brute force) algorithm has O(n^2) complexity
     */
    
    // Fast fail
    if ([squares count] != [clues count])
    {
        return NO;
    }
    
    // Otherwise, do our iterations
    for (RoundRectNode *s in squares)
    {
        int cluesInSquare = 0;
        Clue *validClue;
        CGRect squareRect = CGRectMake(s.position.x, s.position.y - s.size.height, s.size.width, s.size.height);

        for (Clue *c in clues)
        {
           // Create rects to check here
            CGRect clueRect = CGRectMake(c.position.x - c.contentSize.width / 2, c.position.y - c.contentSize.height / 2, c.contentSize.width, c.contentSize.height);
            if (CGRectIntersectsRect(squareRect, clueRect))
            {
                cluesInSquare++;
                validClue = c;
            }
        }

        // No clue could be found for the square
        if (!validClue.value)
        {
            return NO;
        }
        
        // Fail if more than one clue in square
        if (cluesInSquare > 1)
        {
            return NO;
        }
        
        // Fail if the square's area doesn't match the clue's value
        if (validClue.value != s.area)
        {
            return NO;
        }
    }
    
    return YES;
}

/**
 * Crap that happens when you solve the puzzle successfully
 */
- (void)win
{
    // Save details about the completed time to NSUserDefaults
    NSMutableDictionary *levelStatus = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"levelStatus"]];
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:[levelStatus objectForKey:[GameSingleton sharedGameSingleton].levelToLoad]];
    
    // If level was previously completed...
    if ([d objectForKey:@"time"])
    {
        int oldTime = [(NSNumber *)[d objectForKey:@"time"] intValue];
        
        // If new time is less than old, save the new!
        if (timer < oldTime)
        {
            [d setObject:[NSNumber numberWithInt:timer] forKey:@"time"];
        }
    }
    else 
    {
        [d setObject:[NSNumber numberWithInt:timer] forKey:@"time"];
    }
    
    // Re-save the current level's data into the main dictionary
    [levelStatus setValue:d forKey:[GameSingleton sharedGameSingleton].levelToLoad];
    
    // Sync the main dictionary back into NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setObject:levelStatus forKey:@"levelStatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    CCTransitionMoveInT *transition = [CCTransitionMoveInT transitionWithDuration:0.5 scene:[LevelSelectScene scene]];
    [[CCDirector sharedDirector] replaceScene:transition];
}

/**
 * Progresses through the steps in the tutorial
 */
- (void)showTutorial
{
	NSArray *instructions = [NSArray arrayWithObjects:@"Welcome to Nonogram Madness! Nonograms are logic puzzles that reveal an image when solved.", 
                             /* 2 */			@"Solve each puzzle using the numeric clues on the top and left of the grid.",
                             /* 3 */			@"Each number represents squares in the grid that are \"filled\" in a row or column.",
                             /* 4 */			@"Clues with multiple numbers mean a gap of one (or more) between filled squares.",
                             /* 5 */			@"Look at the first column. The clue is \"5\". Tap \"fill\" then tap all 5 squares.",
                             // Action
                             /* 6 */			@"The second column is harder. We don't know where the two single filled squares are.",
                             /* 7 */			@"Skip difficult rows or columns and come back to them later.",
                             /* 8 */			@"Look at the third column. The clue is \"1 1 1\". There's a gap between each filled square.",
                             /* 9 */			@"Make sure the \"fill\" button is selected, then fill in three squares with a gap between each.",
                             // Action
                             /* 10 */		@"You can use the \"mark\" action to protect blocks that are supposed to be empty.",
                             /* 11 */		@"Erase a marked square by tapping it again. Don't worry about making a mistake.",
                             /* 12 */		@"Tap \"mark\" and mark the empty squares so you don't accidentally try to fill them in later.",
                             // Action
                             /* 13 */		@"Check out the fourth column. The clue is \"1 3\". Fill one square, leave a gap, then fill three more.",
                             // Action
                             /* 14 */		@"The fifth column is empty. \"Mark\" all those squares to show they don't need to be filled in.",
                             // Action
                             /* 15 */		@"Let's move on to clues in the rows. The first row has four sequential filled squares.",
                             /* 16 */		@"Fill in the only open square in this row to complete it.",
                             // Action
                             /* 17 */		@"The second, third, and fourth rows are already complete. Mark all the open squares in them.",
                             // Action
                             /* 18 */		@"Use what you've learned so far to finish the puzzle. I'm sure you can figure it out.",
                             // Action
							 nil];	
	
	// Show the instructional text for the current step
	if (tutorialStep - 1 < [instructions count])
	{
		[self showTextWindowAt:ccp(windowSize.width / 2, (110 * fontMultiplier) + iPadOffset.y) withText:[instructions objectAtIndex:tutorialStep - 1]];
	}
	
    //	CCLOG(@"Step %i", tutorialStep);
	
	// Determine if any additional graphics or effects need to be shown
	switch (tutorialStep) 
	{
		case 1:
			break;
		case 2:
			// Blink over clue areas
			tutorialHighlight = [CCSprite spriteWithFile:[NSString stringWithFormat:@"2%@.png", iPadSuffix]];
			tutorialHighlight.position = ccp(100 * fontMultiplier + iPadOffset.x, 269 * fontMultiplier + iPadOffset.y);
			[self addChild:tutorialHighlight z:1];
			break;
		case 3:
			break;
		case 4:
			// Hide clue highlihgt
			tutorialHighlight.opacity = 0;
			break;
		case 5:
			// Highlight first column blocks
			[tutorialHighlight setTexture:[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"5%@.png", iPadSuffix]]];
			tutorialHighlight.opacity = 255;
			
			// Hide the button and set it to inactive
			tutorialButton.opacity = 0;
			[tutorialButton setIsEnabled:NO];
			break;
		case 6:
			// Highlight second column clues
			[tutorialHighlight setTexture:[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"6%@.png", iPadSuffix]]];
			break;
		case 7:
			// Highlight second column clues
			break;
		case 8:
			// Hightlight third column clues
            
			[tutorialHighlight setTexture:[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"8%@.png", iPadSuffix]]];
			break;
		case 9:
			// Highlight correct third column blocks
			[tutorialHighlight setTexture:[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"9%@.png", iPadSuffix]]];
			tutorialHighlight.opacity = 255;
			
			// Hide the button and set it to inactive
			tutorialButton.opacity = 0;
			[tutorialButton setIsEnabled:NO];
			break;
		case 10:
			break;
		case 11:
			break;
		case 12:
			// Blink on correct fourth column blocks
			[tutorialHighlight setTexture:[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"12%@.png", iPadSuffix]]];
			
			// Hide the button and set it to inactive
			tutorialButton.opacity = 0;
			[tutorialButton setIsEnabled:NO];
			break;
		case 13:
			// Hide the button and set it to inactive
			tutorialButton.opacity = 0;
			[tutorialButton setIsEnabled:NO];
			
			// Highlight open blocks in fourth column
			[tutorialHighlight setTexture:[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"13%@.png", iPadSuffix]]];
			break;
		case 14:
			// Hide the button and set it to inactive
			tutorialButton.opacity = 0;
			[tutorialButton setIsEnabled:NO];
			
			// Highlight all open blocks in fifth column
			[tutorialHighlight setTexture:[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"14%@.png", iPadSuffix]]];
			break;
		case 15:
			[tutorialHighlight setTexture:[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"15%@.png", iPadSuffix]]];
			// Hide the button and set it to inactive
			tutorialButton.opacity = 0;
			[tutorialButton setIsEnabled:NO];
			break;
		case 16:
			// Blink over open square in first row
			tutorialHighlight.opacity = 255;
			[tutorialHighlight setTexture:[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"16%@.png", iPadSuffix]]];
			
			tutorialButton.opacity = 0;
			[tutorialButton setIsEnabled:NO];
			break;
		case 17:
			// Blink over 2nd, 3rd, and 4th rows
			[tutorialHighlight setTexture:[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"17%@.png", iPadSuffix]]];
			
			tutorialButton.opacity = 0;
			[tutorialButton setIsEnabled:NO];
			break;
		case 18:
			// Turn off highlights
			tutorialHighlight.opacity = 0;
			
			tutorialButton.opacity = 0;
			[tutorialButton setIsEnabled:NO];
			break;
		default:
			break;
	}
}

/**
 * Shows a blob of text over a "window" background, then animates it on to the screen
 * (sprite and label vars are class properties)
 */
- (void)showTextWindowAt:(CGPoint)position withText:(NSString *)text
{
	// Create the background sprite if it doesn't exist
	if (!textWindowBackground)
	{
		textWindowBackground = [CCSprite spriteWithFile:[NSString stringWithFormat:@"text-window-background%@.png", iPadSuffix]];
		[self addChild:textWindowBackground z:5];		// Should be on top of everything
	}
	
	// Create the label if it doesn't exist
	if (!textWindowLabel)
	{
		int defaultFontSize = 12;
		textWindowLabel = [CCLabelTTF labelWithString:text dimensions:CGSizeMake(textWindowBackground.contentSize.width - 20 * fontMultiplier, textWindowBackground.contentSize.height - 20 * fontMultiplier) alignment:CCTextAlignmentLeft fontName:@"insolent.otf" fontSize:defaultFontSize * fontMultiplier];
		textWindowLabel.position = ccp(textWindowBackground.contentSize.width / 2, textWindowBackground.contentSize.height / 2);
		textWindowLabel.color = ccc3(0, 0, 0);
		[textWindowBackground addChild:textWindowLabel];
	}
	// Otherwise, just update its' text
	else
	{
		[textWindowLabel setString:text];
	}
	
	// Hide the window initially
	textWindowBackground.opacity = 0;
	
	// Hide the text initially
	textWindowLabel.opacity = 0;
	
	// Position below its' intended final location
	textWindowBackground.position = ccp(position.x, position.y - (100 * fontMultiplier));
	
	id move = [CCMoveTo actionWithDuration:0.4 position:position];
	id ease = [CCEaseBackOut actionWithAction:move];
	id fadeIn = [CCFadeIn actionWithDuration:0.3];
	
	[textWindowBackground runAction:[CCSpawn actions:ease, fadeIn, nil]];
	[textWindowLabel runAction:[CCFadeIn actionWithDuration:0.3]];
}

/**
 * Animates the text window off screen
 */
- (void)dismissTextWindow
{
	id fadeOut = [CCFadeOut actionWithDuration:0.2];
	id move = [CCMoveTo actionWithDuration:0.4 position:ccp(textWindowBackground.position.x, textWindowBackground.position.y - (100 * fontMultiplier))];
	
	[textWindowBackground runAction:[CCSpawn actions:move, fadeOut, nil]];
	[textWindowLabel runAction:[CCFadeOut actionWithDuration:0.2]];
}

/**
 * Method that is chained at the end of action sequences to remove a sprite after it has been displayed
 */
- (void)removeNodeFromParent:(CCNode *)node
{
	[node.parent removeChild:node cleanup:YES];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	[squares release];
    [clues release];
    
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
