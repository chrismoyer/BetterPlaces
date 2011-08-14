//
//  Photo.h
//  BetterPlaces
//
//  Created by Chris Moyer on 8/6/11.
//  Copyright (c) 2011 MoeCode. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class Place;

@interface Photo : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * uniqueId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * photoDescription;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSDate * lastViewed;
@property (nonatomic, retain) NSString * lastViewedSection;
@property (nonatomic, retain) NSString * photoURL;
@property (nonatomic, retain) Place *takenAt;
@property (nonatomic, retain) NSString * dateuploadSection;
@property (nonatomic, retain) NSDate * dateupload;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) NSData * thumbnailData;



+ (Photo *)photoFromFlickrData:(NSDictionary *)flickrData 
                 inFlickrPlace:(NSDictionary *)flickrPlace 
        inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSString *)ageDescriptionFromDate:(NSDate *)date;
+ (NSString *)titleForFlickrData:(NSDictionary *)flickrData;
+ (NSString *)descriptionForFlickrData:(NSDictionary *)flickrData;

- (void)viewNow;
- (NSData *)imageData;
- (NSData *)thumbData;

- (void)processImageDataWithBlock:(void (^)(NSData *imageData))processImage;
- (void)makeFavoriteWithImageData:(NSData *)data;
- (void)clearFavorite;

@end
 