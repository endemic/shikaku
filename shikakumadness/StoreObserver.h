//
//  StoreObserver.h
//  infinitearmada
//
//  Created by Nathan Demick on 2/4/12.
//  Copyright (c) 2012 Ganbaru Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface StoreObserver : NSObject <SKPaymentTransactionObserver>
{
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction;
- (void)failedTransaction:(SKPaymentTransaction *)transaction;
- (void)restoreTransaction:(SKPaymentTransaction *)transaction;

- (void)recordTransaction:(SKPaymentTransaction *)transaction;
- (void)provideContent:(NSString *)productIdentifier;

@end
