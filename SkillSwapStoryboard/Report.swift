import Foundation
class Report : PFObject, PFSubclassing
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
        return "Report"
    }






    @NSManaged var reporter : User
    @NSManaged var reported : User
    @NSManaged var course : Course
    @NSManaged var hasBeenTakenCareOf : NSNumber
    @NSManaged var reason : String
    
    
    

    
}