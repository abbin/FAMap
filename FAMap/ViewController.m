//
//  ViewController.m
//  FAMap
//
//  Created by Abbin Varghese on 30/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@import Firebase;

@interface ViewController ()<CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.myLocationEnabled = YES;
    
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    
    /*
     Gets user permission to get their location while the app is in the foreground.
     
     To monitor the user's location even when the app is in the background:
     1. Replace [self.locationManager requestWhenInUseAuthorization] with [self.locationManager requestAlwaysAuthorization]
     2. Change NSLocationWhenInUseUsageDescription to NSLocationAlwaysUsageDescription in InfoPlist.strings
     */
    [self.locationManager requestWhenInUseAuthorization];
    
    /*
     Requests a single location after the user is presented with a consent dialog.
     */
    [self.locationManager startUpdatingLocation];
    
    FIRDatabaseReference *ref = [[[FIRDatabase database] reference] child:@"items"];
    [ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        if (snapshot.value != [NSNull null]) {
            [self.mapView clear];
            NSArray *itemsArray = [snapshot.value allValues];
            for (NSMutableDictionary *item in itemsArray) {
                double lat = [[item objectForKey:@"restaurant_latitude"] doubleValue];
                double lng = [[item objectForKey:@"restaurant_longitude"] doubleValue];
                CLLocationCoordinate2D position = CLLocationCoordinate2DMake(lat, lng);
                GMSMarker *marker = [GMSMarker markerWithPosition:position];
                marker.title = [item objectForKey:@"item_name"];
                marker.map = self.mapView;
            }
        }
    }];

    
}

#pragma mark - CLLocationMangerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {

    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *loc = [locations firstObject];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:loc.coordinate.latitude
                                                            longitude:loc.coordinate.longitude
                                                                 zoom:15];
    [self.mapView animateToCameraPosition:camera];
    [self.locationManager stopUpdatingLocation];
}

@end
