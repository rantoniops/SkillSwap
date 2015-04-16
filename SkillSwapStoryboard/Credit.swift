import Foundation
class Credit : PFObject, PFSubclassing
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
        return "Credit"
    }



    @NSManaged var creditSender : User
    @NSManaged var creditReceiver : User
    @NSManaged var owner : User



    
    
    
}