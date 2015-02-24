//
//  DWNavMenuAction.h
//  DWNavMenuDemo
//
//  Created by Derrick Walker on 2/19/15.
//  Copyright (c) 2015 Derrick Walker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^ MenuAction)();

@class DWNavMenuAction;
@interface DWNavMenuAction : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) MenuAction tapAction;
@property (nonatomic, assign) BOOL shouldDismissMenu;

// Initializers
+ (DWNavMenuAction *)menuActionWithTitle:(NSString *)title shouldDismissMenu:(BOOL)dismissMenu blockHandler:(MenuAction)handler;

@end
