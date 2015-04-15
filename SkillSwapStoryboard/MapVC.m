#import "MapVC.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "SkillSwapStoryboard-Swift.h"
#import "PostCourseVC.h"

@interface MapVC () <MKMapViewDelegate, CLLocationManagerDelegate,UISearchBarDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property UIImageView *pin;
@property NSString *formattedAdress;
@property double *eventLatitude;
@property double *eventLongitude;
@property MKPointAnnotation *anotherAnnotation;



@end
@implementation MapVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self showUserLocation];

}

//fetch the user's location
-(void)showUserLocation
{
    self.mapView.showsUserLocation = true;
    self.locationManager = [CLLocationManager new];
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate = self;
}

//add the image to map - gets called on addButton tap
-(void)addCenterPinImageAndButton
{
    UIImage *pinImage = [UIImage imageNamed:@"pointer"];
    self.pin = [[UIImageView alloc]initWithImage:pinImage];
    self.pin.frame = CGRectMake(self.mapView.bounds.size.width/2 -75  , self.mapView.bounds.size.height/2 - 75, 150, 50);
    UITapGestureRecognizer *pinTap = [[UITapGestureRecognizer alloc]init];
    [self imageview:self.pin addGestureRecognizer:pinTap];
    [self.mapView addSubview:self.pin];
}

//add a tapGesture recognizer to the imageView indicator
-(void)imageview:(UIImageView *)imageView addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    imageView.userInteractionEnabled = YES;
    gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    gestureRecognizer.delegate = self;
    [imageView addGestureRecognizer:gestureRecognizer];
}


//action on tap of imageview indicator
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
        [self performSegueWithIdentifier:@"postClass" sender:self];
    });
}

///Create new pin on tap
-(void)addAnnotation
{
    self.anotherAnnotation = [[MKPointAnnotation alloc]init];
    self.anotherAnnotation.coordinate = self.mapView.centerCoordinate;
    self.anotherAnnotation.title = @"tbd";  ///the address needs to wait until the reverse geolocation block has ended
                                 
    CLLocation *location = [[CLLocation alloc]initWithLatitude:self.anotherAnnotation.coordinate.latitude longitude:self.anotherAnnotation.coordinate.longitude];
    [self reverseGeocodeLocation: location];
    [self.mapView addAnnotation:self.anotherAnnotation];
    
}

//turn coordinates into an address
-(void)reverseGeocodeLocation:(CLLocation *)location
{
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placeMark = [placemarks objectAtIndex:0];
        NSLog(@"Pin location is %@ %@ %@ %@", placeMark.subThoroughfare, placeMark.thoroughfare, placeMark.locality, placeMark.postalCode);
       self.formattedAdress = [NSString stringWithFormat: @"%@ %@ %@, %@, %@", placeMark.subThoroughfare, placeMark.thoroughfare, placeMark.locality, placeMark.administrativeArea ,placeMark.postalCode];
      //            self.anotherAnnotation.title = queryCourse.title;
        }];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.anotherAnnotation.subtitle = self.formattedAdress;
    PFQuery *skillQuery = [PFQuery queryWithClassName:@"Course"];
    [skillQuery whereKey:@"address" containsString:self.formattedAdress];
    [skillQuery getFirstObjectInBackgroundWithBlock: ^(PFObject *course, NSError *error)
     {
         NSLog(@"%@", course);
         self.anotherAnnotation.title = course[@"title"];
    }];

}

//triggers segway to event detailVC
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"mapToSkill" sender:view.annotation];
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"ready to segue");
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

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (![annotation isEqual:self.mapView.userLocation])
    {
        MKPinAnnotationView *newPin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:nil];
        newPin.canShowCallout = true;
        newPin.pinColor = MKPinAnnotationColorPurple;
        newPin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        return newPin;
    }
    else
    {
        return nil;
    }
    
}


- (IBAction)onAddButtonTap:(UIButton *)sender
{

    [self addCenterPinImageAndButton];
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"postClass"])
    {
        PostCourseVC *postVC = segue.destinationViewController;
        postVC.selectedAddress = self.formattedAdress;
//        postVC.selectedLatitude = self.eventLatitude;
//        postVC.selectedLongitude = self.eventLongitude;
    }
    else
    {
        nil;
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
