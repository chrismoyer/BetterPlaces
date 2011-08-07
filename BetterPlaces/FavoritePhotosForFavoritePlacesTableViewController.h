//
//  FavoritePhotosForFavoritePlacesTableViewController.h
//  BetterPlaces
//
//  Created by Chris Moyer on 8/6/11.
//  Copyright 2011 MoeCode. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "PLace.h"

@interface FavoritePhotosForFavoritePlacesTableViewController : CoreDataTableViewController
{
    NSManagedObjectContext *context;
}

@property (retain) NSManagedObjectContext *context;

- initForPlace:(Place *)place InManagedObjectContext:(NSManagedObjectContext *)context;

@end
