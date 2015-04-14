//
//  ViewController.m
//  SkillSwapStoryboard
//
//  Created by Antonio Perez on 4/13/15.
//  Copyright (c) 2015 antonioperez. All rights reserved.
//

#import "MapVC.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface MapVC () <MKMapViewDelegate, CLLocationManagerDelegate,UISearchBarDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation MapVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self showUserLocation];

}

-(void)viewDidAppear:(BOOL)animated
{
    [self addCenterPinImageAndButton];

}

-(void)showUserLocation
{
    self.mapView.showsUserLocation = true;
    self.locationManager = [CLLocationManager new];
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate = self;

}

-(void)addCenterPinImageAndButton
{
    UIImage *pinImage = [UIImage imageNamed:@"redcircle"];
    UIImageView *pin = [[UIImageView alloc]initWithImage:pinImage];
    pin.frame = CGRectMake(self.mapView.bounds.size.width/2 -25  , self.mapView.bounds.size.height/2 - 25, 50, 50);
    UITapGestureRecognizer *pinTap = [[UITapGestureRecognizer alloc]init];
    [self imageview:pin addGestureRecognizer:pinTap];
    [self.mapView addSubview:pin];
    NSLog(@"%f and %f", self.mapView.center.x, self.mapView.center.y);
    
}

//add a tapGesture recognizer to the imageView
-(void)imageview:(UIImageView *)imageView addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    imageView.userInteractionEnabled = YES;
    gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    gestureRecognizer.delegate = self;
    [imageView addGestureRecognizer:gestureRecognizer];
}


//action on tap of pin imageView
-(void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    NSLog(@"Tap was correctly handled, now we need to prescribe an action");
    MKPointAnnotation *newAnnotation = [[MKPointAnnotation alloc]init];
    newAnnotation.coordinate = self.mapView.centerCoordinate;
    [self.mapView addAnnotation:newAnnotation];
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01,0.01);
    [self.mapView setRegion:MKCoordinateRegionMake(newAnnotation.coordinate,span) animated:true];
    [self presentViewController:  animated:true completion:nil]
    
}


//zoom to the user's location
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocationCoordinate2D location;
    location.latitude = userLocation.coordinate.latitude;
    location.longitude = userLocation.coordinate.longitude;
    MKCoordinateSpan span = MKCoordinateSpanMake(0.05,0.05);
    [self.mapView setRegion:MKCoordinateRegionMake(location,span) animated:true];

}
- (IBAction)onAddButtonTap:(UIButton *)sender
{


    
}




- (IBAction)profileButtonPress:(UIButton *)sender {
    [self performSegueWithIdentifier:@"profile" sender:self];
}


- (IBAction)listButtonPress:(UIButton *)sender {
}

- (IBAction)msgButtonPress:(UIButton *)sender {
}


@end
