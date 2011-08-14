//
//  PhotoTableViewController.h
//  FlickrPickr
//
//  Created by Chris Moyer on 7/28/11.
//  Copyright 2011 MoeCode. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoTableViewController : UITableViewController
{
    NSArray *photos;
    NSManagedObjectContext *context;
    NSMutableDictionary *thumbDict;
}

@property (retain) NSArray *photos;
@property (retain) NSMutableDictionary *thumbDict;

- (NSDictionary *)photoForIndexPath:(NSIndexPath *)indexPath;
- initInManagedObjectContext:(NSManagedObjectContext *)context;

@end
