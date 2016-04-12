//
//  FriendMessageCell.m
//  Pollr
//
//  Created by Stephen Huffnagle on 4/7/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//

#import "FriendMessageCell.h"
#import "Chameleon.h"

@implementation FriendMessageCell

-(instancetype)initWithFrame:(CGRect)frame{
    FriendMessageCell *cell = [super initWithFrame:frame];
    [cell setBackgroundColor:[UIColor randomFlatColor]];
    cell.layer.cornerRadius = 5.0;
    
    
    
    return cell;
}

@end
