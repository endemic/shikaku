//
//  CCMenuItemImageWithLabel.h
//  shikakumadness
//
//  Created by Nathan Demick on 4/17/12.
//  Copyright 2012 Ganbaru Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameSingleton.h"

@interface CCMenuItemImageWithLabel : CCMenuItemImage
{
    // Label w/ text on the button
    CCLabelTTF *label;
}

@property (nonatomic, retain) CCLabelTTF *label;
@property (nonatomic, retain) NSString *iPadSuffix;
@property (nonatomic) int fontMultipler;

+ (id)itemFromNormalImage:(NSString *)value selectedImage:(NSString *)value2 text:(NSString *)text block:(void(^)(id sender))block;
+ (id)itemWithText:(NSString *)text block:(void(^)(id sender))block;
+ (id)itemWithText:(NSString *)text size:(NSString *)size block:(void(^)(id sender))block;

@end
