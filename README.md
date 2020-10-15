# Swift-FHIR-Iris
iOS app to export HealthKit data to InterSystems IRIS for Health (or any FHIR respository)

![main](https://raw.githubusercontent.com/grongierisc/Swift-FHIR-Iris/main/img/gif/FHIR.png)

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

#### How it's checking for authorization for health datas

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

#### How to connect to save a patient in the FHIR Repository

### Backend (FHIR)

Not much to say, it's based on the fhir template form the InterSystems community :

https://openexchange.intersystems.com/package/iris-fhir-template

### Frontend

It's based on Henrique works who is a nice front end for FHIR repositories made in jquery.

https://openexchange.intersystems.com/package/iris-fhir-portal

## ToDos

- [ ] add more code comments
- [ ] handle patient name


