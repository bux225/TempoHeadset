//
//  AlamofireController.swift
//  TempoHeadset
//
//  Created by Soltis, Matthew on 2/5/19.
//  Copyright © 2019 Soltis, Matthew. All rights reserved.
//

import Foundation
import Alamofire

class AlamoFireController {
    func getKeys(room: String, completionHandler: @escaping (String, String, String, Error?) -> ()) {
        let serverURL:String = "http://pure-coast-92727.herokuapp.com"
        var url:String = ""
        if let urlRoom = room.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            url = serverURL + "/room/:" + urlRoom
        }
        
        Alamofire.request(url)
            .responseJSON { response in
                // check for errors
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET on " + url)
                    print(response.result.error!)
                    return
                }
                // make sure we got some JSON since that's what we expect
                guard let json = response.result.value as? [String: Any] else {
                    print("didn't get object as JSON from API")
                    if let error = response.result.error {
                        print("Error: \(error)")
                    }
                    return
                }
                // parse json for keys
                guard let apiKey = json["apiKey"] as! String? else {
                    print("Could not get apiKey from JSON")
                    return
                }
                guard let sessionId = json["sessionId"] as! String? else {
                    print("Could not get sessionId from JSON")
                    return
                }
                guard let token = json["token"] as! String? else {
                    print("Could not get token from JSON")
                    return
                }
                completionHandler(apiKey, sessionId, token, nil)
                
        }// end Alamofire request
    }// end func getKeys
}
