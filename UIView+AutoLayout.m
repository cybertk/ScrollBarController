//
//  UIView+AutoLayout.m
//  storydemo
//
//  Created by Quanlong He on 7/9/13.
//  Copyright (c) 2013 Quanlong He. All rights reserved.
//

#import "UIView+AutoLayout.h"

@implementation UIView (AutoLayout)

+ (id)autoLayoutView
{
  UIView *view = [self new];
  view.translatesAutoresizingMaskIntoConstraints = NO;
  return view;
}

- (void)addVisualConstraints:(NSString*)constraintString forViews:(NSDictionary*)views {
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraintString
                                                               options:0
                                                               metrics:0
                                                                 views:views]];
}

- (void)centerInViewHorizontal:(UIView*)superView
{
  [superView addConstraint:
   [NSLayoutConstraint constraintWithItem:self
                                attribute:NSLayoutAttributeCenterX
                                relatedBy:NSLayoutRelationEqual
                                   toItem:superView
                                attribute:NSLayoutAttributeCenterX
                               multiplier:1
                                 constant:0]];
}
@end
