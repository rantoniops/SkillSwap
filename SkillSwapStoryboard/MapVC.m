#import "MapVC.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "SkillSwapStoryboard-Swift.h"
#import "PostCourseVC.h"
#import "TakeCourseVC.h"
#import "CustomCourseAnnotation.h"
#import "CourseListVC.h"
#import "ReviewVC.h"
@interface MapVC () <MKMapViewDelegate, CLLocationManagerDelegate,UISearchBarDelegate, UIGestureRecognizerDelegate, PostVCDelegate>
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
@property NSDate *tomorrow;
@property UIImage *callOutImage;
@property NSArray *filteredResults;
@property NSArray *results;
@property NSArray *lastAnnotationArray;
@property CLLocation *locationToPass;
@property NSMutableArray *friendsArray;
@property BOOL ifNow;
@property BOOL checkEveryone;
@property NSArray *reviews;
@end
@implementation MapVC
- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    if ([User currentUser] == nil)
    {
        [self performSegueWithIdentifier:@"mapToLogin" sender:self];
    }
    else
    {
        [self showUserLocation];
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
        self.ifNow = YES;
        self.checkEveryone = YES;

        self.navigationController.navigationBarHidden = YES;
        self.now = [NSDate date];
        NSLog(@"right now it is %@", self.now);
        NSTimeInterval fourteenHours = 14*60*60;
        self.tomorrow = [self.now dateByAddingTimeInterval:fourteenHours];
        [self pullReviews];
        [self queryForMap];


    }
}

-(void)pullReviews
{
    // Finding courses that expired
    PFQuery *expiredCoursesQuery = [Course query];
    [expiredCoursesQuery whereKey:@"time" lessThan:self.now];
    // Find reviews associated with these courses
    PFQuery *reviewsQuery = [Review query];
    [reviewsQuery whereKey:@"course" matchesQuery:expiredCoursesQuery];
    [reviewsQuery whereKey:@"reviewer" equalTo:[User currentUser]];
    [reviewsQuery whereKey:@"hasBeenReviewed" equalTo:@0];
    [reviewsQuery includeKey:@"course"];
    [reviewsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             if (objects.count > 0)
             {
                 NSLog(@"Successfully retrieved %lu empty reviews.", (unsigned long)objects.count);
                 self.reviews = objects;

                 for (Review *review in objects)
                 {
                     UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                     ReviewVC *reviewVC = [storyBoard instantiateViewControllerWithIdentifier:@"ReviewVCID"];
                     reviewVC.reviewToReview = review;
                     reviewVC.reviewCourse = review.course;
                     [self presentViewController:reviewVC animated:true completion:nil];
                 }
                 
             }
             else
             {
                 NSLog(@"review query didnt return any objects");
             }
         }
         else
         {
             NSLog(@"review query had error : %@ %@", error, [error userInfo]);
         }
     }];
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

-(void)queryMapForFriends
{
    User *currentUser = [User currentUser];
    PFQuery *followingQuery = [Follow query];
    [followingQuery whereKey:@"from" equalTo:currentUser];
    [followingQuery includeKey:@"from"];
    [followingQuery includeKey:@"from"];
    self.friendsArray = [NSMutableArray new];
    [followingQuery findObjectsInBackgroundWithBlock:^(NSArray *allFriends, NSError *error)
     {
         if (!error)
         {
             for (Follow *follow in allFriends)
             {
                 User *userToSee = [follow objectForKey:@"to"];
                 [self.friendsArray addObject:userToSee];
             }
        
             PFQuery *courseQuery = [Course query];
             [courseQuery includeKey:@"teacher"];
             [courseQuery whereKey:@"teacher" containedIn:self.friendsArray];
             if (self.ifNow == YES)
             {
                 [courseQuery whereKey:@"time" greaterThanOrEqualTo:self.now];
                 [courseQuery whereKey:@"time" lessThanOrEqualTo:self.tomorrow];
             }
             else
             {
                 [courseQuery whereKey:@"time" greaterThanOrEqualTo:self.tomorrow];
             }
             [courseQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
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
                                  NSString *timeString = [NSDateFormatter localizedStringFromDate:object.time dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
                                  NSString *titleAndTime = [NSString stringWithFormat:@"%@ @ %@", object.title, timeString];
                                  coursePointAnnotation.title = titleAndTime;
                                  PFFile *imageFile = object.courseMedia;
                                  [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
                                   {
                                       if (!error)
                                       {
                                           NSLog(@"image retrieved");
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
     }];
}
     

//pulls all the pins for existing events
- (void)queryForMap
{
    PFQuery *query = [Course query];
    [query includeKey:@"teacher"];
    if (self.ifNow == YES)
    {
        [query whereKey:@"time" greaterThanOrEqualTo:self.now];
        [query whereKey:@"time" lessThanOrEqualTo:self.tomorrow];
    }
    else
    {
        [query whereKey:@"time" greaterThanOrEqualTo:self.tomorrow];
    }
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
                    NSString *timeString = [NSDateFormatter localizedStringFromDate:object.time dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
                    NSString *titleAndTime = [NSString stringWithFormat:@"%@ @ %@", object.title, timeString];
                    coursePointAnnotation.title = titleAndTime;
                    PFFile *imageFile = object.courseMedia;
                    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
                     {
                         if (!error)
                         {
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
    CustomCourseAnnotation *newAnnotation = [[CustomCourseAnnotation alloc]init];
    newAnnotation.coordinate = self.mapView.centerCoordinate;
    CLLocation *location = [[CLLocation alloc]initWithLatitude:newAnnotation.coordinate.latitude longitude:newAnnotation.coordinate.longitude];
    self.locationToPass = location;
    [self reverseGeocodeLocation: location];
    [self.mapView addAnnotation:newAnnotation];
    self.lastAnnotationArray = [[NSArray alloc]initWithObjects:newAnnotation, nil];
}

//turn coordinates into an address
-(void)reverseGeocodeLocation:(CLLocation *)location
{
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
    {
        CLPlacemark *placeMark = [placemarks objectAtIndex:0];
       self.formattedAdress = [NSString stringWithFormat: @"%@ %@ %@, %@, %@", placeMark.subThoroughfare, placeMark.thoroughfare, placeMark.locality, placeMark.administrativeArea ,placeMark.postalCode];

        if ([self.formattedAdress containsString:@"(null)"])
        {
            NSLog(@"CONTAINS NULL, we replace it");
            NSString *newString = [self.formattedAdress stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
            self.formattedAdress = newString;
        }

        }];
}


//triggers segway to event detailVC
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"mapToCourse" sender:view.annotation];
}



-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[CustomCourseAnnotation class]])
    {
       MKPinAnnotationView *newPin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:nil];
        CustomCourseAnnotation *theAnnotation = newPin.annotation;
       newPin.canShowCallout = true;
        if (theAnnotation.course.teacher == [PFUser currentUser] || theAnnotation.course.teacher == nil)
        {
            newPin.pinColor = MKPinAnnotationColorGreen;
        }
        else
        {
            newPin.pinColor = MKPinAnnotationColorPurple;
        }
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



///resize image
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
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
    UIImage *pinImage = [UIImage imageNamed:@"secondPin"];
    self.pin = [[UIImageView alloc]initWithImage:pinImage];
    self.pin.frame = CGRectMake(self.mapView.bounds.size.width/2 -75  , self.mapView.bounds.size.height/2 - 65, 200, 75);
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
        [postVC setDelegate:self];
        postVC.selectedAddress = self.formattedAdress;
        postVC.courseLocation = self.locationToPass;
    }
    else if ([segue.identifier isEqualToString:@"mapToLogin"])
    {
        NSLog(@"login segue called");
    }
    else if ([segue.identifier isEqualToString:@"messages"])
    {
        NSLog(@"going to messages");
    }
    else if ([segue.identifier isEqualToString:@"mapToList"]) 
    {
        CourseListVC *listVC = segue.destinationViewController;
        listVC.courses = self.results;
    }
    else if ([segue.identifier isEqualToString:@"profile"])
    {
          
    }
    else if ([segue.identifier isEqualToString:@"mapToCourse"])
    {
        TakeCourseVC *takeVC = segue.destinationViewController;
        CustomCourseAnnotation *courseAnnotation = sender;
        Course *courseToShow = courseAnnotation.course;
        takeVC.selectedCourse = courseToShow;
        takeVC.selectedTeacher = courseToShow.teacher;

    }
    else
    {
        
    }
}


- (IBAction)listButtonPress:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"mapToList" sender:self];
}



//zoom to the user's location
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocationCoordinate2D location;
    location.latitude = userLocation.coordinate.latitude;
    location.longitude = userLocation.coordinate.longitude;
}

// search bar filtering
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
            CustomCourseAnnotation *coursePointAnnotation = [[CustomCourseAnnotation alloc]init];
            coursePointAnnotation.course = object;
            NSString *timeString = [NSDateFormatter localizedStringFromDate:object.time dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
            NSString *titleAndTime = [NSString stringWithFormat:@"%@ @ %@", object.title, timeString];
            coursePointAnnotation.title = titleAndTime;

            PFFile *imageFile = object.courseMedia;
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
             {
                 if (!error)
                 {
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


/// segment Control for everyone vs. friends
- (IBAction)segmentTap:(UISegmentedControl *)sender
{
    
    if(sender.selectedSegmentIndex == 1)
    {
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self queryMapForFriends];
        self.checkEveryone = NO;
        
    }
    else
    {
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self queryForMap];
        self.checkEveryone = YES;
    }
}


- (IBAction)nowOrLater:(UISegmentedControl *)sender
{
    if(sender.selectedSegmentIndex == 0)
    {
        [self.mapView removeAnnotations:self.mapView.annotations];
        self.ifNow = YES;
        if (self.checkEveryone == YES)
        {
            [self queryForMap];
        }
        else
        {
            [self queryMapForFriends];
        }
    }
    else
    {
        [self.mapView removeAnnotations:self.mapView.annotations];
        self.ifNow = NO;
        if (self.checkEveryone == YES)
        {
            [self queryForMap];
        }
        else
        {
            [self queryMapForFriends];
        }
    }
    
}






//delegate method when returning from postCourse

-(void)didIcreateACourse:(BOOL *)didCreate
{
    if (didCreate == false)
    {
        [self.mapView removeAnnotation:self.lastAnnotationArray.lastObject];
        [self.pin removeFromSuperview];
    }
}


@end
