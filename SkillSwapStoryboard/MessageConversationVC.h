#import <UIKit/UIKit.h>
#import "SkillSwapStoryboard-Swift.h"
@interface MessageConversationVC : UIViewController
@property User *otherUser;
@property Conversation *selectedConversation;
@property Course *selectedCourse;
@property NSString *origin;
@end
