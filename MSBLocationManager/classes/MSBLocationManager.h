//
//  MSBLocationManager.h
//  MSBLocationManager
//
//  Created by misyobun on 2014/05/26.
//  Copyright (c) 2014年 misyobun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface MSBLocationManager : NSObject<CLLocationManagerDelegate>
@property(nonatomic,strong) MKMapView *mMkMapView;
@property(nonatomic,strong) NSMutableArray    *locationItems;
@property(nonatomic,assign) CLLocationDistance distance;
@property(nonatomic,assign) NSTimeInterval     time;
@property(nonatomic,copy) void (^UpdateLocations)(NSArray *locations);
@property(nonatomic,copy) void (^DumpAllLocations)(NSArray *locations);

- (id)init :(CLActivityType)activityType distanceFilter:(CLLocationDistance)distanceFilter desiredAccuracy:(CLLocationAccuracy)desiredAccuracy;
- (void)startLocateService;
- (void)endLocateService;
@end
