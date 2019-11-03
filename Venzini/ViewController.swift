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
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet var destinationEntry: UITextField!
    
    @IBAction func goButtonPressed(_ sender: Any) {
        let parameters = destinationEntry.text!.replacingOccurrences(of: " ", with: "+")
        let putUrlString = "http://10.198.55.184:3000/server/destination/\(parameters)"
        let getUrlString = "http://10.198.55.184:3000/server/route"
        
        let putUrl = URL(string: putUrlString)! //change the url
        let getUrl = URL(string: getUrlString)!
        
        //now create the URLRequest object using the url object
        var putRequest = URLRequest(url: putUrl)
        putRequest.httpMethod = "PUT"
        
        var getRequest = URLRequest(url: getUrl)
        getRequest.httpMethod = "GET"
        
        let handlerBlock: (URLRequest) -> Void = { request in
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
                DispatchQueue.main.async {
                    UIApplication.shared.open(url)
                }
            }.resume()
        }
        
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
            
            callback(getRequest)
        }.resume()
        
    }
}
