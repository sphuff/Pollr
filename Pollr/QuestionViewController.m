//
//  QuestionViewController.m
//  Pollr
//
//  Created by Stephen Huffnagle on 12/16/15.
//  Copyright (c) 2015 Stephen Huffnagle. All rights reserved.
//

#import "QuestionViewController.h"
#import "HexColors.h"
#import "LGPlusButtonsView.h"
//#import "Chameleon.h"
//#import <LiquidFloatingActionButton/LiquidFloatingActionButton-Swift.h>
//#import "LiquidFloatingActionButton-Swift.h"

@interface QuestionViewController (){
    int charactersLeft;
    CGRect originalLettersRemainingPosition;
    CGRect keyboardLettersRemainingPosition;
    CGRect originalAddAnswerButtonPosition;
    CGRect keyboardAddAnswerButtonPosition;
    CGRect originalLockAnswerButtonPosition;
    CGRect keyboardLockAnswerButtonPosition;
    BOOL answersAreLocked;
    int circleButtonHeight;
}

@property (nonatomic, strong) UITextField *charactersLeftTextField;
@property (nonatomic, strong) UIFont *defaultFont;
@property (nonatomic, strong) UIFont *remainingLetterFont;
@property (nonatomic, strong) UIBarButtonItem *rightButton;
@property (nonatomic, strong) UIButton *addAnswerButton;
@property (nonatomic, strong) UIButton *lockAnswerButton;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) NSMutableArray *answerArray;

@end

@implementation QuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // set up data fields
    charactersLeft = 200;
    answersAreLocked = false;
    circleButtonHeight = 50;
    _defaultFont = [UIFont fontWithName:@"Helvetica" size:20.0];
    _remainingLetterFont = [UIFont fontWithName:@"Helvetica" size:30.0];
    originalLettersRemainingPosition = CGRectMake(self.view.frame.size.width-60, self.view.frame.size.height-50, 60,30);
    originalAddAnswerButtonPosition = CGRectMake(self.view.frame.size.width/20, self.view.frame.size.height-(circleButtonHeight + 20), circleButtonHeight, circleButtonHeight);
    originalLockAnswerButtonPosition = CGRectMake(self.view.frame.size.width/20 + circleButtonHeight + 20, self.view.frame.size.height - (circleButtonHeight + 20), circleButtonHeight, circleButtonHeight);
    _rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStylePlain target:self action:@selector(postButtonPressed)];
    _rightButton.enabled = NO;
    [_rightButton setTintColor:[UIColor whiteColor]];
    
    [self.view setBackgroundColor:[UIColor hx_colorWithHexString:@"C5E1A5"]];
    
    
    // set up nav bar
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:18.0];
//    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    // ^-Use UITextAlignmentCenter for older SDKs.
    label.textColor = [UIColor hx_colorWithHexString:@"6482AD"];
    self.navigationItem.titleView = label;
    [label setText:@"Poll"];
    [label sizeToFit];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)];
    [leftButton setTintColor:[UIColor hx_colorWithHexString:@"6482AD"]];

    self.navigationItem.leftBarButtonItem = leftButton;
    self.navigationItem.rightBarButtonItem = _rightButton;
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor hx_colorWithHexString:@"BEE99F"]];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    
    // set up the text view with placeholder text
    _textView = [[UITextView alloc] initWithFrame:self.view.frame];
    _textView.delegate = self;
    _textView.editable = YES;
    _textView.attributedText = [[NSAttributedString alloc] initWithString:@"What would you like to ask?" attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor], NSFontAttributeName: _defaultFont}];
    _textView.returnKeyType = UIReturnKeyDone;
    _textView.layer.cornerRadius = 5.0;
    
    // set up text in the corner that displays the characters left
    _charactersLeftTextField = [[UITextField alloc] initWithFrame:originalLettersRemainingPosition];
    _charactersLeftTextField.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", charactersLeft] attributes:@{NSForegroundColorAttributeName: [UIColor hx_colorWithHexString:@"689F38"], NSFontAttributeName: _remainingLetterFont}];
    
    // set up add answer button
//    _addAnswerButton = [[UIButton alloc] initWithFrame:originalAddAnswerButtonPosition];
//    [_addAnswerButton setBackgroundColor:[UIColor orangeColor]];
//    _addAnswerButton.layer.cornerRadius = circleButtonHeight/2;
//    [_addAnswerButton addTarget:self action:@selector(addAnswerButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    
    // can scale image here
//    UIImage *plusImg = [UIImage imageNamed:@"plus"];
    LGPlusButtonsView *FAB = [LGPlusButtonsView plusButtonsViewWithNumberOfButtons:3
                                                         firstButtonIsPlusButton:YES
                                                                   showAfterInit:YES
                                                                   actionHandler:^(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index)
                            {
                                NSLog(@"actionHandler | title: %@, description: %@, index: %lu", title, description, (long unsigned)index);
                                if(index == 2){
                                    NSLog(@"Touched the lock");
                                    
                                }
                            }];
    
    //FAB.observedScrollView = self.scrollView;
    FAB.coverColor = [UIColor colorWithWhite:1.f alpha:0.7];
    FAB.position = LGPlusButtonsViewPositionBottomLeft;
    FAB.plusButtonAnimationType = LGPlusButtonAnimationTypeRotate;
    
    [FAB setButtonsTitles:@[@"+", @"", @""] forState:UIControlStateNormal];
    [FAB setDescriptionsTexts:@[@"", @"Add a response", @"Lock responses"]];
    [FAB setButtonsImages:@[[NSNull new], [UIImage imageNamed:@"add44px"], [UIImage imageNamed:@"unlocked44px"]]
                                  forState:UIControlStateNormal
                            forOrientation:LGPlusButtonsViewOrientationAll];
    
    [FAB setButtonsAdjustsImageWhenHighlighted:NO];
    [FAB setButtonsBackgroundColor:[UIColor colorWithRed:0.f green:0.5 blue:1.f alpha:1.f] forState:UIControlStateNormal];
    [FAB setButtonsBackgroundColor:[UIColor colorWithRed:0.2 green:0.6 blue:1.f alpha:1.f] forState:UIControlStateHighlighted];
    [FAB setButtonsBackgroundColor:[UIColor colorWithRed:0.2 green:0.6 blue:1.f alpha:1.f] forState:UIControlStateHighlighted|UIControlStateSelected];
    [FAB setButtonsSize:CGSizeMake(44.f, 44.f) forOrientation:LGPlusButtonsViewOrientationAll];
    [FAB setButtonsLayerCornerRadius:44.f/2.f forOrientation:LGPlusButtonsViewOrientationAll];
    [FAB setButtonsTitleFont:[UIFont boldSystemFontOfSize:24.f] forOrientation:LGPlusButtonsViewOrientationAll];
    [FAB setButtonsLayerShadowColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.f]];
    [FAB setButtonsLayerShadowOpacity:0.5];
    [FAB setButtonsLayerShadowRadius:3.f];
    [FAB setButtonsLayerShadowOffset:CGSizeMake(0.f, 2.f)];
    [FAB setButtonAtIndex:0 size:CGSizeMake(56.f, 56.f)
                            forOrientation:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? LGPlusButtonsViewOrientationPortrait : LGPlusButtonsViewOrientationAll)];
    [FAB setButtonAtIndex:0 layerCornerRadius:56.f/2.f
                            forOrientation:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? LGPlusButtonsViewOrientationPortrait : LGPlusButtonsViewOrientationAll)];
    [FAB setButtonAtIndex:0 titleFont:[UIFont systemFontOfSize:40.f]
                            forOrientation:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? LGPlusButtonsViewOrientationPortrait : LGPlusButtonsViewOrientationAll)];
    [FAB setButtonAtIndex:0 titleOffset:CGPointMake(0.f, -3.f) forOrientation:LGPlusButtonsViewOrientationAll];
    [FAB setButtonAtIndex:1 backgroundColor:[UIColor colorWithRed:1.f green:0.f blue:0.5 alpha:1.f] forState:UIControlStateNormal];
    [FAB setButtonAtIndex:1 backgroundColor:[UIColor colorWithRed:1.f green:0.2 blue:0.6 alpha:1.f] forState:UIControlStateHighlighted];
    [FAB setButtonAtIndex:2 backgroundColor:[UIColor colorWithRed:1.f green:0.5 blue:0.f alpha:1.f] forState:UIControlStateNormal];
    [FAB setButtonAtIndex:2 backgroundColor:[UIColor colorWithRed:1.f green:0.6 blue:0.2 alpha:1.f] forState:UIControlStateHighlighted];
    [FAB setButtonAtIndex:2 backgroundImage:[UIImage imageNamed:@"locked44px"] forState:UIControlStateHighlighted];
//    [FAB setButtonAtIndex:3 backgroundColor:[UIColor colorWithRed:0.f green:0.7 blue:0.f alpha:1.f] forState:UIControlStateNormal];
//    [FAB setButtonAtIndex:3 backgroundColor:[UIColor colorWithRed:0.f green:0.8 blue:0.f alpha:1.f] forState:UIControlStateHighlighted];
    
    [FAB setDescriptionsBackgroundColor:[UIColor whiteColor]];
    [FAB setDescriptionsTextColor:[UIColor blackColor]];
    [FAB setDescriptionsLayerShadowColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.f]];
    [FAB setDescriptionsLayerShadowOpacity:0.25];
    [FAB setDescriptionsLayerShadowRadius:1.f];
    [FAB setDescriptionsLayerShadowOffset:CGSizeMake(0.f, 1.f)];
    [FAB setDescriptionsLayerCornerRadius:6.f forOrientation:LGPlusButtonsViewOrientationAll];
    [FAB setDescriptionsContentEdgeInsets:UIEdgeInsetsMake(4.f, 8.f, 4.f, 8.f) forOrientation:LGPlusButtonsViewOrientationAll];
    
    for (NSUInteger i=1; i<=2; i++)
        [FAB setButtonAtIndex:i offset:CGPointMake(6.f, 0.f)
                                forOrientation:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? LGPlusButtonsViewOrientationPortrait : LGPlusButtonsViewOrientationAll)];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [FAB setButtonAtIndex:0 titleOffset:CGPointMake(0.f, -2.f) forOrientation:LGPlusButtonsViewOrientationLandscape];
        [FAB setButtonAtIndex:0 titleFont:[UIFont systemFontOfSize:32.f] forOrientation:LGPlusButtonsViewOrientationLandscape];
    }
    
    [self.navigationController.view addSubview:FAB];
    

    [self.view addSubview:_textView];
    [self.view addSubview:_charactersLeftTextField];
    [self.view addSubview:FAB];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) drawTextField{
    _charactersLeftTextField.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", charactersLeft] attributes:@{NSForegroundColorAttributeName: [UIColor hx_colorWithHexString:@"9BD672"], NSFontAttributeName: _remainingLetterFont}];
}

- (void)addAnswerButtonPressed{
    NSLog(@"Answer button pressed");
    if(!_answerArray){
        _textView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/3);
        _answerArray = [[NSMutableArray alloc] initWithObjects:@"test", nil];
    }
    
}

- (void)lockAnswerButtonPressed{
    NSLog(@"Lock button pressed");
    if(answersAreLocked){
        [_lockAnswerButton setBackgroundImage:[UIImage imageNamed:@"unlocked"] forState:UIControlStateNormal];
        answersAreLocked = false;
    } else {
        [_lockAnswerButton setBackgroundImage:[UIImage imageNamed:@"locked"] forState:UIControlStateNormal];
        answersAreLocked = true;
    }
}

#pragma mark - UITextView methods
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"What would you like to ask?"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"What would you like to ask?";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    _charactersLeftTextField.frame = originalLettersRemainingPosition;
    _addAnswerButton.frame = originalAddAnswerButtonPosition;
    [textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
    int textLength = [textView.text length];
    
    charactersLeft = 200 - [textView.text length];
    [self drawTextField];
    if (textLength > 0){
        _rightButton.enabled = YES;
    } else {
        _rightButton.enabled = NO;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    } else if([[textView text] length] - range.length + text.length > 200) {
        return NO;
    }
    return YES;
}

- (void)keyboardWasShown:(NSNotification *)notification
{
    if(keyboardLettersRemainingPosition.size.height == 0){
        // Get the size of the keyboard.
        CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        //Given size may not account for screen rotation
        int height = MIN(keyboardSize.height,keyboardSize.width);
        int width = MAX(keyboardSize.height,keyboardSize.width);
        
        keyboardLettersRemainingPosition = CGRectMake(width - 60, self.view.frame.size.height - height - 30, 60, 30);
        keyboardAddAnswerButtonPosition = CGRectMake(width/20, self.view.frame.size.height - height - circleButtonHeight, circleButtonHeight, circleButtonHeight);
    }
    
    _charactersLeftTextField.frame = keyboardLettersRemainingPosition;
    _addAnswerButton.frame = keyboardAddAnswerButtonPosition;
}

#pragma mark - Segue methods

- (void)cancelButtonPressed
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)postButtonPressed
{

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
