//
//  DWNavMenu.h
//  DWNavMenuDemo
//
//  Created by Derrick Walker on 2/19/15.
//  Copyright (c) 2015 Derrick Walker. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWNavMenuAction.h"
#import "DWTouchHighlightButton.h"

@interface DWNavMenu : UIView

@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, copy) UIColor *titleTextColor;
@property (nonatomic, copy) UIFont *titleTextFont;
@property (nonatomic, copy) NSString *backButtonText;
@property (nonatomic, strong) DWNavMenuAction *cancelMenuAction;
@property (nonatomic, strong) DWNavMenuAction *destructiveMenuAction;
@property (nonatomic, assign) float cancelButtonGapSpace;
@property (nonatomic, assign) float buttonHeight;
@property (nonatomic, assign) float buttonGapSpace;
@property (nonatomic, copy) UIColor *buttonBackgroundColor;
@property (nonatomic, copy) UIColor *buttonTextColor;
@property (nonatomic, copy) UIColor *destructiveButtonColor;
@property (nonatomic, copy) UIColor *destructiveButtonTextColor;
@property (nonatomic, assign) UIFont *buttonTextFont;
@property (nonatomic, assign) BOOL backgroundTapToDismissEnabled;
@property (nonatomic, assign) float edgeSpacing;
@property (nonatomic, copy) UIColor *backgroundOverlayColor;

@property (nonatomic, strong, readonly) NSArray *menuButtonActions;
@property (nonatomic, readonly) UIView *buttonContainerView;

// -------------------------
// Public Methods
// -------------------------

// Presents the menu in given view
- (void)showInView:(UIView *)view animated:(BOOL)animated;

// Dismisses the menu, tapping Cancel will or any button action that dismisses the menu will call the same method
- (void)dismissMenuAnimated:(BOOL)animated;

// Push a new menu onto the navigation stack
- (void)pushNavMenu:(DWNavMenu *)navMenu animated:(BOOL)animated;

// Pop current menu off the navigation stack
- (void)popNavMenuAnimated:(BOOL)animated;

// Manually add a new menu button
- (void)addMenuAction:(DWNavMenuAction *)menuAction;

// -------------------------
// Initializers
// -------------------------

// Warning: The 'buttons' argument must be nil terminated, example: buttonAction, button2Action, nil
+ (instancetype)navMenuWithTitle:(NSString *)titleText
               cancelButtonTitle:(NSString *)cancelText
                    cancelAction:(MenuAction)cancelAction
                         buttons:(DWNavMenuAction *)button, ...;

- (instancetype)initWithMenuActions:(NSArray *)menuActions;

@end