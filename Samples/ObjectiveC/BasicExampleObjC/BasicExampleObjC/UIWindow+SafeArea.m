//
//  UIWindow+SafeArea.m
//  BasicExampleObjC
//
//  Created by Teodor Cristea on 17/09/2019.
//  Copyright © 2019 Inc, AdsWizz. All rights reserved.
//

#import "UIWindow+SafeArea.h"

@implementation UIWindow (SafeArea)

- (CGFloat)safeAreaTop {
    CGFloat top = 0.0;
    
    if (@available(iOS 11.0, *)) {
        top = self.safeAreaInsets.top;
    }
    return top;
}

- (CGFloat)safeAreaBottom {
    CGFloat bottom = 0.0;
    
    if (@available(iOS 11.0, *)) {
        bottom = self.safeAreaInsets.bottom;
    }
    
    return bottom;
}

@end
