//
//  PhotoViewController.h
//  FlickrPickr
//
//  Created by Chris Moyer on 7/25/11.
//  Copyright 2011 MoeCode. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"

@interface PhotoViewController : UIViewController  <UIScrollViewDelegate>
{
    NSData *imageData;
    Photo *photo;
    UIImageView *imageView;
    UIScrollView *scrollView;
    UIActivityIndicatorView *activityView;
    UIImage *image;
    NSManagedObjectContext *context;
}

@property (retain) Photo *photo;
@property (retain) UIImageView *imageView;
@property (retain) UIScrollView *scrollView;
@property (retain) UIActivityIndicatorView *activityView;
@property (retain) UIImage *image;
@property (retain) NSManagedObjectContext *context;
@property (retain) NSData *imageData;

- (id)initInManagedContext:(NSManagedObjectContext *)context;

- (void)doFavoriteButton:(id)thing;
@end
