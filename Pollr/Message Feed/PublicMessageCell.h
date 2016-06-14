//
//  MessageCell.h
//  Pollr
//
//  Created by Stephen Huffnagle on 2/10/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PublicMessageCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *userLabel;
@property (nonatomic, strong) UIImage *userImage;
@property (nonatomic, strong) UIImageView *userImageView;

- (void)setMessage:(NSDictionary *)message;

@end
