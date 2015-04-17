#import "MapVC.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "SkillSwapStoryboard-Swift.h"
#import "PostCourseVC.h"
#import "TakeCourseVC.h"
#import "CourseAnnotationVC.h"
@interface MapVC () <MKMapViewDelegate, CLLocationManagerDelegate,UISearchBarDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property UIImageView *pin;
@property NSString *formattedAdress;
@property NSString *formattedAdressTwo;
@property double *eventLatitude;
@property double *eventLongitude;
@property MKPointAnnotation *anotherAnnotation;
@end
@implementation MapVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self showUserLocation];
    NSLog(@"%@", [User currentUser]);
}


-(void)viewDidAppear:(BOOL)animated
{
    if ([User currentUser] == nil)
    {
        [self performSegueWithIdentifier:@"loginSegue" sender:self];
    }
    else
    {
        [self queryForMap];
    }
}


//pulls all the pins for existing events
- (void)queryForMap
{
    PFQuery *query = [Course query];
    [query includeKey:@"teacher"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if (!error)
        {
//            NSLog(@"Successfully retrieved %lu courses.", (unsigned long)objects.count);
            for (Course *object in objects)
            {
                if ([object isKindOfClass:[Course class]]) {
//                    NSLog(@"%@", object.teacher.username);
                    CourseAnnotationVC *coursePointAnnotation = [[CourseAnnotationVC alloc]init];
                    coursePointAnnotation.course = object;
                    coursePointAnnotation.title = object[@"title"];
                    coursePointAnnotation.subtitle = object[@"address"];
                    PFGeoPoint *geoPoint = object[@"location"];
                    coursePointAnnotation.coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
                    [self.mapView addAnnotation:coursePointAnnotation];
//                    NSLog(@"%@", coursePointAnnotation.course);
                }
            }
        }
        else
        {
//            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}


//fetch the user's location
-(void)showUserLocation
{
    self.mapView.showsUserLocation = true;
    self.locationManager = [CLLocationManager new];
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate = self;
}



///Create new pin on tap
-(void)addAnnotation
{
    self.anotherAnnotation = [[MKPointAnnotation alloc]init];
    self.anotherAnnotation.coordinate = self.mapView.centerCoordinate;
    CLLocation *location = [[CLLocation alloc]initWithLatitude:self.anotherAnnotation.coordinate.latitude longitude:self.anotherAnnotation.coordinate.longitude];
    [self reverseGeocodeLocation: location];
    [self.mapView addAnnotation:self.anotherAnnotation];
    
}

//turn coordinates into an address
-(void)reverseGeocodeLocation:(CLLocation *)location
{
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
    {
        CLPlacemark *placeMark = [placemarks objectAtIndex:0];
       self.formattedAdress = [NSString stringWithFormat: @"%@ %@ %@, %@, %@", placeMark.subThoroughfare, placeMark.thoroughfare, placeMark.locality, placeMark.administrativeArea ,placeMark.postalCode];
         self.formattedAdressTwo = [NSString stringWithFormat: @"%@ %@ %@, %@, %@", placeMark.subThoroughfare, placeMark.thoroughfare, placeMark.locality, placeMark.administrativeArea ,placeMark.postalCode];
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
////////Need to figure out how to delete the latest pin dropped if the user does not add a new course, it isn't saved but it stays on map//////
////pins should be colored based on whether current user is course coordinator or not/////


- (IBAction)onAddButtonTap:(UIButton *)sender
{
    [self addCenterPinImageAndButton];
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01,0.01);
    [self.mapView setRegion:MKCoordinateRegionMake(self.mapView.centerCoordinate,span) animated:true];
}

//add the image to map - gets called on addButton tap
-(void)addCenterPinImageAndButton
{
    UIImage *pinImage = [UIImage imageNamed:@"newpin"];
    self.pin = [[UIImageView alloc]initWithImage:pinImage];
    self.pin.frame = CGRectMake(self.mapView.bounds.size.width/2 -75  , self.mapView.bounds.size.height/2 - 65, 150, 75);
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
    MKCoordinateSpan span = MKCoordinateSpanMake(0.007,0.007);
    [self.mapView setRegion:MKCoordinateRegionMake(self.mapView.centerCoordinate,span) animated:true];
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       [self performSegueWithIdentifier:@"postClass" sender:self];
                   });
}


///segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"postClass"])
    {
        PostCourseVC *postVC = segue.destinationViewController;
        CLLocation *locationToPass = [[CLLocation alloc]initWithLatitude:self.anotherAnnotation.coordinate.latitude longitude:self.anotherAnnotation.coordinate.longitude];
        postVC.selectedAddress = self.formattedAdress;
        postVC.courseLocation = locationToPass;
    }
    else if ([segue.identifier isEqualToString:@"loginSegue"])
    {
        NSLog(@"login segue called");
    }
    else if ([segue.identifier isEqualToString:@"messages"])
    {
        NSLog(@"going to messages");
    }
    else if ([segue.identifier isEqualToString:@"profile"])
      {
          
      }
    else
    {
        TakeCourseVC *takeVC = segue.destinationViewController;
        CourseAnnotationVC *courseAnnotation = sender;
        Course *courseToShow = courseAnnotation.course;
        takeVC.selectedCourse = courseToShow;
        
        
//        CLLocation *location = [[CLLocation alloc]initWithLatitude:self.anotherAnnotation.coordinate.latitude longitude:self.anotherAnnotation.coordinate.longitude];
//        [self reverseGeocodeLocation: location];
//        takeVC.selectedAddress = self.formattedAdressTwo;
        //still needs to be changed to be updated for location and not address
    }
}

- (IBAction)profileButtonPress:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"profile" sender:self];
}


- (IBAction)listButtonPress:(UIButton *)sender {
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

@end
