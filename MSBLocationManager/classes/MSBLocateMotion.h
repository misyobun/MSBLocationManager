//
//  MSBLocateMotion.h
//  MSBLocationManager
//
//  Created by misyobun on 2014/05/26.
//  Copyright (c) 2014年 misyobun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>

@interface MSBLocateMotion : NSObject

@property (nonatomic,strong) CLLocation *location;
@property (nonatomic,strong) CMMotionActivity *activity;

- (id)initWithLocation:(CLLocation*)location andActivity:(CMMotionActivity*)activity;
@end
