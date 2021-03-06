//
//  PlacesTableViewController.m
//  FlickrPickr
//
//  Created by Chris Moyer on 7/25/11.
//  Copyright 2011 MoeCode. All rights reserved.
//

#import "PlacesTableViewController.h"
#import "FlickrFetcher.h"
#import "PlacePhotosTableViewController.h"
#import "Place.h"

@implementation PlacesTableViewController


- (NSString *)getSectionForPlace:(NSDictionary *) place
{
    NSString *name = [place objectForKey:@"_content"];
    return [name substringToIndex:1];
}

- (void)loadPlaces:(NSArray *)somePlaces
{
    NSMutableDictionary *placeDict = [[NSMutableDictionary alloc] init];
    NSMutableArray* sectionList = [[NSMutableArray alloc] init];
    
    
    for (NSDictionary *place in somePlaces) {
        NSString *sectionName = [self getSectionForPlace:place];
        
        NSMutableArray *section = [placeDict objectForKey:sectionName];
        
        if (!section) {
            section = [[NSMutableArray alloc] init];
            [placeDict setValue:section forKey:sectionName]; 
            [sectionList addObject:sectionName];
            [section release];
        }
        
        [section addObject:place];        
    }

    [places release];
    [placeSections release];
    
    places = placeDict;
    placeSections = sectionList;    
}

- (void)setup
{
    UITabBarItem *item = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemTopRated tag:0];
    self.tabBarItem = item;
    [item release];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("Flickr Downloader", NULL);
    dispatch_async(downloadQueue, ^{

        NSArray *sortedPlaces = [[FlickrFetcher topPlaces] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"_content" ascending:YES]]];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadPlaces:sortedPlaces];
            [self.tableView reloadData];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    });
    dispatch_release(downloadQueue);
    
    
//    NSArray *sortedPlaces = [[FlickrFetcher topPlaces] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"_content" ascending:YES]]];
    
    //NSLog(@"sorted places received from Flickr: %@", sortedPlaces);
    
    

//    NSLog(@"%@", places);
}

- (void)dealloc
{
    [placeSections release];
    [places release];
    [super dealloc];
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
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return [placeSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSString *sectionName = [placeSections objectAtIndex:section];
    
    return [[places objectForKey:sectionName] count];
}

- (NSDictionary *)placeForIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionName = [placeSections objectAtIndex:indexPath.section];
    NSArray *sectionData = [places objectForKey:sectionName];
    
    return [sectionData objectAtIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlacesTable";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSDictionary *place = [self placeForIndexPath:indexPath];
    NSString *location = [place objectForKey:@"_content"];
    cell.textLabel.text = [Place primaryLocation:location];
    cell.detailTextLabel.text = [Place subLocation:location];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return placeSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [placeSections objectAtIndex:section];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    NSDictionary *place = [self placeForIndexPath:indexPath];

    PlacePhotosTableViewController *pptvc = [[PlacePhotosTableViewController alloc] initInManagedObjectContext:context]; 

    pptvc.place = place;
    pptvc.title = [Place primaryLocation:[place objectForKey:@"_content"]];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    // Look up images from Flickr in background thread
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("Flickr Downloader", NULL);
    dispatch_async(downloadQueue, ^{
        
        // Look up photos from Flickr
        NSArray *photos = [FlickrFetcher photosAtPlace:[place objectForKey:@"place_id"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{

            pptvc.photos = photos;
            [pptvc.tableView reloadData];
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        });
    });
    dispatch_release(downloadQueue);
    
    [self.navigationController pushViewController:pptvc animated:YES];
    [pptvc release];
}

@end
