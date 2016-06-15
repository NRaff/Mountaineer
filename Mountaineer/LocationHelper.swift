//
//  LocationHelper.swift
//  SkiBum
//
//  Created by Nick Raff on 7/24/15.
//  Copyright (c) 2015 Nick Raff. All rights reserved.
//
import UIKit
import Foundation
import CoreLocation
import Firebase
import FirebaseUI


class LocationHelper: NSObject {

// MARK: - References
    let RootRef: Firebase = Firebase(url: "https://mountaineer.firebaseio.com")
    let locationManager = CLLocationManager()
    
    var timer = NSTimer()
    var startTime = NSTimeInterval()
    

// MARK: - Location Variables
    var speed: CLLocationSpeed?
    var altitude: CLLocationDistance?
    var timeStamp: NSDate?
    var startingLocation: CLLocation!
    var averageSpeedArray = [CLLocationSpeed]()
    var sumSpeeds: CLLocationSpeed = 0
    var averageSpeed: Double = 0
    var newSpeed:CLLocationSpeed = 0
    var maxSpeed:CLLocationSpeed?
    var newAltitude: CLLocationDistance = 0
    var peakAltitude: CLLocationDistance?
    var startLocation: CLLocation?
    var nextLocation: CLLocation?
    var totalDistance: CLLocationDistance = 0
    var averageSpeedCount: Double = 0
    
// MARK: - Time Variables
    var seconds: Int = 0
    var minutes: Int = 0
    var hours: Int = 0
    var ventureTime: String = ""
    
// MARK: - Unit Setting Variables
    var unitsSetting: Bool = true
    var metricConversionKPH = 3.6
    var metricConversionKM = 0.001
    var imperialConvMPH = 2.23694
    var imperialConvMi = 0.000621371
    var imperialConvFt = 3.28084

// MARK: - Temporary Speed Variables
    var finalTopSpeed: Double = 0.0
    var highAltitude: Double = 0.0
    var finalDistance: Double = 0.0
    var finalAveSpeed: Double = 0.0
}

// MARK: - All Functions
extension LocationHelper {
    func startedLocation(){
        
        RootRef.childByAppendingPath("users/\(RootRef.authData.uid)").observeSingleEventOfType(.Value, withBlock: { snapshot in
            self.unitsSetting = snapshot.value["sessionUnits"] as! Bool
        })

        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.startUpdatingLocation()
            
        } else {
            print("Location services are not enabled");
        }
    }
    
    func getTopSpeed() -> Double {
        if locationManager.location != nil {
            if locationManager.location!.speed >= 0 {
                newSpeed = locationManager.location!.speed
                if maxSpeed != nil {
                    //find the maxSpeed
                    if newSpeed > maxSpeed {
                        maxSpeed = newSpeed
                        if unitsSetting == false {
                            finalTopSpeed = (round(maxSpeed! * imperialConvMPH * 100)/100)
                        }
                        else{
                            finalTopSpeed = (round(maxSpeed! * metricConversionKPH * 100)/100)
                        }
                    }
                    else
                    {
                        if unitsSetting == false {
                            finalTopSpeed = (round(maxSpeed! * imperialConvMPH * 100)/100)
                        }
                        else{
                            finalTopSpeed = (round(maxSpeed! * metricConversionKPH * 100)/100)
                        }
                    }
                }
                else {
                    //just display the most recently recorded speed
                    maxSpeed = newSpeed
                    if unitsSetting == false {
                        finalTopSpeed = (round(newSpeed * imperialConvMPH * 100)/100)
                    }
                    else {
                        finalTopSpeed = (round(newSpeed * metricConversionKPH * 100)/100)
                    }
                }
            }
            else {
                newSpeed = 0.0
                if maxSpeed == nil {
                    maxSpeed = 0.0
                    finalTopSpeed = 0.0
                }
            }
        }
        else{
            if finalTopSpeed == 0.0 {
            finalTopSpeed = 0.0
            }
        }
        return finalTopSpeed
    }


    func getPeakAltitude() -> Double{
        if locationManager.location != nil {
            if locationManager.location!.altitude >= 0 {
                newAltitude = locationManager.location!.altitude
                if peakAltitude != nil {
                    if newAltitude > peakAltitude {
                        peakAltitude = newAltitude
                        if unitsSetting == false {
                           highAltitude = round(peakAltitude! * imperialConvFt * 100)/100
                        }
                        else {
                            highAltitude = round(peakAltitude! * 100)/100
                        }
                    }
                    else
                    {
                        if unitsSetting == false {
                            highAltitude = round(peakAltitude! * imperialConvFt * 100)/100
                        }
                        else {
                            highAltitude = round(peakAltitude! * 100)/100
                        }
                    }
                }
                else {
                    peakAltitude = newAltitude
                    if unitsSetting == false {
                        highAltitude = round(newAltitude * imperialConvFt * 100)/100
                    }
                    else {
                        highAltitude = round(newAltitude * 100)/100
                    }
                }
            }
        }
        else {
            if highAltitude == 0.0 {
            highAltitude = 0.0
            }
        }
        
       return highAltitude
    }

    func getTotalDistance() -> Double {
        if locationManager.location != nil {
            if startLocation == nil {
                startLocation = locationManager.location
                if unitsSetting == false {
                    finalDistance = round(totalDistance * imperialConvMi * 1000)/1000
                }
                else {
                    finalDistance = round(totalDistance * metricConversionKM * 1000)/1000
                }
            }
            else {
                nextLocation = locationManager.location
                totalDistance += nextLocation!.distanceFromLocation(startLocation!)
                startLocation = nextLocation
                if unitsSetting == false {
                    finalDistance = round(totalDistance * imperialConvMi * 1000)/1000
                }
                else {
                    finalDistance = round(totalDistance * metricConversionKM * 1000)/1000
                }
            }
        }
        else {
            if finalDistance == 0.0 {
                finalDistance = 0.0
            }
        }
        
        return finalDistance
    }
    
    func NewAverageSpeed() -> Double {
        if locationManager.location != nil {
            averageSpeedCount += 1
            if locationManager.location!.speed >= 0 {
                sumSpeeds += locationManager.location!.speed
            }
            else {
                sumSpeeds += 0.0
            }
            
            averageSpeed = sumSpeeds/averageSpeedCount
            
            if unitsSetting == false {
                finalAveSpeed = round(averageSpeed * imperialConvMPH * 100)/100
            }
            else {
                finalAveSpeed = round(averageSpeed * metricConversionKPH * 100)/100
            }
        }
        
        return finalAveSpeed
    }
    
    func getAltitudeSkied(){
        //formula to find total ft skiied rather than sitting on the lift
        //use if statements to determine if user is going downhill
        //if user is going downhill then calculate how many feet downhill
        //keep updating the total like total distance
    }
    

    func tripDuration() -> (timeString: String, seconds: Int, minutes: Int, hours: Int) {
        seconds += 1
        if seconds > 59 {
            seconds = 0
            minutes += 1
        }
        if minutes > 59 {
            minutes = 0
            hours += 1
        }
        return (adventureTime(), seconds, minutes, hours)
    }
    
    func adventureTime() -> String {
        if hours < 10 && minutes < 10 && seconds < 10 {
            ventureTime = "0\(hours).0\(minutes).0\(seconds)"
        }
        else {
            if hours < 10 && minutes < 10 && seconds > 9 {
                ventureTime = "0\(hours).0\(minutes).\(seconds)"
            }
            else {
                if hours < 10 && minutes > 9 && seconds < 10 {
                    ventureTime = "0\(hours).\(minutes).0\(seconds)"
                }
                else {
                    if hours < 10 && minutes > 9 && seconds > 9 {
                        ventureTime = "0\(hours).\(minutes).\(seconds)"
                    }
                    else {
                        if hours > 9 && minutes < 10 && seconds < 10 {
                            ventureTime = "\(hours).0\(minutes).0\(seconds)"
                        }
                        else {
                            if hours > 9 && minutes < 10 && seconds > 9 {
                                ventureTime = "\(hours).0\(minutes).\(seconds)"
                            }
                            else {
                                if hours > 9 && minutes > 9 && seconds < 10 {
                                    ventureTime = "\(hours).\(minutes).0\(seconds)"
                                }
                                else {
                                    if hours > 9 && minutes > 9 && seconds > 9 {
                                        ventureTime = "\(hours).\(minutes).\(seconds)"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return ventureTime
    }

}

// MARK: - Location Manager Delegate
extension LocationHelper: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()
        //if error != nil {
        //   print(error, terminator: "")
        //   print("Nope you broke it")
        // }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation

         speed = locationObj.speed
         timeStamp = locationObj.timestamp
         altitude = locationObj.altitude
    }
}