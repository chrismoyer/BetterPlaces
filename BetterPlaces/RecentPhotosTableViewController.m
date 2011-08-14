//
//  RecentPhotosTableViewController.m
//  BetterPlaces
//
//  Created by Chris Moyer on 8/6/11.
//  Copyright 2011 MoeCode. All rights reserved.
//

#import "RecentPhotosTableViewController.h"
#import "PhotoViewController.h"
#import "Photo.h"

@implementation RecentPhotosTableViewController

@synthesize context;

- (void)dealloc
{
    [context release];
    [super dealloc];
}
    
- initInManagedObjectContext:(NSManagedObjectContext *)aContext
{
    UITabBarItem *item = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMostRecent tag:0];
    self.tabBarItem = item;
    [item release];

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.context = context;
    
	if (self = [super initWithStyle:UITableViewStylePlain])
	{
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		request.entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:aContext];
		request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"lastViewed" ascending:NO]];
        
        NSDate *recentLimit = [NSDate dateWithTimeIntervalSinceNow:(-48 * 60 * 60)];
        NSLog(@"Date: %@", recentLimit);
        
		request.predicate = [NSPredicate predicateWithFormat:@"lastViewed > %@", recentLimit];
		//request.predicate = nil;

		request.fetchBatchSize = 20;
		
		NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]
										   initWithFetchRequest:request managedObjectContext:aContext sectionNameKeyPath:nil cacheName:nil];
		[request release];
		
		self.fetchedResultsController = frc;
		[frc release];
		
		self.titleKey = @"title";
        self.searchKey = @"title";
        self.subtitleKey = @"photoDescription";
	}
	return self;
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject
{
    Photo *photo = (Photo *)managedObject;
    [photo viewNow];
    [context save:nil];
    
    PhotoViewController *pview = [[PhotoViewController alloc] init];
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
    
    photo.lastViewed = [NSDate dateWithTimeIntervalSince1970:0];
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
