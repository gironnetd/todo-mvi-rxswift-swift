//
//  Task.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 03/12/2021.
//

import Foundation

//data class Task(
//    val id: String = UUID.randomUUID().toString(),
//    val title: String?,
//    val description: String?,
//    val completed: Boolean = false
//) {
//  val titleForList =
//      if (title.isNotNullNorEmpty()) {
//        title
//      } else {
//        description
//      }
//
//  val active = !completed
//
//  val empty = title.isNullOrEmpty() && description.isNullOrEmpty()
//}

import Foundation
import CoreData

import Foundation
import CoreData

@objc(Task)
public class Task: NSManagedObject {
    
    static var managedContext : NSManagedObjectContext = {
        return AppDelegate().persistentContainer.viewContext
    }()
    
    //MARK: - Initialize
    convenience init(id: String? = nil , title: String? = nil , taskDescription : String? = nil, completed : Bool? = nil) {
        // Create the NSEntityDescription
        let entity = NSEntityDescription.entity(forEntityName: "Task", in: Self.managedContext)
        
        self.init(entity: entity!, insertInto: nil)
        
        // Init class variables
        self.id = id ?? objectID.uriRepresentation().lastPathComponent //UUID().uuidString
        self.title = title ?? ""
        self.taskDescription = taskDescription ?? ""
        self.completed = completed ?? false
    }
}

extension Task {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }
    
    @NSManaged private var identifiant : String?
    var id : String {
        get {
            if(identifiant == nil) {
                identifiant = objectID.uriRepresentation().lastPathComponent
            }
            return identifiant!
        }
        set {
            identifiant = newValue
        }
    }
    
    @NSManaged public var title : String?
    @NSManaged public var taskDescription : String?
    
    @NSManaged private var isCompleted : NSNumber
    var completed : Bool {
        get {
            return Bool(truncating: isCompleted)
        }
        set {
            isCompleted = NSNumber(booleanLiteral: newValue)
        }
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(objectID.uriRepresentation().lastPathComponent, forKey: "identifiant")
    }
}

extension Task {
    
    var titleForList : String {
        if ((title?.isEmpty) != nil) {
            return title ?? ""
        } else {
            return taskDescription ?? ""
        }
    }
    
    var active : Bool {
        return !completed
    }
    
    var empty : Bool {
        return ((title?.isEmpty) != nil) && ((taskDescription?.isEmpty) != nil)
    }
}



