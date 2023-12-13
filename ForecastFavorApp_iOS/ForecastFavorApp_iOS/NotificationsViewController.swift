//
//  NotificationsViewController.swift
//  ForecastFavorApp_iOS
//
//  Created by Sreenath Segar on 2023-12-06.
//

import UIKit
import CoreData

class NotificationsViewController: UIViewController {
    @IBOutlet weak var stormSwitch: UISwitch!
    @IBOutlet weak var sunnySwitch: UISwitch!
    @IBOutlet weak var rainySwitch: UISwitch!
    @IBOutlet weak var snowySwitch: UISwitch!
    @IBOutlet weak var cloudySwitch: UISwitch!
    
    // Reference to the managed object context
        var managedObjectContext: NSManagedObjectContext!

    
    override func viewDidLoad() {
           super.viewDidLoad()

           // Access the managed object context from the app delegate
           let appDelegate = UIApplication.shared.delegate as! AppDelegate
           managedObjectContext = appDelegate.persistentContainer.viewContext
           
           // Load switch states from Core Data
           loadSwitchStates()
       }
    // Load switch states from Core Data
        func loadSwitchStates() {
            // Fetch the user preferences entity (replace "UserPreference" with your entity name)
            let fetchRequest = NSFetchRequest<UserPreference>(entityName: "UserPreference")
            
            do {
                let userPreferences = try managedObjectContext.fetch(fetchRequest)
                
                if let userPreference = userPreferences.first {
                    stormSwitch.isOn = userPreference.isStormEnabled
                    sunnySwitch.isOn = userPreference.isSunnyEnabled
                    rainySwitch.isOn = userPreference.isRainyEnabled
                    snowySwitch.isOn = userPreference.isSnowyEnabled
                    cloudySwitch.isOn = userPreference.isCloudyEnabled
                }
            } catch {
                print("Error fetching user preferences: \(error.localizedDescription)")
            }
        }
        
        // Save switch states to Core Data
        func saveSwitchStates() {
            // Fetch the user preferences entity (replace "UserPreference" with your entity name)
            let fetchRequest = NSFetchRequest<UserPreference>(entityName: "UserPreference")
            
            do {
                let userPreferences = try managedObjectContext.fetch(fetchRequest)
                
                if let userPreference = userPreferences.last {
                    userPreference.isStormEnabled = stormSwitch.isOn
                    userPreference.isSunnyEnabled = sunnySwitch.isOn
                    userPreference.isRainyEnabled = rainySwitch.isOn
                    userPreference.isSnowyEnabled = snowySwitch.isOn
                    userPreference.isCloudyEnabled = cloudySwitch.isOn
                    
                    try managedObjectContext.save()
                }
            } catch {
                print("Error fetching user preferences: \(error.localizedDescription)")
            }
        }
        
    
    @IBAction func stormSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            if let currentConditionText = WeatherDataManager.shared.currentConditionText,
               currentConditionText.range(of: "storm", options: .caseInsensitive) != nil {
                stormNotification()
            }
        } else {
            stormCancelNotification()
        }
    }
    @IBAction func sunnySwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            if let currentConditionText = WeatherDataManager.shared.currentConditionText,
               currentConditionText.range(of: "sun", options: .caseInsensitive) != nil {
                sunnyNotification()
            }
        } else {
            sunnyCancelNotification()        }
    }
    @IBAction func rainySwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            if let currentConditionText = WeatherDataManager.shared.currentConditionText,
               currentConditionText.range(of: "rain", options: .caseInsensitive) != nil {
                rainyNotification()
            }
        } else {
            rainyCancelNotification()
        }
    }
    @IBAction func snowySwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            if let currentConditionText = WeatherDataManager.shared.currentConditionText,
               currentConditionText.range(of: "snow", options: .caseInsensitive) != nil {
                snowyNotification()
            }
        } else {
            snowyCancelNotification()
        }
    }
    @IBAction func cloudySwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            if let currentConditionText = WeatherDataManager.shared.currentConditionText {
                let conditionsToCheck = ["cloud", "clear", "overcast", "fog"]
                
                for condition in conditionsToCheck {
                    if currentConditionText.range(of: condition, options: .caseInsensitive) != nil {
                        cloudyNotification()
                        return
                    }
                }
            }
        } else {
            cloudyCancelNotification()
        }
    }
    
    func stormNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Storm Brewing!"
        content.body = "Best to stay indoors today. It's a great opportunity to catch up on a book or binge-watch your favorite show."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: true)
        let request = UNNotificationRequest(identifier: "storm", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func stormCancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["storm"])
    }
    func sunnyNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Glorious Sunshine Awaits!"
        content.body = "It's a perfect day for a picnic or a leisurely walk in the park. Don't forget your sunscreen!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: true)
        let request = UNNotificationRequest(identifier: "sunny", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func sunnyCancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["sunny"])
    }
    func rainyNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Rainy Day Alert!"
        content.body = "It looks like it's time to grab your umbrella. A cozy coffee shop visit might be just the thing!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: true)
        let request = UNNotificationRequest(identifier: "rainy", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func rainyCancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["rainy"])
    }
    func snowyNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Snowflakes Are Falling!"
        content.body = "The world is your snow globe! A good day for building a snowman or enjoying hot chocolate by the fire."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: true)
        let request = UNNotificationRequest(identifier: "snowy", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func snowyCancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["snowy"])
    }
    func cloudyNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Overcast Skies Today"
        content.body = "A moody sky sets the stage. Perfect for a trip to the museum or a relaxed day at home."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: true)
        let request = UNNotificationRequest(identifier: "cloudy", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func cloudyCancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["cloudy"])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Call the method to save switch states
        saveSwitchStates()
    }

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
