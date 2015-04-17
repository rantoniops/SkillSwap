#import "MapVC.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "SkillSwapStoryboard-Swift.h"
#import "PostCourseVC.h"
#import "TakeCourseVC.h"
#import "CustomCourseAnnotation.h"
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
@property NSDate *now;
@property UIImage *callOutImage;
@property NSArray *filteredResults;
@property NSArray *results;

@end
@implementation MapVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self showUserLocation];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
    
//    [self loadZoom];
    NSLog(@"%@", [User currentUser]);
    self.now = [NSDate date];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
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
    [query whereKey:@"time" greaterThanOrEqualTo:self.now];
    NSLog(@"Mapquery is called");
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if (!error)
        {
            self.results = objects;

            for (Course *object in objects)
            {
                if ([object isKindOfClass:[Course class]])
                {
                    CustomCourseAnnotation *coursePointAnnotation = [[CustomCourseAnnotation alloc]init];
                    coursePointAnnotation.course = object;
                    coursePointAnnotation.title = object.title;
                    
                    PFFile *imageFile = object.courseMedia;
                    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
                     {
                         if (!error)
                         {
                             NSLog(@"image retrieved");
//                             UIImage *image =
//                             UIImage *smallerImage = [self imageWithImage:image scaledToSize:CGSizeMake(40, 40)];
//                             self.callOutImage = smallerImage;
//                             coursePointAnnotation.image = self.callOutImage;
                             object.callOutImage = [UIImage imageWithData:data];
                             object.sizedCallOutImage = [self imageWithImage: object.callOutImage scaledToSize:CGSizeMake(40, 40)];
                             coursePointAnnotation.subtitle = object.address;
                             PFGeoPoint *geoPoint = object.location;
                             coursePointAnnotation.coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
                             [self.mapView addAnnotation:coursePointAnnotation];
                         }
                     }];

                }
            }
        }
        else
        {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
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



-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[CustomCourseAnnotation class]])
    {
       NSLog(@"custom annotation is called");
       MKPinAnnotationView *newPin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:nil];
        CustomCourseAnnotation *theAnnotation = newPin.annotation;
       newPin.canShowCallout = true;
       newPin.pinColor = MKPinAnnotationColorPurple;
//       UIImage *image = [UIImage imageNamed:@"emptyProfile"];
//       UIImage *smallerImage = [self imageWithImage:image scaledToSize:CGSizeMake(40, 40)];
       newPin.leftCalloutAccessoryView = [[UIImageView alloc]initWithImage:theAnnotation.course.sizedCallOutImage];
       newPin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
       return newPin;
    }
    else
    {
        NSLog(@"user annotation is called");
        return nil;
    }
    
}
////////Need to figure out how to delete the latest pin dropped if the user does not add a new course, it isn't saved but it stays on map//////
////pins should be colored based on whether current user is course coordinator or not/////


///resize image

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

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
        CustomCourseAnnotation *courseAnnotation = sender;
        Course *courseToShow = courseAnnotation.course;
        takeVC.selectedCourse = courseToShow;
    }
}

- (IBAction)profileButtonPress:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"profile" sender:self];
    NSLog(@"%@", [User currentUser]);

}


- (IBAction)listButtonPress:(UIButton *)sender {
}



//zoom to the user's location
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocationCoordinate2D location;
    location.latitude = userLocation.coordinate.latitude;
    location.longitude = userLocation.coordinate.longitude;
}






-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (![searchText isEqualToString:@""]) // if searchbar text is not empty
    {
        NSMutableArray *tempSearchArray = [NSMutableArray new];
        for ( Course *course in self.results )
        {

            ////////////////////////// OPTION 1 ////////////////////////////////////

            // MISSING FILTERING FOR SKILLSTAUGHT
            if ( [course.title localizedCaseInsensitiveContainsString:searchText] || [course.courseDescription localizedCaseInsensitiveContainsString:searchText] || [course.address localizedCaseInsensitiveContainsString:searchText] || [course.teacher.username localizedCaseInsensitiveContainsString:searchText] )
            {
                [tempSearchArray addObject:course];
            }

            ////////////////////////////////////////////////////////////////////////

            ////////////////////////// OPTION 2 ////////////////////////////////////

//            NSRange textRange = [course.title rangeOfString:searchText options:NSCaseInsensitiveSearch];
//            if (textRange.location != NSNotFound)
//            {
//                [tempSearchArray addObject:course];
//            }

            ////////////////////////////////////////////////////////////////////////

        }
        self.filteredResults = tempSearchArray;
        NSLog(@"FILTERED ASSIGN %@", self.filteredResults);
    }
    else
    {
        self.filteredResults = [self.results mutableCopy];
    }

    [self.mapView removeAnnotations:self.mapView.annotations];

    for (Course *object in self.filteredResults)
    {
        if ([object isKindOfClass:[Course class]])
        {
            NSLog(@"FILTERED SHOW %@", self.filteredResults);
            CustomCourseAnnotation *coursePointAnnotation = [[CustomCourseAnnotation alloc]init];
            coursePointAnnotation.course = object;
            coursePointAnnotation.title = object.title;

            PFFile *imageFile = object.courseMedia;
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
             {
                 if (!error)
                 {
                     NSLog(@"image retrieved");
                     //                             UIImage *image =
                     //                             UIImage *smallerImage = [self imageWithImage:image scaledToSize:CGSizeMake(40, 40)];
                     //                             self.callOutImage = smallerImage;
                     //                             coursePointAnnotation.image = self.callOutImage;
                     object.callOutImage = [UIImage imageWithData:data];
                     object.sizedCallOutImage = [self imageWithImage: object.callOutImage scaledToSize:CGSizeMake(40, 40)];
                     coursePointAnnotation.subtitle = object.address;
                     PFGeoPoint *geoPoint = object.location;
                     coursePointAnnotation.coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
                     [self.mapView addAnnotation:coursePointAnnotation];
                 }
             }];
        }
    }


}









@end
