//
//  RootViewController.swift
//  Local Notifications
//
//  Created by Tiago Santos on 14/02/18.
//  Copyright © 2018 Tiago Santos. All rights reserved.
//

import UIKit
import UserNotifications

class RootViewController: UIViewController {
    
    
    struct Notification {
        
        struct Category {
            static let tutorial = "tutorial"
        }
        
        struct Action {
            static let readLater = "readLater"
            static let showDetails = "showDetails"
            static let unsubscribe = "unsubscribe"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUserNotificationsCenter()
    }
    
    private func configureUserNotificationsCenter() {
        // Configure User Notification Center
        UNUserNotificationCenter.current().delegate = self
        
        // Define Actions
        let actionReadLater = UNNotificationAction(identifier: Notification.Action.readLater, title: "Read Later", options: [])
        let actionShowDetails = UNNotificationAction(identifier: Notification.Action.showDetails, title: "Show Details", options: [.foreground])
        let actionUnsubscribe = UNNotificationAction(identifier: Notification.Action.unsubscribe, title: "Unsubscribe", options: [.destructive, .authenticationRequired])
        
        // Define Category
        let tutorialCategory = UNNotificationCategory(identifier: Notification.Category.tutorial, actions: [actionReadLater, actionShowDetails, actionUnsubscribe], intentIdentifiers: [], options: [])
        
        // Register Category
        UNUserNotificationCenter.current().setNotificationCategories([tutorialCategory])
        
    }
    
    // MARK: - Private Methods
    
    private func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
        // Request Authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            
            completionHandler(success)
        }
    }
    
    @IBAction func didTapButton(_ sender: Any) {
        // Request Notification Settings
        
        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
            switch notificationSettings.authorizationStatus {
            case .notDetermined:
                // Request Authorization
                self.requestAuthorization(completionHandler: { (success) in
                    guard success else { return }
                    
                    self.scheduleLocalNotification()
                })
            case .authorized:
                // Schedule Local Notification
                self.scheduleLocalNotification()
            case .denied:
                print("Application Not Allowed To Display Local Notifications")
            }
        }
    }
    
    private func scheduleLocalNotification() {
        // Create Notification Content
        let notificationContent = UNMutableNotificationContent()
        
        // Configure Notification Content
        notificationContent.title = "Local Notifications"
        notificationContent.subtitle = "Local Notifications"
        notificationContent.body = "Hello. This is a notification."
        notificationContent.categoryIdentifier = Notification.Category.tutorial
        
        // Add Trigger
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5.0, repeats: false)
        
        // Create Notification Request
        let notificationRequest = UNNotificationRequest(identifier: "local_notification", content: notificationContent, trigger: notificationTrigger)
        
        // Add Request to User Notification Center
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
        }
    }
}

extension RootViewController: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case Notification.Action.readLater:
            print("Save Tutorial For Later")
        case Notification.Action.unsubscribe:
            print("Unsubscribe Reader")
        default:
            print("Other Action")
        }
        
        completionHandler()
    }
}
