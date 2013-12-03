//
//  ABBetterNavigationController.m
//  DailyPhoto
//
//  Created by Антон Буков on 01.12.13.
//  Copyright (c) 2013 Codeless Solution. All rights reserved.
//

#import "UINavigationController+Rotation.h"

@implementation UINavigationController (Rotation)

- (BOOL)shouldAutorotate {
    return [[self.viewControllers lastObject] shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations {
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}

@end
