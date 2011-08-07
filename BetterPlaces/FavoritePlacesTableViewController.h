//
//  FavoritePlacesTableViewController.h
//  BetterPlaces
//
//  Created by Chris Moyer on 8/6/11.
//  Copyright 2011 MoeCode. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface FavoritePlacesTableViewController : CoreDataTableViewController
{
    NSManagedObjectContext *context;
    BOOL favoriteOnly;
}

@property (retain) NSManagedObjectContext *context;

- initInManagedObjectContext:(NSManagedObjectContext *)context;

@end
