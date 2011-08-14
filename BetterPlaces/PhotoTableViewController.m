//
//  PhotoTableViewController.m
//  FlickrPickr
//
//  Created by Chris Moyer on 7/28/11.
//  Copyright 2011 MoeCode. All rights reserved.
//

#import "PhotoTableViewController.h"
#import "PhotoViewController.h"
#import "Photo.h"
#import "FlickrFetcher.h"


@implementation PhotoTableViewController

@synthesize photos, thumbDict;

- (void)dealloc
{
    thumbDict = nil;
    photos = nil;
    [super dealloc];
}

- (void)setup
{
    self.thumbDict = [NSMutableDictionary dictionary];
}

- initInManagedObjectContext:(NSManagedObjectContext *)aContext
{
    if (self = [super initWithStyle:UITableViewStylePlain])	{
        context = aContext;
        [self setup];
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [photos count];
}

- (NSDictionary *)photoForIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *photo = [photos objectAtIndex:indexPath.row];
    return photo;    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Loading cell for indexPath %@", indexPath);
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSDictionary *photo = [self photoForIndexPath:indexPath];
    
    cell.textLabel.text = [Photo titleForFlickrData:photo];
    cell.detailTextLabel.text = [Photo descriptionForFlickrData:photo];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UIImage *thumbImage = [thumbDict objectForKey:[photo objectForKey:@"id"]];
    
    if (thumbImage) {
        cell.imageView.image = thumbImage;        
    } else {
      
        cell.imageView.image = [UIImage imageNamed:@"white_thumb.png"];
        dispatch_queue_t downloadQueue = dispatch_queue_create("Flickr Downloader", NULL);
        dispatch_async(downloadQueue, ^{
            NSData *thumbData = [FlickrFetcher imageDataForPhotoWithFlickrInfo:photo format:FlickrFetcherPhotoFormatSquare];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *thumbImage = [UIImage imageWithData:thumbData];
                NSLog(@"Image Size: %fx%f", thumbImage.size.width, thumbImage.size.height);
                
                [self.thumbDict setObject:thumbImage forKey:[photo objectForKey:@"id"]];
                
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];    
            });
        });
        dispatch_release(downloadQueue);
    }    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate



@end
