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
#import "AnswerCell.h"

@interface MessageViewController()

@property (nonatomic, strong) UITableView *answerTable;
@property (nonatomic, strong) NSDictionary *answerDict;

@end

@implementation MessageViewController

-(instancetype) initWithDict:(NSDictionary *)dict{
    _messageDict = [NSDictionary dictionaryWithDictionary:dict];
    MessageViewController *ret = [super init];
    return ret;
}

-(void)viewDidLoad{
    [self.view addSubview:_messageView];
    
    [self.view setBackgroundColor:[UIColor hx_colorWithHexString:@"E4DCDC"]]; // same color as MessageFeedViewController
    _answerDict = [_messageDict objectForKey:@"answers"];
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:nil];
//    [self.navigationItem setLeftBarButtonItem:backButton];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIView *backButtonView = [[UIView alloc] initWithFrame:backButton.frame];
    backButtonView.bounds = CGRectOffset(backButton.frame, 10, 0);
    [backButtonView addSubview:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];
    
    
    int viewWidth = self.view.frame.size.width;
    int viewHeight = self.view.frame.size.height;
    
    _answerTable = [[UITableView alloc] initWithFrame:CGRectMake(0, viewHeight/2, viewWidth, viewHeight/2)];
    [self.view addSubview:_answerTable];
    _answerTable.delegate = self;
    _answerTable.dataSource = self;
    
    
    [_answerTable registerClass:[AnswerCell class] forCellReuseIdentifier:@"answerCell"];
    
    [_answerTable setSeparatorInset:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    [_answerTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [_answerTable reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ceilf(self.view.frame.size.height/6);
}

- (void)backButtonPressed{
    NSLog(@"Pressed back button");
    [self.navigationController popViewControllerAnimated:NO];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_answerDict count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"answerCell" forIndexPath:indexPath];

    return cell;
}






@end
