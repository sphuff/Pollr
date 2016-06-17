//
//  MessageViewController.m
//  Pollr
//
//  Created by Stephen Huffnagle on 2/11/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//

#import "MessageViewController.h"
#import "Chameleon.h"
#import "HexColors.h"
#import "CommentCell.h"

@interface MessageViewController()

@property (nonatomic, strong) UITableView *commentTable;
@property (nonatomic, strong) NSArray *commentArray;
@property (nonatomic, strong) UIButton *commentButton;

@end

@implementation MessageViewController

-(instancetype) initWithDict:(NSDictionary *)dict{
    _messageDict = [NSDictionary dictionaryWithDictionary:dict];
    MessageViewController *ret = [super init];
    return ret;
}

-(void)viewDidLoad{
    [self.view addSubview:_messageView];
    
    [self.view setBackgroundColor:[UIColor hx_colorWithHexRGBAString:@"E4DCDC"]]; // same color as MessageFeedViewController
    _commentArray = [_messageDict objectForKey:@"comments"];
    
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIView *backButtonView = [[UIView alloc] initWithFrame:backButton.frame];
    backButtonView.bounds = CGRectOffset(backButton.frame, 10, 0);
    [backButtonView addSubview:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];
    
    
    int viewWidth = self.view.frame.size.width;
    int viewHeight = self.view.frame.size.height;
    
    _commentTable = [[UITableView alloc] initWithFrame:CGRectMake(0, viewHeight/2, viewWidth, viewHeight/2)];
    [self.view addSubview:_commentTable];
    _commentTable.delegate = self;
    _commentTable.dataSource = self;
    
    
    [_commentTable registerClass:[CommentCell class] forCellReuseIdentifier:@"commentCell"];
    
    [_commentTable setSeparatorInset:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    [_commentTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [_commentTable reloadData];
    
    int buttonHeight = 40;
    int yCoord = viewHeight/2 - buttonHeight;
    
    _commentButton = [[UIButton alloc] initWithFrame:CGRectMake(10, yCoord, buttonHeight, buttonHeight)];
    [_commentButton setBackgroundColor:[UIColor blackColor]];
    [_commentButton.layer setCornerRadius:buttonHeight/2.0];
    [self.view addSubview:_commentButton];
    
    [self setUpCardView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ceilf(tableView.frame.size.height/6);
}

- (void)backButtonPressed{
    NSLog(@"Pressed back button");
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)setUpCardView {
    int textLabelHeight = self.messageView.frame.size.height/5;
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.messageView.frame.size.width, textLabelHeight)];
    NSAttributedString *textString = [[NSAttributedString alloc] initWithString:[self.messageDict objectForKey:@"text"] attributes: @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:20.0]}];
    [textLabel setAttributedText:textString];
    
    int userImageViewWidth = self.messageView.frame.size.width/6;
    NSLog(@"Dict: %@", self.messageDict);
    UIImageView *userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, textLabelHeight + textLabel.frame.size.height, userImageViewWidth, userImageViewWidth)];
    [userImageView.layer setCornerRadius:userImageViewWidth/2.0];
    [userImageView setImage:[UIImage imageNamed:self.userImageName]];
    [userImageView setBackgroundColor:[UIColor whiteColor]];
    [userImageView setContentMode:UIViewContentModeCenter];
    [userImageView.layer setBorderColor:[UIColor blackColor].CGColor];
    [userImageView.layer setBorderWidth:3.0];
    
    int authorLabelX = userImageView.frame.origin.x + userImageView.frame.size.width + 10;
    UILabel *authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(authorLabelX, userImageView.frame.origin.y + 10, self.messageView.frame.size.width - authorLabelX, textLabelHeight)];
    NSAttributedString *authorString = [[NSAttributedString alloc] initWithString:[self.messageDict objectForKey:@"createdBy"] attributes: @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:17.0]}];
    [authorLabel setAttributedText:authorString];
    
    [self.messageView addSubview:textLabel];
    [self.messageView addSubview:authorLabel];
    [self.messageView addSubview:userImageView];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_commentArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
    NSDictionary *commentDict = [_commentArray objectAtIndex:indexPath.item];
    [cell.textLabel setText:[commentDict objectForKey:@"text"]];
    return cell;
}






@end
