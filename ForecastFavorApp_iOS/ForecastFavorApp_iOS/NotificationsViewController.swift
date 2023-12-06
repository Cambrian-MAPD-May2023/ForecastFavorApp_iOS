//
//  NotificationsViewController.swift
//  ForecastFavorApp_iOS
//
//  Created by Sreenath Segar on 2023-12-06.
//

import UIKit

class NotificationsViewController: UIViewController {
    @IBOutlet weak var stormSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func stormSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
               scheduleNotification()
           } else {
               cancelNotification()
           }
    }
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Storm Brewing!"
        content.body = "Best to stay indoors today. It's a great opportunity to catch up on a book or binge-watch your favorite show."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        let request = UNNotificationRequest(identifier: "storm", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }

    func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["uniqueIdentifier"])
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
