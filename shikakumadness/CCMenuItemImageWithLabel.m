//
//  CCMenuItemImageWithLabel.m
//  shikakumadness
//
//  Created by Nathan Demick on 4/17/12.
//  Copyright 2012 Ganbaru Games. All rights reserved.
//

#import "CCMenuItemImageWithLabel.h"

#define kFontName @"insolent.otf"
#define kFontSize 24
#define kDefaultNormalImage @"button-background%@.png"
#define kDefaultSelectedImage @"button-background-selected%@.png"

@implementation CCMenuItemImageWithLabel

@synthesize label, iPadSuffix, fontMultipler;

- (id)init
{
    if ((self = [super init]))
    {
    }
    return self;
}

+ (id)itemFromNormalImage:(NSString *)value selectedImage:(NSString *)value2 text:(NSString *)text block:(void(^)(id sender))block 
{
    NSString *iPadSuffix = @"";
    int fontMultiplier = 1;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        iPadSuffix = @"-hd";
        fontMultiplier = 2;
    }
    
    // Create button
    CCMenuItemImageWithLabel *item = [self itemFromNormalImage:value selectedImage:value2 disabledImage:nil block:block];
    
    // Create label + append to button
    item.label = [CCLabelTTF labelWithString:text dimensions:CGSizeMake(item.contentSize.width, item.contentSize.height) alignment:CCTextAlignmentCenter fontName:kFontName fontSize:kFontSize];
    item.label.color = ccc3(0, 0, 0);
    item.label.position = ccp(item.contentSize.width / 2, item.contentSize.height / 3);
    [item addChild:item.label];
    
    // Return button
	return item;
}

+ (id)itemWithText:(NSString *)text block:(void(^)(id sender))block
{
    NSString *iPadSuffix = @"";
    int fontMultiplier = 1;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        iPadSuffix = @"-hd";
        fontMultiplier = 2;
    }
    
    // Create button
    CCMenuItemImageWithLabel *item = [self itemFromNormalImage:[NSString stringWithFormat:@"button-background%@.png", iPadSuffix] selectedImage:[NSString stringWithFormat:@"button-background-selected%@.png", iPadSuffix] disabledImage:nil block:block];
    
    // Create label + append to button
    item.label = [CCLabelTTF labelWithString:text dimensions:CGSizeMake(item.contentSize.width, item.contentSize.height) alignment:CCTextAlignmentCenter fontName:kFontName fontSize:kFontSize * fontMultiplier];
    item.label.color = ccc3(0, 0, 0);
    item.label.position = ccp(item.contentSize.width / 2.1, item.contentSize.height / 8);
    [item addChild:item.label];
    
    // Return button
	return item;
}

+ (id)itemWithText:(NSString *)text size:(NSString *)size block:(void(^)(id sender))block
{
    NSString *iPadSuffix = @"";
    int fontMultiplier = 1;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        iPadSuffix = @"-hd";
        fontMultiplier = 2;
    }
    
    // Create button
    CCMenuItemImageWithLabel *item;
    
    if ([size isEqualToString:@"small"])
    {
        item = [self itemFromNormalImage:[NSString stringWithFormat:@"small-button-background%@.png", iPadSuffix] selectedImage:[NSString stringWithFormat:@"small-button-background-selected%@.png", iPadSuffix] disabledImage:nil block:block];
        item.label = [CCLabelTTF labelWithString:text dimensions:CGSizeMake(item.contentSize.width, item.contentSize.height) alignment:CCTextAlignmentCenter fontName:kFontName fontSize:14 * fontMultiplier];
        item.label.position = ccp(item.contentSize.width / 2.1, item.contentSize.height / 10);
    }
    else if ([size isEqualToString:@"large"])
    {
        item = [self itemFromNormalImage:[NSString stringWithFormat:@"large-button-background%@.png", iPadSuffix] selectedImage:[NSString stringWithFormat:@"large-button-background-selected%@.png", iPadSuffix] disabledImage:nil block:block];
        item.label = [CCLabelTTF labelWithString:text dimensions:CGSizeMake(item.contentSize.width, item.contentSize.height) alignment:CCTextAlignmentLeft fontName:kFontName fontSize:26 * fontMultiplier];
        item.label.position = ccp(item.contentSize.width / 1.8, item.contentSize.height / 8);
    }
    // Default
    else
    {
        item = [self itemFromNormalImage:[NSString stringWithFormat:@"button-background%@.png", iPadSuffix] selectedImage:[NSString stringWithFormat:@"button-background-selected%@.png", iPadSuffix] disabledImage:nil block:block];
        item.label = [CCLabelTTF labelWithString:text dimensions:CGSizeMake(item.contentSize.width, item.contentSize.height) alignment:CCTextAlignmentCenter fontName:kFontName fontSize:kFontSize * fontMultiplier];
        item.label.position = ccp(item.contentSize.width / 2.1, item.contentSize.height / 8);
    }
    
    // Create label + append to button
    item.label.color = ccc3(0, 0, 0);
    [item addChild:item.label];
    
    // Return button
	return item; 
}

@end
