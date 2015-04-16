import Foundation
@objc class User : PFUser, PFSubclassing
{
    override class func initialize()
    {
        registerSubclass()
    }


    @NSManaged var profilePic: PFFile
    @NSManaged var rating : Int

    @NSManaged var friends: PFRelation
    @NSManaged var teachers: PFRelation
    @NSManaged var students: PFRelation
    
    @NSManaged var skills : PFRelation
    @NSManaged var conversations : PFRelation
    




    
    





}