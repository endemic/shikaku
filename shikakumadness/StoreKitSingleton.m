//
//  StoreKitSingleton.m
//  infinitearmada
//
//  Created by Nathan Demick on 2/4/12.
//  Copyright (c) 2012 Ganbaru Games. All rights reserved.
//

#import "StoreKitSingleton.h"

@implementation StoreKitSingleton

SYNTHESIZE_SINGLETON_FOR_CLASS(StoreKitSingleton);

@synthesize products;

/**
 * Call on singleton init
 */
- (void)loadStore
{
    // Restart any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    // Get product descriptions
    [self requestProductData];
}

/**
 * Create an SKProductsRequest object to query iTunes for valid IAP content
 */
- (void)requestProductData
{
    NSSet *productIds = [NSSet setWithObjects:@"com.ganbarugames.shikakumadness.easy", 
                                              @"com.ganbarugames.shikakumadness.medium", 
                                              @"com.ganbarugames.shikakumadness.hard", nil];
    
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIds];
    request.delegate = self;
    [request start];
}

/**
 * Add a product to the payment queue
 * TODO: Probably change this to accept a product ID string instead of SKProduct object
 */
- (void)addToPaymentQueue:(SKProduct *)product
{
    if ([SKPaymentQueue canMakePayments])
    {
        // Create the payment item based off the product
        SKPayment *item = [SKPayment paymentWithProduct:product];
        
        // Starts to process the payment
        [[SKPaymentQueue defaultQueue] addPayment:item];
    }
}

#pragma mark -
#pragma mark SKProductsRequestDelegate methods

/**
 * Create an SKProductsRequest object to query iTunes for valid IAP content
 */
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    // Returns an array of SKProduct objects
    products = response.products;
    
    [products retain];
    
    // Populate the UI here
    for (int i = 0; i < [products count]; i++)
    {
        SKProduct *p = [products objectAtIndex:i];
        NSLog(@"%@", p.localizedTitle);
        NSLog(@"%@", p.localizedDescription);
        NSLog(@"%@", p.price);
        
        /**
         Format price as follows
         NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
         [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
         [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
         [numberFormatter setLocale:product.priceLocale];
         NSString *formattedString = [numberFormatter stringFromNumber:product.price];
         */
    }
    
    // DEBUG: Show invalid products
    NSArray *invalidProducts = response.invalidProductIdentifiers;
    for (int i = 0; i < [invalidProducts count]; i++)
    {
        NSString *s = [invalidProducts objectAtIndex:i];
        NSLog(@"Invalid product ID: %@", s);
    }
    
    [request autorelease];
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

/**
 * Called when transaction status is updated
 */
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState) 
        {
            case SKPaymentTransactionStatePurchased:
                // Store that the item was purchased
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                // Present message that there was a problem
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                // Restore the transaction
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

#pragma mark -
#pragma mark Transaction record helpers

/**
 * Stores a reciept to NSUserDefaults
 */
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:transaction.transactionReceipt forKey:[NSString stringWithFormat:@"%@.receipt", transaction.payment.productIdentifier]];
    NSLog(@"Storing receipt in NSUserDefaults: %@", [NSString stringWithFormat:@"%@.receipt", transaction.payment.productIdentifier]);
    [defaults synchronize];
}

/**
 * Called when transaction was successful
 */
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    // Store receipt in NSUserDefaults
    [self recordTransaction:transaction];
    [self finishTransaction:transaction wasSuccessful:YES];
}

/**
 * Restores a previously-purchased transaction
 */
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    // Store receipt in NSUserDefaults
    [self recordTransaction:transaction.originalTransaction];
    [self finishTransaction:transaction wasSuccessful:YES];
}

/**
 * Called when transaction fails
 */
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // There was an error, show that to the user
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else 
    {
        // This condition is executed if the transaction is cancelled, so just remove it from the queue
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

/**
 * Removes transaction from queue and posts notification
 */
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)success
{
    // Remove transaction from the queue
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:transaction forKey:@"transaction"];
    
    if (success)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StoreKitSuccess" object:self userInfo:userInfo];
    }
    else 
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StoreKitFailure" object:self userInfo:userInfo];
    }
}

#pragma mark -
#pragma mark Object Serialization

+ (void)loadState
{
	@synchronized([StoreKitSingleton class]) 
	{
		// just in case loadState is called before GameSingleton inits
		if (!sharedStoreKitSingleton)
        {
			[StoreKitSingleton sharedStoreKitSingleton];
        }
        
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *file = [documentsDirectory stringByAppendingPathComponent:@"StoreKitSingleton.state"];
		Boolean saveFileExists = [[NSFileManager defaultManager] fileExistsAtPath:file];
		
		if (saveFileExists) 
		{
			// don't need to set the result to anything here since we're just getting initwithCoder to be called.
			[NSKeyedUnarchiver unarchiveObjectWithFile:file];
		}
	}
}

+ (void)saveState
{
	@synchronized([StoreKitSingleton class]) 
	{  
		StoreKitSingleton *state = [StoreKitSingleton sharedStoreKitSingleton];
        
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *saveFile = [documentsDirectory stringByAppendingPathComponent:@"StoreKitSingleton.state"];
		
		[NSKeyedArchiver archiveRootObject:state toFile:saveFile];
	}
}

#pragma mark -
#pragma mark NSCoding Protocol Methods

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:self.products forKey:@"products"];
}

- (id)initWithCoder:(NSCoder *)coder
{
	if ((self = [super init])) 
	{
		self.products = [coder decodeObjectForKey:@"products"];
	}
	return self;
}

@end
