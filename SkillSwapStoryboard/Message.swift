import Foundation
class Message : PFObject, PFSubclassing
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
        return "Message"
    }



    @NSManaged var messageBody : String
    
    @NSManaged var messageSender : User
    @NSManaged var messageReceiver : User





    
    
    
    
}