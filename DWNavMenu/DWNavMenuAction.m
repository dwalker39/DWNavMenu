//
//  DWNavMenuAction.m
//  DWNavMenuDemo
//
//  Created by Derrick Walker on 2/19/15.
//  Copyright (c) 2015 Derrick Walker. All rights reserved.
//

#import "DWNavMenuAction.h"

@implementation DWNavMenuAction

+ (DWNavMenuAction *)menuActionWithTitle:(NSString *)title shouldDismissMenu:(BOOL)dismissMenu blockHandler:(MenuAction)handler {
    DWNavMenuAction *instance = [[DWNavMenuAction alloc] init];
    instance.title = title;
    instance.shouldDismissMenu = dismissMenu;
    instance.tapAction = handler;
    
    return instance;
}

@end
