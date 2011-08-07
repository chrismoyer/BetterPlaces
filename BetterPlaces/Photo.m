//
//  Photo.m
//  BetterPlaces
//
//  Created by Chris Moyer on 8/6/11.
//  Copyright (c) 2011 MoeCode. All rights reserved.
//

#import "Photo.h"
#import "Place.h"
#import "FlickrFetcher.h"


@implementation Photo
@dynamic uniqueId;
@dynamic title;
@dynamic photoDescription;
@dynamic favorite;
@dynamic lastViewed;
@dynamic lastViewedSection;
@dynamic photoURL;
@dynamic takenAt;
@dynamic dateuploadSection;
@dynamic dateupload;


+ (Photo *)photoFromFlickrData:(NSDictionary *)flickrData 
                 inFlickrPlace:(NSDictionary *)flickrPlace 
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"uniqueId = %@", [flickrData objectForKey:@"id"]];
    
    NSError *error = nil;
    photo = [[context executeFetchRequest:request error:&error] lastObject];
    
    if (!error && !photo) {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.uniqueId = [flickrData objectForKey:@"id"];
        photo.title = [Photo titleForFlickrData:flickrData];
        photo.photoDescription = [Photo descriptionForFlickrData:flickrData];
        photo.favorite = [NSNumber numberWithBool:NO];
        photo.lastViewed = [NSDate dateWithTimeIntervalSince1970:0];
        photo.lastViewedSection = @"";
        photo.photoURL = [FlickrFetcher urlStringForPhotoWithFlickrInfo:flickrData format:FlickrFetcherPhotoFormatLarge];
        photo.dateupload = [NSDate dateWithTimeIntervalSince1970: [[flickrData objectForKey:@"dateupload"] doubleValue]];
        photo.dateuploadSection = [Photo ageDescriptionFromDate:photo.dateupload];
        photo.takenAt = [Place placeFromFlickrPlace:flickrPlace inManagedObjectContext:context];   
        
        [context save:nil];
        
        NSLog(@"Taken at: %@", photo.takenAt);
    }
    
    [request release];
    
    return photo;
}

+ (NSString *)ageDescriptionFromDate:(NSDate *)date 
{
    double pictureTime = [date timeIntervalSince1970];
    double now = [[NSDate date] timeIntervalSince1970];
    double age = now - pictureTime;
    
    int ageInHours = floor(age/60/60);
    
    NSString *sectionName;
    
    if (ageInHours == 0) {
        sectionName = @"Now";
    } else {
        sectionName = [NSString stringWithFormat:@"%i hours ago", ageInHours];
    }
    
    return sectionName;    
}

+ (BOOL)stringIsEmpty:(NSString *)s
{
    return s && [[s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""];
}

+ (NSString *)titleForFlickrData:(NSDictionary *)flickrData
{
    NSString *title = [flickrData objectForKey:@"title"];
    
    if ([self stringIsEmpty:title]) {
        NSString *description = [[flickrData objectForKey:@"description"] objectForKey:@"_content"];
        
        if ([self stringIsEmpty:description]) {
            title = @"Unknown";
        } else {
            title = description;
        }        
    }
    
    return title;
}

+ (NSString *)descriptionForFlickrData:(NSDictionary *)flickrData
{
    NSString *description = [[flickrData objectForKey:@"description"] objectForKey:@"_content"];
    
    if ([[Photo titleForFlickrData:flickrData] isEqualToString:description]) {
        description = @"";
    }
    
    return description;    
}

- (void)viewNow;
{
    self.lastViewed = [NSDate date];
}

- (void)cacheData:(NSData *) data
{
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [cacheDir stringByAppendingPathComponent:self.uniqueId]; 
    
    [[NSFileManager defaultManager] createFileAtPath:fileName contents:data attributes:nil];
}

- (NSData *)fetchData
{
    NSData *imageData = nil;
    
    // Check to see if the file is in the cache
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    // Check to see if the cache directory exists
    NSString *fileName = [cacheDir stringByAppendingPathComponent:self.uniqueId];
    
    BOOL cacheFileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileName];
    
    NSLog(@"%@ exists: %@", fileName, [NSNumber numberWithBool:cacheFileExists]);

    if (cacheFileExists) {
        NSLog(@"Loading image data from file: %@", fileName);
        imageData = [[NSFileManager defaultManager] contentsAtPath:fileName];
    } else {
        NSLog(@"Loading image data from flickr: %@", self.photoURL);
        imageData = [FlickrFetcher imageDataForPhotoWithURLString:self.photoURL];
    }
    
    NSLog(@"Photo is favorite: %@", self.favorite);
    
    if ([self.favorite boolValue] && !cacheFileExists) {
        NSLog(@"Writing image data to cache file: %@", fileName);
        [[NSFileManager defaultManager] createFileAtPath:fileName contents:imageData attributes:nil];
    }
    
    return imageData;
}

- (void)makeFavoriteWithImageData:(NSData *)data
{   
    if (![self.favorite boolValue]) {
        self.favorite = [NSNumber numberWithBool:YES];        
        [self cacheData:data];
    } else {
        self.favorite = [NSNumber numberWithBool:YES];
    }
    
    Place *place = self.takenAt;
    place.hasFavorites = [NSNumber numberWithBool:YES];        
    
}

- (void)clearFavorite
{
    self.favorite = [NSNumber numberWithBool:NO];
    
    Place *place = self.takenAt;
    int favCount = 0;
    
    NSNumber *yes = [NSNumber numberWithBool:YES]; 
    
    for (Photo *p in place.photos) {
        if ([p.favorite isEqualToNumber:yes]) {
            favCount++;
        }
    }
    
    if (!favCount) {
        place.hasFavorites = [NSNumber numberWithBool:NO];
    }
    
}
@end
