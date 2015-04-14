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

@interface MapVC () <MKMapViewDelegate, CLLocationManagerDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation MapVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.showsUserLocation = true;
    self.locationManager = [CLLocationManager new];
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate = self;
}



-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocationCoordinate2D location;
    location.latitude = userLocation.coordinate.latitude;
    location.longitude = userLocation.coordinate.longitude;
    MKCoordinateSpan span = MKCoordinateSpanMake(0.1,0.1);
    [self.mapView setRegion:MKCoordinateRegionMake(location,span) animated:true];

}
- (IBAction)onAddButtonTap:(UIButton *)sender
{
    MKPointAnnotation *newAnnotation = [[MKPointAnnotation alloc]init];
    [self.mapView addAnnotation:newAnnotation];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateStarting)
    {
        annotationView.dragState = MKAnnotationViewDragStateDragging;
    }
    else if (newState == MKAnnotationViewDragStateEnding || newState == MKAnnotationViewDragStateCanceling)
    {
        annotationView.dragState = MKAnnotationViewDragStateNone;
    }
}



- (IBAction)profileButtonPress:(UIButton *)sender {
    [self performSegueWithIdentifier:@"profile" sender:self];
}


- (IBAction)listButtonPress:(UIButton *)sender {
}

- (IBAction)msgButtonPress:(UIButton *)sender {
}


@end
