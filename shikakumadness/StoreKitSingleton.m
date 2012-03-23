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

/**
 - IAP products are registered via iTunesConnect
 
 
*/

/**
 * Create an SKProductsRequest object to query iTunes for valid IAP content
 */
- (void)requestProductData
{
    NSSet *productIds = [NSSet setWithObjects:@"com.ganbarugames.mugenteki.one", 
                                              @"com.ganbarugames.mugenteki.one", 
                                              @"com.ganbarugames.mugenteki.one", nil];
    
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIds];
    request.delegate = self;
    [request start];
}

/**
 * Create an SKProductsRequest object to query iTunes for valid IAP content
 */
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    // Returns an array of SKProduct objects
    NSArray *products = response.products;
    
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
    
    [request autorelease];
}

/**
 * Add a product to the payment queue
 */
- (void)addToPaymentQueue:(SKProduct *)product
{
    if ([SKPaymentQueue canMakePayments])
    {
        // Create the payment item based off the product
        SKPayment *item = [SKPayment paymentWithProduct:product];
        
        // Starts to process the payment
        // NEED TO CREATE AN SKPaymentTransactionObserver DELEGATE TO ACTION WHEN PAYMENT IS COMPLETE
        [[SKPaymentQueue defaultQueue] addPayment:item];
    }
}

@end
