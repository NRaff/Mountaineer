//
//  SessionClass.swift
//  Mountaineer
//
//  Created by Nick Raff on 4/11/16.
//  Copyright © 2016 Nick Raff. All rights reserved.
//

import Foundation
import Firebase

struct Session {
    let sessionID: String!
    let sessionTitle: String!
    let sessionTime: String!
    let thisSessionUnits: Bool!
    let averageSpeed: Double!
    let dateCreated: String!
    let imageID: Int!
    let topSpeed: Double!
    let peakAltitude: Double!
    let totalDistance: Double!
    let ref: Firebase?
    
    
    init(sessionID: String = "", sessionTitle: String, sessionTime: String, thisSessionUnits: Bool, averageSpeed: Double, dateCreated: String, imageID: Int, topSpeed: Double, peakAltitude: Double, totalDistance: Double){
        self.sessionID = sessionID
        self.sessionTitle = sessionTitle
        self.sessionTime = sessionTime
        self.thisSessionUnits = thisSessionUnits
        self.averageSpeed = averageSpeed
        self.dateCreated = dateCreated
        self.imageID = imageID
        self.topSpeed = topSpeed
        self.peakAltitude = peakAltitude
        self.totalDistance = totalDistance
        self.ref = nil
    }
    
    init(snapshot: FDataSnapshot) {
        sessionID = snapshot.key
        sessionTitle = snapshot.value["sessionTitle"] as! String
        sessionTime = snapshot.value["sessionTime"] as! String
        thisSessionUnits = snapshot.value["thisSessionUnits"] as! Bool
        averageSpeed = snapshot.value["averageSpeed"] as! Double
        dateCreated = snapshot.value["dateCreated"] as! String
        imageID = snapshot.value["imageID"] as! Int
        topSpeed = snapshot.value["topSpeed"] as! Double
        peakAltitude = snapshot.value["peakAltitude"] as! Double
        totalDistance = snapshot.value["totalDistance"] as! Double
        ref = snapshot.ref
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "sessionID": sessionID,
            "sessionTitle": sessionTitle,
            "sessionTime": sessionTime,
            "thisSessionUnits": thisSessionUnits,
            "averageSpeed": averageSpeed,
            "dateCreated": dateCreated,
            "imageID": imageID,
            "topSpeed": topSpeed,
            "peakAltitude": peakAltitude,
            "totalDistance": totalDistance
        ]
    }
    
}