//
//  ViewController.swift
//  LocalNotifications
//
//  Created by Владимир Тимофеев on 10.02.2022.
//

import UserNotifications
import UIKit

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    @IBOutlet var button: UIButton!
    
    var granted = false
    var started = false
    
    @IBAction func startTapped(_ sender: UIButton) {
        registerLocal()
        if !started && granted {
            scheduleLocal()
            changeButtonState(true)
        } else {
            cancelSchedule()
            changeButtonState(false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeButtonState(false)
    }

    func changeButtonState(_ condition: Bool) {
        var configuration = button.configuration
        if condition {
            configuration?.title = "CANCEL"
            configuration?.baseBackgroundColor = .systemRed
        } else {
            configuration?.title = "START"
            configuration?.baseBackgroundColor = .systemGreen
        }
        button.configuration = configuration
    }
    func registerLocal() {
        granted = true
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Granted")
            } else {
                print("Not granted")
            }
        }
    }
    
    func scheduleLocal() {
        started = true
        registerCategories()
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Time to stand!"
        content.body = "Warm up, make a coffee etc. Mr. Fletcher."
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 11
        dateComponents.minute = 47
        //let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 6, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func cancelSchedule() {
        started = false
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let show = UNNotificationAction(identifier: "show", title: "Tell me more", options: .foreground)
        let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [])
        center.setNotificationCategories([category])
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let customData = userInfo["customData"] as? String {
            print("Custom data received: \(customData)")
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                print("Default identifier")
            case "show":
                print("Show more")
            default:
                break
            }
        }
        
        completionHandler()
    }
}

