//
//  FavoritePlacesTableViewController.m
//  BetterPlaces
//
//  Created by Chris Moyer on 8/6/11.
//  Copyright 2011 MoeCode. All rights reserved.
//

#import "FavoritePlacesTableViewController.h"
#import "FavoritePhotosForFavoritePlacesTableViewController.h"
#import "Place.h"

@implementation FavoritePlacesTableViewController

@synthesize context;

- (void)dealloc
{
    self.context = nil;
    [super dealloc];    
}

- (NSFetchedResultsController *)createFetchedResultsControllerInManagedObjectContext:(NSManagedObjectContext *)aContext
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:aContext];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    if (favoriteOnly) {
        request.predicate = [NSPredicate predicateWithFormat:@"hasFavorites = %@", [NSNumber numberWithBool:YES]];
    } else {
        request.predicate = nil;
    }
    
    request.fetchBatchSize = 20;
    
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]
                                       initWithFetchRequest:request managedObjectContext:aContext sectionNameKeyPath:@"sectionName" cacheName:nil];
    
    [request release];
    
    self.fetchedResultsController = frc;
    [frc release];
    
    return self.fetchedResultsController;
}

- initInManagedObjectContext:(NSManagedObjectContext *)aContext
{
    favoriteOnly = YES;
    
    self.context = aContext;
    
    UITabBarItem *item = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:0];
    self.tabBarItem = item;
    [item release];
    
    
	if (self = [super initWithStyle:UITableViewStylePlain])
	{
        [self createFetchedResultsControllerInManagedObjectContext:aContext];
		
		self.titleKey = @"name";
        self.subtitleKey = @"placeDescription";
	}
	return self;
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject
{
    NSLog(@"Selecting favorite place");
    
    Place *place = (Place *)managedObject;
    
    FavoritePhotosForFavoritePlacesTableViewController *pview = [[FavoritePhotosForFavoritePlacesTableViewController alloc] initForPlace:place InManagedObjectContext:self.context];
    
    [self.navigationController pushViewController:pview animated:YES];
    [pview release];
}

- (void)setUpFavoriteButton
{
    NSString *text;
    
    if (favoriteOnly) {
        text = @"Only Favorites";
    } else {
        text = @"All Places";
    }
    
    UIBarButtonItem *barbutton = [[UIBarButtonItem alloc] initWithTitle:text style:UIBarButtonItemStylePlain target:self action:@selector(doFavoriteButton:)];
    
    self.navigationItem.rightBarButtonItem = barbutton;
    [barbutton release];
}

- (void)doFavoriteButton:(id)something
{
    favoriteOnly = !favoriteOnly;
    [self setUpFavoriteButton];
    
    if (favoriteOnly) {
        [fetchedResultsController.fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"hasFavorites = %@", [NSNumber numberWithBool:YES]]];
    } else {
        [fetchedResultsController.fetchRequest setPredicate:nil];
    }
    
    NSLog(@"Predicate: %@", fetchedResultsController.fetchRequest.predicate);
    
    NSError *error = nil;
    
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"failure performing fetch: %@", [error localizedDescription]);
    }
    
    [self createFetchedResultsControllerInManagedObjectContext:self.context];
    
    [self.tableView reloadData];

}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    //[super viewDidLoad];
    
    NSLog(@"Creating a button");
    [self setUpFavoriteButton];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
