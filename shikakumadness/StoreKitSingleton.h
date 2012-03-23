//
//  StoreKitSingleton.h
//  infinitearmada
//
//  Created by Nathan Demick on 2/4/12.
//  Copyright (c) 2012 Ganbaru Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import <StoreKit/StoreKit.h>

@interface StoreKitSingleton : NSObject <SKProductsRequestDelegate>
{
    
}

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(StoreKitSingleton);

- (void)requestProductData;

@end
