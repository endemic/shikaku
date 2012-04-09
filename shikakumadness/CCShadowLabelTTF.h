//
//  CCShadowLabelTTF.h
//  Shikaku Madness
//
//  Created by Nathan Demick on 4/6/12.
//  Copyright 2012 Ganbaru Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCShadowLabelTTF : CCNode 
{
    CCLabelTTF *textLabel;
    
    int numberOfShadowLabels;
    NSMutableArray *shadowLabels;
    
    ccColor3B textColor, shadowColor;
}

@property (nonatomic, retain) CCLabelTTF *textLabel;
@property (nonatomic, retain) NSMutableArray *shadowLabels;

@property (nonatomic) int numberOfShadowLabels;
@property (nonatomic) ccColor3B textColor;
@property (nonatomic) ccColor3B shadowColor;

+ (CCShadowLabelTTF *)labelWithString:(NSString *)string fontName:(NSString *)font fontSize:(CGFloat)size;
+ (CCShadowLabelTTF *)labelWithString:(NSString *)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString *)font fontSize:(CGFloat)size;

- (void)setString:(NSString *)string;
- (void)setTextColor:(ccColor3B)color;
- (void)setShadowColor:(ccColor3B)color;

@end
