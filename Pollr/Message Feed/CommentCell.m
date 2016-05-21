//
//  CommentCell.m
//  Pollr
//
//  Created by Stephen Huffnagle on 5/20/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//

#import "CommentCell.h"

@implementation CommentCell

-(instancetype) initWithFrame:(CGRect)frame{
    CommentCell *cell = [super initWithFrame:frame];
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
