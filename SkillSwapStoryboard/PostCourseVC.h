#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol PostVCDelegate <NSObject>
@required

-(void)didIcreateACourse:(BOOL *)didCreate;

@end

@interface PostCourseVC : UIViewController
@property NSString *selectedAddress;
@property CLLocation *courseLocation;

@property (nonatomic, weak) id<PostVCDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *items;


@end
