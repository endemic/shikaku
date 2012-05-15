//
//  Clue.m
//  Shikaku Madness
//
//  Created by Nathan Demick on 3/20/12.
//  Copyright 2012 Ganbaru Games. All rights reserved.
//

#import "Clue.h"


@implementation Clue

@synthesize value;

// The init method we have to override - http://www.cocos2d-iphone.org/wiki/doku.php/prog_guide:sprites (bottom of page)
- (id)initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	// Call the init method of the parent class (CCSprite)
	if ((self = [super initWithTexture:texture rect:rect]))
	{
        
	}
	return self;
}

+ (Clue *)clueWithNumber:(int)number
{
    int fontMultiplier = 1;
    if ([GameSingleton sharedGameSingleton].isPad)
    {
        fontMultiplier = 2;
    }
    
    Clue *c = [self spriteWithFile:@"clue-background.png"];
    c.value = number;
    
    CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i", number] 
                                         dimensions:CGSizeMake(c.contentSize.width, c.contentSize.height) 
                                          alignment:CCTextAlignmentCenter 
                                           fontName:@"insolent.otf" 
                                           fontSize:18 * fontMultiplier];
    label.position = ccp(c.contentSize.width / 2, c.contentSize.height / 3.2);
    
    [c addChild:label];
    
    return c;
}

@end
