//
//  Place.h
//  BetterPlaces
//
//  Created by Chris Moyer on 8/6/11.
//  Copyright (c) 2011 MoeCode. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface Place : NSManagedObject {
@private
}

+ (Place *)placeFromFlickrPlace:(NSDictionary *)flickrData inManagedObjectContext:(NSManagedObjectContext *) context;
+ (NSString *)primaryLocation:(NSString *)location;
+ (NSString *)subLocation:(NSString *)location;


@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * hasFavorites;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) NSString * placeId;
@property (nonatomic, retain) NSString * placeDescription;


@end

@interface Place (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(NSManagedObject *)value;
- (void)removePhotosObject:(NSManagedObject *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
