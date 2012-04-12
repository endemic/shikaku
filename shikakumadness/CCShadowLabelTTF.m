//
//  CCShadowLabelTTF.m
//  Shikaku Madness
//
//  Created by Nathan Demick on 4/6/12.
//  Copyright 2012 Ganbaru Games. All rights reserved.
//

#import "CCShadowLabelTTF.h"


@implementation CCShadowLabelTTF

@synthesize textLabel, shadowLabels, numberOfShadowLabels, textColor, shadowColor;

- (id)init
{
	// always call "super" init
	if ((self = [super init]))
	{
        // Set some defaults here
        textColor = ccc3(255, 255, 255);
        shadowColor = ccc3(0, 0, 0);
        numberOfShadowLabels = 1;
        
        shadowLabels = [[NSMutableArray array] retain];
    }
    return self;
}

/*! 
 @method labelWithString:(NSString *)string fontName:(NSString *)font fontSize:(CGFloat)size
 @abstract Factory method to return a CCNode with a bunch of CCLabelTTF objects
 @result Returns a CCNode with CCLabelTTF text and a bunch of "shadows"
 */
+ (CCShadowLabelTTF *)labelWithString:(NSString *)string fontName:(NSString *)font fontSize:(CGFloat)size
{
    int shadowDistance = 5;
    CCShadowLabelTTF *n = [CCShadowLabelTTF node];
    
    n.textLabel = [CCLabelTTF labelWithString:string fontName:font fontSize:size];
    n.textLabel.color = n.textColor;
    
    for (int i = 1; i <= n.numberOfShadowLabels; i++)
    {
        CCLabelTTF *shadow = [CCLabelTTF labelWithString:string fontName:font fontSize:size];
        shadow.color = n.shadowColor;
        shadow.position = ccp(n.textLabel.position.x + (shadowDistance * i), n.textLabel.position.y + (shadowDistance * i));    // -135 angle
        [n addChild:shadow z:n.numberOfShadowLabels - i];
        [n.shadowLabels addObject:shadow];
    }
    
    [n addChild:n.textLabel z:n.numberOfShadowLabels];
    
    [n setContentSize:CGSizeMake(n.textLabel.contentSize.width, n.textLabel.contentSize.height)];
    
    return n;
}

+ (CCShadowLabelTTF *)labelWithString:(NSString *)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString *)font fontSize:(CGFloat)size
{
    int shadowDistance = 5;
    CCShadowLabelTTF *n = [CCShadowLabelTTF node];
    
    n.textLabel = [CCLabelTTF labelWithString:string dimensions:dimensions alignment:alignment fontName:font fontSize:size];
    n.textLabel.color = n.textColor;
    
    for (int i = 1; i <= n.numberOfShadowLabels; i++)
    {
        CCLabelTTF *shadow = [CCLabelTTF labelWithString:string dimensions:dimensions alignment:alignment fontName:font fontSize:size];
        shadow.color = n.shadowColor;
        shadow.position = ccp(n.textLabel.position.x + (shadowDistance * i), n.textLabel.position.y + (shadowDistance * i));    // -135 angle
        [n addChild:shadow z:n.numberOfShadowLabels - i];
        [n.shadowLabels addObject:shadow];
    }
    
    [n addChild:n.textLabel z:n.numberOfShadowLabels];
    
    [n setContentSize:CGSizeMake(n.textLabel.contentSize.width, n.textLabel.contentSize.height)];
    
    return n;
}

/*! 
 @method setString:(NSString *)string
 @abstract Called when the StoreKitSingleton posts a "success" message
 @result The contents of the menu item that corresponds to the purchased item is updated
 */
- (void)setString:(NSString *)string
{
    textLabel.string = string;
    for (CCLabelTTF *label in shadowLabels) 
    {
        label.string = string;
    }
}

/*! 
 @method setTextColor:(ccColor3B)color
 @abstract Called when the StoreKitSingleton posts a "success" message
 @result The contents of the menu item that corresponds to the purchased item is updated
 */
- (void)setTextColor:(ccColor3B)color
{
    textLabel.color = color;
}

/*! 
 @method setShadowColor:(ccColor3B)color
 @abstract Called when the StoreKitSingleton posts a "success" message
 @result The contents of the menu item that corresponds to the purchased item is updated
 */
- (void)setShadowColor:(ccColor3B)color
{
    for (CCLabelTTF *label in shadowLabels) 
    {
        label.color = color;
    }
}

- (void)dealloc
{
    [shadowLabels release];
    
    [super dealloc];
}

@end
