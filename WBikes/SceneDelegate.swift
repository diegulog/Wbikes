//
//  SceneDelegate.swift
//  WBikes
//
//  Created by Diego on 14/10/2020.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    let dataController = DataController(modelName: "WBikes")
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        dataController.load()
        
        if let city = getCity() {
            let tabBarController = window?.rootViewController as! TabBarViewController
            tabBarController.dataController = dataController
            tabBarController.city = city
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let cityViewController = storyboard.instantiateViewController(withIdentifier: "CityNavegationViewController") as! UINavigationController
            self.window?.rootViewController = cityViewController
        }
        
    }
    fileprivate func getCity() -> City? {
        if let id = UserDefaults.standard.string(forKey: Constants.idCity.rawValue) {
            let fetchRequest: NSFetchRequest<City> = City.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "createDate", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            if let result = try? dataController.viewContext.fetch(fetchRequest).first {
                return result
            }
        }
        return nil
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        saveViewContext()
    }
    
    func saveViewContext(){
        if dataController.viewContext.hasChanges {
            try? dataController.viewContext.save()
        }
    }
    
}

