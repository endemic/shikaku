//
//  AppDelegate.m
//  shikakumadness
//
//  Created by Nathan Demick on 3/23/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "GameConfig.h"
#import "LogoScene.h"
#import "GameScene.h"
#import "RootViewController.h"
#import "GameSingleton.h"
#import "StoreKitSingleton.h"

@implementation AppDelegate

@synthesize window;

//- (void) applicationDidFinishLaunching:(UIApplication*)application
//{
//	// Init the window
//	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//	
//	// Try to use CADisplayLink director
//	// if it fails (SDK < 3.1) use the default director
//	if (![CCDirector setDirectorType:kCCDirectorTypeDisplayLink])
//    {
//        [CCDirector setDirectorType:kCCDirectorTypeDefault];
//    }
//	
//	CCDirector *director = [CCDirector sharedDirector];
//	
//	// Init the View Controller
//	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
//	viewController.wantsFullScreenLayout = YES;
//	
//	// Create the EAGLView manually
//	//  1. Create a RGB565 format. Alternative: RGBA8
//	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
//	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
//								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
//								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
//						];
//	
//	// attach the openglView to the director
//	[director setOpenGLView:glView];
//	
//    // Init game singleton
//    [GameSingleton loadState];
//    [GameSingleton sharedGameSingleton].levelToLoad = @"";  // Reset this value
//    
//	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
//	if ([director enableRetinaDisplay:YES])
//    {
//        [GameSingleton sharedGameSingleton].isRetina = YES;
//    }
//
//	// Rotation controlled by UIViewController
//	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
//	
//	[director setAnimationInterval:1.0/60];
//    [director setDisplayFPS:NO];
//	
//	// make the OpenGLView a child of the view controller
//	[viewController setView:glView];
//	
//	// make the View Controller a child of the main window
//	[window addSubview:viewController.view];
//	[window makeKeyAndVisible];
//	
//	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
//	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
//	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
//
//	// Run the intro Scene
//	[[CCDirector sharedDirector] runWithScene:[LogoScene scene]];
//}

/**
 * Handle receiving shikaku:// URLs here
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"%@", launchOptions);
    
    // Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if (![CCDirector setDirectorType:kCCDirectorTypeDisplayLink])
    {
        [CCDirector setDirectorType:kCCDirectorTypeDefault];
    }
	
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
    // Init game singleton
    [GameSingleton loadState];
    [GameSingleton sharedGameSingleton].levelToLoad = @"";  // Reset this value
    
    // Load the store to get products
    [StoreKitSingleton loadState];
    [[StoreKitSingleton sharedStoreKitSingleton] loadStore];
    
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if ([director enableRetinaDisplay:YES])
    {
        [GameSingleton sharedGameSingleton].isRetina = YES;
    }
    
    // Set up the dictionary that stores best times, etc. for the first time
    NSMutableDictionary *levelStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"levelStatus"];
    if (!levelStatus)
    {
        levelStatus = [NSMutableDictionary dictionary];
        [[NSUserDefaults standardUserDefaults] setObject:levelStatus forKey:@"levelStatus"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
	// Rotation controlled by UIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
	
	[director setAnimationInterval:1.0/60];
    [director setDisplayFPS:NO];
	
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
	
	// make the View Controller a child of the main window
	[window addSubview:viewController.view];
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    
    /**
     
     If URL in options dictionary can be opened, return YES and let the application:openURL method handle opening the URL
     
     **/
    
    NSURL *url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    if ([[url scheme] isEqualToString:@"shikaku"])
    {
        return YES;
    }
    else 
    {
        // Run the intro Scene
        [[CCDirector sharedDirector] runWithScene:[LogoScene scene]];
        
        return NO;
    }
}

/*! 
 @method application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
 @abstract Handles opening URLs when app is running
 @result Starts downloading remote data if URL is valid, otherwise starts app normally
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[url scheme] isEqualToString:@"shikaku"])
    {
        // Replace the shikaku:// scheme with http://
        NSString *newUrlString = [NSString stringWithFormat:@"http://%@%@", [url host], [url path]];
        
        url = [NSURL URLWithString:newUrlString];
        CCLOG(@"URL: %@", url);
        
        // Set up a request/connection to download the level
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"GET"];
        
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
        downloadData = [[NSMutableData data] retain];
        
        [connection start];

        return YES;
    }
    else 
    {
        // Invalid URL; not sure when this would happen, since app only registers the shikaku:// scheme
        // If app is already initialized, replace the scene instead of running a new one
        if ([CCDirector sharedDirector].runningScene)
        {
            [[CCDirector sharedDirector] replaceScene:[LogoScene scene]];
        }
        else 
        {
            [[CCDirector sharedDirector] runWithScene:[LogoScene scene]];
        }
        
        return NO;
    }
}

/* 
 * NSURLConnection delegate methods 
 */

#pragma mark -
#pragma mark NSURLConnection delegate methods

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
    CCLOG(@"NSURLConnection didReceiveResponse!");
    [downloadData setLength:0]; 
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
    CCLOG(@"NSURLConnection didReceiveData!");
    [downloadData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection 
{
    CCLOG(@"NSURLConnection finished loading!");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filename = @"tmp.json";  // This will always be overwritten (for now)
    
    NSString *pathToFile = [documentsDirectory stringByAppendingPathComponent:filename];
    
    if ([downloadData writeToFile:pathToFile atomically:YES])
    {
        [GameSingleton sharedGameSingleton].levelToLoad = filename;
        
        // If app is already initialized, replace the scene instead of running a new one
        if ([CCDirector sharedDirector].runningScene)
        {
            [[CCDirector sharedDirector] replaceScene:[GameScene scene]];
        }
        else 
        {
            [[CCDirector sharedDirector] runWithScene:[GameScene scene]];
        }
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
    CCLOG(@"NSURLConnection error!");
    CCLOG(@"%@", error);
    
    // If app is already initialized, replace the scene instead of running a new one
    if ([CCDirector sharedDirector].runningScene)
    {
        [[CCDirector sharedDirector] replaceScene:[LogoScene scene]];
    }
    else 
    {
        [[CCDirector sharedDirector] runWithScene:[LogoScene scene]];
    }
}

/*
 * End NSURLConnection delegate methods
 */

- (void)applicationWillResignActive:(UIApplication *)application 
{
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application 
{
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application 
{
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application 
{
    [GameSingleton saveState];
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application 
{
    [GameSingleton loadState];
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application 
{
    [GameSingleton saveState];
    
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	
	[window release];
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application 
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc 
{
	[[CCDirector sharedDirector] end];
    [downloadData release];
	[window release];
	[super dealloc];
}

@end
