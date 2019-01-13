//
//  TGBGeoPoint.h
//  LeanCloud
//


#import <Foundation/Foundation.h>

@class CLLocation;

NS_ASSUME_NONNULL_BEGIN

/*!
 Object which may be used to embed a latitude / longitude point as the value for a key in a TGBObject.
 TGBObjects with a TGBGeoPoint field may be queried in a geospatial manner using TGBQuery's whereKey:nearGeoPoint:.
 
 This is also used as a point specifier for whereKey:nearGeoPoint: queries.
 
 Currently, object classes may only have one key associated with a GeoPoint type.
 */

@interface TGBGeoPoint : NSObject<NSCopying>

/** @name Creating a TGBGeoPoint */
/*!
 Create a TGBGeoPoint object.  Latitude and longitude are set to 0.0.
 @return a new TGBGeoPoint.
 */
+ (instancetype)geoPoint;

/*!
 Creates a new TGBGeoPoint object for the given CLLocation, set to the location's
 coordinates.
 @param location CLLocation object, with set latitude and longitude.
 @return a new TGBGeoPoint at specified location.
 */
+ (instancetype)geoPointWithLocation:(CLLocation *)location;

/*!
 Creates a new TGBGeoPoint object with the specified latitude and longitude.
 @param latitude Latitude of point in degrees.
 @param longitude Longitude of point in degrees.
 @return New point object with specified latitude and longitude.
 */
+ (instancetype)geoPointWithLatitude:(double)latitude longitude:(double)longitude;

/*!
 Fetches the user's current location and returns a new TGBGeoPoint object via the
 provided block.
 @param geoPointHandler A block which takes the newly created TGBGeoPoint as an
 argument.
 */
+ (void)geoPointForCurrentLocationInBackground:(void(^)(TGBGeoPoint * _Nullable geoPoint, NSError * _Nullable error))geoPointHandler;

/** @name Controlling Position */

/// Latitude of point in degrees.  Valid range (-90.0, 90.0).
@property (nonatomic) double latitude;
/// Longitude of point in degrees.  Valid range (-180.0, 180.0).
@property (nonatomic) double longitude;

/** @name Calculating Distance */

/*!
 Get distance in radians from this point to specified point.
 @param point TGBGeoPoint location of other point.
 @return distance in radians
 */
- (double)distanceInRadiansTo:(TGBGeoPoint*)point;

/*!
 Get distance in miles from this point to specified point.
 @param point TGBGeoPoint location of other point.
 @return distance in miles
 */
- (double)distanceInMilesTo:(TGBGeoPoint*)point;

/*!
 Get distance in kilometers from this point to specified point.
 @param point TGBGeoPoint location of other point.
 @return distance in kilometers
 */
- (double)distanceInKilometersTo:(TGBGeoPoint*)point;


@end

NS_ASSUME_NONNULL_END
