# Swift-FHIR-Iris
iOS app to export HealthKit data to InterSystems IRIS for Health (or any FHIR respository)

![main](https://raw.githubusercontent.com/grongierisc/Swift-FHIR-Iris/main/img/gif/FHIR.png)

# Table of content

# Table of Contents
1. [Goal of this demo](#goal)
2. [How-To run this demo](#rundemo)
2.1. [Prerequisites](#Prerequisites)
2.2. [Install Xcode](#Installxcode)
2.3. [Open the SwiftUi project](#openswiftui)
2.4. [Configure the simulator](#simulator)
2.5. [Lunch the InterSystems FHIR Server](#lunchfhir)
2.6. [Play with the iOS app](#iosplay)
3. [How it works](#howtos)
3.1. [iOS](#howtosios)
3.1.1. [How to check for authorization for health data works](#authorisation)
3.1.2. [How to connect to a FHIR Repository](#howtoFhir)
3.1.3. [How to save a patient in the FHIR Repository](#howtoPatientFhir)
3.1.4. [How to extrat data from the HealthKit](#queryHK)
3.1.5. [How to transform HealthKit data to FHIR](#HKtoFHIR)
3.2. [Backend (FHIR)](#backend)
3.3. [Frontend](#frontend)
4. [ToDos(#todo)


## Goal of this demo

The objective is to create an end-to-end demonstration of the FHIR protocol.

What I mean by end-to-end, from an information source such as an iPhone. 
Collect your health data in Apple format (HealthKit), transform it into FHIR and then send it to the InterSystems IRIS for Health repository.

This information must be accessible via a web interface.


In short: iPhone -> InterSystems FHIR -> Web Page.


## How-To run this demo

### Prerequisites

 * For the client part (iOS)
   * Xcode 12
 * For the server and Web app
   * Docker

### Install Xcode

Not much to say here, open the AppStore, search for Xcode, Install.

### Open the SwiftUi project

Swift is Apple's programming language for iOS, Mac, Apple TV and Apple Watch. It is the replacement for objective-C.

Double clic on Swift-FHIR-Iris.xcodeproj

Open the simulator by a clic on the top left arrow.

![xcode](https://raw.githubusercontent.com/grongierisc/Swift-FHIR-Iris/main/img/gif/xcode_and_simulator.gif)


### Configure the simulator

Go to Health

Clic Steps

Add Data

![simulator](https://raw.githubusercontent.com/grongierisc/Swift-FHIR-Iris/main/img/gif/configuration_simulator.gif)

### Lunch the InterSystems FHIR Server

In the root folder of this git, run the following command :

```sh
docker-compose up -d
```

At the end of the building procress you will be able to connect to the FHIR repository :

http://localhost:32783/fhir/portal/patientlist.html

![portal](https://raw.githubusercontent.com/grongierisc/Swift-FHIR-Iris/main/img/gif/portal_default.png)

This portal was made by @diashenrique. 

With some modification to handle Apple's activity foot steps.

### Play with the iOS app

The app will first request you to accept to share some information.

Clic on authorise

![authorise](https://raw.githubusercontent.com/grongierisc/Swift-FHIR-Iris/main/img/gif/ios_authorise.gif)

Then you can test the FHIR server by clicking on 'Save and test server'

The deafult settings point to the docker configuration.

If succed, you can enter your patient informations.

First Name, Last Name, Birth day, Genre.

The save the patient to Fhir. A pop-up will show you your unique Fhir ID.

![savepatient](https://raw.githubusercontent.com/grongierisc/Swift-FHIR-Iris/main/img/gif/save_patient.gif)

Consult this patient on the portal :

Go to : http://localhost:32783/fhir/portal/patientlist.html

We can see here, that thier is a new patient "toto" with 0 activities.

![patient portal](https://raw.githubusercontent.com/grongierisc/Swift-FHIR-Iris/main/img/gif/patient_toto.png)

Send her activites :

Go back to the iOS application and clic on Step count

This panel summuries the step count of the week. In our case 2 entries.

Now you can send them to InterSystems IRIS FHIR by a clic on send.

![ios send](https://raw.githubusercontent.com/grongierisc/Swift-FHIR-Iris/main/img/gif/ios_send.gif)

Consult the new activites on the portal :

We can see now that Toto has two new observation and activities.

![portal activites](https://raw.githubusercontent.com/grongierisc/Swift-FHIR-Iris/main/img/gif/portal_activities.gif)

You can event clic on the chart button to display it as a chart.

![portal charts](https://raw.githubusercontent.com/grongierisc/Swift-FHIR-Iris/main/img/gif/portal_chart.gif)

## How it works

### iOS

Most of this demo is build on SwiftUI.

https://developer.apple.com/xcode/swiftui/

Who is the latest framework for iOS and so.

#### How to check for authorization for health data works

It's in the SwiftFhirIrisManager class. 

This class is a singleton and it will be carry all around the application with @EnvironmentObject annotation.

More info at : https://www.hackingwithswift.com/quick-start/swiftui/how-to-use-environmentobject-to-share-data-between-views

The requestAuthorization method :

```swift
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
```
Where healthStore is the object of HKHealthStore().

The HKHealthStore is like the database of healthdata in iOS.

dataTypesToWrite and dataTypesToRead are the object we would like to query in the database.

The authorisation need a perpose and this is done in the Info.plist xml file by adding :

```xml
    <key>NSHealthClinicalHealthRecordsShareUsageDescription</key>
    <string>Read data for IrisExporter</string>
    <key>NSHealthShareUsageDescription</key>
    <string>Send data to IRIS</string>
    <key>NSHealthUpdateUsageDescription</key>
    <string>Write date for IrisExporter</string>
```

#### How to connect to a FHIR Repository

For this part I used the FHIR package from Smart-On-FHIR : https://github.com/smart-on-fhir/Swift-FHIR

The class used is the FHIROpenServer.

```swift
    private func test() {
        
        progress = true
        
        let url = URL(string: self.url)

        swiftIrisManager.fhirServer = FHIROpenServer(baseURL : url! , auth: nil)
        
        swiftIrisManager.fhirServer.getCapabilityStatement() { FHIRError in
            
            progress = false
            showingPopup = true
            
            if FHIRError == nil {
                showingSuccess = true
                textSuccess = "Connected to the fhir repository"
            } else {
                textError = FHIRError?.description ?? "Unknow error"
                showingSuccess = false
            }
            
            return
        }
 
    }
```

This create an new object fhirServer in the singleton swiftIrisManager.

Next we use the getCapabilityStatement()

If we can retrive the capabilityStatement of the FHIR server this mean we successufly connected to the FHIR repository.

This repository is not in HTTPS, by default apple bock this kind of communication.

To allow HTTP support, the Info.plist xml file is edited like this : 

```xml
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSExceptionDomains</key>
        <dict>
            <key>localhost</key>
            <dict>
                <key>NSIncludesSubdomains</key>
                <true/>
                <key>NSExceptionAllowsInsecureHTTPLoads</key>
                <true/>
            </dict>
        </dict>
    </dict>
```

#### How to save a patient in the FHIR Repository

Basic operation by first checking if the patient already exist in the repository 

```swift
Patient.search(["family": "\(self.lastName)"]).perform(fhirServer)
```

This search for patient with the same family name. 

Here we can imaging other senarios like with Oauth2 and JWT token to join the patientid and his token. But for this demo we keep things simple.

Next if the patient exist, we retrive it, otherwise we create the patient :

```swift
    func createPatient(callback: @escaping (Patient?, Error?) -> Void) {
        // Create the new patient resource
        let patient = Patient.createPatient(given: firstName, family: lastName, dateOfBirth: birthDay, gender: gender)
        
        patient?.create(fhirServer, callback: { (error) in
            callback(patient, error)
        })
    }
```

#### How to extrat data from the HealthKit

It's done by quering the healthkit Store (HKHealthStore())

Here we are quering for footsteps.

Prepare the query with the predicate.

```swift
        //Last week
        let startDate = swiftFhirIrisManager.startDate
        //Now
        let endDate = swiftFhirIrisManager.endDate

        print("Collecting workouts between \(startDate) and \(endDate)")

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.strictEndDate)
```

Then the query it self with his type of data (HKQuantityType.quantityType(forIdentifier: .stepCount)) and the predicate.

```swift
func queryStepCount(){
        
        //Last week
        let startDate = swiftFhirIrisManager.startDate
        //Now
        let endDate = swiftFhirIrisManager.endDate

        print("Collecting workouts between \(startDate) and \(endDate)")

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.strictEndDate)

        let query = HKSampleQuery(sampleType: HKQuantityType.quantityType(forIdentifier: .stepCount)!, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            
            guard let results = results as? [HKQuantitySample] else {
                   return
            }
       
            process(results, type: .stepCount)
        
        }

        healthStore.execute(query)

    }
```

#### How to transform HealthKit data to FHIR

For this part, we use the microsoft package HealthKitToFHIR

https://github.com/microsoft/healthkit-to-fhir

This is a convinente package that offer factories to transforme HKQuantitySample to FHIR Observation

```swift
     let observation = try! ObservationFactory().observation(from: item)
      let patientReference = try! Reference(json: ["reference" : "Patient/\(patientId)"])
      observation.category = try! [CodeableConcept(json: [
          "coding": [
            [
              "system": "http://terminology.hl7.org/CodeSystem/observation-category",
              "code": "activity",
              "display": "Activity"
            ]
          ]
      ])]
      observation.subject = patientReference
      observation.status = .final
      print(observation)
      observation.create(self.fhirServer,callback: { (error) in
          if error != nil {
              completion(error)
          }
      })
```

Where item is an HKQuantitySample in our case an stepCount type.

The factory does most of the job of converting 'unit' and 'type' to FHIR codeableConcept and 'value' to FHIR valueQuantity.

The reference to the patientId is done manualy by casting a json fhir refenrence.

```swift
let patientReference = try! Reference(json: ["reference" : "Patient/\(patientId)"])
```

Same is done for the category :

```swift
      observation.category = try! [CodeableConcept(json: [
          "coding": [
            [
              "system": "http://terminology.hl7.org/CodeSystem/observation-category",
              "code": "activity",
              "display": "Activity"
            ]
          ]
      ])]
```

At last the observationo is created in the fhir repository :

```swift
      observation.create(self.fhirServer,callback: { (error) in
          if error != nil {
              completion(error)
          }
      })
```

### Backend (FHIR)

Not much to say, it's based on the fhir template form the InterSystems community :

https://openexchange.intersystems.com/package/iris-fhir-template

### Frontend

It's based on Henrique works who is a nice front end for FHIR repositories made in jquery.

https://openexchange.intersystems.com/package/iris-fhir-portal

## ToDos

- [ ] add more code comments
- [ ] handle patient name


