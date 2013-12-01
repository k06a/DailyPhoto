//
//  ABBetterNavigationController.m
//  DailyPhoto
//
//  Created by Антон Буков on 01.12.13.
//  Copyright (c) 2013 Codeless Solution. All rights reserved.
//

#import "ABBetterNavigationController.h"

@implementation ABBetterNavigationController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [self.topViewController preferredStatusBarStyle];
}

@end
