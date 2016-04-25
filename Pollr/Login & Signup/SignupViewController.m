//
//  SignupViewController.m
//  Pollr
//
//  Created by Stephen Huffnagle on 12/17/15.
//  Copyright (c) 2015 Stephen Huffnagle. All rights reserved.
//

#import "SignupViewController.h"
#import "HexColors.h"
#import <AFNetworking/AFNetworking.h>
#import "PollrNetworkAPI.h"
#import "User.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>

@interface SignupViewController ()

@property (nonatomic, strong) UITextField *usernameField;
@property (nonatomic, strong) UITextField *emailField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UIFont *textFieldFont;
@property (nonatomic, strong) PollrNetworkAPI *api;

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _api = [[PollrNetworkAPI alloc] init];
    self.title = @"Create Account";
    UIFont *placeholderFont = [UIFont fontWithName:@"Helvetica" size:12.0];
    _textFieldFont = [UIFont fontWithName:@"Helvetica" size:20.0];
    UIFont *buttonFont = [UIFont fontWithName:@"Helvetica" size:20.0];

    NSDictionary *placeholderAttributes = @{NSFontAttributeName: placeholderFont, NSForegroundColorAttributeName: [UIColor grayColor]};
    NSDictionary *textAttributes =@{NSFontAttributeName: _textFieldFont};
    NSDictionary *buttonAttributes = @{NSFontAttributeName: buttonFont, NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    // set up the navigation bar
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;// use self's navigationItem since it is connected programmatically

    
    [self.view setBackgroundColor:[UIColor hx_colorWithHexRGBAString:@"9BD672"]];
    
    CGRect usernameFieldFrame = CGRectMake(40, (self.view.frame.size.height/2) - (3*(10 + self.view.frame.size.height/20)), self.view.frame.size.width - 80, self.view.frame.size.height/20);
    _usernameField = [[UITextField alloc] initWithFrame:usernameFieldFrame];
    _usernameField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 5, 0); // makes a placeholder inset
    [_usernameField setBackgroundColor:[UIColor whiteColor]];
    _usernameField.layer.cornerRadius = 2.0;
    [_usernameField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Enter your username" attributes:placeholderAttributes]];
    // [_usernameField setDefaultTextAttributes:textAttributes];
    
    
    CGRect emailFieldFrame = CGRectMake(40, usernameFieldFrame.origin.y + usernameFieldFrame.size.height + 20, self.view.frame.size.width - 80, self.view.frame.size.height/20);
    _emailField = [[UITextField alloc] initWithFrame:emailFieldFrame];
    _emailField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 5, 0); // makes a placeholder inset
    [_emailField setBackgroundColor:[UIColor whiteColor]];
    _emailField.layer.cornerRadius = 2.0;
    [_emailField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Enter your email" attributes:placeholderAttributes]];
    
    CGRect passwordFieldFrame = CGRectMake(40, emailFieldFrame.origin.y + emailFieldFrame.size.height + 20, self.view.frame.size.width - 80, self.view.frame.size.height/20);
    _passwordField = [[UITextField alloc] initWithFrame:passwordFieldFrame];
    [_passwordField setSecureTextEntry:YES];
    _passwordField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 5, 0);
    [_passwordField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Enter your password" attributes:placeholderAttributes]];
    [_passwordField setBackgroundColor:[UIColor whiteColor]];
    _passwordField.layer.cornerRadius = 2.0;
    
    CGRect signupButtonFrame = CGRectMake(CGRectGetMidX(self.view.frame) - self.view.frame.size.width/6, passwordFieldFrame.origin.y + passwordFieldFrame.size.height + 20, self.view.frame.size.width/3, (3*self.view.frame.size.height)/48);
    UIButton *signupButton = [[UIButton alloc] initWithFrame:signupButtonFrame];
    signupButton.layer.cornerRadius = 5.0;
    [signupButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Sign Up" attributes:buttonAttributes] forState:UIControlStateNormal];
    [signupButton addTarget:self action:@selector(signupButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [signupButton setBackgroundColor:[UIColor hx_colorWithHexRGBAString:@"549426"]];
    
    
    [self.view addSubview:_usernameField];
    [self.view addSubview:_emailField];
    [self.view addSubview:_passwordField];
    [self.view addSubview:signupButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelButtonPressed{
    NSLog(@"Cancel Pressed");
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)signupButtonPressed{
    NSLog(@"Sign Up Pressed");
    
    if(![self checkBasicFields]){
        return;
    }
    
    PollrUser *currentUser = [[PollrUser alloc] init];
    
    currentUser.username = [_usernameField text];
    currentUser.password = [_passwordField text];
    currentUser.email = [_emailField text];
    
    [_api signupWithUser:currentUser WithContext: _managedObjectContext AndWithCompletionHandler:^(BOOL signedUp, BOOL usernameTaken, BOOL serverProblem) {
        if(signedUp){
            NSLog(@"Signed Up!");
        } else {
            if(usernameTaken){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh Oh" message:@"This username is already in use. Please enter another one." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                return;
            }
            else if (serverProblem) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh Oh" message:@"Sorry, something went wrong with our servers! Please try again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                return;
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh Oh" message:@"Something weird happened and your signup request was not processed. Please file a bug complaint. " delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                return;
            }
        }
    }];
}

- (BOOL)checkBasicFields{
    // later add cases like 8 chars of more for pass, etc
    if([_usernameField.text isEqualToString:@""] ||[_emailField.text isEqualToString:@""] || [_passwordField.text isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh Oh" message:@"Please enter a valid username, email, and password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return NO;
    } else if(![_api isValidPassword:[_passwordField text]]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh Oh" message:@"Please enter a password with 8 or more digits" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return NO;
    }
    else if([[_usernameField text] length] < 8){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh Oh" message:@"Please enter a username with 8 or more digits" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return NO;
    }
    
    if(![_api isValidEmail:[_emailField text]]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh Oh" message:@"Please enter a valid email ending in .edu or .com" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return NO;
    }
    return YES;
}

@end
