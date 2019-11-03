//
//  ViewController.swift
//  Venzini
//
//  Created by Yoel K on 11/2/19.
//  Copyright © 2019 Yoel K. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        
    }
    
    let getUrlString = "http://10.198.55.184:3000/server/route"
    
    let handlerBlock: (URLRequest) -> Void = { request in
        let timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(notify), userInfo: nil, repeats: false)
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {                                              // check for fundamental networking error
                print("error", error ?? "Unknown error")
                return
            }

            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)!
            print(responseString)

             //here dataResponse received from a network request
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject] else { return }
            guard let url = URL(string: (json["maplink"] as? String)!) else { return }
            
            // open google maps link and demo notification
            DispatchQueue.main.async {
                UIApplication.shared.open(url)
                timer.fire()
            }
            
        }.resume()
    }
    
    @IBOutlet var destinationEntry: UITextField!
    
    @IBAction func goButtonPressed(_ sender: Any) {
        let parameters = destinationEntry.text!.replacingOccurrences(of: " ", with: "+")
        let putUrlString = "http://10.198.55.184:3000/server/destination/\(parameters)"
        
        let putUrl = URL(string: putUrlString)!
        let getUrl = URL(string: getUrlString)!
        
        var putRequest = URLRequest(url: putUrl)
        putRequest.httpMethod = "PUT"
        
        var getRequest = URLRequest(url: getUrl)
        getRequest.httpMethod = "GET"
        
        putDestination(putRequest: putRequest, getRequest: getRequest, callback: handlerBlock)
    }
    
    func putDestination(putRequest: URLRequest, getRequest: URLRequest, callback: @escaping (URLRequest) -> Void) {
        print(putRequest)
        
        URLSession.shared.dataTask(with: putRequest) { data, response, error in
            guard let _ = data,
                let response = response as? HTTPURLResponse,
                error == nil else {                                              // check for fundamental networking error
                print("error", error ?? "Unknown error")
                return
            }

            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            
            callback(getRequest) // callback to handlerBlock
        }.resume()
        
    }
    
    @objc func notify() -> Void {
        let content = UNMutableNotificationContent()
        content.title = "Your smartcar is running low on charge!";
        content.body = "Tap to add a charging station to your route"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: "timeDone", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func openMapsWithStop() {
        let batteryUrlString = "http://10.198.55.184:3000/server/batteryreroll"
        let batteryUrl = URL(string: batteryUrlString)!
        var batteryRequest = URLRequest(url: batteryUrl)
        batteryRequest.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: batteryRequest) { data, response, error in
            guard let _ = data,
                let response = response as? HTTPURLResponse,
                error == nil else {                                              // check for fundamental networking error
                print("error", error ?? "Unknown error")
                return
            }

            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            
            self.handlerBlock(URLRequest(url: URL(string: self.getUrlString)!))
            
        }.resume()
    }
}
