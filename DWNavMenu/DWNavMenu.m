//
//  DWNavMenu.m
//  DWNavMenuDemo
//
//  Created by Derrick Walker on 2/19/15.
//  Copyright (c) 2015 Derrick Walker. All rights reserved.
//

#import "DWNavMenu.h"

#define kDefaultAnimationDuration 0.3f

@interface MenuNavigationHandler : NSObject

@property (nonatomic, strong, readonly) NSMutableArray *menuNavigationStack;

@end

@implementation MenuNavigationHandler

- (void)appendMenu:(DWNavMenu *)menu {
    if (![_menuNavigationStack containsObject:menu]) {
        [_menuNavigationStack addObject:menu];
    }
}

- (void)popMenu {
    [_menuNavigationStack removeLastObject];
}

- (void)resetNavigationStack {
    [_menuNavigationStack removeObjectsInRange:NSMakeRange(1, _menuNavigationStack.count - 1)];
}

- (DWNavMenu *)parentMenu {
    return [_menuNavigationStack firstObject];
}

- (DWNavMenu *)lastMenu {
    return [_menuNavigationStack lastObject];
}

- (instancetype)initWithMenu:(DWNavMenu *)menu {
    self = [super init];
    
    if (self) {
        _menuNavigationStack = [[NSMutableArray alloc] initWithObjects:menu, nil];
    }
    
    return self;
}

@end

@interface DWInternalLabel : UILabel
@end

@implementation DWInternalLabel

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets defaultInset = UIEdgeInsetsMake(2.f, 5.f, 0.f, 5.f);
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, defaultInset)];
}

@end

@interface DWNavMenu()

@property (nonatomic, strong) MenuNavigationHandler *navigationHandler;
@property (nonatomic, strong) DWTouchHighlightButton *cancelButton;
@property (nonatomic, strong) DWTouchHighlightButton *backButton;
@property (nonatomic, strong) DWInternalLabel *titleLabel;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UIView *tapGestureView;

@property (nonatomic, strong) NSArray *allMenuActions;
@property (nonatomic, assign) BOOL needsButtonUpdate;

@end

@implementation DWNavMenu

#pragma mark - Public Methods

- (void)showInView:(UIView *)view animated:(BOOL)animated {
    self.frame = CGRectMake(0.f, 0.f, view.frame.size.width, view.frame.size.height);
    
    [self _prepareMenuButtons];
    
    [view addSubview:self];
    
    [self _toggleMenuShown:YES animated:animated withCompletion:nil];
}

- (void)dismissMenuAnimated:(BOOL)animated {
    [self _dismissMenuAnimated:animated withCompletion:nil];
}

- (void)pushNavMenu:(DWNavMenu *)navMenu animated:(BOOL)animated {
    navMenu.frame = CGRectMake(self.frame.size.width,
                               self.frame.origin.y,
                               self.frame.size.width,
                               self.frame.size.height);
    
    if (self.navigationHandler == nil) {
        self.navigationHandler = [[MenuNavigationHandler alloc] initWithMenu:self];
    }
    
    navMenu.navigationHandler = self.navigationHandler;
    navMenu.needsButtonUpdate = YES;
    
    [navMenu _adoptStyleFromParent];
    [navMenu _prepareMenuButtons];
    [navMenu _addBackButton];
    
    [self.navigationHandler appendMenu:navMenu];
    
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = [self safeAreaInsets];
    }
    
    CGRect frame = navMenu.buttonContainerView.frame;
    frame.origin.y = navMenu.frame.size.height - frame.size.height - safeAreaInsets.bottom;
    navMenu.buttonContainerView.frame = frame;
    
    [self addSubview:navMenu];
    
    [self _layoutAnimated:YES
                withBlock:^{
                    navMenu.frame = CGRectMake(0.f,
                                               navMenu.frame.origin.y,
                                               navMenu.frame.size.width,
                                               navMenu.frame.size.height);
                    
                    self.buttonContainerView.alpha = 0.f;
                }
               completion:nil];
}

- (void)popNavMenuAnimated:(BOOL)animated {
    if (self.navigationHandler != nil) {
        [self.navigationHandler popMenu];
        DWNavMenu *lastMenu = [self.navigationHandler lastMenu];
        
        lastMenu.buttonContainerView.frame = CGRectMake(-lastMenu.buttonContainerView.frame.size.width,
                                                        lastMenu.buttonContainerView.frame.origin.y,
                                                        lastMenu.buttonContainerView.frame.size.width,
                                                        lastMenu.buttonContainerView.frame.size.height);
        lastMenu.buttonContainerView.alpha = 1.f;
        self.buttonContainerView.alpha = 1.f;
        
        [self _layoutAnimated:YES
                    withBlock:^{
                        self.buttonContainerView.alpha = 0.f;
                        
                        lastMenu.buttonContainerView.frame = CGRectMake((self.frame.size.width - lastMenu.buttonContainerView.frame.size.width) / 2.f,
                                                                        lastMenu.buttonContainerView.frame.origin.y,
                                                                        lastMenu.buttonContainerView.frame.size.width,
                                                                        lastMenu.buttonContainerView.frame.size.height);
                    }
                   completion:^ {
                       [self removeFromSuperview];
                       self.buttonContainerView.alpha = 1.f;
                   }];
    }
}

- (void)addMenuAction:(DWNavMenuAction *)menuAction atIndex:(NSUInteger)index {
    NSMutableArray *buttonActionsMutable = self.menuButtonActions.mutableCopy;
    [buttonActionsMutable insertObject:menuAction atIndex:index];
    _menuButtonActions = buttonActionsMutable.copy;
    
    self.needsButtonUpdate = YES;
    [self _updateMenuActionsArray];
}

- (void)addMenuAction:(DWNavMenuAction *)menuAction {
    [self addMenuAction:menuAction atIndex:0];
}

#pragma mark - Private Methods

- (void)_dismissMenuAnimated:(BOOL)animated withCompletion:(void (^)(void))completion {
    if (self.backButton) {
        DWNavMenu *parentMenu = self.navigationHandler.parentMenu;
        
        [self _layoutAnimated:YES
                    withBlock:^{
                        parentMenu.backgroundColor = [UIColor clearColor];
                        self.backgroundColor = [UIColor clearColor];
                        
                        CGRect buttonContainerViewFrame = self.buttonContainerView.frame;
                        self.buttonContainerView.frame = CGRectMake(buttonContainerViewFrame.origin.x,
                                                                          self.frame.size.height,
                                                                          buttonContainerViewFrame.size.width,
                                                                          buttonContainerViewFrame.size.height);
                    }
                   completion:^{
                       self.buttonContainerView.userInteractionEnabled = YES;
                       
                       for (DWNavMenu *menu in self.navigationHandler.menuNavigationStack) {
                           menu.buttonContainerView.alpha = 1.f;
                           [menu removeFromSuperview];
                       }
                       
                       [self.navigationHandler resetNavigationStack];
                       self.navigationHandler = nil;
                       
                       if (completion) {
                           completion();
                       }
                   }];
    } else {
        [self _toggleMenuShown:NO animated:animated withCompletion:completion];
    }
}

- (void)_prepareMenuButtons {
    [self _updateMenuActionsArray];
    
    _buttonContainerView.frame = CGRectMake(self.horizontalLayoutInsets.left,
                                            self.frame.size.height,
                                            self.frame.size.width - self.horizontalLayoutInsets.left - self.horizontalLayoutInsets.right,
                                            self.allMenuActions.count * (_buttonHeight + _buttonGapSpace) + _cancelButtonGapSpace + ([self _titleLabelHeight] + _buttonGapSpace));
    
    _buttonContainerView.backgroundColor = [UIColor clearColor];
    
    _tapGestureView.frame = CGRectMake(0.f, 0.f, self.frame.size.width, self.frame.size.height - _buttonContainerView.frame.size.height);
    
    [self _addButtons];
}

- (void)_handleTapGesture:(id)sender {
    if (self.backgroundTapToDismissEnabled) {
        [self dismissMenuAnimated:YES];
    }
}

- (void)_addBackButton {
    DWTouchHighlightButton *backButton = [[DWTouchHighlightButton alloc] init];
    backButton.backgroundColor = self.buttonBackgroundColor;
    backButton.titleLabel.font = self.buttonTextFont;
    backButton.exclusiveTouch = YES;
    backButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    backButton.tag = -1;
    backButton.standbyTextColor = self.buttonTextColor;
    backButton.highlightTextColor = self.buttonHighlightedTextColor;
    
    [backButton setTitleColor:self.buttonTextColor forState:UIControlStateNormal];
    [backButton setTitle:self.backButtonText forState:UIControlStateNormal];
    
    __weak DWNavMenu *weakSelf = self;
    [backButton setTapHandler:^(DWTouchHighlightButton *button) {
        [weakSelf _backTapped:button];
    }];
    
    backButton.frame = CGRectMake(0.f,
                                  _buttonContainerView.frame.size.height - _buttonHeight - _buttonGapSpace,
                                  _buttonContainerView.frame.size.width / 2.f - 4.f,
                                  _buttonHeight);
    
    self.backButton = backButton;
    [_buttonContainerView addSubview:_backButton];
    
    self.cancelButton.frame = CGRectMake(_buttonContainerView.frame.size.width / 2.f + 4.f,
                                         self.cancelButton.frame.origin.y,
                                         backButton.frame.size.width,
                                         self.cancelButton.frame.size.height);
    self.cancelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
}

- (float)_titleLabelHeight {
    if (self.titleText == nil) {
        return 0.f;
    }
    
    CGRect frame = [self.titleText boundingRectWithSize:CGSizeMake(self.frame.size.width - self.horizontalLayoutInsets.left - self.horizontalLayoutInsets.right - 10.f, INFINITY)
                                                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                             attributes:@{NSFontAttributeName : self.titleTextFont}
                                                context:nil];
    
    return frame.size.height + 16.f;
}

- (void)_layoutAnimated:(BOOL)animated withBlock:(void (^)(void))layoutBlock completion:(void (^)(void))completion {
    BOOL needsResetTapEnabled = NO;
    if (self.backgroundTapToDismissEnabled) {
        self.backgroundTapToDismissEnabled = NO;
        needsResetTapEnabled = YES;
    }
    
    [UIView animateWithDuration:animated ? self.animationDuration : 0.f
                          delay:0.01f
         usingSpringWithDamping:0.8f
          initialSpringVelocity:0.25f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if (layoutBlock) {
                             layoutBlock();
                         }
                     }
                     completion:^(BOOL finished) {
                         if (completion) {
                             completion();
                         }
                         
                         if (needsResetTapEnabled) {
                             self.backgroundTapToDismissEnabled = YES;
                         }
                     }];
}

- (void)_toggleMenuShown:(BOOL)shown animated:(BOOL)animated withCompletion:(void (^)(void))completion {
    _buttonContainerView.userInteractionEnabled = NO;
    
    [self _layoutAnimated:animated
                withBlock:^{
                    self.backgroundColor = shown ? self.backgroundOverlayColor : [UIColor clearColor];
                    
                    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
                    if (@available(iOS 11.0, *)) {
                        safeAreaInsets = [self safeAreaInsets];
                    }
                    
                    CGRect buttonContainerViewFrame = self.buttonContainerView.frame;
                    CGFloat height = self.frame.size.height;
                    CGFloat targetY = shown ? height - buttonContainerViewFrame.size.height - safeAreaInsets.bottom : height;
                    self.buttonContainerView.frame = CGRectMake(buttonContainerViewFrame.origin.x,
                                                                targetY,
                                                                buttonContainerViewFrame.size.width,
                                                                buttonContainerViewFrame.size.height);
                }
               completion:^{
                   self.buttonContainerView.userInteractionEnabled = YES;
                   
                   if (!shown) {
                       [self removeFromSuperview];
                   }
                   
                   if (completion) {
                       completion();
                   }
               }];
}

- (void)_backTapped:(DWTouchHighlightButton *)button {
    [self popNavMenuAnimated:YES];
}

- (void)_menuButtonTapped:(DWTouchHighlightButton *)button {
    DWNavMenuAction *buttonAction = [self.allMenuActions objectAtIndex:button.tag];
    
    if (buttonAction.shouldDismissMenu) {
        [self _dismissMenuAnimated:YES
                    withCompletion:^{
                        if (buttonAction.tapAction) {
                            buttonAction.tapAction();
                        }
                    }];
    } else {
        if (buttonAction.tapAction) {
            buttonAction.tapAction();
        }
    }
}

- (void)_updateMenuActionsArray {
    if (!self.needsButtonUpdate)
        return;
    
    NSMutableArray *allActions = [[NSMutableArray alloc] init];
    
    if (self.cancelMenuAction) {
        [allActions addObject:self.cancelMenuAction];
    }
    
    for (int i = 0; i < self.menuButtonActions.count; i++) {
        [allActions addObject:[self.menuButtonActions objectAtIndex:i]];
    }
    
    if (self.destructiveMenuAction) {
        [allActions addObject:self.destructiveMenuAction];
    }
    
    self.allMenuActions = [allActions copy];
    self.needsButtonUpdate = YES;
}

- (void)_addButtons {
    if (!self.needsButtonUpdate)
        return;
    
    [_buttonContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    int index = 0;
    for (DWNavMenuAction *menuAction in self.allMenuActions) {
        DWTouchHighlightButton *menuButton = [[DWTouchHighlightButton alloc] init];
        menuButton.backgroundColor = [menuAction isEqual:self.destructiveMenuAction] ? self.destructiveButtonColor : self.buttonBackgroundColor;
        menuButton.titleLabel.font = self.buttonTextFont;
        menuButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        menuButton.exclusiveTouch = YES;
        menuButton.tag = index;
        menuButton.standbyTextColor = [menuAction isEqual:self.destructiveMenuAction] ? self.destructiveButtonTextColor : self.buttonTextColor;
        menuButton.highlightTextColor = [menuAction isEqual:self.destructiveMenuAction] ? self.destructiveButtonTextColor : self.self.buttonHighlightedTextColor;
        
        [menuButton setTitle:menuAction.title forState:UIControlStateNormal];
        
        __weak DWNavMenu *weakSelf = self;
        [menuButton setTapHandler:^(DWTouchHighlightButton *button) {
            [weakSelf _menuButtonTapped:button];
        }];
        
        menuButton.frame = CGRectMake(0.f,
                                      _buttonContainerView.frame.size.height - _buttonHeight - _buttonGapSpace - (index > 0 ? _cancelButtonGapSpace + (index * (_buttonHeight + _buttonGapSpace)) : 0.f),
                                      _buttonContainerView.frame.size.width,
                                      _buttonHeight);
        
        if (index == 0) {
            self.cancelButton = menuButton;
        }
        
        index++;
        
        [_buttonContainerView addSubview:menuButton];
    }
    
    if (self.titleText) {
        [self _createTitleLabelView];
        
        self.titleLabel.tag = index;
        float labelHeight = [self _titleLabelHeight];
        
        self.titleLabel.frame = CGRectMake(0.f,
                                           _buttonContainerView.frame.size.height - _buttonHeight - _buttonGapSpace - _cancelButtonGapSpace - (--index * (_buttonHeight + _buttonGapSpace)) - labelHeight - _buttonGapSpace * 2.f,
                                           _buttonContainerView.frame.size.width,
                                           labelHeight);
        
        [_buttonContainerView addSubview:self.titleLabel];
    }
    
    [self addSubview:_buttonContainerView];

    self.needsButtonUpdate = NO;
}

- (void)_createTitleLabelView {
    if (self.titleLabel == nil) {
        self.titleLabel = [[DWInternalLabel alloc] init];
    }
    
    self.titleLabel.text = self.titleText;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.backgroundColor = self.buttonBackgroundColor;
    self.titleLabel.font = self.titleTextFont;
    self.titleLabel.textColor = self.titleTextColor;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    if (self.topCornerRadius > 0) {
        CAShapeLayer *mask = [CAShapeLayer layer];
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.buttonContainerView.bounds
                                                         byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                               cornerRadii:CGSizeMake(_topCornerRadius, _topCornerRadius)];
        
        mask.frame = self.buttonContainerView.bounds;
        mask.path = bezierPath.CGPath;
        
        self.buttonContainerView.layer.mask = mask;
    }
}

- (void)_adoptStyleFromParent {
    if (self.navigationHandler) {
        DWNavMenu *parentMenu = [self.navigationHandler parentMenu];
        
        self.titleTextColor = parentMenu.titleTextColor;
        self.titleTextFont = parentMenu.titleTextFont;
        self.topCornerRadius = parentMenu.topCornerRadius;
        self.cancelButtonGapSpace = parentMenu.cancelButtonGapSpace;
        self.buttonHeight = parentMenu.buttonHeight;
        self.buttonGapSpace = parentMenu.buttonGapSpace;
        self.buttonBackgroundColor = parentMenu.buttonBackgroundColor;
        self.buttonTextColor = parentMenu.buttonTextColor;
        self.buttonHighlightedTextColor = parentMenu.buttonHighlightedTextColor;
        self.destructiveButtonColor = parentMenu.destructiveButtonColor;
        self.destructiveButtonTextColor = parentMenu.destructiveButtonTextColor;
        self.buttonTextFont = parentMenu.buttonTextFont;
        self.backgroundTapToDismissEnabled = parentMenu.backgroundTapToDismissEnabled;
        self.horizontalLayoutInsets = parentMenu.horizontalLayoutInsets;
        self.backgroundOverlayColor = parentMenu.backgroundOverlayColor;
        self.animationDuration = parentMenu.animationDuration;
    }
}

- (void)setTopCornerRadius:(float)topCornerRadius {
    _topCornerRadius = topCornerRadius;
    
    [self _createTitleLabelView];
}

#pragma mark - Initializer Methods

+ (instancetype)navMenuWithTitle:(NSString *)titleText
               cancelButtonTitle:(NSString *)cancelText
                    cancelAction:(MenuAction)cancelAction
                         buttons:(DWNavMenuAction *)button, ... {
    va_list list;
    va_start(list, button);
    
    NSMutableArray *menuActionsMutable = [[NSMutableArray alloc] init];
    
    for (DWNavMenuAction *_action = button; _action != nil; _action = va_arg(list, DWNavMenuAction*)) {
        if (_action != nil) {
            [menuActionsMutable addObject:_action];
        }
    }
    
    va_end(list);
    
    DWNavMenu *navMenuInstance = [[DWNavMenu alloc] initWithMenuActions:menuActionsMutable.copy];
    navMenuInstance.titleText = titleText;
    navMenuInstance.cancelMenuAction = [DWNavMenuAction menuActionWithTitle:cancelText == nil ? @"Cancel" : cancelText
                                                         shouldDismissMenu:YES
                                                              blockHandler:cancelAction];
    
    return navMenuInstance;
}

- (instancetype)initWithMenuActions:(NSArray *)menuActions {
    self = [super init];
    
    if (self) {
        [self commonInit];
        _menuButtonActions = menuActions;
    }
    
    return self;
}

#pragma mark - Lifecycle Methods

- (void)commonInit {
    // Init view
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight |
                            UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                            UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    // Init button container view
    _buttonContainerView = [[UIView alloc] init];
    _buttonContainerView.clipsToBounds = YES;
    _buttonContainerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    
    // Add tap gesture
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTapGesture:)];
    
    self.tapGestureView = [[UIView alloc] init];
    self.tapGestureView.backgroundColor = [UIColor clearColor];
    [self.tapGestureView addGestureRecognizer:self.tapGestureRecognizer];
    
    [self addSubview:self.tapGestureView];
    
    // Set default values
    self.titleTextColor = [UIColor grayColor];
    self.titleTextFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.f];
    self.backButtonText = @"Back";
    self.cancelButtonGapSpace = 12.f;
    self.buttonGapSpace = 2.f;
    self.buttonHeight = 60.f;
    self.buttonBackgroundColor = [UIColor whiteColor];
    self.buttonTextColor = [UIColor blackColor];
    self.buttonHighlightedTextColor = [UIColor blackColor];
    self.destructiveButtonColor = [UIColor colorWithRed:244.f/255.f green:14.f/255.f blue:50.f/255.f alpha:1.f];
    self.destructiveButtonTextColor = [UIColor whiteColor];
    self.buttonTextFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.f];
    self.backgroundTapToDismissEnabled = YES;
    self.horizontalLayoutInsets = UIEdgeInsetsMake(0.0, 8.f, 0.0, 8.f);
    self.backgroundOverlayColor = [UIColor colorWithWhite:0.f alpha:0.45f];
    self.animationDuration = kDefaultAnimationDuration;
    self.needsButtonUpdate = YES;
}

@end
