//
//  UIView+AutoLayout.h
//  storydemo
//
//  Created by Quanlong He on 7/9/13.
//  Copyright (c) 2013 Quanlong He. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AutoLayout)

// Return a frameless view that does not automatically use autoresizing (for use in autolayouts)
+ (id)autoLayoutView;

- (void)addVisualConstraints:(NSString*)constraintString forViews:(NSDictionary*)views;

/// Centers the receiver in the superview
- (void)centerInViewHorizontal:(UIView*)superView;

@end
