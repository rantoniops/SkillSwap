import Foundation
@objc class Follow : PFObject, PFSubclassing
{
    override class func initialize()
    {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken)
            {
                self.registerSubclass()
        }
    }
    
    
    
    class func parseClassName() -> String
    {
        return "Follow"
    }
    
    @NSManaged var friendTime : NSDate
    @NSManaged var from : User
    @NSManaged var to : User

    
}