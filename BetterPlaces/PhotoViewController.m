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

@synthesize photo, imageView, image, scrollView, activityView, context, imageData;

- (void)dealloc
{
    [activityView release];
    [scrollView release];
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
//    UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
//    self.view = contentView;
    
    UIImageView *iv = [[UIImageView alloc] init];
    self.imageView = iv;
    [iv release];
    
    UIScrollView *sv = [[UIScrollView alloc] init];
    //scrollView.contentMode = UIViewContentModeScaleToFill;
	[sv addSubview:self.imageView];
    
	sv.delegate = self; 
    
    self.scrollView = sv;    
    self.view = self.scrollView;
    [sv release];
    
    
    UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  	ai.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    self.activityView = ai;
    [self.view addSubview:self.activityView];
    [ai release];
    
    

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

- (void)viewWillAppear:(BOOL)animated
{
    self.activityView.center = self.view.center;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    if (!self.imageData) {
        [activityView startAnimating];
        
        [self.photo processImageDataWithBlock:^(NSData *data) {
            
            if (self.view.window) {
                self.imageData = data;
                self.image = [UIImage imageWithData:self.imageData];
                self.imageView.image = self.image;
                self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                
                CGRect viewRect = scrollView.bounds;
                
                self.scrollView.contentSize = self.image.size;
                self.scrollView.bounces = NO;
                self.scrollView.maximumZoomScale = 6.0;
                
                float xscale = viewRect.size.width / image.size.width;
                float yscale = viewRect.size.height / image.size.height;
                float minscale = (xscale < yscale ? xscale : yscale);
                self.scrollView.minimumZoomScale = minscale;        
                
                // Set up the default zoom and origin
                
                
                float screenAspect = viewRect.size.width / viewRect.size.height;
                float imageAspect = image.size.width/image.size.height;
                
                NSLog(@"Image Size %fx%f with ar %f", image.size.width, image.size.height, imageAspect);
                NSLog(@"Frame Size %fx%f with ar %f", viewRect.size.width, viewRect.size.height, screenAspect);
                
                CGRect zoomRect;
                
                if (imageAspect > screenAspect) {
                    zoomRect = CGRectMake(0, 0, image.size.height * screenAspect, image.size.height);
                } else {
                    zoomRect = CGRectMake(0, 0, image.size.width, image.size.width / screenAspect);
                }
                
                zoomRect.origin.x = (image.size.width - zoomRect.size.width) / 2;
                zoomRect.origin.y = (image.size.height - zoomRect.size.height) / 2;
                
                NSLog(@"Zoomrect %f,%f - %fx%f with ar %f", zoomRect.origin.x, zoomRect.origin.y, 
                      zoomRect.size.width, zoomRect.size.height, zoomRect.size.width / zoomRect.size.height);
                
                [scrollView zoomToRect:zoomRect animated:NO];
                
                // Set the minimum zoom
                
                
                [activityView stopAnimating];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                NSLog(@"Creating a button");
                [self setUpFavoriteButton];
            }
        }];
    }
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)sender
{
    return self.imageView;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    


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
