import Foundation
@objc class Course : PFObject, PFSubclassing
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
    @NSManaged var courseMedia: PFFile
    @NSManaged var location: PFGeoPoint

    @NSManaged var skillsTaught : PFRelation

    @NSManaged var teacher : User
}