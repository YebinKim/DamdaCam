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
        
        // FIXME: String 관리 효율화 필요
        var FaceARMotionArray = [UIImage(named: "FaceAR_Heart")!, UIImage(named: "FaceAR_Angel")!, UIImage(named: "FaceAR_Rabbit")!, UIImage(named: "FaceAR_Cat")!, UIImage(named: "FaceAR_Mouse")!, UIImage(named: "FaceAR_Peach")!, UIImage(named: "FaceAR_BAAAM")!, UIImage(named: "FaceAR_Mushroom")!, UIImage(named: "FaceAR_Doughnut")!, UIImage(named: "FaceAR_Flower")!]
        
        let BGARMotionArray = [UIImage(named: "BGAR_Snow")!, UIImage(named: "BGAR_Blossom")!, UIImage(named: "BGAR_Rain")!, UIImage(named: "BGAR_Fish")!, UIImage(named: "BGAR_Greenery")!, UIImage(named: "BGAR_Fruits")!, UIImage(named: "BGAR_Glow")!]
        
        do {
            makingARRecords = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        for index in 0 ..< makingARRecords.count {
            let makingARRecord = makingARRecords[index]
            
            guard let fileName = makingARRecord.value(forKey: "idString") as? String,
                  let image = loadImageFromDiskWith(fileName: fileName) else { return nil }
            FaceARMotionArray.append(image)
        }
        
        makingARArray = FaceARMotionArray + BGARMotionArray
        
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
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
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
