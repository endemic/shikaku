//
//  StoreKitSingleton.h
//
//  Created by Nathan Demick on 2/4/12.
//  Copyright (c) 2012 Ganbaru Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "SynthesizeSingleton.h"

@interface StoreKitSingleton : NSObject <NSCoding, SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    NSArray *products;
}

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(StoreKitSingleton);

@property (readwrite, retain) NSArray *products;

- (void)loadStore;
- (void)requestProductData;
- (void)addToPaymentQueue:(SKProduct *)product;

// Helper methods to finish/record transactions
- (void)recordTransaction:(SKPaymentTransaction *)transaction;
- (void)completeTransaction:(SKPaymentTransaction *)transaction;
- (void)restoreTransaction:(SKPaymentTransaction *)transaction;
- (void)failedTransaction:(SKPaymentTransaction *)transaction;
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)success;

// Serialization methods
+ (void)loadState;
+ (void)saveState;

@end
