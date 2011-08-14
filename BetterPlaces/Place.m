//
//  Place.m
//  BetterPlaces
//
//  Created by Chris Moyer on 8/6/11.
//  Copyright (c) 2011 MoeCode. All rights reserved.
//

#import "Place.h"


@implementation Place
@dynamic name;
@dynamic placeDescription;
@dynamic hasFavorites;
@dynamic photos;
@dynamic placeId;
@dynamic sectionName;


+ (Place *)placeFromFlickrPlace:(NSDictionary *)flickrData inManagedObjectContext:(NSManagedObjectContext *) context
{
    Place *place = nil;

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"placeId = %@", [flickrData objectForKey:@"place_id"]];
    
    NSError *error = nil;
    place = [[context executeFetchRequest:request error:&error] lastObject];
    
    if (!error && !place) {
        place = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:context];
        place.placeId = [flickrData objectForKey:@"place_id"];
        place.name = [Place primaryLocation:[flickrData objectForKey:@"_content"]];
        place.placeDescription = [Place subLocation:[flickrData objectForKey:@"_content"]];
        place.hasFavorites = [NSNumber numberWithBool:NO];   
        place.sectionName = [place.name substringToIndex:1];
    }
    
    [request release];
    
    return place;
}

+ (NSString *)primaryLocation:(NSString *)location
{
    NSArray *locationParts = [location componentsSeparatedByString:@", "];
    NSMutableArray *subLocationParts = [NSMutableArray arrayWithArray:locationParts];
    return [subLocationParts objectAtIndex:0];
}

+ (NSString *)subLocation:(NSString *)location
{
    NSArray *locationParts = [location componentsSeparatedByString:@", "];
    NSMutableArray *subLocationParts = [NSMutableArray arrayWithArray:locationParts];
    [subLocationParts removeObjectAtIndex:0];
    
    NSString *subLocation = [subLocationParts componentsJoinedByString:@", "];
    return subLocation;
}


@end
