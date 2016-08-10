//
//  SessionClass.swift
//  Mountaineer
//
//  Created by Nick Raff on 4/11/16.
//  Copyright © 2016 Nick Raff. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

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
//    let timeSeconds: Int!
//    let timeMinutes: Int!
//    let timeHours: Int!
//    let averageSpeedArray: [CLLocationSpeed]!
    let ref: Firebase?
    
    
    init(sessionID: String = "", sessionTitle: String, sessionTime: String, thisSessionUnits: Bool, averageSpeed: Double, dateCreated: String, imageID: Int, topSpeed: Double, peakAltitude: Double, totalDistance: Double/*, timeSeconds: Int, timeMinutes: Int, timeHours: Int/*, averageSpeedArray: [CLLocationSpeed]*/*/){
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
//        self.timeSeconds = timeSeconds
//        self.timeMinutes = timeMinutes
//        self.timeHours = timeHours
//        self.averageSpeedArray = averageSpeedArray
        self.ref = nil
    }
    
    init(snapshot: FDataSnapshot!) {
        sessionID = snapshot.key
        sessionTitle = snapshot.value["sessionTitle"] as! String
        sessionTime = snapshot.value["sessionTime"] as! String
        thisSessionUnits = snapshot.value["thisSessionUnits"] as! Bool
        averageSpeed = snapshot.value["averageSpeed"] as! Double
        dateCreated = snapshot.value["dateCreated"] as! String
        imageID = snapshot.value["imageID"] as! Int
        topSpeed = snapshot.value["topSpeed"] as! Double
        peakAltitude = snapshot.value["highAltitude"] as! Double
        totalDistance = snapshot.value["totalDistance"] as! Double
        ref = snapshot.ref
//        timeSeconds = snapshot.value["seconds"] as! Int
//        timeMinutes = snapshot.value["minutes"] as! Int
//        timeHours = snapshot.value["hours"] as! Int
//        averageSpeedArray = snapshot.value["averageSpeedArray"] as! [CLLocationSpeed]
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
//            "seconds": timeSeconds,
//            "minutes": timeMinutes,
//            "hours": timeHours
        ]
    }
    
}