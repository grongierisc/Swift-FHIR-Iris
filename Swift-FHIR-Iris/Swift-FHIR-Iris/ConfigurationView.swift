//
//  ConfigurationView.swift
//  Swift-FHIR-Iris
//
//  Created by Guillaume Rongier on 09/10/2020.
//

import SwiftUI
import HealthKit

struct ConfigurationView: View {
    
    @State private var firstName :String = "First Name"
    @State private var lastName :String = "Last Name"
    @State private var gender = "Unknow"
    @State private var url = "http://localhost:52773/v1/fhiraas/toto/fhir/r4/endpoint/"
    @State var birthDay = Date()
    
    struct Gender {
        static let gender = [
            "Male",
            "Female",
            "Other",
            "Unknow"
        ]
    }
    
    
    var body: some View {
        NavigationView {

            Form {
             
                Section(header: Text("Patient")){
                    HStack {
                        Text("First Name")
                        Spacer()
                        TextField("Enter your first name", text: $firstName).multilineTextAlignment(.trailing)
                    }
             
                    HStack {
                        Text("Last Name")
                        Spacer()
                        TextField("Enter your last name", text: $lastName).multilineTextAlignment(.trailing)
                    }
             
                    HStack {
                        Picker(selection : $gender, label: Text("Gender")) {
                                ForEach(Gender.gender, id: \.self) { gender in
                                    Text(gender).tag(gender)
                                }
                        }
                    }
                    HStack {
                        DatePicker(
                            selection: $birthDay,
                            displayedComponents: .date,
                            label: { Text("Day of birth") }
                        )
                    }
 
                    
                }
                Section(header: Text("Server Setting")) {
                    HStack {
                        Text("URL")
                        Spacer()
                        TextField("Url", text: $url).multilineTextAlignment(.trailing)
                    }


                }
                Button(action: { }, label: {
                  Text("Save and Test")
                })

            }
            .navigationBarTitle(Text("Config"), displayMode: .inline)
            .navigationBarItems(leading: Button(action: { }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
            })
        
        }
        
    }
   
}

struct ConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationView()
    }
}
