//
//  KSDeckControl.h
//  KSDeckController
//
//  Created by Kireto on 3/7/14.
//  Copyright (c) 2014 No Name. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSDeckControl : UIViewController

@property(nonatomic,strong) UIViewController *centerController;
@property(nonatomic,strong) UIViewController *menuController;
@property(nonatomic,assign) CGFloat menuOffset;

- (id)initWithCenterViewController:(UIViewController*)centerController
                menuViewController:(UIViewController*)menuController;

- (void)setNewCenterViewController:(UIViewController*)centerController;

- (void)setupLeftMenuButtonForController:(UIViewController*)controller;

- (void)toggleLeftView;
- (void)removePanGessture;
- (void)addPanGessture;

@end
