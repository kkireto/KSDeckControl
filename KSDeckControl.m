//
//  KSDeckControl.m
//  KSDeckController
//
//  Created by Kireto on 3/7/14.
//  Copyright (c) 2014 No Name. All rights reserved.
//

#import "KSDeckControl.h"

#import "LeftMenuButton.h"

@interface KSDeckControl ()

@property(nonatomic,strong) UIPanGestureRecognizer *panGesture;
@property(nonatomic,strong) UITapGestureRecognizer *tapGesture;
@property(nonatomic,strong) UIView *maskView;
@property(nonatomic,strong) UIView *centerHolderView;
@property(nonatomic,assign) CGPoint touchOffset;
@property(nonatomic,assign) BOOL isMenuVisible;

@end

@implementation KSDeckControl

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCenterViewController:(UIViewController*)centerController
                menuViewController:(UIViewController*)menuController
{
    self = [super init];
    if (self) {
        // Custom initialization
        _centerController = centerController;
        _menuController = menuController;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor lightGrayColor];
    _isMenuVisible = NO;
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleLeftView)];
    
    [self createCenterView];
    [self setupView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setup view
- (void)setupView {
    
    if (_centerController) {
        [_centerController.view setFrame:CGRectMake(0.0, 0.0, _centerHolderView.frame.size.width, _centerHolderView.frame.size.height)];
        _centerController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_centerHolderView addSubview:_centerController.view];
        
        if (_menuController) {
            [_menuController.view setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
            _menuController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.view insertSubview:_menuController.view belowSubview:_centerHolderView];
            _menuController.view.alpha = 0.0;
        }
    }
}

- (void)createCenterView {
    
    if (_centerHolderView) {
        [_centerHolderView removeFromSuperview];
        _centerHolderView = nil;
    }
    _centerHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    _centerHolderView.backgroundColor = [UIColor clearColor];
    _centerHolderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_centerHolderView];
}

#pragma mark - left menu button
- (void)setupLeftMenuButtonForController:(UIViewController*)controller {
    
    LeftMenuButton *menuButton = [[LeftMenuButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 44.0)];
    [menuButton addTarget:self action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];
    [menuButton customizeButton];
    
	UIBarButtonItem *menuBarButton = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
	controller.navigationItem.leftBarButtonItem = menuBarButton;
}

#pragma mark - public methods
- (void)setNewCenterViewController:(UIViewController*)centerController {
    
    self.view.userInteractionEnabled = NO;
    if (_centerController) {
        [_centerController.view removeFromSuperview];
        _centerController = nil;
    }
    
    _centerController = centerController;
    [_centerController.view setFrame:CGRectMake(0.0, 0.0, _centerHolderView.frame.size.width, _centerHolderView.frame.size.height)];
    _centerController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_centerHolderView addSubview:_centerController.view];
    
    [self resetViewFrames];
    self.view.userInteractionEnabled = YES;
}

- (void)toggleLeftView {
    
    _isMenuVisible = !_isMenuVisible;
    [self animateCenterView];
}

#pragma mark - add/remove pan gesture
- (void)removePanGessture {
    if (_centerHolderView) {
        [_centerHolderView removeGestureRecognizer:_panGesture];
    }
}

- (void)addPanGessture {
    if (_centerHolderView) {
        [_centerHolderView addGestureRecognizer:_panGesture];
    }
}

#pragma mark - pan gesture
- (void)handlePanGesture:(UIPanGestureRecognizer*)panGesture {
    
    CGPoint location = [panGesture locationInView:self.view];
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        _touchOffset = location;
    }
    else if (panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateEnded) {
        [self panningEnded];
    }
    else {
        CGFloat positionX = location.x - _touchOffset.x;
        CGFloat positionY = 0.0;
        if (_isMenuVisible) {
            positionX += _menuOffset;
        }
        if (positionX < 0) {
            positionX = 0;
        }
        else if (positionX > _menuOffset) {
            positionX = _menuOffset;
        }
        positionY = (self.view.frame.size.height - ((self.view.frame.size.width - positionX)/self.view.frame.size.width)*self.view.frame.size.height)/2.0;
        NSLog(@"positionX:%f, positionY:%f", positionX, positionY);
        
        [_centerHolderView setFrame:CGRectMake(positionX, positionY, self.view.frame.size.width - positionX, self.view.frame.size.height - 2*positionY)];
        _centerHolderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        CGFloat menuAlpha = (_menuOffset - positionX)/_menuOffset;
        _menuController.view.alpha = 1 - menuAlpha;
    }
}

- (void)panningEnded {
    
    _isMenuVisible = NO;
    if (_centerHolderView.frame.origin.x > _menuOffset/2) {
        _isMenuVisible = YES;
    }
    [self animateCenterView];
}

#pragma mark - mask view
- (void)addCenterMaskView {
    
    if (_maskView) {
        [_maskView removeFromSuperview];
        _maskView = nil;
    }
    _maskView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, _centerController.view.frame.size.width, _centerController.view.frame.size.height)];
    _maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _maskView.backgroundColor = [UIColor clearColor];
    [_centerController.view addSubview:_maskView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetViewFrames)];
    [_maskView addGestureRecognizer:tapGesture];
}

#pragma mark - change subview frames
- (void)resetViewFrames {
    
    _isMenuVisible = NO;
    [self animateCenterView];
}

- (void)animateCenterView {
    
    self.view.userInteractionEnabled = NO;
    if (_maskView) {
        [_maskView removeFromSuperview];
        _maskView = nil;
    }
    CGFloat positionX = 0.0;
    CGFloat positionY = 0.0;
    if (_isMenuVisible) {
        positionX = _menuOffset;
        positionY = (self.view.frame.size.height - ((self.view.frame.size.width - positionX)/self.view.frame.size.width)*self.view.frame.size.height)/2.0;
    }
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         if (_centerHolderView) {
                             [_centerHolderView setFrame:CGRectMake(positionX, positionY, self.view.frame.size.width - positionX, self.view.frame.size.height - 2*positionY)];
                             _centerHolderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                         }
                         if (_isMenuVisible) {
                             _menuController.view.alpha = 1.0;
                         }
                         else {
                             _menuController.view.alpha = 0.0;
                         }
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             
                         }
                         [_centerHolderView setFrame:CGRectMake(positionX, positionY, self.view.frame.size.width, self.view.frame.size.height - 2*positionY)];
                         _centerHolderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                         
                         if (_maskView) {
                             [_maskView removeFromSuperview];
                             _maskView = nil;
                         }
                         if (_isMenuVisible) {
                             [self addPanGessture];
                             [self addCenterMaskView];
                             _menuController.view.alpha = 1.0;
                         }
                         else {
                             [self removePanGessture];
                             _menuController.view.alpha = 0.0;
                         }
                         self.view.userInteractionEnabled = YES;
                     }];
}

@end
