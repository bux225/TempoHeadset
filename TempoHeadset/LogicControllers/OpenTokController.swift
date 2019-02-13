//
//  OpenTokController.swift
//  TempoHeadset
//
//  Created by Soltis, Matthew on 2/5/19.
//  Copyright © 2019 Soltis, Matthew. All rights reserved.
//

import Foundation
import OpenTok

struct SessionSignal : Codable {
    var userName:String
    var channel:Int
    var streamId:String
}

class OpenTokController: NSObject {
    fileprivate var alamofireController = AlamoFireController()
    var userName = ""
    weak var delegate: OpenTokDelegate?
    var session: OTSession?
    lazy var publisher: OTPublisher = {
        let settings = OTPublisherSettings()
        settings.videoTrack = false
        settings.name = userName
        //settings.name = "phone"
        return OTPublisher(delegate: self, settings: settings)!
    }()
    var error: OTError?
    var myStreamId:String = ""
    //var userName = ""
    var currentChannel:Int = -1
    var signals = [SessionSignal]() {
        didSet {
            sendUsersOnMyChannel(fullList: signals)
        }
    }
    
    
    func connectToSession(teamName: String) {
        print("opentok connectToSession")
       if let getName = UserDefaults.standard.object(forKey: "userName") as? String {
            userName = getName
        } else {
            userName = "Undefined"
        }
        alamofireController.getKeys(room: teamName) { apiKey, sessionId, token, error in
            self.session = OTSession(apiKey: apiKey, sessionId: sessionId, delegate: self)
            self.session?.connect(withToken: token, error: &self.error)
        }
    }
    
    func switchChannels(channel:Int) {
        doSignal(type: "Normal", channel: channel)
        let oldChannel = currentChannel
        currentChannel = channel
        doCheckSubscriptions(oldChannel: oldChannel, newChannel: currentChannel)
    }
    
    func doCheckSubscriptions(oldChannel:Int, newChannel:Int) {
        let newSubscriptions = signals.filter({$0.channel == newChannel})
        if newSubscriptions.count > 0{
            for subscription in newSubscriptions {
                if subscription.streamId != myStreamId {
                    doSubscribe(to: (session?.streams[subscription.streamId])!)
                }
            }
        }
        let oldSubscriptions = signals.filter({$0.channel == oldChannel})
        if oldSubscriptions.count > 0 {
            for subscription in oldSubscriptions {
                if subscription.streamId != myStreamId {
                    doUnubscribe(from: (session?.streams[subscription.streamId])!)
                }
            }
        }
    }
    
    func doSubscribe(to stream: OTStream) {
        print("doSubscribe")
        if let subscriber = OTSubscriber(stream: stream, delegate: self) {
            session?.subscribe(subscriber, error: &error)
            print("subscribed to: \(String(describing: subscriber.stream?.streamId))")
        }
    }
    
    func doUnubscribe(from stream: OTStream) {
        print("doUnsubscribe")
        if let subscriber = OTSubscriber(stream: stream, delegate: self) {
            session?.unsubscribe(subscriber, error: &error)
            print("unsubscribed to: \(String(describing: subscriber.stream?.streamId))")
        }
    }
    
    func doSignal(type: String, channel: Int) {
        let signal = SessionSignal(userName: userName, channel: channel, streamId: myStreamId)
        let signalString = toJSON(dataStruct: signal)
        session?.signal(withType: type, string: signalString, connection: nil, error: &error)
    }
    
    func sendUsersOnMyChannel(fullList:[SessionSignal]) {
        var usersOnMyChannel = [String]()
        
        usersOnMyChannel = fullList.filter({$0.channel == currentChannel}).map({$0.userName})
        delegate?.usersChanged(usersOnMyChannel)
    }
    
    
    //MARK: - Utility Functions
    func toJSON(dataStruct:SessionSignal) -> String {
        do {
            let jsonData = try JSONEncoder().encode(dataStruct)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            } else {
                return ""
            }
        } catch {
            return ""
        }
    }
    
    func fromJSON(jsonString:String) -> SessionSignal {
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                let stream = try JSONDecoder().decode(SessionSignal.self, from: jsonData)
                return stream
            } catch {
                return SessionSignal(userName: "", channel: -1, streamId: "")
            }
        } else {
            return SessionSignal(userName: "", channel: -1, streamId: "")
        }
    }
    
}

// MARK: - OTSession delegate callbacks
extension OpenTokController: OTSessionDelegate {
    func sessionDidConnect(_ session: OTSession) {
        print("sessionDidConnect")
        session.publish(publisher, error: &error)
    }
    
    func session(_ session: OTSession, receivedSignalType type: String?, from connection: OTConnection?, with string: String?) {
        print("Received signal: " + string!)
        let signal = fromJSON(jsonString: string!)
        //Don't do anything if the signal came from me
        if signal.streamId != myStreamId {
            print("signal.streamId: " + signal.streamId)
            print("myStreamId: " + myStreamId)
            //Subscribe if a user signaled that they've joined my channel
            if signal.channel == currentChannel {
                doSubscribe(to: session.streams[signal.streamId]!)
            } else {
                //Unsubscribe if a user signaled and they've left my channel
                if let index = signals.firstIndex(where: {$0.streamId == signal.streamId}) {
                    if signals[index].channel == currentChannel {
                        doUnubscribe(from: session.streams[signal.streamId]!)
                    }
                }
            }
        }
        //Add or update the user that signaled in users list
        if let index = signals.firstIndex(where: {$0.streamId == signal.streamId}) {
            signals[index] = signal
        } else {
            signals.append(signal)
        }
        //If there's a first time signal, send one of your own to let the new person subscribe possibly
        if type == "First" {
            doSignal(type: "Normal", channel: currentChannel)
        }
    } // end session-receivedSignalType
    
    func sessionDidDisconnect(_ session: OTSession) {
        print("sessionDidDisconnect")
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("sessionDidFailWithError")
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("Session streamCreated: \(stream.name!)")
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("Session streamDestroyed: " + stream.name!)
        if let index = signals.firstIndex(where: {$0.streamId == stream.streamId}) {
            signals.remove(at: index)
        }
    }
}

// MARK: - OTPublisher delegate callbacks
extension OpenTokController: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
        print("publisher streamCreated: \(stream.name!)")
        myStreamId = stream.streamId
        //Send a first time signal so that people know you're new to the session
        doSignal(type: "First", channel: currentChannel)
        delegate?.didPublish(myStreamId)
    }
    
    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        print("publisher streamDestroyed")
    }
    
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("Publisher failed: \(error.localizedDescription)")
    }
}

// MARK: - OTSubscriber delegate callbacks
extension OpenTokController: OTSubscriberDelegate {
    func subscriberDidConnect(toStream subscriberKit: OTSubscriberKit) {
        print("subscriberDidConnect")
        print(NSDate().timeIntervalSince1970)
    }
    
    func subscriberDidDisconnect(fromStream subscriber: OTSubscriberKit) {
        print("subscriberDidDisconnect")
    }
    
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("Subscriber didFailWithError: \(error.localizedDescription)")
    }
}
