//
//  EditorScene.m
//  shukakumadness
//
//  Created by Nathan Demick on 3/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "EditorScene.h"


@implementation EditorScene

+(CCScene *) scene
{
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];

    // 'layer' is an autorelease object.
    EditorScene *layer = [EditorScene node];

    // add layer as a child to scene
    [scene addChild: layer];

    // return the scene
    return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if ((self = [super init]))
    {
        // Get window size
        window = [CCDirector sharedDirector].winSize;
        
        // Determine offset of grid
        if ([GameSingleton sharedGameSingleton].isPad)
        {
            // Determine offset of grid
            offset = ccp(64, 32);
            blockSize = 64;
            iPadSuffix = @"-ipad";
            fontMultiplier = 2;
        }
        else 
        {
            offset = ccp(0, 0);
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
		CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
        background.position = ccp(window.width / 2, window.height / 2);
        [self addChild:background];
        
        // Add grid
        CCSprite *grid = [CCSprite spriteWithFile:@"grid.png"];
        grid.position = ccp(window.width / 2, grid.contentSize.height / 2 + offset.y);
        [self addChild:grid];
        
        // Add title/buttons for controlling the editor
        
        // "Quit" button
        CCMenuItemImage *quitButton = [CCMenuItemImage itemFromNormalImage:@"quit-button.png" selectedImage:@"quit-button.png" block:^(id sender) {
            // TODO: Pop up a modal asking if user wants to save the level
            [self saveLevel];
            
            CCTransitionMoveInT *transition = [CCTransitionMoveInT transitionWithDuration:0.5 scene:[TitleScene scene]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        
        // Difficulty toggle button
        CCMenuItemImage *easyButton = [CCMenuItemImage itemFromNormalImage:@"easy-button.png" selectedImage:@"easy-button.png"];
        CCMenuItemImage *mediumButton = [CCMenuItemImage itemFromNormalImage:@"medium-button.png" selectedImage:@"medium-button.png"];
        CCMenuItemImage *hardButton = [CCMenuItemImage itemFromNormalImage:@"hard-button.png" selectedImage:@"hard-button.png"];
        
        CCMenuItemToggle *difficulty = [CCMenuItemToggle itemWithBlock:^(id sender) {
            NSLog(@"Selected difficulty: %i", [(CCMenuItemToggle *)sender selectedIndex]);
        } items:easyButton, mediumButton, hardButton, nil];

        // "Tool" toggle button
        CCMenuItemImage *squareButton = [CCMenuItemImage itemFromNormalImage:@"square-button.png" selectedImage:@"square-button.png"];
        CCMenuItemImage *clueButton = [CCMenuItemImage itemFromNormalImage:@"clue-button.png" selectedImage:@"clue-button.png"];
        
        CCMenuItemToggle *tool = [CCMenuItemToggle itemWithBlock:^(id sender) {
            NSLog(@"Selected tool: %i", [(CCMenuItemToggle *)sender selectedIndex]);
        } items:squareButton, clueButton, nil];
        
        // Title graphic
        CCSprite *title = [CCSprite spriteWithFile:@"editor-title.png"];
        title.position = ccp(title.contentSize.width / 2, window.height - title.contentSize.height / 2);
        [self addChild:title];
                
        // Menus for buttons
        CCMenu *quitMenu = [CCMenu menuWithItems:quitButton, nil];
        quitMenu.position = ccp(window.width  - quitButton.contentSize.width / 2, window.height - quitButton.contentSize.height / 2);
        [self addChild:quitMenu];        
        

        // "Tools" menu
        CCMenu *toolsMenu = [CCMenu menuWithItems:difficulty, tool, nil];
        toolsMenu.position = ccp(window.width / 2, grid.position.y + (grid.contentSize.height / 2) + (difficulty.contentSize.height / 1.5));
        [toolsMenu alignItemsHorizontallyWithPadding:20.0];
        [self addChild:toolsMenu];
        
        // Tools menu labels
        CCSprite *toolsLabel = [CCSprite spriteWithFile:@"editor-button-labels.png"];
        toolsLabel.position = ccp(window.width / 2, toolsMenu.position.y + toolsLabel.contentSize.height * 2);
        [self addChild:toolsLabel];
        
        // Set up a test level
        level = [NSArray arrayWithObjects:
                 [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:2], @"x", [NSNumber numberWithInt:0], @"y", [NSNumber numberWithInt:3], @"value", nil],
                 [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:5], @"x", [NSNumber numberWithInt:0], @"y", [NSNumber numberWithInt:9], @"value", nil],
                 [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:9], @"x", [NSNumber numberWithInt:0], @"y", [NSNumber numberWithInt:4], @"value", nil],
                 [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], @"x", [NSNumber numberWithInt:2], @"y", [NSNumber numberWithInt:4], @"value", nil],
                 [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:5], @"x", [NSNumber numberWithInt:3], @"y", [NSNumber numberWithInt:6], @"value", nil],
                 [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:7], @"x", [NSNumber numberWithInt:3], @"y", [NSNumber numberWithInt:8], @"value", nil],
                 [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:9], @"x", [NSNumber numberWithInt:3], @"y", [NSNumber numberWithInt:12], @"value", nil],
                 [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], @"x", [NSNumber numberWithInt:6], @"y", [NSNumber numberWithInt:8], @"value", nil],
                 [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:2], @"x", [NSNumber numberWithInt:6], @"y", [NSNumber numberWithInt:6], @"value", nil],
                 [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:4], @"x", [NSNumber numberWithInt:6], @"y", [NSNumber numberWithInt:8], @"value", nil],
                 [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], @"x", [NSNumber numberWithInt:9], @"y", [NSNumber numberWithInt:9], @"value", nil],
                 [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:4], @"x", [NSNumber numberWithInt:9], @"y", [NSNumber numberWithInt:12], @"value", nil],
                 [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:7], @"x", [NSNumber numberWithInt:9], @"y", [NSNumber numberWithInt:5], @"value", nil],
                 [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:9], @"x", [NSNumber numberWithInt:7], @"y", [NSNumber numberWithInt:6], @"value", nil],
                 nil];
        
        // Grab each clue out of the level dictionary, create a "clue" object from it, then add it to the layer
        for (int i = 0; i < [level count]; i++)
        {
            NSDictionary *clue = [level objectAtIndex:i];
            // Get x,y, and value for clue
            int value = [(NSNumber *)[clue objectForKey:@"value"] intValue],
            x = [(NSNumber *)[clue objectForKey:@"x"] intValue],
            y = [(NSNumber *)[clue objectForKey:@"y"] intValue];
            
            Clue *c = [Clue clueWithNumber:value];
            c.position = ccp(x * blockSize + offset.x + blockSize / 2, y * blockSize + offset.y + blockSize / 2);
            [self addChild:c];
            
            // Add clue to the organization array
            [clues addObject:c];
        }
        
        [level retain];
	}
	return self;
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

            int width = r.size.width, height = r.size.height;
            CGRect rectBounds = CGRectMake(r.position.x, r.position.y - height, width, height);
            CGRect touchBounds = CGRectMake(touchPoint.x, touchPoint.y, 1, 1);		// 1x1 square
            
            // If the touch point is inside the bounds of an existing square, remove it
            if (CGRectIntersectsRect(rectBounds, touchBounds))
            {
                [self removeChild:r cleanup:NO];
                [squares removeObjectAtIndex:i];
                i--;
            }
        }
        
        selection.visible = YES;
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
        // Change height
        selection.size = CGSizeMake(selection.size.width, height * blockSize);
        
        // Determine if necessary to just draw (normal) or draw & move up (upwards movement)
        if (touchRow >= startRow)
        {
            selection.position = ccp(selection.position.x, 
                                     (touchRow * blockSize) + offset.y + blockSize);
        }
        
        // Play SFX
        //        [[SimpleAudioEngine sharedEngine] playEffect:@"mark.caf"];
    }
    
    // x-axis
    if (touchCol != previousCol)
    {
        selection.size = CGSizeMake(width * blockSize, selection.size.height);
        
        // Determine if necessary to just draw (normal) or draw & move left (left movement)
        if (touchCol <= startCol)
        {
            selection.position = ccp((touchCol * blockSize) + offset.x, 
                                     selection.position.y);
        }
        
        // Play SFX
        //        [[SimpleAudioEngine sharedEngine] playEffect:@"mark.caf"];
    }

    // Store the "previous" value for each row/col
    previousCol = touchCol;
    previousRow = touchRow;
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
    
    // Create new roundrect w/ same props as "selection"
    RoundRectNode *r = [RoundRectNode initWithRectSize:CGSizeMake(selection.size.width, selection.size.height)];
    r.position = selection.position;
    
    // "Eat" any squares that overlap the newly created one
    CGRect newRect = CGRectMake(r.position.x, r.position.y - r.size.height, r.size.width, r.size.height);
    for (int i = 0; i < [squares count]; i++) 
    {
        RoundRectNode *o = [squares objectAtIndex:i]; 
        CGRect oldRect = CGRectMake(o.position.x, o.position.y - o.size.height, o.size.width, o.size.height);
        
        // Remove old squares that overlap
        if (CGRectIntersectsRect(newRect, oldRect))
        {
            [self removeChild:o cleanup:NO];
            [squares removeObjectAtIndex:i];
            i--;
        }
    }
    
    // If player just tapped, simply remove the tapped square
    if (CGPointEqualToPoint(touchStart, touchPoint) == NO)
    {
        // Add new square to layer
        [self addChild:r];
        
        // Store it in the "squares" array
        [squares addObject:r];
        
        areaLabel.string = @"Area: ~";
    }
    
    // Hide the original "selection" roundrect
    selection.visible = NO;
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
        // TODO: this borks
        if (validClue.value != s.area)
        {
            return NO;
        }
    }
    
    return YES;
}

/**
 * Write out the current level object to disk, in the form of a serialized .plist
 */
- (BOOL)saveLevel
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *uuid = [self createUUID];
    NSString *pathToFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", uuid]];
    
    if (![fileManager fileExistsAtPath:pathToFile])
    {
        NSLog(@"Trying to write %@", pathToFile);
        return [level writeToFile:pathToFile atomically:YES];
    }
    // To read, use method "initWithContentsOfFile"

    return NO;
}

/**
 * Create unique identifier for puzzle filename
 */
- (NSString *)createUUID
{
    // Create universally unique identifier (object)
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    
    // Get the string representation of CFUUID object.
    NSString *uuidStr = [(NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject) autorelease];
    
    CFRelease(uuidObject);
    
    return uuidStr;
}

- (NSArray *)getDocumentsDirectoryContents
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *directoryContent = [[NSFileManager defaultManager] directoryContentsAtPath:documentsDirectory];
    
    NSLog(@"%@", documentsDirectory);
    return directoryContent;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	[squares release];
    [clues release];
    [level release];
    
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
