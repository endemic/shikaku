//
//  AppDelegate.h
//  shikakumadness
//
//  Created by Nathan Demick on 3/23/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate, NSURLConnectionDelegate> 
{
	UIWindow			*window;
	RootViewController	*viewController;
    
    NSMutableData *downloadData;
}

@property (nonatomic, retain) UIWindow *window;

@end
