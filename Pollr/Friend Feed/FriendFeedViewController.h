//
//  FriendFeedControllerViewController.h
//  Pollr
//
//  Created by Stephen Huffnagle on 4/6/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendFeedViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSManagedObjectContext *context;

@end
