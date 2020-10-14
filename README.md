# Swift-FHIR-Iris
iOS app to export HealthKit data to InterSystems IRIS for Health (or any FHIR respository)

## Objective

The objective is to create an end-to-end demonstration of the FHIR protocol.
What I mean by end-to-end, from an information source such as an iPhone. Collect your health data in Apple format (HealthKit), transform it into FHIR and then send it to the InterSystems IRIS for Health repository.
This information must be accessible via a web interface.


In short: iPhone -> InterSystems FHIR -> Web Page.


### How-To run this demo

#### Prerequisites

 * For the client part (iOS)
   * Xcode 12
 * For the server and Web app
   * Docker

#### Install Xcode

Not much to say here, open the AppStore, search for Xcode, Install.

#### Open the SwiftUi project

Swift is Apple's programming language for iOS, Mac, Apple TV and Apple Watch. It is the replacement for objective-C.

Double clic on Swift-FHIR-Iris.xcodeproj

Open the simulator by a clic on the top left arrow.

GIF_xcode

#### Configure the simulator

Go to Health
Clic Steps
Add Data

GIF_simulator

#### Lunch the InterSystems FHIR Server

In the root folder of this git, run the following command :

```sh
docker-compose up -d
```

At the end of the building procress you will be able to connect to the FHIR repository :

http://localhost:32783/fhir/portal/patientlist.html

screenshot_portal

This portal was made by @diashenrique. 
With some modification to handle Apple's activity foot steps.

#### Play with the iOS app

The app will first request you to accept to share some information.
Clic on autorise

GIF authorise

Then you can test the FHIR server by clicking on 'Save and test server'
The deafult settings point on the docker configuration.
If succed, you can enter your patient informations.
First Name, Last Name, Birth day, Genre.
The save the patient to Fhir. A pop-up will show you your unique Fhir ID.

GIF patient

Consult this patient on the portal :
Go to : http://localhost:32783/fhir/portal/patientlist.html
We can see here, that thier is a new patient "toto" with 0 activities.

GIT patient TOTO

Send her activites :
Go back to the iOS application and clic on Step count
This panel summuries the step count of the week. In our case 2 entries.
Now you can send them to InterSystems IRIS FHIR by a clic on send.

GIF_send

Consult the new activites on the portal :
We can see now that Toto has two new observation and activities.

Gif_portal

You can event clic on the chart button to display it as a chart.

Git_chart

