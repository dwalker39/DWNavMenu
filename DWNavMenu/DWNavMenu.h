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

// The text of the menu title, if not set then no title will be present
@property (nonatomic, copy) NSString *titleText;

// The text color of the menu title
@property (nonatomic, copy) UIColor *titleTextColor;

// The text font of the menu title
@property (nonatomic, copy) UIFont *titleTextFont;

// The background color of the menu buttons
@property (nonatomic, copy) NSString *backButtonText;

// The NavMenuAction for the cancel button, this specifies the title of the cancel button and an additional action to perform when cancel is tapped besides dismissing the menu
@property (nonatomic, strong) DWNavMenuAction *cancelMenuAction;

// The NavMenuAction for the destructive button, this specifies the title of the destructive button and the action to perform when tapped
@property (nonatomic, strong) DWNavMenuAction *destructiveMenuAction;

// This specifies the gap space between the menu buttons at the cancel button
@property (nonatomic, assign) float cancelButtonGapSpace;

// This specifies the height of all buttons in the menu, including cancel and destructive buttons
@property (nonatomic, assign) float buttonHeight;

// This specifies the gap space between the menu buttons and destructive button (if present)
@property (nonatomic, assign) float buttonGapSpace;

// The background color of the menu buttons
@property (nonatomic, copy) UIColor *buttonBackgroundColor;

// The text color of the menu buttons
@property (nonatomic, copy) UIColor *buttonTextColor;

// The background color of the destructive button (if present)
@property (nonatomic, copy) UIColor *destructiveButtonColor;

// The text color of the destructive button (if present)
@property (nonatomic, copy) UIColor *destructiveButtonTextColor;

// The font of all menu buttons
@property (nonatomic, assign) UIFont *buttonTextFont;

// This specifies whether tapping outside of the menu buttons will dimiss the menu
@property (nonatomic, assign) BOOL backgroundTapToDismissEnabled;

// This specifies the edge gap space between the menu and the sides of the screen
@property (nonatomic, assign) float edgeSpacing;

// This specifies the background overlay color behind the menu
@property (nonatomic, copy) UIColor *backgroundOverlayColor;

// The duration of all animations, specifically presenting, dismissing, pushing, and popping
@property (nonatomic, assign) float animationDuration;

// The list of all NavMenuActions (readonly)
@property (nonatomic, strong, readonly) NSArray *menuButtonActions;

// The button container view (read only)
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

// Note: The 'buttons' argument must be nil terminated, example: buttonAction, button2Action, nil
+ (instancetype)navMenuWithTitle:(NSString *)titleText
               cancelButtonTitle:(NSString *)cancelText
                    cancelAction:(MenuAction)cancelAction
                         buttons:(DWNavMenuAction *)button, ...;

- (instancetype)initWithMenuActions:(NSArray *)menuActions;

@end