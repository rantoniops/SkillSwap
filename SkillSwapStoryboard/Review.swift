import Foundation
class Review : PFObject, PFSubclassing
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
        return "Review"
    }



    @NSManaged var reviewContent : String
    @NSManaged var rating : Int
    
    @NSManaged var reviewer : User
    @NSManaged var reviewed : User

    @NSManaged var course : Course

    @NSManaged var hasBeenReviewed : NSNumber





    
    
    
    
    
}