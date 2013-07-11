//
//  ScrollBarController.m
//  storydemo
//
//  Created by Quanlong He on 7/8/13.
//  Copyright (c) 2013 Quanlong He. All rights reserved.
//

#import "ScrollBarController.h"

#import "UIView+AutoLayout.h"

// In order to highlight the first title.
const int kInvalidPage = -1;

@interface ScrollItem : NSObject

@property(nonatomic, copy) NSString *title;
@property(nonatomic, retain) UIViewController *content;

+ (id)itemWithTitle:(NSString *)title withContent:(UIViewController *)content;

@end

@implementation ScrollItem

+ (id)itemWithTitle:(NSString *)title withContent:(UIViewController *)content
{
  ScrollItem *item = [ScrollItem new];
  item.title = title;
  item.content = content;
  return item;
}

@end

@interface ScrollBarController () {
  NSMutableArray *labels_;
  NSMutableArray *items_;
  UIScrollView *internalTitleBar_;
  UIView *internalTitleContent_;
  int current_page_;
}

@end

@implementation ScrollBarController

@synthesize titleColor;
@synthesize highlightedTitleColor;
@synthesize titleFontSize;

- (id)initWithCoder:(NSCoder *)aDecoder
{
  if (self = [super initWithCoder:aDecoder]) {
    self.titleFontSize = 20;
    self.titleColor = [UIColor lightGrayColor];
    self.highlightedTitleColor = [UIColor whiteColor];

    labels_ = [NSMutableArray new];
    items_ = [NSMutableArray new];
    // In order to highlight the first title.
    current_page_ = kInvalidPage;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self configureView];
  [self loadItems];
  [self updateContentContstraints];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  // TODO(quanlong): Better impl need.
  if (scrollView == contentView_ ) {
    CGFloat internalTitleWidth = internalTitleBar_.contentSize.width;
    CGFloat titleWidth =
        labels_.count * ((UIView *)labels_.lastObject).frame.size.width;
    CGFloat contentWidth = contentView_.contentSize.width;

    CGFloat ratio1 = internalTitleWidth / contentWidth;
    CGFloat ratio2 = titleWidth / contentWidth;
    internalTitleBar_.contentOffset =
        CGPointMake(contentView_.contentOffset.x * ratio1, 0);
    titleBar_.contentOffset =
        CGPointMake(contentView_.contentOffset.x * ratio2, 0);

    [self switchHighlightedTitleIfNeeded];
    return;
  }

  if (scrollView == internalTitleBar_) {
    CGFloat internalTitleWidth =
        internalTitleBar_.contentSize.width;
    CGFloat titleWidth =
        (labels_.count) * ((UIView *)labels_.lastObject).frame.size.width;
    CGFloat contentWidth =
        contentView_.contentSize.width;
    float ratio1 = titleWidth / internalTitleWidth;
    float ratio2 = contentWidth / internalTitleWidth;
    titleBar_.contentOffset =
      CGPointMake(internalTitleBar_.contentOffset.x * ratio1, 0);
    contentView_.contentOffset =
      CGPointMake(internalTitleBar_.contentOffset.x * ratio2, 0);
    [self switchHighlightedTitleIfNeeded];
  }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  // Do nothing for uninteresting segue.
  // if (![segue isKindOfClass:[ScrollBarRelationshipSegue class]]) {
  //   return;
  // }
  [items_ addObject:[ScrollItem itemWithTitle:segue.identifier
                                  withContent:segue.destinationViewController]];
}

- (void)addContentItem:(UIViewController *)content
             withTitle:(NSString *)title
{
  [self addContentItemIfNeeded:content withTitle:title];
}

- (void)addContentItemIfNeeded:(UIViewController *)content
                     withTitle:(NSString *)title
{
  // TODO(quanlong): Storyboard will auto dealloc this view controll when pushed
  // into sideBarController.
  // Do nothing if the item is already added.
  if (NSNotFound != [[self childViewControllers] indexOfObject:content]) {
    return;
  }

  [items_ addObject:[ScrollItem itemWithTitle:title
                                  withContent:content]];

  // Manager item view controller.
  // TODO(quanlong): Move to addContentItem.
  [self addChildViewController:content];
  [content didMoveToParentViewController:self];

  [self addContentItem:content];
  [self addTitle:title];
  [self switchHighlightedTitleIfNeeded];
}

- (void)addContentItem:(UIViewController *)item
{
  [item.view removeFromSuperview];
  [contentView_ addSubview:item.view];
  item.view.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void) addTitle:(NSString *)title
{
  UILabel *label = [UILabel autoLayoutView];
  label.text = title;
  label.opaque = NO;
  label.textAlignment = NSTextAlignmentCenter;
  label.font = [UIFont systemFontOfSize:self.titleFontSize];
  label.backgroundColor = [UIColor clearColor];
  label.textColor = self.titleColor;
  label.highlightedTextColor = self.highlightedTitleColor;
  [labels_ addObject:label];
  [titleBar_ addSubview:label];
}

- (void)switchHighlightedTitleIfNeeded
{
  // Get current page index.
  int page =
      round(contentView_.contentOffset.x / contentView_.frame.size.width);
  if (current_page_ == page) {
    return;
  }

  // Validate page range [0, labels_.count).
  if (page < 0) {
    page = 0;
  } else if (page >= labels_.count) {
    page = labels_.count - 1;
  }

  // Switch highlighted label.
  if (current_page_ != kInvalidPage) {
    ((UILabel *)labels_[current_page_]).highlighted = NO;
  }
  ((UILabel *)labels_[page]).highlighted = YES;
  current_page_ = page;
}

- (void)configureView
{
  // NOTE: Order make sense.
  if (!titleBar_) {
    [self configureTitleBar];
  }
  if (!contentView_) {
    [self configureContentView];
  }
  [self configureInternalTitleBar];
}

- (void)updateContentContstraints
{
  [self updateItemConstraints];
  [self updateTitleBarConstraints];
  [self updateInternalTitleBarConstraints];
}

- (void)configureTitleBar
{
  UIScrollView *view = [UIScrollView autoLayoutView];
  view.scrollEnabled = NO;
  view.backgroundColor = [UIColor clearColor];
  view.opaque = NO;

  [self.view insertSubview:view atIndex:0];

  // Setup constraints;
  [self.view addVisualConstraints:@"V:|[view(45)]"
                         forViews:NSDictionaryOfVariableBindings(view)];
  [self.view addVisualConstraints:@"H:|[view]|"
                         forViews:NSDictionaryOfVariableBindings(view)];
  titleBar_ = view;
}

- (void)configureContentView
{
  UIScrollView *view = [UIScrollView autoLayoutView];
  view.backgroundColor = [UIColor clearColor];
  view.opaque = NO;
  view.pagingEnabled = YES;
  view.delegate = self;

  [self.view insertSubview:view atIndex:0];

  // Setup constraints;
  [self.view addVisualConstraints:@"V:[titleBar_]-0-[view]|"
                         forViews:NSDictionaryOfVariableBindings(view,
                                                                 titleBar_)];
  [self.view addVisualConstraints:@"H:|[view]|"
                         forViews:NSDictionaryOfVariableBindings(view)];
  contentView_ = view;
}

- (void)configureInternalTitleBar
{
  UIScrollView *view = [UIScrollView autoLayoutView];
  view.pagingEnabled = YES;
  view.backgroundColor = [UIColor clearColor];
  view.opaque = NO;
  view.delegate = self;

  [self.view insertSubview:view aboveSubview:titleBar_];

  // Setup constraints;
  [self.view addVisualConstraints:@"V:|[view(45)]"
                         forViews:NSDictionaryOfVariableBindings(view)];
  [self.view addVisualConstraints:@"H:|[view]|"
                         forViews:NSDictionaryOfVariableBindings(view)];

  internalTitleBar_ = view;
  internalTitleContent_ = [UIView autoLayoutView];
  [internalTitleBar_ addSubview:internalTitleContent_];
}

- (void)loadItems
{
  // Remove all subviews from contentView.
  [[contentView_ subviews]
    enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      [(UIView *)obj removeFromSuperview];
    }];

  for (ScrollItem *item in items_) {
    [self addContentItem:item.content];
    [self addTitle:item.title];
  }
}

- (void)updateInternalTitleBarConstraints
{
  // Remove previous added constraints.
  [internalTitleBar_ removeConstraints:internalTitleBar_.constraints];

  [internalTitleBar_ addVisualConstraints:
                         @"V:|[internalTitleContent_(==internalTitleBar_)]|"
                                forViews:
                         NSDictionaryOfVariableBindings(internalTitleContent_, internalTitleBar_)];
  [internalTitleBar_ addVisualConstraints:@"H:|[internalTitleContent_]|"
                         forViews:NSDictionaryOfVariableBindings(internalTitleContent_)];


    NSLayoutConstraint *c =
        [NSLayoutConstraint constraintWithItem:internalTitleContent_
        attribute:NSLayoutAttributeWidth
        relatedBy:NSLayoutRelationEqual
        toItem:internalTitleBar_
        attribute:NSLayoutAttributeWidth
        multiplier:labels_.count
        constant:0];
    c.priority = 500;
    [internalTitleBar_ addConstraint:c];
}

- (void) updateItemConstraints
{
  // Remove previous added constraints.
  [contentView_ removeConstraints:contentView_.constraints];

  [items_ enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    UIView *item = ((ScrollItem *)obj).content.view;
    NSDictionary* views = NSDictionaryOfVariableBindings(item, contentView_);

    [contentView_ addVisualConstraints:@"V:|[item(==contentView_)]|"
                              forViews:views];
    // Leftmost.
    if (idx == 0) {
      [contentView_ addVisualConstraints:@"|[item(==contentView_)]"
                                forViews:views];
      return;
    }

    UIView *prevItem =
        ((ScrollItem *)[items_ objectAtIndex:idx - 1]).content.view;
    views = NSDictionaryOfVariableBindings(item, prevItem);

    // Rightmost.
    if (idx == items_.count - 1) {
      [contentView_ addVisualConstraints:@"[prevItem]-0-[item(==prevItem)]|"
                                  forViews:views];
      return;
    }

    [contentView_ addVisualConstraints:@"[prevItem]-0-[item(==prevItem)]"
                                  forViews:views];
  }];
}

// TODO(quanlong): Optimize is need.
// NOTE: UIScrollView must be pinned to both directions(vertically, horizontal)
// for it to determine its intrinsic content size.
// See http://stackoverflow.com/a/13940008
- (void) updateTitleBarConstraints
{
  // Remove previous added constraints.
  [titleBar_ removeConstraints:titleBar_.constraints];

  [labels_ enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    UIView *title = ((UIView *)obj);
    NSDictionary* views = NSDictionaryOfVariableBindings(title, titleBar_);

    [titleBar_ addVisualConstraints:@"V:|[title(==titleBar_)]|" forViews:views];
    // Leftmost.
    if (idx == 0) {
      [title centerInViewHorizontal:titleBar_];
      return;
    }

    UIView *prevTitle = [labels_ objectAtIndex:idx - 1];
    views = NSDictionaryOfVariableBindings(title, prevTitle);

    // Rightmost.
    if (idx == labels_.count - 1) {
      [titleBar_ addVisualConstraints:@"[prevTitle]-0-[title(==prevTitle)]|"
                                  forViews:views];
      return;
    }

    [titleBar_ addVisualConstraints:@"[prevTitle]-0-[title(==prevTitle)]"
                                  forViews:views];
  }];
}

@end
