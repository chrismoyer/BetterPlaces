//
//  PlacePhotosTableViewController.m
//  FlickrPickr
//
//  Created by Chris Moyer on 7/25/11.
//  Copyright 2011 MoeCode. All rights reserved.
//

#import "PlacePhotosTableViewController.h"
#import "FlickrFetcher.h"
#import "PhotoViewController.h"

@implementation PlacePhotosTableViewController

@synthesize place;

- (void)dealloc
{
    [place release];
    [photoSections release];
    [photosBySection release];
    [super dealloc];    
}

- (void)setPhotos:(NSArray *)newPhotos
{
//    NSLog(@"%@", newPhotos);
    
    [photosBySection release];
    [photoSections release];
    
    photosBySection = [[NSMutableDictionary alloc] init];
    photoSections = [[NSMutableArray alloc] init];
    
    for (NSDictionary *photo in newPhotos) {
        
        NSString *sectionName = [Photo ageDescriptionFromDate:[NSDate dateWithTimeIntervalSince1970:[[photo objectForKey:@"dateupload"] doubleValue]]];
        
        NSMutableArray *section = [photosBySection objectForKey:sectionName];
        if (!section) {
            section = [[NSMutableArray alloc] init];
            [section addObject:photo];            
            [photoSections addObject:sectionName]; 
            [photosBySection setObject:section forKey:sectionName];
            [section release];
        } else {
            [section addObject:photo];
        }        
    }
    
//    NSLog(@"Sections: %@", photoSections);
//    NSLog(@"Photos By Section: %@", photosBySection);
    
    [super setPhotos:newPhotos];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [photoSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *s = [photosBySection objectForKey:[photoSections objectAtIndex:section]];
    return [s count];
}

- (NSDictionary *)photoForIndexPath:(NSIndexPath *)indexPath
{
    NSArray *s = [photosBySection objectForKey:[photoSections objectAtIndex:indexPath.section]];
    NSDictionary *p = [s objectAtIndex:indexPath.row];
    return p;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [photoSections objectAtIndex:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *flickrPhoto = [self photoForIndexPath:indexPath];
    
    Photo *photo = [Photo photoFromFlickrData:flickrPhoto inFlickrPlace:self.place inManagedObjectContext:context];
    [photo viewNow];
    
    PhotoViewController *pview = [[PhotoViewController alloc] init];
    pview.title = photo.title;
    pview.photo = photo;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [self.navigationController pushViewController:pview animated:YES];
    [pview release];
}

@end
