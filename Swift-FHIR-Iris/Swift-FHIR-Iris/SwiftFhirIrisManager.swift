//
//  SwiftFhirIrisManager.swift
//  Swift-FHIR-Iris
//
//  Created by Guillaume Rongier on 11/10/2020.
//

import Foundation
import HealthKit
import HealthKitToFhir
import FHIR

class SwiftFhirIrisManager: NSObject,ObservableObject {
    
    @Published var authorisedHK : Bool = false;
    
    let healthStore = HKHealthStore()
    
    @Published var fhirUrl : URL = URL(string: "http://localhost:52773/v1/fhiraas/toto/fhir/r4/endpoint/")!
    
    var fhirServer: FHIROpenServer = FHIROpenServer(baseURL: URL(string: "http://localhost:52773/v1/fhiraas/toto/fhir/r4/endpoint/")!)
    
    @Published var firstName :String = ""
    @Published var lastName :String = ""
    @Published var gender :String = ""
    @Published var birthDay = Date()
    
    @Published var startDate = Date(timeIntervalSinceNow: -3600 * 24 * 7)
    @Published var endDate = Date()
    
    
    // data types allowed to write in healthkit
    private func dataTypesToWrite() -> Set<HKSampleType> {
        
        let distanceWalkingRunning = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let writeDataTypes: Set<HKSampleType> = [ stepType, distanceWalkingRunning]
        
        return writeDataTypes
    }
    
    // data types allowed to read in healthkit
    private func dataTypesToRead() -> Set<HKObjectType> {
        
        let birthdayType = HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!
        let biologicalSexType = HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!
        let distanceWalkingRunning = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let woType = HKObjectType.workoutType()
        
        let readDataTypes: Set<HKObjectType> = [ birthdayType, biologicalSexType, distanceWalkingRunning, stepType, woType]
        
        return readDataTypes
    }
    
    // Request authorization to access HealthKit.
    func requestAuthorization() {
        // Requesting authorization.
        /// - Tag: RequestAuthorization
        
        let writeDataTypes: Set<HKSampleType> = dataTypesToWrite()
        let readDataTypes: Set<HKObjectType> = dataTypesToRead()
        
        // requset authorization
        healthStore.requestAuthorization(toShare: writeDataTypes, read: readDataTypes) { (success, error) in
            if !success {
                // Handle the error here.
            } else {
                
                DispatchQueue.main.async {
                    self.authorisedHK = true
                }
                
            }
        }
    }
    
    func createPatient(callback: @escaping (Patient?, Error?) -> Void) {
        // Create the new patient resource
        let patient = Patient.createPatient(given: firstName, family: lastName, dateOfBirth: birthDay, gender: gender)
        
        patient?.create(fhirServer, callback: { (error) in
            callback(patient, error)
        })
    }
    
    func getPatientByName(completion: @escaping (Patient?, Error?) -> Void ) {
        
        // search patient on the fhir repository by family name
        Patient.search(["family": "\(self.lastName)"]).perform(fhirServer) { (bundle, error) in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            if let bundleEntry = bundle?.entry?.first,
                let patient = bundleEntry.resource as? Patient {
                // Complete with the patient resource.
                completion(patient, nil)
            } else {
                // No Patient Resource exists for this user.
                completion(nil, nil)
            }
        }
    
    }
    
    func syncPatient( completion: @escaping (Patient?, Error?) -> Void ) {
        
        getPatientByName() { (patient,error ) in
            
            if patient == nil {
                
                self.createPatient(callback: completion)
                
            } else {
                
                completion(patient,error)
                
            }
            
        }
        
    }
    
    func send(hksamples: [HKSample], completion: @escaping (Error?) -> Void ) {
        
        syncPatient() { (patient,error ) in
            
            if error == nil {
                
                if let patientId = patient?.id {
                
                    for item in hksamples {
     
                            let observation = try! ObservationFactory().observation(from: item)
                            let patientReference = try! Reference(json: ["reference" : "Patient/\(patientId)"])
                            observation.subject = patientReference
                            observation.status = .final
                            print(observation)
                            observation.create(self.fhirServer,callback: { (error) in
                                if error != nil {
                                    completion(error)
                                }
                            })
                            
                    }
                    completion(nil)

                }
            
            }
            
        }
    }
}
