//  ModalAlert.m
//
//  Created by Hans-Juergen Richstein
//  Copyright 2012 ROMBOS. All rights reserved.


#import "ModalAlert.h"

#define kDialogTag 1234
#define kAnimationTime 0.4f
#define kDialogImg @"modal-background.png"
#define kButtonImg @"modal-button.png"
#define kFontName @"insolent.otf"

// class that implements a black colored layer that will cover the whole screen 
// and eats all touches except within the dialog box child
@interface CoverLayer : CCLayerColor { }
@end

@implementation CoverLayer
- (id)init {
    if ((self = [super init])) 
    {
        [self initWithColor:ccc4(0,0,0,0) 
                      width:[CCDirector sharedDirector].winSize.width 
                     height:[CCDirector sharedDirector].winSize.height];
        self.isTouchEnabled = YES;
    }
    return self;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event 
{
    CGPoint touchLocation = [self convertTouchToNodeSpace: touch];
    CCNode *dialogBox = [self getChildByTag: kDialogTag];
    
    // eat all touches outside of dialog box
    return !CGRectContainsPoint(dialogBox.boundingBox, touchLocation);
}

- (void) registerWithTouchDispatcher 
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN+1 swallowsTouches:YES];
}
@end


@implementation ModalAlert

+ (void) CloseAlert: (CCSprite*) alertDialog onCoverLayer: (CCLayer*) coverLayer executingBlock: (void(^)())block {
    CGSize windowSize = [CCDirector sharedDirector].winSize;
    
    id moveOut = [CCMoveTo actionWithDuration:0.4 position:ccp(windowSize.width / 2, windowSize.height / 1.5)];
	id easeOut = [CCEaseBackIn actionWithAction:moveOut];
	id fadeOut = [CCFadeOut actionWithDuration:0.3];
	
	id hide = [CCSpawn actions:easeOut, fadeOut, nil];
    
    // shrink dialog box
    [alertDialog runAction:hide];
    
    // in parallel, fadeout and remove cover layer and execute block 
    // (note: you can't use CCFadeOut since we don't start at opacity 1!)
    [coverLayer runAction:[CCSequence actions:
                           [CCFadeTo actionWithDuration:kAnimationTime opacity:0], 
                           [CCCallBlock actionWithBlock:^{
                                [coverLayer removeFromParentAndCleanup:YES];
                                if (block) block();
                            }],
                           nil]];
}

+ (void) ShowAlert: (NSString*) message onLayer: (CCLayer *) layer
          withOpt1: (NSString*) opt1 withOpt1Block: (void(^)())opt1Block
           andOpt2: (NSString*) opt2 withOpt2Block: (void(^)())opt2Block {
    
    CGSize windowSize = [CCDirector sharedDirector].winSize;
    
    // create the cover layer that "hides" the current application
    CCLayerColor *coverLayer = [CoverLayer new];
    [layer addChild:coverLayer z:INT_MAX]; // put to the very top to block application touches
    [coverLayer runAction:[CCFadeTo actionWithDuration:kAnimationTime opacity:80]]; // smooth fade-in to dim with semi-transparency
    
    // open the dialog
    CCSprite *dialog = [CCSprite spriteWithFile:kDialogImg];
    dialog.tag = kDialogTag;
    dialog.position = ccp(windowSize.width / 2, windowSize.height / 3);
    
//    dialog.opacity = 220; // make it a bit transparent for a cooler look
    
    // add the alert text
    CGSize msgSize = CGSizeMake(dialog.contentSize.width * 0.9, dialog.contentSize.height * 0.55);
    float fontSize = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 48 : 24;
    
    CCLabelTTF *dialogMsg = [CCLabelTTF labelWithString:message dimensions: msgSize alignment:UITextAlignmentCenter 
                                               fontName:kFontName fontSize:fontSize];
    //dialogMsg.anchorPoint = ccp(0, 0);
    dialogMsg.position = ccp(dialog.contentSize.width/2, dialog.contentSize.height * 0.6);
    dialogMsg.color = ccBLACK; 
    [dialog addChild: dialogMsg]; 
    
    // add one or two buttons, as needed 
    CCMenuItemSprite *opt1Button = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile: kButtonImg]
                                                             selectedSprite:[CCSprite spriteWithFile: kButtonImg]
                                                                    block:^(id sender){ 
                                                                        // close alert and call opt1block when first button is pressed
                                                                        [self CloseAlert:dialog onCoverLayer: coverLayer executingBlock:opt1Block];
                                                                    } ];
    opt1Button.position = ccp(dialog.textureRect.size.width * (opt2 ? 0.27f:0.5f), opt1Button.contentSize.height * 0.8f);

    CCLabelTTF *opt1Label = [CCLabelTTF labelWithString:opt1 dimensions:opt1Button.contentSize alignment:UITextAlignmentCenter 
                                               fontName:kFontName fontSize:fontSize];
    opt1Label.anchorPoint = ccp(0, 0.1);
    opt1Label.color = ccBLACK; 
    [opt1Button addChild: opt1Label];    
    
    // create second button, if requested
    CCMenuItemSprite *opt2Button = nil;
    if (opt2) {
        opt2Button = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile: kButtonImg]
                                             selectedSprite:[CCSprite spriteWithFile: kButtonImg]
                                                      block:^(id sender){ 
                                                          // close alert and call opt2block when second button is pressed
                                                          [self CloseAlert:dialog onCoverLayer: coverLayer executingBlock:opt2Block];
                                                      } ];
        
        opt2Button.position = ccp(dialog.textureRect.size.width * 0.73f, opt1Button.contentSize.height * 0.8f);

        CCLabelTTF *opt2Label = [CCLabelTTF labelWithString:opt2 dimensions:opt2Button.contentSize alignment:UITextAlignmentCenter 
                                                   fontName:kFontName fontSize:fontSize];
        opt2Label.anchorPoint = ccp(0, 0.1);
        opt2Label.color = ccBLACK; 
        [opt2Button addChild: opt2Label];
    }

    CCMenu *menu = [CCMenu menuWithItems:opt1Button, opt2Button, nil];
    menu.position = CGPointZero;
    
    [dialog addChild:menu];
    [coverLayer addChild:dialog];
    
    // open the dialog with a nice popup-effect
    dialog.opacity = 0;
    
    // Move/fade the modal window into place
	id moveIn = [CCMoveTo actionWithDuration:0.4 position:ccp(windowSize.width / 2, windowSize.height / 2)];
	id easeIn = [CCEaseBackOut actionWithAction:moveIn];
	id fadeIn = [CCFadeIn actionWithDuration:0.3];
	
	id show = [CCSpawn actions:easeIn, fadeIn, nil];
    
    [dialog runAction:show];
}



+ (void) Ask: (NSString *) question onLayer: (CCLayer *) layer yesBlock: (void(^)())yesBlock noBlock: (void(^)())noBlock {
    [self ShowAlert:question onLayer:layer withOpt1:@"Yes" withOpt1Block:yesBlock andOpt2:@"No" withOpt2Block:noBlock];
}

+ (void) Confirm: (NSString *) question onLayer: (CCLayer *) layer okBlock: (void(^)())okBlock cancelBlock: (void(^)())cancelBlock {
    [self ShowAlert:question onLayer:layer withOpt1:@"Ok" withOpt1Block: okBlock andOpt2:@"Cancel" withOpt2Block:cancelBlock];
}

+ (void) Tell: (NSString *) statement onLayer: (CCLayer *) layer okBlock: (void(^)())okBlock {
    [self ShowAlert:statement onLayer:layer withOpt1:@"Ok" withOpt1Block: okBlock andOpt2:nil withOpt2Block:nil];
}

@end
