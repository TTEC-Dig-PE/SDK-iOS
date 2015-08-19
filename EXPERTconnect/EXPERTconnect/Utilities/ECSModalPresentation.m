//
//  ECSModalPresentation.m
//  helloWorldModals
//
//  Created by Shammi Didla on 14/08/15.
//  Copyright (c) 2015 Mutual Mobile. All rights reserved.
//

#import "ECSModalPresentation.h"

@implementation ECSModalPresentation

- (CGRect)frameOfPresentedViewInContainerView {
    return CGRectMake(380, 400, 200, 200);
}

- (void)presentationTransitionWillBegin {
    [super presentationTransitionWillBegin];
    self.containerView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
}

@end
