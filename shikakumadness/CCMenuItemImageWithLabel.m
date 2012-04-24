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
        iPadSuffix = @"";
        fontMultiplier = 1;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            iPadSuffix = @"-hd";
            fontMultiplier = 2;
        }
    }
    return self;
}

+ (id)itemFromNormalImage:(NSString *)value selectedImage:(NSString *)value2 text:(NSString *)text block:(void(^)(id sender))block 
{
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
    // Create button
    CCMenuItemImageWithLabel *item = [self itemFromNormalImage:[NSString stringWithFormat:@"button-background%@.png", item.iPadSuffix] selectedImage:[NSString stringWithFormat:@"button-background-selected%@.png", item.iPadSuffix] disabledImage:nil block:block];
    
    // Create label + append to button
    item.label = [CCLabelTTF labelWithString:text dimensions:CGSizeMake(item.contentSize.width, item.contentSize.height) alignment:CCTextAlignmentCenter fontName:kFontName fontSize:kFontSize * item.fontMultipler];
    item.label.color = ccc3(0, 0, 0);
    item.label.position = ccp(item.contentSize.width / 2.1, item.contentSize.height / 8);
    [item addChild:item.label];
    
    // Return button
	return item;
}

@end
