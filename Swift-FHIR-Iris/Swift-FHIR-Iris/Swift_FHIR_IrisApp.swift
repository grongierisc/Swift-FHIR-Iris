//
//  Swift_FHIR_IrisApp.swift
//  Swift-FHIR-Iris
//
//  Created by Guillaume Rongier on 09/10/2020.
//

import SwiftUI

@main
struct Swift_FHIR_IrisApp: App {
    
    // Get the business logic from the environment.
    var swiftFhirIrisManager = SwiftFhirIrisManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(swiftFhirIrisManager)
        }
    }
}
