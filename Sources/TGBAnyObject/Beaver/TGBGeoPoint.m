//
//  TGBGeoPoint.h
//  LeanCloud
//


#import "TGBGeoPoint.h"
#import "TGBLocationManager.h"
#import <CoreLocation/CoreLocation.h>

@implementation  TGBGeoPoint

@synthesize latitude = _latitude;
@synthesize longitude = _longitude;

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];

    if (self) {
        _latitude = [aDecoder decodeDoubleForKey:@"latitude"];
        _longitude = [aDecoder decodeDoubleForKey:@"longitude"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeDouble:_latitude forKey:@"latitude"];
    [aCoder encodeDouble:_longitude forKey:@"longitude"];
}

- (id)copyWithZone:(NSZone *)zone
{
    TGBGeoPoint *point = [[[self class] allocWithZone:zone] init];
    point.longitude = self.longitude;
    point.latitude = self.latitude;
    return point;
}

+ (TGBGeoPoint *)geoPoint
{
    TGBGeoPoint * result = [[TGBGeoPoint alloc] init];
    return result;
}

+ (TGBGeoPoint *)geoPointWithLocation:(CLLocation *)location
{
    TGBGeoPoint * point = [TGBGeoPoint geoPoint];
    point.latitude = location.coordinate.latitude;
    point.longitude = location.coordinate.longitude;
    return point;
}

+ (TGBGeoPoint *)geoPointWithLatitude:(double)latitude longitude:(double)longitude
{
    TGBGeoPoint * point = [TGBGeoPoint geoPoint];
    point.latitude = latitude;
    point.longitude = longitude;
    return point;
}

- (CLLocation *)location {
    return [[CLLocation alloc] initWithLatitude:self.latitude longitude:self.longitude];
}

+ (void)geoPointForCurrentLocationInBackground:(void(^)(TGBGeoPoint *geoPoint, NSError *error))geoPointHandler
{
    [[TGBLocationManager sharedInstance] updateWithBlock:geoPointHandler];
}

- (double)distanceInRadiansTo:(TGBGeoPoint*)point
{
    // 6378.140 is the Radius of the earth 
    return ([self distanceInKilometersTo:point] / 6378.140);
}

- (double)distanceInMilesTo:(TGBGeoPoint*)point
{
    return [self distanceInKilometersTo:point] / 1.609344;
}

- (double)distanceInKilometersTo:(TGBGeoPoint*)point
{
    return [[self location] distanceFromLocation:[point location]] / 1000.0;
}

+(NSDictionary *)dictionaryFromGeoPoint:(TGBGeoPoint *)point
{
    return @{ @"__type": @"GeoPoint", @"latitude": @(point.latitude), @"longitude": @(point.longitude) };
}

+(TGBGeoPoint *)geoPointFromDictionary:(NSDictionary *)dict
{
    TGBGeoPoint * point = [[TGBGeoPoint alloc]init];
    point.latitude = [[dict objectForKey:@"latitude"] doubleValue];
    point.longitude = [[dict objectForKey:@"longitude"] doubleValue];
    return point;
}

@end
