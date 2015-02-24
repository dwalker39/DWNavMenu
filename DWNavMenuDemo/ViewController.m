//
//  ViewController.m
//  DWNavMenuDemo
//
//  Created by Derrick Walker on 2/23/15.
//  Copyright (c) 2015 Derrick Walker. All rights reserved.
//

#import "ViewController.h"
#import "DWNavMenu.h"

@interface ViewController ()

@property (nonatomic, strong) DWNavMenu *mainMenu;
@property (nonatomic, strong) DWNavMenu *subMenu;
@property (nonatomic, strong) DWNavMenu *lastMenu;

@end

@implementation ViewController

- (IBAction)showMenu:(id)sender {
    [self.mainMenu showInView:self.view animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Last Sub-menu
    self.lastMenu = [DWNavMenu navMenuWithTitle:@"Are you sure you want to something something?"
                              cancelButtonTitle:nil
                                   cancelAction:nil
                                        buttons:
                     [DWNavMenuAction menuActionWithTitle:@"No"
                                        shouldDismissMenu:YES
                                             blockHandler:^{
                                                 NSLog(@"Tapped no");
                                             }],
                     [DWNavMenuAction menuActionWithTitle:@"Yes"
                                        shouldDismissMenu:YES
                                             blockHandler:^{
                                                 NSLog(@"Tapped yes");
                                             }], nil
                     ];
    
    // First Sub-menu
    self.subMenu = [DWNavMenu navMenuWithTitle:@"This sub-menu has a really long title for demonstration purposes to show what it would look like with a really long title"
                             cancelButtonTitle:@"Cancel"
                                  cancelAction:nil
                                       buttons:
                    [DWNavMenuAction menuActionWithTitle:@"Show last sub-menu?"
                                       shouldDismissMenu:NO
                                            blockHandler:^{
                                                NSLog(@"Show last sub-menu tapped");
                                                [self.subMenu pushNavMenu:self.lastMenu animated:YES];
                                            }],
                    [DWNavMenuAction menuActionWithTitle:@"This is a useless button"
                                       shouldDismissMenu:YES
                                            blockHandler:^{
                                                NSLog(@"Useless button was tapped");
                                            }],
                    [DWNavMenuAction menuActionWithTitle:@"Another useless button"
                                       shouldDismissMenu:YES
                                            blockHandler:^{
                                                NSLog(@"Another useless button was tapped");
                                            }], nil
                    ];
    
    // Main Menu
    self.mainMenu = [DWNavMenu navMenuWithTitle:@"Sample Main Menu"
                              cancelButtonTitle:@"Cancel"
                                   cancelAction:nil
                                        buttons:
                     [DWNavMenuAction menuActionWithTitle:@"Show sample sub-menu?"
                                        shouldDismissMenu:NO
                                             blockHandler:^{
                                                 NSLog(@"Tapped show sample sub-menu");
                                                 [self.mainMenu pushNavMenu:self.subMenu animated:YES];
                                             }],
                     [DWNavMenuAction menuActionWithTitle:@"This is a useless button"
                                        shouldDismissMenu:YES
                                             blockHandler:^{
                                                 NSLog(@"Useless button was tapped");
                                             }],
                     [DWNavMenuAction menuActionWithTitle:@"This is another useless button"
                                        shouldDismissMenu:YES
                                             blockHandler:^{
                                                 NSLog(@"Another useless button was tapped");
                                             }], nil
                     ];
    
    self.mainMenu.destructiveMenuAction = [DWNavMenuAction menuActionWithTitle:@"Delete"
                                                             shouldDismissMenu:YES
                                                                  blockHandler:^{
                                                                      NSLog(@"Destructive button was tapped");
                                                                  }];
}

@end
