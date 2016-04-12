//
//  LoginViewController.m
//  Pollr
//
//  Created by Stephen Huffnagle on 3/25/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//

#import "LoginViewController.h"
#import "Chameleon.h"
#import "PollrNetworkAPI.h"
#import "MessageFeedViewController.h"
#import "PollrUser.h"
#import "QuestionViewController.h"
#import "FriendFeedViewController.h"

@interface LoginViewController()

@property (nonatomic, strong) UITextField *usernameField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) PollrNetworkAPI *api;
@property (nonatomic, strong) NSAttributedString *loginText;


@end

@implementation LoginViewController

-(void)viewDidLoad{
    _api = [[PollrNetworkAPI alloc] init];

    NSArray *colors = [NSArray arrayWithObjects:[UIColor flatMintColor], [UIColor flatMintColor], [UIColor colorWithHexString:@"BEE99F"], nil];
    [self.view setBackgroundColor:[UIColor colorWithGradientStyle:UIGradientStyleTopToBottom withFrame:self.view.frame andColors:colors]];
    
    // set up text label field
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:15.0];
    _usernameField = [[UITextField alloc] initWithFrame:CGRectMake(20, (int)self.view.frame.size.height/3, self.view.frame.size.width-40, 20)];
    NSAttributedString *usernameString = [[NSAttributedString alloc] initWithString:@"USERNAME" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: font}];
    _usernameField.attributedText = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    _usernameField.textColor = [UIColor whiteColor];
    [_usernameField setAttributedPlaceholder:usernameString];
    _usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    
    UIView *usernameBottomBorder = [[UIView alloc] initWithFrame:CGRectMake(20.0f, _usernameField.frame.origin.y + _usernameField.frame.size.height + 10, self.view.frame.size.width - 40, 1.0f)];
    [usernameBottomBorder setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:usernameBottomBorder];
    
    _passwordField = [[UITextField alloc] initWithFrame:CGRectMake(20, _usernameField.frame.origin.y + _usernameField.frame.size.height + 30, self.view.frame.size.width-40, 20)];
    NSAttributedString *passwordString = [[NSAttributedString alloc] initWithString:@"PASSWORD" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: font}];
    [_passwordField setAttributedPlaceholder:passwordString];
    _passwordField.textColor = [UIColor whiteColor];
    _passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [_passwordField setSecureTextEntry:YES];
    
    UIView *passwordBottomBorder = [[UIView alloc] initWithFrame:CGRectMake(20.0f, _passwordField.frame.origin.y + _passwordField.frame.size.height + 10, self.view.frame.size.width - 40, 1.0f)];
    [passwordBottomBorder setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:passwordBottomBorder];
    
    
    // Login button
    _loginButton = [[UIButton alloc] initWithFrame:CGRectMake(20, _passwordField.frame.origin.y + _passwordField.frame.size.height + 30, self.view.frame.size.width - 40, 50)];
    _loginButton.layer.cornerRadius = 5.0;
    [_loginButton setBackgroundColor:[UIColor flatMintColorDark]];
    [_loginButton addTarget:self action:@selector(loginPressed) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIFont *loginFont = [UIFont fontWithName:@"Helvetica" size:17.0];
    _loginText = [[NSAttributedString alloc] initWithString:@"SIGN IN" attributes:@{NSFontAttributeName: loginFont, NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [_loginButton setAttributedTitle:_loginText forState:UIControlStateNormal];
    
    // logo image
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_tiny"]];
    int imageWidth = 90;
    int imageHeight = 50;
    imageView.frame = CGRectMake(CGRectGetMidX(self.view.frame) - imageWidth/2, (_usernameField.frame.origin.y - self.navigationController.navigationBar.frame.size.height)/2 + self.navigationController.navigationBar.frame.size.height, imageWidth, imageHeight);
    
    // forgot password button
    int forgotPasswordWidth = self.view.frame.size.width/2;
    UIButton *forgotPasswordButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - forgotPasswordWidth/2, _loginButton.frame.origin.y + _loginButton.frame.size.height + 5, forgotPasswordWidth, 50)];
    UIFont *forgotPassFont = [UIFont fontWithName:@"Helvetica" size:17.0];
    NSAttributedString *forgotPasswordString = [[NSAttributedString alloc] initWithString:@"Forgot your password?" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: forgotPassFont}];
    [forgotPasswordButton setAttributedTitle:forgotPasswordString forState:UIControlStateNormal];
    
    
    
    [self.view addSubview:_usernameField];
    [self.view addSubview:_passwordField];
    [self.view addSubview:_loginButton];
    [self.view addSubview:imageView];
    [self.view addSubview:forgotPasswordButton];
}

// TODO: Make check mark appear

- (void) loginPressed{
    NSLog(@"Login pressed");

    [_loginButton setAttributedTitle:nil forState:UIControlStateNormal];
    PollrNetworkAPI *api = [[PollrNetworkAPI alloc] init];
    PollrUser *user = [[PollrUser alloc] init];
    user.username = [_usernameField text];
    user.password = [_passwordField text];
    
    int spinnerWidth = _loginButton.frame.size.height - 10;
    int spinnerHeight = spinnerWidth;
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(CGRectGetMidX(_loginButton.frame) - spinnerWidth/2, CGRectGetMidY(_loginButton.frame) - spinnerHeight/2, spinnerWidth, spinnerHeight)];
    [spinner startAnimating];
    [_loginButton setTitle:@"" forState:UIControlStateNormal];
    
    if(![self checkBasicFields]){
        [spinner stopAnimating];
        return;
    }
    
    [self.view addSubview:spinner];
    
    
    [api userExists:user WithCompletionHandler:^(BOOL isAUser, BOOL correctPass, NSDictionary *dict) {
        [spinner stopAnimating];
        if(isAUser && correctPass){
            UIImageView *successView = [[UIImageView alloc] initWithFrame:spinner.frame];
            successView.image = [UIImage imageNamed:@"check30px"];
            successView.contentMode = UIViewContentModeCenter;
            successView.alpha = 0.0;
            [self.view addSubview:successView];
            [UIView animateWithDuration:2.0 animations:^{
                successView.alpha = 1.0;
            } completion:^(BOOL finished) {
                if(finished){
                    NSString *email = [dict objectForKey:@"email"];
                    user.email = email;
                    User *currentUser = [api saveUser:user WithContext:self.context];
                    NSLog(@"Saved user");
                    
                    // add Messages to User entity
                    [api getMessagesForUser:currentUser WithCompletionHandler:^(NSOrderedSet<Message *> *messageSet) {
                        NSLog(@"Called get Messages");
                    }];
                    
                    MessageFeedViewController *messageVC = [[MessageFeedViewController alloc] init];
                    messageVC.context = self.context;
                    
                    FriendFeedViewController *friendVC = [[FriendFeedViewController alloc] init];
                    
                    UINavigationController *publicNC = [[UINavigationController alloc] initWithRootViewController:messageVC];
                    publicNC.tabBarItem.title = @"Public";
                    
                    UINavigationController *friendNC = [[UINavigationController alloc] initWithRootViewController:friendVC];
                    friendNC.tabBarItem.title = @"Friend";
                    
                    UITabBarController *tabBarController = [[UITabBarController alloc] init];
                    
                    tabBarController.viewControllers = [NSArray arrayWithObjects:publicNC, friendNC, nil];
                    [self.navigationController pushViewController:tabBarController animated:NO];
                    [self.navigationController setNavigationBarHidden:YES];
                }
            }];
            
        }
        else if(isAUser){
            UIImageView *failureView = [[UIImageView alloc] initWithFrame:spinner.frame];
            failureView.image = [UIImage imageNamed:@"failure30px"];
            failureView.contentMode = UIViewContentModeCenter;
            failureView.alpha = 0.0;
            [self.view addSubview:failureView];
            [UIView animateWithDuration:2.0 animations:^{
                failureView.alpha = 1.0;
            } completion:^(BOOL finished) {
                if(finished){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh Oh" message:@"Incorrect password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    [_loginButton setAttributedTitle:_loginText forState:UIControlStateNormal];
                    [failureView removeFromSuperview];
                }
            }];
        } else {
            UIImageView *failureView = [[UIImageView alloc] initWithFrame:spinner.frame];
            failureView.image = [UIImage imageNamed:@"failure30px"];
            failureView.contentMode = UIViewContentModeCenter;
            failureView.alpha = 0.0;
            [self.view addSubview:failureView];
            [UIView animateWithDuration:2.0 animations:^{
                failureView.alpha = 1.0;
            } completion:^(BOOL finished) {
                if(finished){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh Oh" message:@"Invalid username" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    [_loginButton setAttributedTitle:_loginText forState:UIControlStateNormal];
                    [failureView removeFromSuperview];
                }
            }];
        }
    }];
}

- (BOOL)checkBasicFields{
    // later add cases like 8 chars of more for pass, etc
    if([_usernameField.text isEqualToString:@""] || [_passwordField.text isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh Oh" message:@"Please enter a valid username and password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return NO;
    }
    return YES;
}

// TODO: Add forgot email functionality

@end
