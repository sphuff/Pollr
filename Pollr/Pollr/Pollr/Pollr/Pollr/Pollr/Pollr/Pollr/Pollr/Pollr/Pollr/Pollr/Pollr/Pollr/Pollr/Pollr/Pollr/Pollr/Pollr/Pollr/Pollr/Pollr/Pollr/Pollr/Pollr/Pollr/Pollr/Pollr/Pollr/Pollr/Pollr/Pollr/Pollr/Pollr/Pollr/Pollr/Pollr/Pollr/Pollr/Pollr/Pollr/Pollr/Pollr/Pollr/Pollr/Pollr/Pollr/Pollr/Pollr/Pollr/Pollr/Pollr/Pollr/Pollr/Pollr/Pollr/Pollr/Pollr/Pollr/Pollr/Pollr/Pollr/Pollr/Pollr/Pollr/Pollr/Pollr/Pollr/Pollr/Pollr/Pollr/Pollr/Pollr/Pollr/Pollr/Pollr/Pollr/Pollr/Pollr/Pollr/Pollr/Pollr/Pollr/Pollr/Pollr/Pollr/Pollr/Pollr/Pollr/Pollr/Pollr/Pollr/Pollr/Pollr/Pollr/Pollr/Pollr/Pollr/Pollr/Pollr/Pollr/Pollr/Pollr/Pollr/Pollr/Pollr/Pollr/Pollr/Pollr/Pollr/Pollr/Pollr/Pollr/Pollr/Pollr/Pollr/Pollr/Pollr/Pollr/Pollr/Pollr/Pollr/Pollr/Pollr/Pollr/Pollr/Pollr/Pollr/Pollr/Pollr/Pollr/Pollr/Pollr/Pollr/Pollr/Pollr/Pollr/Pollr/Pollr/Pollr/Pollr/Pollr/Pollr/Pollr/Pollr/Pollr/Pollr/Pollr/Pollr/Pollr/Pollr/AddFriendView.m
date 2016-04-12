//
//  AddFriendView.m
//  Pollr
//
//  Created by Stephen Huffnagle on 1/1/16.
//  Copyright (c) 2016 Stephen Huffnagle. All rights reserved.
//

#import "AddFriendView.h"
#import "HexColors.h"

@implementation AddFriendView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame{
    AddFriendView *view = [super initWithFrame:frame];
    [view setBackgroundColor:[UIColor hx_colorWithHexString:@"9BD672"]];
    
    UIFont *textFieldFont = [UIFont fontWithName:@"Helvetica" size:12.0];
    UIFont *buttonFont = [UIFont fontWithName:@"Helvetica" size:20.0];
    
    NSDictionary *attributes = @{NSFontAttributeName: textFieldFont, NSForegroundColorAttributeName: [UIColor grayColor]};
    NSDictionary *buttonAttributes = @{NSFontAttributeName: buttonFont, NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    
    // set up text field
    int textFieldWidth = frame.size.width/2;
    UITextField *usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(frame.size.width/2 - textFieldWidth/2, frame.size.height/5, textFieldWidth, frame.size.height/5)];
    //[usernameTextField setText:@"Test"];
    [usernameTextField setBackgroundColor:[UIColor whiteColor]];
    usernameTextField.layer.cornerRadius = 2.0;
    usernameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 5, 0);
    [usernameTextField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Enter your friend's username" attributes:attributes]];
    [view addSubview:usernameTextField];
    
    
    UIButton *addFriendButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width/6, frame.size.height/5 + frame.size.height/5 + 10, frame.size.width/3, frame.size.height/4)];
    addFriendButton.layer.cornerRadius = 5.0;
    [addFriendButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Add Friend" attributes:buttonAttributes] forState:UIControlStateNormal];
    [addFriendButton addTarget:self action:@selector(addFriendButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [addFriendButton setBackgroundColor:[UIColor hx_colorWithHexString:@"549426"]];
    
    [view addSubview:addFriendButton];

    return view;
}

- (void)addFriendButtonPressed{
    NSLog(@"Add friend button pressed");
    
}

@end
