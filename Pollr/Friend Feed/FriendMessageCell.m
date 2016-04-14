//
//  FriendMessageCell.m
//  Pollr
//
//  Created by Stephen Huffnagle on 4/7/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//

#import "FriendMessageCell.h"
#import "Chameleon.h"

@interface FriendMessageCell()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *authorLabel;

@end


@implementation FriendMessageCell

-(instancetype)initWithFrame:(CGRect)frame{
    FriendMessageCell *cell = [super initWithFrame:frame];
    
    cell.layer.cornerRadius = 5.0;
    
    cell.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, (int)cell.frame.size.width/2, cell.frame.size.height)];
    [cell addSubview:cell.titleLabel];
    
    cell.authorLabel = [[UILabel alloc] initWithFrame:CGRectMake((int)(cell.frame.size.width * (3.0f/4.0f)), 10, (int)cell.frame.size.width/4, cell.frame.size.height)];
    [cell addSubview:cell.authorLabel];
    
    
    return cell;
}

- (void)setMessage:(NSDictionary *)message{
    NSString *titleString = [message objectForKey:@"title"];
    NSAttributedString *titleLabelAtt = [[NSAttributedString alloc] initWithString:titleString
                                                                        attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:17.0],
                                                                                     NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [self.titleLabel setAttributedText:titleLabelAtt];
    
    NSString *authorString = [message objectForKey:@"createdBy"];
    NSAttributedString *authorLabelAtt = [[NSAttributedString alloc] initWithString:authorString
                                                                        attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:17.0],
                                                                                     NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [self.authorLabel setAttributedText:authorLabelAtt];
    
}

@end
