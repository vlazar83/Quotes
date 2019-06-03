//
//  ViewController.swift
//  Quotes
//
//  Created by Lazar, Viktor on 2019. 01. 07..
//  Copyright © 2019. Lazar, Viktor. All rights reserved.
//

import UIKit
import UserNotifications
import SafariServices

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    @IBOutlet weak var trailingC: NSLayoutConstraint!
    @IBOutlet weak var leadingC: NSLayoutConstraint!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var quoteDetailsTextView: UITextView!
    
    var isMenuIsVisible = false
    var isQuoteAvailable = false
    
    var backupURL = "https://theysaidso.com/img/bgs/man_on_the_mountain.jpg"
    let localJSONFile = Bundle.main.path(forResource:"input_JSON", ofType: "txt")
    
    var quoteURL :URL! = URL(string:"https://quotes.rest/qod")
    
    var jsonString = ""
    
    var jsonData : TheQuoteFromJSON?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if !isQuoteAvailable {
            if let url = URL(string: backupURL) {
                backgroundImageView.contentMode = .scaleAspectFit
                downloadImage(from: url)
            }
            print("The image will continue downloading in the background and it will be loaded when it ends.")
        }
        
        getFreshQuoteButtonTapped(self)
        
        displayTheQuoteAndAuthor()
        
        // 1. create a gesture recognizer (tap gesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        
        // 2. add the gesture recognizer to a view
        mainView.addGestureRecognizer(tapGesture)

        UNUserNotificationCenter.current().delegate = self
        
        
    }

    @IBAction func whoIsThisPersonButtonTapped(_ sender: Any) {
        
        let author = jsonData?.contents.quotes[0].author

        let path = "https://www.google.com/search?q=" + author!.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        let url = NSURL(string: path)
        let svc = SFSafariViewController(url: url! as URL)
        present(svc, animated: true, completion: nil)
        
        /*
         if #available(iOS 10.0, *) {
         UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
         } else {
         UIApplication.shared.openURL(url! as URL)
         }
         */
    }
    
// MARK: Button methods
    @IBAction func getFreshQuoteButtonTapped(_ sender: Any) {
        
        // just to use the locally donwloaded JSON
        if localJSONFile != nil{
            loadAndParseJSONFile()
        } else {
            downloadQuoteDataInJSONFormat(from:quoteURL)
            displayTheQuoteAndAuthor()
        }
        
    }
    
    @IBAction func settingsButtonTapped(_ sender: Any) {
        
        moveSettingsWindow()
        if(notificationSwitch.isOn){
            configureNotification()
        }
        
    }
    
// MARK: Utility methods
    @objc func handleTap(sender: UITapGestureRecognizer) {
        print("tap")
        if isMenuIsVisible {
            moveSettingsWindow()
        } else {
            
        }
        
    }
    
    func displayTheQuoteAndAuthor() {
        let author = jsonData?.contents.quotes[0].author
        let theQuote = jsonData?.contents.quotes[0].quote
        
        if(theQuote != "" && author != ""){
            quoteDetailsTextView.text = "\"" + theQuote! + "\""
            quoteDetailsTextView.text = quoteDetailsTextView.text + "\n\n\n\n\n" + "by: " + author!
        }
    }
    
    func configureNotification() {
        let centre = UNUserNotificationCenter.current()
        centre.requestAuthorization(options: [.alert, .sound, .badge]) { // 2
            granted, error in
            print("Permission granted: \(granted)")
        }
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "This is the title", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "The message body goes here.", arguments: nil)
        content.categoryIdentifier = "Category"
        // Deliver the notification in five seconds.
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        // Schedule the notification.
        let request = UNNotificationRequest(identifier: "FiveSecond", content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        
        let completeAction = UNNotificationAction.init(identifier: "Complete", title: "Complete", options: UNNotificationActionOptions())
        let editAction = UNNotificationAction.init(identifier: "Edit", title: "Edit", options: UNNotificationActionOptions.foreground)
        let deleteAction = UNNotificationAction.init(identifier: "Delete", title: "Delete", options: UNNotificationActionOptions.destructive)
        let categories = UNNotificationCategory.init(identifier: "Category", actions: [completeAction, editAction, deleteAction], intentIdentifiers: [], options: [])
        
        centre.setNotificationCategories([categories])
        
        center.add(request, withCompletionHandler: nil)
        /*
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Wake up!", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "Rise and shine! It's morning time!", arguments: nil)
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "MorningAlarm", content: content, trigger: trigger)
        
        // Schedule the request.
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
        */
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Test: \(response.notification.request.identifier)")
        switch response.actionIdentifier {
        case "Complete":
            print("Complete")
            completionHandler()
        case "Edit":
            print("Edit")
            completionHandler()
        case "Delete":
            print("Delete")
            completionHandler()
        default:
            completionHandler()
        }
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Test Foreground: \(notification.request.identifier)")
        completionHandler([.alert, .sound])
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func loadAndParseJSONFile() {
        do {
            let jsonFileContent = try String(contentsOf: NSURL(fileURLWithPath:localJSONFile!) as URL, encoding: .utf8)
            //self.quoteDetailsTextView.text = jsonFileContent

            let jsonFileContentData: Data = jsonFileContent.data(using: .utf8)!
            do {
                jsonData = try JSONDecoder().decode(TheQuoteFromJSON.self, from: jsonFileContentData)
            } catch{
                print("Error: Couldn't decode data into Quote")
            }
        } catch{
            print("Error: Couldn't decode data into Quote")
        }
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.backgroundImageView.image = UIImage(data: data)
            }
        }
    }
    
    func downloadQuoteDataInJSONFormat(from url: URL) {
        print("Quote Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Quote Download Finished")
            self.jsonString = (String(data: data, encoding: String.Encoding.utf8))!
        }
    }
    
    func moveSettingsWindow() {
        if !isMenuIsVisible {
            leadingC.constant = 170
            trailingC.constant = 0
            
            isMenuIsVisible = true
        } else {
            leadingC.constant = 0
            trailingC.constant = 0
            
            isMenuIsVisible = false
            
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations:{
            self.view.layoutIfNeeded()
        })
    }
    
// MARK: Quote Structure
    struct Quote: Decodable {
        let quote: String?
        let author: String?
        let tags: [String]
        let category: String
        let title: String
        let date: String
        let id: String
    }
    
    struct Contents: Decodable {
        let quotes: [Quote]
        let copyright: String
    }
    
    struct TheQuoteFromJSON: Decodable {
        let success: Success
        let contents: Contents
    }
    
    struct Success: Decodable {
        let total: Int
    }

}

