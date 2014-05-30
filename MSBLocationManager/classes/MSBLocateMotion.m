//
//  MSBLocateMotion.m
//  MSBLocationManager
//
//  Created by misyobun on 2014/05/26.
//  Copyright (c) 2014年 misyobun. All rights reserved.
//

#import "MSBLocateMotion.h"

@implementation MSBLocateMotion

- (id)initWithLocation:(CLLocation*)location
           andActivity:(CMMotionActivity*)activity {
    
	_location = location;
	_activity = activity;
    
	return self;
}

@end
