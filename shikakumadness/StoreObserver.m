//
//  StoreObserver.m
//  infinitearmada
//
//  Created by Nathan Demick on 2/4/12.
//  Copyright (c) 2012 Ganbaru Games. All rights reserved.
//

#import "StoreObserver.h"

@implementation StoreObserver
    
/**
 * Gets fired when a StoreKit transaction ends
 */
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState) 
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}


- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    // TODO: implememnt these two methods
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

/**
 * Transaction failed
 */
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // Optionally, display an error here.
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction]; 
}

/**
 This routine is similar to that for a purchased item. A restored purchase provides a new transaction, including a 
 different transaction identifier and receipt. You can save this information separately as part of any audit trail 
 if you desire. However, when it comes time to complete the transaction, you’ll want to recover the original 
 transaction that holds the actual payment object and use its product identifier.
 */
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}


- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    
}

- (void)provideContent:(NSString *)productIdentifier
{
    
}

@end
