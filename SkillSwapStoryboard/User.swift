import Foundation
class User : PFUser, PFSubclassing
{
    override class func initialize()
    {
        registerSubclass()
    }


    @NSManaged var friends: User
    @NSManaged var profilePic: PFFile



    
    
    
    
    





}