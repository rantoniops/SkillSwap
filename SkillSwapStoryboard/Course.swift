import Foundation
class Course : PFObject, PFSubclassing
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
        return "Course"
    }


    @NSManaged var title: String
    @NSManaged var courseDescription: String
    @NSManaged var time: String
    @NSManaged var address: String
    @NSManaged var coursePhoto: PFFile

    @NSManaged var skillTaught: Skill


    @NSManaged var teacher : User
    
    @NSManaged var students : User



    
    
    
}