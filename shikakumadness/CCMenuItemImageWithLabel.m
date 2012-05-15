//
//  CCMenuItemImageWithLabel.m
//
//  Created by Nathan Demick on 4/17/12.
//  Copyright 2012 Ganbaru Games. All rights reserved.
//

#import "CCMenuItemImageWithLabel.h"

#define kFontName @"insolent.otf"

#define kDefaultFontSize 24
#define kLargeFontSize 26
#define kSmallFontSize 14

#define kDefaultNormalImage @"button-background.png"
#define kDefaultSelectedImage @"button-background-selected.png"
#define kLargeNormalImage @"large-button-background.png"
#define kLargeSelectedImage @"large-button-background-selected.png"
#define kSmallNormalImage @"small-button-background.png"
#define kSmallSelectedImage @"small-button-background-selected.png"


@implementation CCMenuItemImageWithLabel

@synthesize label;

- (id)init
{
    if ((self = [super init]))
    {
    }
    return self;
}


+ (id)itemWithText:(NSString *)text block:(void(^)(id sender))block
{
    int fontMultiplier = 1;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        fontMultiplier = 2;
    }
    
    // Create button
    CCMenuItemImageWithLabel *item = [self itemFromNormalImage:kDefaultNormalImage selectedImage:kDefaultSelectedImage disabledImage:nil block:block];
    
    // Create label + append to button
    item.label = [CCLabelTTF labelWithString:text dimensions:CGSizeMake(item.contentSize.width, item.contentSize.height) alignment:CCTextAlignmentCenter fontName:kFontName fontSize:kDefaultFontSize * fontMultiplier];
    item.label.color = ccc3(0, 0, 0);    // Tweak this based on your button background image
    item.label.position = ccp(item.contentSize.width / 2.1, item.contentSize.height / 8);    // Tweak this based on your button background image
    [item addChild:item.label];
    
    // Return button
	return item;
}

+ (id)itemWithText:(NSString *)text size:(NSString *)size block:(void(^)(id sender))block
{
    int fontMultiplier = 1;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        fontMultiplier = 2;
    }
    
    // Create button
    CCMenuItemImageWithLabel *item;
    
    if ([size isEqualToString:@"small"])
    {
        item = [self itemFromNormalImage:kSmallNormalImage selectedImage:kSmallSelectedImage disabledImage:nil block:block];
        item.label = [CCLabelTTF labelWithString:text dimensions:CGSizeMake(item.contentSize.width, item.contentSize.height) alignment:CCTextAlignmentCenter fontName:kFontName fontSize:kSmallFontSize * fontMultiplier];
        item.label.position = ccp(item.contentSize.width / 2.1, item.contentSize.height / 10.5);    // Tweak this based on your button background image
    }
    else if ([size isEqualToString:@"large"])
    {
        item = [self itemFromNormalImage:kLargeNormalImage selectedImage:kLargeSelectedImage disabledImage:nil block:block];
        item.label = [CCLabelTTF labelWithString:text dimensions:CGSizeMake(item.contentSize.width, item.contentSize.height) alignment:CCTextAlignmentLeft fontName:kFontName fontSize:kLargeFontSize * fontMultiplier];
        item.label.position = ccp(item.contentSize.width / 1.8, item.contentSize.height / 8);    // Tweak this based on your button background image
    }
    // Default
    else
    {
        item = [self itemFromNormalImage:kDefaultNormalImage selectedImage:kDefaultSelectedImage disabledImage:nil block:block];
        item.label = [CCLabelTTF labelWithString:text dimensions:CGSizeMake(item.contentSize.width, item.contentSize.height) alignment:CCTextAlignmentCenter fontName:kFontName fontSize:kDefaultFontSize * fontMultiplier];
        item.label.position = ccp(item.contentSize.width / 2.1, item.contentSize.height / 8);    // Tweak this based on your button background image
    }
    
    // Create label + append to button
    item.label.color = ccc3(0, 0, 0);    // Tweak this based on your button background image
    [item addChild:item.label];
    
    // Return button
	return item; 
}

@end
