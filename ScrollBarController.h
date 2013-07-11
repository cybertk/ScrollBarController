//
//  ScrollBarController.h
//  storydemo
//
//  Created by Quanlong He on 7/8/13.
//  Copyright (c) 2013 Quanlong He. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollBarController : UIViewController <UIScrollViewDelegate> {

IBOutlet UIScrollView *titleBar_;
IBOutlet UIScrollView *contentView_;
}

// Default 20.
@property(nonatomic) CGFloat titleFontSize;
// Default gray
@property(nonatomic, retain) UIColor *titleColor;
// Default white
@property(nonatomic, retain) UIColor *highlightedTitleColor;

- (void)addContentItem:(UIViewController *)content
             withTitle:(NSString *)title;
@end
