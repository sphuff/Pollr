//
//  AnswerCell.m
//  Pollr
//
//  Created by Stephen Huffnagle on 2/14/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//

#import "AnswerCell.h"

@implementation AnswerCell

-(instancetype) initWithFrame:(CGRect)frame{
    AnswerCell *cell = [super initWithFrame:frame];
    cell.layer.cornerRadius = 5.0;
    [cell setBackgroundColor:[UIColor whiteColor]];
    return cell;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    for (UIView *subview in self.contentView.superview.subviews) {
        if ([NSStringFromClass(subview.class) hasSuffix:@"SeparatorView"]) {
            subview.hidden = NO;
        }
    }
}

@end
