//
//  ConfigurationView.swift
//  Swift-FHIR-Iris
//
//  Created by Guillaume Rongier on 09/10/2020.
//

import SwiftUI
import HealthKit
import FHIR

struct ConfigurationView: View {
    
    // Get the business logic from the environment.
    @EnvironmentObject var swiftIrisManager: SwiftFhirIrisManager
    
    let healthStore = HKHealthStore()

    @State private var showingSuccess = false
    @State private var textSuccess = ""
    @State private var textError = ""
    @State private var showingPopup = false
    @State private var progress : Bool = false
    
    @State private var url : String = "http://localhost:52773/v1/fhiraas/toto/fhir/r4/endpoint/"
    
    struct Gender {
        static let gender = [
            "male",
            "female",
            "other",
            "unknow"
        ]
    }
    
    func start() {
        getUserGender()
        getUserName()
        getUserBirthDay()
    }
    
    
    var body: some View {
        NavigationView{
            
        VStack{
            
            Form {
                Section(header: Text("Server Setting")) {
                    HStack {
                        Text("URL")
                        Spacer()
                        TextField("Url", text: $url).multilineTextAlignment(.trailing)
                    }


                }
                Button(action: { test() }, label: {
                  Text("Save and test server")
                })
                .alert(isPresented: $showingPopup) {
                    if showingSuccess {
                        return Alert(title: Text("Done"), message: Text(textSuccess), dismissButton: .default(Text("OK")))
                    } else {
                        return Alert(title: Text("Error"), message: Text(textError), dismissButton: .default(Text("OK")))
                    }
                    
                }
             
                Section(header: Text("Patient")){
                    HStack {
                        Text("First Name")
                        Spacer()
                        TextField("Enter your first name", text: $swiftIrisManager.firstName).multilineTextAlignment(.trailing)
                    }
             
                    HStack {
                        Text("Last Name")
                        Spacer()
                        TextField("Enter your last name", text: $swiftIrisManager.lastName).multilineTextAlignment(.trailing)
                    }
             
                    HStack {
                        Picker(selection : $swiftIrisManager.gender, label: Text("Gender")) {
                                ForEach(Gender.gender, id: \.self) { gender in
                                    Text(gender).tag(gender)
                                }
                        }
                    }
                    HStack {
                        DatePicker(
                            selection: $swiftIrisManager.birthDay,
                            displayedComponents: .date,
                            label: { Text("Day of birth") }
                        )
                    }
                }
                Button(action: { save() }, label: {
                  Text("Save Patient to Fhir")
                })
                .alert(isPresented: $showingPopup) {
                    if showingSuccess {
                        return Alert(title: Text("Done"), message: Text("Test Succeed"), dismissButton: .default(Text("OK")))
                    } else {
                        return Alert(title: Text("Error"), message: Text(textError), dismissButton: .default(Text("OK")))
                    }
                    
                }
                Section(header: Text("Step Count Setting")) {
                    VStack {
                        DatePicker(
                            selection: $swiftIrisManager.startDate,
                            displayedComponents: .date,
                            label: { Text("Start Date") }
                        )
                        DatePicker(
                            selection: $swiftIrisManager.endDate,
                            displayedComponents: .date,
                            label: { Text("End Date") }
                        )
                    }



                }
                NavigationLink(destination: MainView()
                    .environmentObject(swiftIrisManager)
            ) {
                Text("Step Count")
             }


                
            }.isHidden(progress, remove: progress)
            VStack {
                ProgressView("Save and Testing…")
            }.isHidden(!progress, remove: !progress)
        }
        .navigationBarTitle(Text("Configuration"), displayMode: .inline)
        .navigationBarItems(
            trailing:
                NavigationLink(destination: MainView()
                    .environmentObject(swiftIrisManager)
            ) {
                Text("Step Count")
             })
        
        }.onAppear(perform: start)

        
    }
    
    
    
    private func getUserGender() -> Void
    {
        var biologicalSexObject: HKBiologicalSexObject!
        do {
            biologicalSexObject = try healthStore.biologicalSex()
        } catch {
            print("Either an error occured fetching the user's biological sex information or none has been stored yet. In your app, try to handle this gracefully.")
            return
        }
        
        switch biologicalSexObject.biologicalSex {
            case .male:
                swiftIrisManager.gender = "male"
            case .female:
                swiftIrisManager.gender = "female"
            case .other:
                swiftIrisManager.gender = "other"
            default:
                swiftIrisManager.gender = "unknow"
        }

    }
    
    private func getUserName() -> Void
    {
        // TODO
        guard let cdaType = HKObjectType.documentType(forIdentifier: .CDA) else {
            fatalError("Unable to create a CDA document type.")
        }
         
        var allDocuments = [HKDocumentSample]()
        _ = HKDocumentQuery(documentType: cdaType,
                                       predicate: nil,
                                       limit: HKObjectQueryNoLimit,
                                       sortDescriptors: nil,
                                       includeDocumentData: true) {
                                        
                                        (query, resultsOrNil, done, errorOrNil) in
                                        
                                        guard let results = resultsOrNil else {
                                            if errorOrNil != nil {
                                                // Handle the query error here...
                                            }
                                            
                                            return
                                        }
                                        
                                        allDocuments += results
                                        
                                        if done {
                                            // the allDocuments array now contains all the samples returned by the query.
                                            // Handle the documents here...
                                        }
        }
        
    }
    
    private func getUserBirthDay() -> Void
    {
        
        do {
            let dateOfBirthComponents = try self.healthStore.dateOfBirthComponents()
            swiftIrisManager.birthDay = dateOfBirthComponents.date!

        } catch {
            print("Either an error occured fetching the user's age information or none has been stored yet. In your app, try to handle this gracefully.")
            return
        }
        
        
        
    }
    
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
    
    private func save() {
        
        progress = true
        
        swiftIrisManager.syncPatient() { (patient,error) in
           
            progress = false
            showingPopup = true
            
            if error == nil {
                showingSuccess = true
                if let patientId = patient?.id {
                    textSuccess = "Patient id from fhir is \(patientId)"
                } else {
                    textSuccess = "Patient id from fhir is nil"
                }
            } else {
                showingSuccess = false
                textError = error?.humanized ?? "Unknow error"
            }
            
            return
        }
    }
}
   


struct ConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationView()
    }
}

