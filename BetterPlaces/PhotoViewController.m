//
//  PhotoViewController.m
//  FlickrPickr
//
//  Created by Chris Moyer on 7/25/11.
//  Copyright 2011 MoeCode. All rights reserved.
//

#import "PhotoViewController.h"
#import "FlickrFetcher.h"

@implementation PhotoViewController

@synthesize photo, imageView, image, scrollView, context, imageData;

- (void)dealloc
{
    [imageData release];
    [context release];
    [photo release];
    [imageView release];
    [super dealloc];
}

- (id)initInManagedContext:(NSManagedObjectContext *)aContext
{
    self = [super init];
    if (self) {
        self.context = aContext;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    // Get the image
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSLog(@"Photo is favorite: %i", [photo.favorite boolValue]);
    
    self.imageData = [photo fetchData];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSLog(@"Loaded data with size: %i", [self.imageData length]);
    self.image = [UIImage imageWithData:self.imageData];
    
    UIImageView *iv = [[UIImageView alloc] initWithImage:self.image];
    self.imageView = iv;
    [iv release];
    
    UIScrollView *sv = [[UIScrollView alloc] init];
    //scrollView.contentMode = UIViewContentModeScaleToFill;
	sv.contentSize = self.image.size;
	[sv addSubview:self.imageView];
    
    
	sv.bounces = NO;
	sv.minimumZoomScale = 0.1;
	sv.maximumZoomScale = 6.0;
	sv.delegate = self; 

    self.scrollView = sv;
    
    self.view = sv;
    [sv release];
    
  
}

- (void)viewWillAppear:(BOOL)animated
{
    // Set up the default zoom and origin
    
    CGRect viewRect = scrollView.bounds;
    
    float screenAspect = viewRect.size.width / viewRect.size.height;
    float imageAspect = image.size.width/image.size.height;
    
//    NSLog(@"Image Size %fx%f with ar %f", image.size.width, image.size.height, imageAspect);
//    NSLog(@"Frame Size %fx%f with ar %f", viewRect.size.width, viewRect.size.height, screenAspect);
    
    CGRect zoomRect;
    
    if (imageAspect > screenAspect) {
        zoomRect = CGRectMake(0, 0, image.size.height * screenAspect, image.size.height);
    } else {
        zoomRect = CGRectMake(0, 0, image.size.width, image.size.width / screenAspect);
    }
    
    zoomRect.origin.x = (image.size.width - zoomRect.size.width) / 2;
    zoomRect.origin.y = (image.size.height - zoomRect.size.height) / 2;
    
//    NSLog(@"Zoomrect %f,%f - %fx%f with ar %f", zoomRect.origin.x, zoomRect.origin.y, 
//          zoomRect.size.width, zoomRect.size.height, zoomRect.size.width / zoomRect.size.height);

    [scrollView zoomToRect:zoomRect animated:NO];
    
    // Set the minimum zoom
    
    float xscale = viewRect.size.width / image.size.width;
    float yscale = viewRect.size.height / image.size.height;
    
    float minscale = (xscale < yscale ? xscale : yscale);
    self.scrollView.minimumZoomScale = minscale;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)sender
{
    return self.imageView;
}

- (void)setUpFavoriteButton
{
    NSString *text;
    
    NSLog(@"Photo is favorite: %i", [photo.favorite boolValue]);
    
    if ([photo.favorite boolValue]) {
        text = @"ON";
    } else {
        text = @"OFF";
    }
    
    UIBarButtonItem *barbutton = [[UIBarButtonItem alloc] initWithTitle:text style:UIBarButtonItemStylePlain target:self action:@selector(doFavoriteButton:)];
    
    self.navigationItem.rightBarButtonItem = barbutton;
    [barbutton release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"Creating a button");
    [self setUpFavoriteButton];

}

- (void)doFavoriteButton:(id) thing
{
    NSLog(@"Doing stuff");
    
    if ([photo.favorite boolValue]) {
        [photo clearFavorite];
    } else {
        [photo makeFavoriteWithImageData:self.imageData];
    }
    
    [self.context save:nil];
    
    [self setUpFavoriteButton];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
