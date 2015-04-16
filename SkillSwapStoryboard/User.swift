import Foundation
@objc class User : PFUser, PFSubclassing
{
    override class func initialize()
    {
        registerSubclass()
    }


    @NSManaged var friends: User
    @NSManaged var teachers: User
    @NSManaged var students: User

    @NSManaged var profilePic: PFFile
    @NSManaged var rating : Int

    @NSManaged var skills : Skill
    @NSManaged var courses : PFRelation



    
    
    
    
    





}