//
//  DamdaData.swift
//  DamdaCam
//
//  Created by Yebin Kim on 2020/02/03.
//  Copyright © 2020 김예빈. All rights reserved.
//

import UIKit
import CoreData

final class DamdaData {
    
    static let shared = DamdaData()
    
    lazy var context = self.persistentContainer.viewContext
//    private lazy var context = self.persistentContainer.viewContext
    
    var customPaletteArray: [UIColor]? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CustomPalette")
        var customPaletteRecords = [NSManagedObject]()
        var customPaletteArray = [UIColor]()
        
        do {
            customPaletteRecords = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        for index in 0 ..< customPaletteRecords.count {
            let customPalette = customPaletteRecords[index]
            
            guard let hex = customPalette.value(forKey: "colorHex") as? String, let hexToColor = UIColor(hex: hex) else { return nil }
            customPaletteArray.append(hexToColor)
        }
        
        return customPaletteArray
    }
    
    var makingARArray: [UIImage]? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MakingARData")
        var makingARRecords = [NSManagedObject]()
        var makingARArray = [UIImage]()
        
        do {
            makingARRecords = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        for index in 0 ..< makingARRecords.count {
            let makingARRecord = makingARRecords[index]
            
            guard let fileName = makingARRecord.value(forKey: "idString") as? String,
                  let image = loadImageFromDiskWith(fileName: fileName) else { return nil }
            makingARArray.append(image)
        }
        
        return makingARArray
    }
    
//    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MakingARData")
//
//    do {
//        localRecords = try context.fetch(fetchRequest)
//    } catch let error as NSError {
//        print("Could not fetch. \(error), \(error.userInfo)")
//    }
//
//    for index in 0 ..< localRecords.count {
//        let localRecord = localRecords[index]
//        FaceARMotionArray.append(MakingARInstance.loadImageFromDiskWith(fileName: localRecord.value(forKey: "idString") as! String)!)
//    }
//
//    AllARMotionArray = FaceARMotionArray + BGARMotionArray
    
    private func loadImageFromDiskWith(fileName: String) -> UIImage? {
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        
        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            let image = UIImage(contentsOfFile: imageUrl.path)
            return image
        }
        
        return nil
    }
    
    // MARK: - Core Data stack
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DamdaCamCoreData")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
