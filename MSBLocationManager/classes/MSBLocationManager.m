//
//  MSBLocationManager.m
//  MSBLocationManager
//
//  Created by misyobun on 2014/05/26.
//  Copyright (c) 2014年 misyobun. All rights reserved.
//

#import "MSBLocationManager.h"
#import "MSBLocateMotion.h"

double const MSB_DEFAULT_DISTANCE = 100.0;
double const MSB_DEFAULT_TIME     = 30.0;
NSString *const MSB_DUMP_ALL_LOCATIONITEMS = @"dumpLocationItems";

@interface MSBLocationManager()
@property (strong,nonatomic)CLLocationManager        *locationManager;
@property (strong,nonatomic)CMMotionActivityManager  *activityManager;
@property (weak,nonatomic)CMMotionActivity		     *motionActivity;
@property (assign,nonatomic)BOOL                     deferredLocationUpdates;

@end


@implementation MSBLocationManager

- (id)init :(CLActivityType)activityType distanceFilter:(CLLocationDistance)distanceFilter desiredAccuracy:(CLLocationAccuracy)desiredAccuracy {
    
    if (![CLLocationManager locationServicesEnabled]) {
        [NSException raise:@"LocationServiceNotEnable" format:@"LocationServiceNotEnable"];
        return nil;
    }

    self = [super init];
    if (self) {
        [self setUp:activityType distanceFilter:distanceFilter desiredAccuracy:desiredAccuracy];
    }
    return self;

}

- (void)setUp:(CLActivityType)activityType distanceFilter:(CLLocationDistance)distanceFilter desiredAccuracy:(CLLocationAccuracy)desiredAccuracy {
    _locationManager                    = [[CLLocationManager alloc] init];
    _locationManager.activityType       = activityType;
    _locationManager.distanceFilter     = distanceFilter;
    _locationManager.desiredAccuracy    = desiredAccuracy;
    _locationManager.delegate           = self;
    _locationItems                      = [NSMutableArray array];
   
}

- (void)startLocateService {
    
    [self registNotification];
    
    if (_locationManager) {
        
        [_locationManager startUpdatingLocation];
        [_locationManager startUpdatingHeading];
        
    }
    
    if([CMMotionActivityManager isActivityAvailable]) {
		
        [self startMotionActivity];
	
    }

}

- (void)endLocateService {
    
    [self removeNotification];
    
    if (_locationManager) {
        
        [_locationManager stopUpdatingLocation];
        [_locationItems removeAllObjects];
        _locationManager = nil;
        _locationItems   = nil;
    }
    
    if (_activityManager) {
        [self stopMotionActivity];
    }
    
}

#pragma mark - notifiaction setting
- (void)registNotification {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(dumpAllItemsIntoBlock) name:MSB_DUMP_ALL_LOCATIONITEMS object:nil];
}

- (void)removeNotification {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
}

- (void)dumpAllItemsIntoBlock {
    if (_DumpAllLocations) {
        _DumpAllLocations(_locationItems);
    }
}


#pragma mark - location Delegate methods

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations{
    
    NSMutableArray *locateMotionImtes = [NSMutableArray array];
    for (CLLocation *location in locations) {
        MSBLocateMotion *locateMotion = [[MSBLocateMotion alloc] initWithLocation:location andActivity:_motionActivity];
        [locateMotionImtes addObject:locateMotion];
        
        if (_locationItems) {
            [_locationItems addObject:locateMotion];
        }
    }
    if([locateMotionImtes count] > 0) {
        if (_UpdateLocations) {
            _UpdateLocations(locateMotionImtes);
        }
    }
    
    if (!_deferredLocationUpdates) {
        
        if (_distance <= 0.0f) {
            _distance = MSB_DEFAULT_DISTANCE;
        }
        if (_time < 0.0f) {
            _time = MSB_DEFAULT_TIME;
        }
        
        [_locationManager allowDeferredLocationUpdatesUntilTraveled:_distance timeout:_time];
        
        _deferredLocationUpdates = YES;
    }
    
    
    
}

-(void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error {
	
	_deferredLocationUpdates = NO;
}

#pragma mark - CoreMotion methods

- (void)startMotionActivity {
    
    void (^motionHandler)(CMMotionActivity *activity) =
    ^void(CMMotionActivity *activity) {
      dispatch_async(dispatch_get_main_queue(), ^{
          _motionActivity = activity;
      });
    };
    
    _activityManager = [[CMMotionActivityManager alloc] init];
    [_activityManager startActivityUpdatesToQueue:[NSOperationQueue mainQueue]
                                      withHandler:motionHandler];
    
    
}

- (void)stopMotionActivity {

    if (_activityManager) {
        [_activityManager stopActivityUpdates];
        _activityManager = nil;
    }

}



@end
