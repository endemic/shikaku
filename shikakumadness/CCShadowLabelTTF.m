//
//  CCShadowLabelTTF.m
//  Shikaku Madness
//
//  Created by Nathan Demick on 4/6/12.
//  Copyright 2012 Ganbaru Games. All rights reserved.
//

#import "CCShadowLabelTTF.h"


@implementation CCShadowLabelTTF

@synthesize numberOfShadowLabels, textColor, shadowColor;

- (id)init
{
	// always call "super" init
	if ((self = [super init]))
	{
        // Set some defaults here
        textColor = ccc3(255, 255, 255);
        shadowColor = ccc3(0, 0, 0);
        numberOfShadowLabels = 4;
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
    CCShadowLabelTTF *n = [CCShadowLabelTTF node];
    
    CCLabelTTF *text = [CCLabelTTF labelWithString:string fontName:font fontSize:size];
    text.color = n.textColor;
    
    for (int i = 1; i <= n.numberOfShadowLabels; i++)
    {
        CCLabelTTF *shadow = [CCLabelTTF labelWithString:string fontName:font fontSize:size];
        shadow.color = n.shadowColor;
        shadow.position = ccp(text.position.x + (2 * i), text.position.y + (2 * i));    // -135 angle
        [n addChild:shadow z:n.numberOfShadowLabels - i];
    }
    
    [n addChild:text z:n.numberOfShadowLabels];
    
    return n;
}

/*! 
 @method setString:(NSString *)string
 @abstract Called when the StoreKitSingleton posts a "success" message
 @result The contents of the menu item that corresponds to the purchased item is updated
 */
- (void)setString:(NSString *)string
{

}

/*! 
 @method setTextColor:(ccColor3B)color
 @abstract Called when the StoreKitSingleton posts a "success" message
 @result The contents of the menu item that corresponds to the purchased item is updated
 */
- (void)setTextColor:(ccColor3B)color
{
    
}

/*! 
 @method setShadowColor:(ccColor3B)color
 @abstract Called when the StoreKitSingleton posts a "success" message
 @result The contents of the menu item that corresponds to the purchased item is updated
 */
- (void)setShadowColor:(ccColor3B)color
{

}

@end
