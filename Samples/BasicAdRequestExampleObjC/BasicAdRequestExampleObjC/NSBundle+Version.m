//
//  NSBundle+Version.m
//  BasicAdRequestExampleObjC
//
//  Created by Ciprian Caba on 10/20/21.
//  Copyright © 2021 Inc, AdsWizz. All rights reserved.
//

#import <Foundation/Foundation.h>

@implementation NSBundle (Version)

- (NSString *)version {
    NSString *buildNumber = [self.infoDictionary valueForKey:@"CFBundleVersion"];
    NSString *shortVersion = [self.infoDictionary valueForKey:@"CFBundleShortVersionString"];

    return [NSString stringWithFormat:@"%@ (%@)", shortVersion, buildNumber];
}

@end
