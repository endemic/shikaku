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
}

+ (id)itemFromNormalImage:(NSString *)value selectedImage:(NSString *)value2 text:(NSString *)text block:(void(^)(id sender))block;
+ (id)buttonWithText:(NSString *)text block:(void(^)(id sender))block;

@end
