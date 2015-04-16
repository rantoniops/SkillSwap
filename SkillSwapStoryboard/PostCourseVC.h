#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface PostCourseVC : UIViewController
@property NSString *selectedAddress;
@property CLLocation *courseLocation;

@property (nonatomic, strong) NSMutableArray *items;


@end
