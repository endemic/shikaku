//
//  CCMenuItemImageWithLabel.h
//
//  Created by Nathan Demick on 4/17/12.
//  Copyright 2012 Ganbaru Games. All rights reserved.
//

#import "cocos2d.h"

@interface CCMenuItemImageWithLabel : CCMenuItemImage
{
    // Label w/ text on the button
    CCLabelTTF *label;
}

@property (nonatomic, retain) CCLabelTTF *label;

+ (id)itemWithText:(NSString *)text block:(void(^)(id sender))block;
+ (id)itemWithText:(NSString *)text size:(NSString *)size block:(void(^)(id sender))block;

@end
