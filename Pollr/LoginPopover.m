//
//  LoginPopover.m
//  Pollr
//
//  Created by Stephen Huffnagle on 2/22/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//

#import "LoginPopover.h"
#import "Chameleon.h"
#import "PollrNetworkAPI.h"
#import "User.h"
#import "MessageFeedViewController.h"
//#import <QuartzCore/QuartzCore.h>

@interface LoginPopover()

@property (nonatomic, strong) UITextField *usernameField;
@property (nonatomic, strong) UITextField *passwordField;

@end

@implementation LoginPopover

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
//        [self setBackgroundColor:[UIColor colorWithHexString:@"E4DCDC"]];
        [self setBackgroundColor:[UIColor colorWithHexString:@"EAA9A9"]];
        self.layer.cornerRadius = 3.0;
        
        // header
        CGRect loginViewHeaderFrame = CGRectIntegral(CGRectMake(0, 0, frame.size.width, frame.size.height/3));
        UIView *loginViewHeader = [[UIView alloc] initWithFrame:loginViewHeaderFrame];
        loginViewHeader.layer.cornerRadius = 3.0;
        loginViewHeader.layer.borderWidth = 0.75;
        [loginViewHeader setBackgroundColor:[UIColor colorWithHexString:@"9F4949"]];
        
        
        NSAttributedString *loginLabelAtt = [[NSAttributedString alloc] initWithString:@"Login"
                                                                            attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:24.0],
                                                                                         NSForegroundColorAttributeName: [UIColor whiteColor]}];
        int loginLabelX = loginViewHeader.frame.size.width/20;
        int loginLabelY = loginViewHeader.frame.size.height/4;
        int loginLabelWidth = loginViewHeader.frame.size.width/5;
        int loginLabelHeight = loginViewHeader.frame.size.height/2;
        CGRect loginLabelFrame = CGRectIntegral(CGRectMake(loginLabelX, loginLabelY, loginLabelWidth, loginLabelHeight));
        UILabel *loginLabel = [[UILabel alloc] initWithFrame:loginLabelFrame];
        [loginLabel setAttributedText:loginLabelAtt];
        loginLabel.adjustsFontSizeToFitWidth = YES;
        loginLabel.numberOfLines = 0;
        
        [self addSubview:loginViewHeader];
        [loginViewHeader addSubview:loginLabel];
        
        
        // username text field
        int usernameFieldX = frame.size.width/20;
        int usernameFieldY = loginViewHeaderFrame.size.height + frame.size.height/20;
        int usernameFieldWidth = frame.size.width - ((frame.size.width/20) * 2);
        int usernameFieldHeight = loginViewHeaderFrame.size.height/2;
        _usernameField = [[UITextField alloc]initWithFrame:CGRectIntegral(CGRectMake(usernameFieldX, usernameFieldY, usernameFieldWidth, usernameFieldHeight))];
        _usernameField.layer.cornerRadius = 5.0;
        [_usernameField setPlaceholder:@"Enter your username"];
        [_usernameField setBackgroundColor:[UIColor whiteColor]];
        //UIImageView *leftView = [[UIImageView alloc] initWithImage:[UIImage imageWithSVGNamed:@"user_icon2" targetSize:CGSizeMake(_usernameField.frame.size.width/10,_usernameField.frame.size.height - 10) fillColor:[UIColor blackColor]]];
        UIImageView *leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_icon20px"]];
        leftView.frame = CGRectIntegral(CGRectMake(0, 0, _usernameField.frame.size.width/10 + 20, _usernameField.frame.size.height));
        leftView.contentMode = UIViewContentModeCenter;
        _usernameField.leftView = leftView;
        _usernameField.leftViewMode = UITextFieldViewModeAlways;
        _usernameField.layer.borderWidth = 0.75;
        [self addSubview:_usernameField];
        
        // password text field
        int passwordFieldX = frame.size.width/20;
        int passwordFieldY = _usernameField.frame.origin.y + _usernameField.frame.size.height + frame.size.height/20;
        int passwordFieldWidth = frame.size.width - ((frame.size.width/20) * 2);
        int passwordFieldHeight = loginViewHeaderFrame.size.height/2;
        _passwordField = [[UITextField alloc]initWithFrame:CGRectIntegral(CGRectMake(passwordFieldX, passwordFieldY, passwordFieldWidth, passwordFieldHeight))];
        _passwordField.layer.cornerRadius = 5.0;
        [_passwordField setPlaceholder:@"Enter your password"];
        [_passwordField setBackgroundColor:[UIColor whiteColor]];
        //UIImageView *passwordLeftView = [[UIImageView alloc] initWithImage:[UIImage imageWithSVGNamed:@"password3" targetSize:CGSizeMake(_passwordField.frame.size.width/10,_passwordField.frame.size.height - 10) fillColor:[UIColor blackColor]]];
        UIImageView *passwordLeftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"password20px"]];
        passwordLeftView.frame = CGRectIntegral(CGRectMake(0, 0, _passwordField.frame.size.width/10 + 20, _passwordField.frame.size.height));
        passwordLeftView.contentMode = UIViewContentModeCenter;
        _passwordField.leftView = passwordLeftView;
        _passwordField.leftViewMode = UITextFieldViewModeAlways;
        _passwordField.layer.borderWidth = 0.75;
        [self addSubview:_passwordField];
        
        // Login UIButton
        int loginButtonWidth = 60;
        int loginButtonHeight = 60;
        
        int loginButtonX = frame.size.width/2 - loginButtonWidth/2;
        int loginButtonY = frame.size.height - loginButtonHeight/2;
        
        
        UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectIntegral(CGRectMake(loginButtonX, loginButtonY, loginButtonWidth, loginButtonHeight))];
        loginButton.clipsToBounds = YES;
        [loginButton setBackgroundImage:[UIImage imageNamed:@"login_button60px"] forState:UIControlStateNormal];
        loginButton.layer.cornerRadius = loginButtonWidth/2.0;
        [loginButton addTarget:self action:@selector(loginPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:loginButton];
        
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(-10, -10, 30, 30)];
        cancelButton.layer.cornerRadius = cancelButton.frame.size.width/2.0;
        [cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel30px"] forState:UIControlStateNormal];
        [[cancelButton layer] setBorderWidth:1.0f];
        [[cancelButton layer] setBorderColor:[UIColor blackColor].CGColor];
        [cancelButton addTarget:self action:@selector(cancelPressed) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:cancelButton];
        
    }
    return self;
}

// FIXME: Only top half clickable and add password protection
- (void)loginPressed{
    NSLog(@"Login pressed");
    
    PollrNetworkAPI *api = [[PollrNetworkAPI alloc] init];
    
    PollrUser *user = [[PollrUser alloc] init];
    user.username = [_usernameField text];
    user.password = [_passwordField text];
    
    
    [api userExists:user WithCompletionHandler:^(BOOL isAUser, BOOL correctPass, NSDictionary *dict) {
        if(isAUser && correctPass){
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
            [self.navController pushViewController:messageVC animated:NO];
            
        }
        else if(isAUser){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh Oh" message:@"Incorrect password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh Oh" message:@"Invalid username" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}

- (void)cancelPressed{
    NSLog(@"Cancel Pressed");
    for (UIView *view in self.subviewArray) {
        [view removeFromSuperview];
    }
    
}


@end
