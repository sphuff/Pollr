//
//  ViewController.m
//  Pollr
//
//  Created by Stephen Huffnagle on 12/16/15.
//  Copyright (c) 2015 Stephen Huffnagle. All rights reserved.
//

#import "ViewController.h"
#import <HexColors/HexColors.h>
#import "Chameleon.h"
#import "AppDelegate.h"
#import "SignupViewController.h"
#import "QuestionViewController.h"
#import "MessageFeedViewController.h"
#import "PublicMessageCell.h"
#import "User.h"
#import "LoginPopover.h"
#import "PollrNetworkAPI.h"
#import "LoginViewController.h"
#import "FriendFeedViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIView *popupView;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *signupButton;
@property (nonatomic, strong) UITextView *loginTextView;
@property (nonatomic, strong) PollrNetworkAPI *api;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _api = [[PollrNetworkAPI alloc] init];
    [self.view setBackgroundColor:[UIColor hx_colorWithHexRGBAString:@"BEE99F"]];
    
    
    // set up rounded UIView at bottom
    CGRect popupFrame = CGRectMake(0, (3*self.view.frame.size.height)/4, self.view.frame.size.width, (3*self.view.frame.size.height)/4);
    
    _popupView = [[UIView alloc] initWithFrame:popupFrame];
    _popupView.layer.cornerRadius = 5.0;
    [_popupView setBackgroundColor:[UIColor whiteColor]];
    
    // set up login UIButton
    CGRect loginFrame = CGRectMake(_popupView.frame.size.width/3, _popupView.frame.size.height/20, _popupView.frame.size.width/3, _popupView.frame.size.height/12);
    _loginButton = [[UIButton alloc] initWithFrame:loginFrame];
    _loginButton.layer.cornerRadius = 5.0;
    [_loginButton addTarget:self action:@selector(loginButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_loginButton setBackgroundColor:[UIColor flatBlueColor]];
    
    NSAttributedString *loginTitle = [[NSAttributedString alloc] initWithString:@"Login" attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:20.0], NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [_loginButton setAttributedTitle:loginTitle forState:UIControlStateNormal];
    
    // set up text field in the middle of the popup
    CGRect textFieldFrame = CGRectMake(loginFrame.origin.x - 10, loginFrame.origin.y + loginFrame.size.height, loginFrame.size.width + 20, loginFrame.size.height);
    CGRect signupButtonFrame = CGRectMake(textFieldFrame.origin.x, textFieldFrame.origin.y + (2*textFieldFrame.size.height)/3, textFieldFrame.size.width, textFieldFrame.size.height);
    
    _loginTextView = [[UITextView alloc] initWithFrame:textFieldFrame];
    [_loginTextView setEditable:NO];
    _loginTextView.textAlignment = NSTextAlignmentCenter;
    [_loginTextView setBackgroundColor:[UIColor clearColor]];
    
    UIFont *textFont = [UIFont fontWithName:@"Helvetica" size:12.0];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    
    NSDictionary *attributesForLoginText = @{NSFontAttributeName: textFont, NSForegroundColorAttributeName: [UIColor flatGrayColor], NSParagraphStyleAttributeName: paragraphStyle};
    NSMutableDictionary *attributesForSignupText = [NSMutableDictionary dictionaryWithDictionary:attributesForLoginText];
    [attributesForSignupText setValue:[UIColor flatBlueColor] forKey:NSForegroundColorAttributeName];
    
    [_loginTextView setAttributedText:[[NSAttributedString alloc] initWithString:@"Login with your email and password" attributes:attributesForLoginText]];
    // set up signup button
    _signupButton = [[UIButton alloc] initWithFrame:signupButtonFrame];
    [_signupButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Or, you can sign up" attributes:attributesForSignupText]  forState:UIControlStateNormal];
    [_signupButton addTarget:self action:@selector(signupButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pollr_bear_logo.png"]];
    int iconY = CGRectGetMidY(self.view.frame) - 100 - (self.view.frame.size.height/8);
    int iconX = CGRectGetMidX(self.view.frame) - 100;
    
    icon.frame = CGRectMake(iconX, iconY, 200, 200);
    [self.view addSubview:icon];
    
//    int logoY = icon.frame.origin.y + icon.frame.size.height + 10;
//    UITextField *logoText = [[UITextField alloc] initWithFrame:CGRectMake(0, logoY, 100, 100)];
//    UIFont *logoFont = [UIFont fontWithName:@"Roboto" size:20.0];
//    logoText.attributedText = [[NSAttributedString alloc] initWithString:@"Pollr" attributes:@{NSFontAttributeName: logoFont}];
//    
//    [self.view addSubview:logoText];
    
    // add to views
    [_popupView addSubview:_loginButton];
    [_popupView addSubview:_loginTextView];
    [_popupView addSubview:_signupButton];
    [self.view addSubview:_popupView];
}

- (void)loginButtonPressed{
    NSLog(@"Login pressed");
    
    AppDelegate *appDel = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDel managedObjectContext];
    
    User *user = [_api getUserWithContext:context];
    if(!user){
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        AppDelegate *appDel = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [appDel managedObjectContext];
        loginVC.context = context;
        
        [self.navigationController pushViewController:loginVC animated:NO];
    } else {
        MessageFeedViewController *messageVC = [[MessageFeedViewController alloc] init];
        messageVC.context = context;
        
        FriendFeedViewController *friendVC = [[FriendFeedViewController alloc] init];
        friendVC.context = context;
        
        UINavigationController *publicNC = [[UINavigationController alloc] initWithRootViewController:messageVC];
        publicNC.tabBarItem.title = @"Public";
        publicNC.tabBarItem.image = [UIImage imageNamed:@"public_unselected"];
        
        UINavigationController *friendNC = [[UINavigationController alloc] initWithRootViewController:friendVC];
        friendNC.tabBarItem.title = @"Friend";
        friendNC.tabBarItem.image = [UIImage imageNamed:@"friends_unselected"];
        
        UITabBarController *tabBarController = [[UITabBarController alloc] init];

        tabBarController.viewControllers = [NSArray arrayWithObjects:publicNC, friendNC, nil];
        
        
        CGFloat frameHeight = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y;
        
        [UIView animateWithDuration:0.33 animations:^{
            _popupView.frame = CGRectMake(0, frameHeight, self.view.frame.size.width, self.view.frame.size.height);
            [_popupView setBackgroundColor:[UIColor hx_colorWithHexRGBAString:@"E4DCDC"]];
            [_loginButton setAlpha:0.0];
            [_signupButton setAlpha:0.0];
            [_loginTextView setAlpha:0.0];
            
        } completion:^(BOOL finished) {
            if(finished){
                [self.navigationController pushViewController:tabBarController animated:NO];
                [self.navigationController setNavigationBarHidden:YES];
                
                _popupView.frame = CGRectMake(0, (3*self.view.frame.size.height)/4, self.view.frame.size.width, (3*self.view.frame.size.height)/4);
                [_popupView setBackgroundColor:[UIColor whiteColor]];
                [_loginButton setAlpha:1.0];
                [_signupButton setAlpha:1.0];
                [_loginTextView setAlpha:1.0];
            }
        }];
    }
}

/**
 * @brief Blurs the current view, and creates the login popover view
 
- (LoginPopover *)setUpLoginView{
    UIERealTimeBlurView *blurView = [[UIERealTimeBlurView alloc] initWithFrame:CGRectIntegral(self.view.frame)];
    blurView.tintColor = [UIColor blackColor];
    [self.view addSubview:blurView];
    
    int loginViewWidth = (4*self.view.frame.size.width)/5;
    int loginViewHeight = self.view.frame.size.height/3;
    int loginViewX = (self.view.frame.size.width - (4*self.view.frame.size.width)/5) / 2;
    int loginViewY = self.view.frame.size.height/5;
    LoginPopover *loginView;
    
    CGRect loginViewFrame = CGRectIntegral(CGRectMake(loginViewX, loginViewY, loginViewWidth, loginViewHeight));
    loginView = [[LoginPopover alloc] initWithFrame:loginViewFrame];
    loginView.subviewArray = [[NSMutableArray alloc] initWithObjects:blurView, nil];
    
    AppDelegate *appDel = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDel managedObjectContext];
    loginView.context = context;
    loginView.navController = self.navigationController;
    [blurView addSubview:loginView];
    return loginView;
}
 */

- (void)signupButtonPressed{
    NSLog(@"Signup pressed");
    SignupViewController *signup = [[SignupViewController alloc] init];
    AppDelegate *appDel = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDel managedObjectContext];
    signup.managedObjectContext = context;
    [self.navigationController pushViewController:signup animated:NO];
    
}

- (void)viewWillAppear:(BOOL)animated{
    // FIXME: Bar disappears after logout
    // FIXME: Login not possible after logout
    [self.navigationController.navigationBar setBarTintColor:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
