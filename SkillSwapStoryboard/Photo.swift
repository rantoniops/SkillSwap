import Foundation
class Photo : PFObject, PFSubclassing
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
        return "Photo"
    }


    @NSManaged var commentBody: String
    @NSManaged var commenter : User

    
    
    
    
    
}