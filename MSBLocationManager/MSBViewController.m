//
//  MSBViewController.m
//  MSBLocationManager
//
//  Created by misyobun on 2014/05/26.
//  Copyright (c) 2014年 misyobun. All rights reserved.
//

#import "MSBViewController.h"
#import "MSBLocationManager.h"
#import "MSBLocateMotion.h"
#import <MapKit/MapKit.h>

@interface MSBViewController ()
@property(weak, nonatomic) IBOutlet MKMapView *mMapView;
@property(strong,nonatomic) NSMutableArray     *locationItems;
@property(nonatomic,copy) void (^UpdateLocations)(NSArray *locations);
@end

@implementation MSBViewController{
    CLLocationCoordinate2D _centerLocation;
    
    MKPointAnnotation  *point;
    MSBLocationManager *_msbLocationManger;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _locationItems = [NSMutableArray array];
    _mMapView.delegate = self;
    [self performLocate];
}

- (void)viewDidAppear:(BOOL)animated {
    [_mMapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
     _centerLocation = CLLocationCoordinate2DMake(35.656375, 139.699587);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(_centerLocation, 50, 50);
	[_mMapView setRegion:region animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)startLocate:(id)sender {
    [self performLocate];
}

- (void)performLocate {
    if (!_msbLocationManger) {
        __block MSBViewController *msbViewController = self;
        _msbLocationManger = [[MSBLocationManager alloc] init:CLActivityTypeAutomotiveNavigation distanceFilter:kCLDistanceFilterNone desiredAccuracy:kCLLocationAccuracyBest];
        _msbLocationManger.mMkMapView = _mMapView;
        _msbLocationManger.UpdateLocations = ^(NSArray* locations) {
            
            [msbViewController performSelectorOnMainThread:@selector(updateLocate:) withObject:locations waitUntilDone:YES];
        };
    }
    [_msbLocationManger startLocateService];
}

- (IBAction)stopLocate:(id)sender {
    if (_msbLocationManger) {
        [_msbLocationManger endLocateService];
    }
}

- (void)updateLocate:(NSArray*)locations {
    
    for (MSBLocateMotion *msblocation in locations) {
        
        if(_locationItems && _locationItems.count > 0) {
            MSBLocateMotion *lastMotion = ((MSBLocateMotion *)_locationItems.lastObject);
            CLLocation *lastLocation   = ((MSBLocateMotion *)_locationItems.lastObject).location;
            if (point) {
                [_mMapView removeAnnotation:point];
            }
            point                             = [[MKPointAnnotation alloc] init];
            point.coordinate                  = lastLocation.coordinate;
            point.title                       = [self getActivityStat:lastMotion];
            
            [_mMapView addAnnotation:point];
            [_mMapView selectAnnotation:point animated:YES];
            [_mMapView setCenterCoordinate:lastLocation.coordinate animated:YES];
            
            
            CLLocationCoordinate2D coordinates[500];
            for (int index = 0; index< _locationItems.count; index++) {
                MSBLocateMotion *target = [_locationItems lastObject];
                CLLocationCoordinate2D coordinate = target.location.coordinate;
                coordinates[index] = coordinate;
            }
            
            MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:_locationItems.count];
            [_mMapView addOverlay:polyLine level:MKOverlayLevelAboveRoads];
            
//            for (int index = 0; index < _locationItems.count; index++) {
//                [_locationItems removeObjectAtIndex:0];
//            }
            
        }
        
        [_locationItems addObject:msblocation];
    }
}



- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolyline *polyLine        = (MKPolyline *)overlay;
    MKPolylineRenderer *render  = [[MKPolylineRenderer alloc] initWithPolyline:polyLine];
    render.strokeColor          = [UIColor redColor];
    render.lineWidth            = 10.0;
    return (MKOverlayRenderer *)render;
    
}

- (NSString *)getActivityStat:(MSBLocateMotion*)msbLocateMotion {
    
	if(msbLocateMotion.activity.stationary)     return @"止まってる";
	if(msbLocateMotion.activity.walking)		return @"歩いてる";
	if(msbLocateMotion.activity.running)		return @"走ってる";
	if(msbLocateMotion.activity.automotive)     return @"乗り物";
	
	return @"不明";
}


@end
