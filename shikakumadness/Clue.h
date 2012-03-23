//
//  Clue.h
//  Shikaku Madness
//
//  Created by Nathan Demick on 3/20/12.
//  Copyright 2012 Ganbaru Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Clue : CCSprite 
{
    int value;
}

@property int value;

+ (Clue *)clueWithNumber:(int)number;

@end
