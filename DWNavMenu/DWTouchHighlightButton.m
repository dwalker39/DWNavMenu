//
//  DWTouchHighlightButton.m
//  DWNavMenuDemo
//
//  Created by Derrick Walker on 2/20/15.
//  Copyright (c) 2015 Derrick Walker. All rights reserved.
//

#import "DWTouchHighlightButton.h"

#define kDefaultAnimationDuration 0.18f

@interface DWTouchHighlightButton()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *foregroundView;

@end

@implementation DWTouchHighlightButton

#pragma mark - Private Methods

- (void)_animateWithBlock:(void (^)(void))animationBlock {
    [UIView animateWithDuration:self.animationDuration
                          delay:0.f
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                     animations:animationBlock
                     completion:nil];
}

- (void)_setTouchHighlighted:(BOOL)highlighted {
    float alphaValue = highlighted ? _highlightAlpha : _standbyAlpha;
    
    if (self.foregroundView.alpha == alphaValue)
        return;
    
    if (_animatedHighlighting) {
        [self _animateWithBlock:^{
            self.foregroundView.alpha = alphaValue;
            [self setTitleColor:highlighted ? _highlightTextColor : _standbyTextColor forState:UIControlStateNormal];
        }];
    } else {
        self.foregroundView.alpha = alphaValue;
        [self setTitleColor:highlighted ? _highlightTextColor : _standbyTextColor forState:UIControlStateNormal];
    }
}

#pragma mark - Touch Handling Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    
    if (CGRectContainsPoint(self.bounds, [touch locationInView:self])) {
        [self _setTouchHighlighted:YES];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    
    [self _setTouchHighlighted:NO];
    
    if (CGRectContainsPoint(self.bounds, [touch locationInView:self])) {
        if (self.tapHandler) {
            self.tapHandler(self);
        } else {
            [self sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    [self _setTouchHighlighted:NO];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    
    [self _setTouchHighlighted:CGRectContainsPoint(self.bounds, [touch locationInView:self])];
}

#pragma mark - Overrides

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.foregroundView.backgroundColor = backgroundColor;
}

- (void)setStandbyTextColor:(UIColor *)standbyTextColor {
    _standbyTextColor = standbyTextColor;
    
    [self setTitleColor:standbyTextColor forState:UIControlStateNormal];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    self.foregroundView.frame = super.bounds;
    self.backgroundView.frame = super.bounds;
}

#pragma mark - Lifecycle Methods

- (void)commonInit {
    NSUInteger autoResizingAll = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    self.foregroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.foregroundView.autoresizingMask = autoResizingAll;

    self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.backgroundView.autoresizingMask = autoResizingAll;
    self.backgroundView.backgroundColor = [UIColor blackColor];
    self.backgroundView.userInteractionEnabled = NO;
    
    [self addSubview:self.backgroundView];
    [self addSubview:self.foregroundView];
    
    // Defaults
    self.clipsToBounds = YES;
    self.animatedHighlighting = YES;
    self.animationDuration = kDefaultAnimationDuration;
    self.standbyAlpha = 1.f;
    self.highlightAlpha = 0.8f;
    self.standbyTextColor = [UIColor whiteColor];
    self.highlightTextColor = [UIColor whiteColor];
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

@end
