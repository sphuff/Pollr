//
//  MessageFeedViewController.h
//  Pollr
//
//  Created by Stephen Huffnagle on 2/8/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTCollectionViewWaterfallLayout.h"

@interface MessageFeedViewController : UIViewController < UICollectionViewDataSource, UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout>

@property (nonatomic, strong) NSManagedObjectContext *context;

@end
