#import "MapVC.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "SkillSwapStoryboard-Swift.h"

@interface MapVC () <MKMapViewDelegate, CLLocationManagerDelegate,UISearchBarDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property UIImageView *pin;

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
    UIImage *pinImage = [UIImage imageNamed:@"pointer"];
    self.pin = [[UIImageView alloc]initWithImage:pinImage];
    self.pin.frame = CGRectMake(self.mapView.bounds.size.width/2 -75  , self.mapView.bounds.size.height/2 - 75, 150, 50);
    UITapGestureRecognizer *pinTap = [[UITapGestureRecognizer alloc]init];
    [self imageview:self.pin addGestureRecognizer:pinTap];
    [self.mapView addSubview:self.pin];
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
    [self addAnnotation];
    self.pin.hidden = YES;
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01,0.01);
    [self.mapView setRegion:MKCoordinateRegionMake(self.mapView.centerCoordinate,span) animated:true];
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
    {
        [self performSegueWithIdentifier:@"mapToSkill" sender:self];
    });
}


///Create new pin
-(void)addAnnotation
{
    MKPointAnnotation *newAnnotation = [[MKPointAnnotation alloc]init];
    newAnnotation.coordinate = self.mapView.centerCoordinate;
    newAnnotation.title = @"skill";
    newAnnotation.subtitle = @"location";
    CLLocation *location = [[CLLocation alloc]initWithLatitude:newAnnotation.coordinate.latitude longitude:newAnnotation.coordinate.longitude];
    [self reverseGeocodeLocation: location];
    [self.mapView addAnnotation:newAnnotation];
}



//turn coordinates into an address
-(void)reverseGeocodeLocation:(CLLocation *)location
{
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placeMark = [placemarks objectAtIndex:0];
        NSLog(@"Pin location is %@ %@ %@ %@", placeMark.subThoroughfare, placeMark.thoroughfare, placeMark.locality, placeMark.postalCode);
    }];
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
