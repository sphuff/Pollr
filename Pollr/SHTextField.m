//
//  SHTextField.m
//  Pollr
//
//  Created by Stephen Huffnagle on 4/14/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//

#import "SHTextField.h"

@implementation SHTextField

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 0);
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 0);
}

@end
