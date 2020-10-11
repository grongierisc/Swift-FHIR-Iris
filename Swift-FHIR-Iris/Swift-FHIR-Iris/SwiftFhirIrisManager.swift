//
//  SwiftFhirIrisManager.swift
//  Swift-FHIR-Iris
//
//  Created by Guillaume Rongier on 11/10/2020.
//

import Foundation
import HealthKit

class SwiftFhirIrisManager: NSObject,ObservableObject {
    
    @Published var authorisedHK : Bool = false;
    
    let healthStore = HKHealthStore()
    
    // Request authorization to access HealthKit.
    func requestAuthorization() {
        // Requesting authorization.
        /// - Tag: RequestAuthorization
        
        let allTypes = Set([HKObjectType.workoutType(),
                            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                            HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
                            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                            HKObjectType.quantityType(forIdentifier: .heartRate)!])

        healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
            if !success {
                // Handle the error here.
            } else {
                self.authorisedHK = true
            }
        }
    }
}
