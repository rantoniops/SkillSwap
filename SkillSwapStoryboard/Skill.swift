import Foundation
class Skill : PFObject, PFSubclassing
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
        return "Skill"
    }


    @NSManaged var name: String

    @NSManaged var owner : User
    @NSManaged var course : Course

    
    

    
}