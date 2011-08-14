//
//  FavoritePhotosForFavoritePlacesTableViewController.m
//  BetterPlaces
//
//  Created by Chris Moyer on 8/6/11.
//  Copyright 2011 MoeCode. All rights reserved.
//

#import "FavoritePhotosForFavoritePlacesTableViewController.h"
#import "PhotoViewController.h"

@implementation FavoritePhotosForFavoritePlacesTableViewController

@synthesize context;

- (void)dealloc
{
    [context release];
    [super dealloc];
}

- initForPlace:(Place *)place InManagedObjectContext:(NSManagedObjectContext *)aContext
{
    self.context = aContext;
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (self = [super initWithStyle:UITableViewStylePlain])
    {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:aContext];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:NO]];
        request.predicate = [NSPredicate predicateWithFormat:@"takenAt = %@ AND favorite = %@", place, [NSNumber numberWithBool:YES]];
        
        request.fetchBatchSize = 20;
        
        NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]
                                           initWithFetchRequest:request managedObjectContext:aContext sectionNameKeyPath:nil cacheName:nil];
        [request release];
        self.fetchedResultsController = frc;
        [frc release];
        
        self.titleKey = @"title";
        self.subtitleKey = @"photoDescription";
    }
    
    self.title = place.name;
    
    return self;
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject
{
    Photo *photo = (Photo *)managedObject;
    [photo viewNow];
    [context save:nil];
    
    PhotoViewController *pview = [[PhotoViewController alloc] initInManagedContext:context];
    pview.title = photo.title;
    pview.photo = photo;
    
    [self.navigationController pushViewController:pview animated:YES];
    [pview release];
}

- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject
{
    return YES;
}

- (void)deleteManagedObject:(NSManagedObject *)managedObject
{
    Photo *photo = (Photo *)managedObject;
    
    [photo clearFavorite];
    [context save:nil];
    
}

- (UIImage *)thumbnailImageForManagedObject:(NSManagedObject *)managedObject
{
    Photo *photo = (Photo *)managedObject;
    
    NSData *data = photo.thumbData;
    UIImage *image = nil;
    
    
	if (data) {
        image = [[[UIImage alloc] initWithData:data] autorelease];
    } else {
        image = [UIImage imageNamed:@"white_thumb.png"];
    }
    
    return image;
}
@end
