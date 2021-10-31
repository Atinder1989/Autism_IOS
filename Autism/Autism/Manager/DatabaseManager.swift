//
//  DatabaseManager.swift
//  Autism
//
//  Created by Atinderpal Singh on 2020/05/14.
//  Copyright © 2020 IMPUTE. All rights reserved.
//


import Foundation
import CoreData

enum DatabaseEntity: String {
    case User           = "User"
    case AvatarVariation    = "AvatarVariation"

}

class DatabaseManager: NSObject {
    static let sharedInstance = DatabaseManager()
    // MARK: - CORE DATA METHODS
    // MARK: - utility routines
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    // MARK: - Core Data stack (generic)
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "Autism", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
let url = self.applicationDocumentsDirectory.appendingPathComponent("Autism").appendingPathExtension("sqlite")
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
let dict: [String: Any] = [NSLocalizedDescriptionKey:
    "Failed to initialize the application's saved data" as NSString,
    NSLocalizedFailureReasonErrorKey:
    "There was an error creating or loading the application's saved data." as NSString,
    NSUnderlyingErrorKey: error as NSError]
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            fatalError("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
        }
        return coordinator
    }()
    // MARK: - Core Data stack (iOS 9)
    @available(iOS 9.0, *)
    lazy var managedObjectContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    // MARK: - Core Data stack (iOS 10)
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Autism")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
    // Replace this implementation with code to handle the error appropriately.
// fatalError() causes the application to generate a crash log and terminate.
//You should not use this function in a shipping application, although it may be useful during development.
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
    * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    // MARK: - Core Data context
    lazy var databaseContext: NSManagedObjectContext = {
        if #available(iOS 10.0, *) {
            return self.persistentContainer.viewContext
        } else {
            return self.managedObjectContext
        }
    }()
    // MARK: - Core Data save
    private func saveContext () {
        self.databaseContext.performAndWait {
            do {
                if databaseContext.hasChanges {
                    try databaseContext.save()
                }
            } catch {
                let nserror = error as NSError
                print(nserror.localizedDescription)
            }
        }
    }
    // MARK: - Clear Database With Entity Name
    func clearDatabaseWithEntityName(_ entity: String) {
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: entity)
let deleteRequest = NSBatchDeleteRequest(fetchRequest: (fetchRequest as? NSFetchRequest<NSFetchRequestResult>)!)
        do {
            try self.persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: databaseContext)
        } catch let error as NSError {
            print(error.description)
        }
    }
    // MARK: - Save Login User Info Data In Database
    func saveUserInfo(model: UserModel) {
        let user   = User(context: databaseContext)
        user.token = model.token
        user.email = model.email
        user.id = model.id
        user.parentName = model.parentName
        user.verification  = model.verification
        user.verified  = model.verified
        user.screen_id = model.screen_id
        user.avatar = model.avatar
        user.languageCode = model.languageCode
        user.languageImage = model.languageImage
        user.languageName = model.languageName
        user.languageStatus = model.languageStatus
        user.nickname = model.nickname
        user.avatarGender = model.avatar_gender
        self.saveContext()
    }
    
    // MARK: - Save Login User Info Data In Database
    func saveAvatarVariation(model: AvatarModel,user:UserModel) {
         let avatar   = AvatarVariation(context: databaseContext)
         avatar.avtar_id = model.avtar_id
         avatar.file = model.file
         avatar.file_type = model.file_type
         avatar.id = model.id
         avatar.isDownloaded = model.isDownloaded
         avatar.userid = user.id
         avatar.variation_type = model.variation_type
         self.saveContext()
    }
    
    // MARK: - Get Login User Info Data From Database
    func getLoginUserData() -> UserModel? {
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: DatabaseEntity.User.rawValue)
        var userVO: UserModel?
        do {
            let manageObjectContext = try databaseContext.fetch(fetchRequest)
            if (manageObjectContext.count) > 0 {
                for manageObject in manageObjectContext {
                    userVO = UserModel.init()
                    userVO?.token = manageObject.value(forKeyPath: ServiceParsingKeys.token.rawValue) as? String ?? ""
                    userVO?.email = manageObject.value(forKeyPath: ServiceParsingKeys.email.rawValue) as? String ?? ""
                    userVO?.id = manageObject.value(forKeyPath: "id") as? String ?? ""
                    userVO?.parentName = manageObject.value(forKeyPath: ServiceParsingKeys.parentName.rawValue) as? String ?? ""
                    userVO?.verification = manageObject.value(forKeyPath: ServiceParsingKeys.verification.rawValue) as? String ?? ""
                    userVO?.screen_id = manageObject.value(forKeyPath: ServiceParsingKeys.screen_id.rawValue) as? String ?? ""
                    userVO?.verified = manageObject.value(forKeyPath: ServiceParsingKeys.verified.rawValue) as? Bool ?? false
                    userVO?.avatar = manageObject.value(forKeyPath: ServiceParsingKeys.avatar.rawValue) as? String ?? ""
                    userVO?.languageCode = manageObject.value(forKeyPath: ServiceParsingKeys.languageCode.rawValue) as? String ?? ""
                    userVO?.languageName = manageObject.value(forKeyPath: ServiceParsingKeys.languageName.rawValue) as? String ?? ""
                    userVO?.languageImage = manageObject.value(forKeyPath: ServiceParsingKeys.languageImage.rawValue) as? String ?? ""
                    userVO?.languageStatus = manageObject.value(forKeyPath: ServiceParsingKeys.languageStatus.rawValue) as? String ?? ""
                    userVO?.nickname = manageObject.value(forKeyPath: ServiceParsingKeys.nickname.rawValue) as? String ?? ""
                    print(manageObject.value(forKeyPath: ServiceParsingKeys.avatarGender.rawValue) as? String ?? "")
//                    userVO?.avatar_gender = manageObject.value(forKeyPath: ServiceParsingKeys.avtar_gender.rawValue) as? String ?? ""
                    userVO?.avatar_gender = manageObject.value(forKeyPath: ServiceParsingKeys.avatarGender.rawValue) as? String ?? ""
                }
                return userVO
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
        return nil
    }
    
    func getUnDownloadedAvatarVariationList() -> [AvatarModel] {
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: DatabaseEntity.AvatarVariation.rawValue)
        var list = [AvatarModel]()
        fetchRequest.predicate = NSPredicate(format: "isDownloaded == false")

        do {
            let manageObjectContext = try databaseContext.fetch(fetchRequest)
            if (manageObjectContext.count) > 0 {
                for manageObject in manageObjectContext {
                    var av = AvatarModel.init()
                    av.avtar_id = manageObject.value(forKeyPath: ServiceParsingKeys.avtar_id.rawValue) as? String ?? ""
                    av.file = manageObject.value(forKeyPath: ServiceParsingKeys.file.rawValue) as? String ?? ""
                    av.file_type = manageObject.value(forKeyPath: ServiceParsingKeys.file_type.rawValue) as? String ?? ""
                    av.id = manageObject.value(forKeyPath: ServiceParsingKeys.normalId.rawValue) as? String ?? ""
                    av.isDownloaded = manageObject.value(forKeyPath: ServiceParsingKeys.isDownloaded.rawValue) as? Bool ?? false
                    av.variation_type = manageObject.value(forKeyPath: ServiceParsingKeys.variation_type.rawValue) as? String ?? ""
                   list.append(av)
                }
                return list
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
        return []
    }
    
    
    func getAvatarVariationOfType(variationType:String) -> AvatarModel? {
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: DatabaseEntity.AvatarVariation.rawValue)
        fetchRequest.predicate = NSPredicate(format: "variation_type == %@", variationType)

        do {
            let manageObjectContext = try databaseContext.fetch(fetchRequest)
            if (manageObjectContext.count) > 0 {
                for manageObject in manageObjectContext {
                    var av = AvatarModel.init()
                    av.avtar_id = manageObject.value(forKeyPath: ServiceParsingKeys.avtar_id.rawValue) as? String ?? ""
                    av.file = manageObject.value(forKeyPath: ServiceParsingKeys.file.rawValue) as? String ?? ""
                    av.file_type = manageObject.value(forKeyPath: ServiceParsingKeys.file_type.rawValue) as? String ?? ""
                    av.id = manageObject.value(forKeyPath: ServiceParsingKeys.normalId.rawValue) as? String ?? ""
                    av.isDownloaded = manageObject.value(forKeyPath: ServiceParsingKeys.isDownloaded.rawValue) as? Bool ?? false
                    av.variation_type = manageObject.value(forKeyPath: ServiceParsingKeys.variation_type.rawValue) as? String ?? ""
                    return av
                }
                return nil
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
        
        return nil
    }

    func updateDownloadStatusOfAvatarVariation(variationType:String,status:Bool)  {
        let fetchRequest =
                 NSFetchRequest<NSManagedObject>(entityName: DatabaseEntity.AvatarVariation.rawValue)
        fetchRequest.predicate = NSPredicate(format: "variation_type == %@", variationType)
       do {
            let manageObjectContext = try databaseContext.fetch(fetchRequest)
            if (manageObjectContext.count) > 0 {
                var managedObject = manageObjectContext[0]
                managedObject.setValue(status, forKey: "isDownloaded")
                self.saveContext()
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }

}
