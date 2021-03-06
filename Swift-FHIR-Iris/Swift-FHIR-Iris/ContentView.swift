//
//  ContentView.swift
//  Swift-FHIR-Iris
//
//  Created by Guillaume Rongier on 09/10/2020.
//

import SwiftUI



struct ContentView: View {
    
    // Get the business logic from the environment.
    @EnvironmentObject var swiftFhirIrisManager: SwiftFhirIrisManager
    
    var authorize : Bool = false
    
    var body: some View {
        
                WelcomeUIView()
                    .environmentObject(swiftFhirIrisManager)

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
