//
//  CCMenuItemImageWithLabel.m
//  shikakumadness
//
//  Created by Nathan Demick on 4/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CCMenuItemImageWithLabel.h"


@implementation CCMenuItemImageWithLabel

+ (id)itemFromNormalImage:(NSString *)value selectedImage:(NSString *)value2 text:(NSString *)text block:(void(^)(id sender))block 
{
    // Create button
    CCMenuItemImage *item = [self itemFromNormalImage:value selectedImage:value2 disabledImage:nil block:block];
    
    // Create label + append to button
    CCLabelTTF *label = [CCLabelTTF labelWithString:text dimensions:CGSizeMake(item.contentSize.width, item.contentSize.height) alignment:CCTextAlignmentCenter fontName:@"insolent.otf" fontSize:24.0];
    label.color = ccc3(0, 0, 0);
    label.position = ccp(item.contentSize.width / 2, item.contentSize.height / 3);
    [item addChild:label];
    
    // Return button
	return item;
}

+ (id)buttonWithText:(NSString *)text block:(void(^)(id sender))block
{
    NSString *iPadSuffix = @"";
    int fontMultiplier = 1;

    if ([GameSingleton sharedGameSingleton].isPad)
    {
        iPadSuffix = @"-hd";
        fontMultiplier = 2;
    }
    
    // Create button
    CCMenuItemImage *item = [self itemFromNormalImage:[NSString stringWithFormat:@"button-background%@.png", iPadSuffix] selectedImage:[NSString stringWithFormat:@"button-background-selected%@.png", iPadSuffix] disabledImage:nil block:block];
    
    // Create label + append to button
    CCLabelTTF *label = [CCLabelTTF labelWithString:text dimensions:CGSizeMake(item.contentSize.width, item.contentSize.height) alignment:CCTextAlignmentCenter fontName:@"insolent.otf" fontSize:24.0 * fontMultiplier];
    label.color = ccc3(0, 0, 0);
    label.position = ccp(item.contentSize.width / 2.1, item.contentSize.height / 8);
    [item addChild:label];
    
    // Return button
	return item;
}

@end
