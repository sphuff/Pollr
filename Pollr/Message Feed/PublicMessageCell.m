//
//  MessageCell.m
//  Pollr
//
//  Created by Stephen Huffnagle on 2/10/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//

#import "PublicMessageCell.h"
#import "Chameleon.h"

@interface PublicMessageCell()


@end

@implementation PublicMessageCell

-(instancetype) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[UIColor randomFlatColor]];
        while([self.backgroundColor isEqual:[UIColor flatWhiteColor]] || [self.backgroundColor isEqual:[UIColor flatWhiteColorDark]]){
            [self setBackgroundColor:[UIColor randomFlatColor]];
        }
        self.layer.cornerRadius = 5.0;
        
        self.titleLabel = [[UILabel alloc] initWithFrame:(CGRectMake((int) 10,(int) 10,(int) self.frame.size.width - 20,(int) 50))];
        self.titleLabel.frame = CGRectIntegral(self.titleLabel.frame);
        [self addSubview:self.titleLabel];
        
        self.titleLabel.numberOfLines = 0; // needed for multiple lines
    }
   
    return self;
}

- (void)setMessage:(NSDictionary *)message{
    NSString *titleString = [message objectForKey:@"text"];
    NSAttributedString *titleLabelAtt = [[NSAttributedString alloc] initWithString:titleString
                                                                        attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:17.0],
                                                                                     NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [self.titleLabel setAttributedText:titleLabelAtt];
    [self.titleLabel sizeToFit]; // fits label to constraints
    [self.titleLabel setFrame:CGRectMake(self.titleLabel.frame.origin.x, self.titleLabel.frame.origin.y, self.frame.size.width - 20, self.titleLabel.frame.size.height)];
    
    self.userImageString = [NSString stringWithFormat:@"user%d", 1 + arc4random() % 21];
    self.userImage = [UIImage imageNamed:self.userImageString];
    
    NSMutableArray *colorArray = [[NSMutableArray alloc] initWithArray:[NSArray arrayOfColorsWithColorScheme:ColorSchemeTriadic usingColor:self.backgroundColor withFlatScheme:YES]];
    _userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height +10, 29, 31)];
    [_userImageView setImage:self.userImage];
    [_userImageView setBackgroundColor:[UIColor whiteColor]];
    _userImageView.bounds = CGRectMake(_userImageView.frame.origin.x, _userImageView.frame.origin.y, _userImageView.frame.size.width + 10, _userImageView.frame.size.height + 10);
    _userImageView.contentMode = UIViewContentModeCenter;
    _userImageView.layer.cornerRadius = _userImageView.frame.size.width/2.0f;
    _userImageView.layer.borderWidth = 2.0;
    _userImageView.clipsToBounds = YES;
    UIColor *borderColor = [colorArray objectAtIndex:arc4random_uniform(5)];

    _userImageView.layer.borderColor = borderColor.CGColor;
    
    int xCoord = self.userImageView.frame.origin.x + self.userImageView.frame.size.width + 10;
    int yCoord = self.userImageView.frame.origin.y;
    self.userLabel = [[UILabel alloc] initWithFrame:(CGRectMake((int) xCoord,(int) yCoord,(int) 40,(int) 40))];
    NSString *userString = [message objectForKey:@"createdBy"];
    NSAttributedString *userLabelAtt = [[NSAttributedString alloc] initWithString:userString
                                                                        attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:10.0],
                                                                                     NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [self.userLabel setAttributedText:userLabelAtt];
    [self addSubview:_userLabel];
    
    xCoord = self.frame.size.width - 30;
    yCoord = self.frame.size.height - 32;
    
    UIImageView *commentImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"commentBubble"]];
    [commentImageView setFrame:CGRectMake(xCoord, yCoord, 24, 31)];
    
    NSString *commentNumString = [message objectForKey:@"commentNum"];
    if(!commentNumString){
        commentNumString = @"0";
    }
    UILabel *commentNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 4, 16, 16)];
    NSAttributedString *commentNumLabelAtt = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", commentNumString]
                                                                             attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:15.0],
                                                                                          NSForegroundColorAttributeName: //[UIColor colorWithComplementaryFlatColorOf:self.backgroundColor]}];
                                                                                          self.backgroundColor}];
    [commentNumLabel setAttributedText:commentNumLabelAtt];
    [commentImageView addSubview:commentNumLabel];
    [commentImageView bringSubviewToFront:commentNumLabel];
    
    [self addSubview:commentImageView];
    [self addSubview:_userImageView];
}

-(void)prepareForReuse{
    _userImageView = nil;
}
@end
