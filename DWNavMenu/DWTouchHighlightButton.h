//
//  DWTouchHighlightButton.h
//  DWNavMenuDemo
//
//  Created by Derrick Walker on 2/20/15.
//  Copyright (c) 2015 Derrick Walker. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWTouchHighlightButton;

typedef void(^ TapHandlerBlock)(DWTouchHighlightButton *);

@interface DWTouchHighlightButton : UIButton

// Block handler
@property (nonatomic, copy) void(^ tapHandler)(DWTouchHighlightButton *sender);

// Indicates whether the home button will animate it's touch highlighting, this is enabled by default
@property (nonatomic) BOOL animatedHighlighting;

// The duration of the expand/collapse animation
@property (nonatomic) float animationDuration;

// The default alpha of the homeButtonView when not tapped
@property (nonatomic) float standbyAlpha;

// The highlighted alpha of the homeButtonView when tapped
@property (nonatomic) float highlightAlpha;

@end
