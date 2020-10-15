//
//  WelcomeUIView.swift
//  Swift-FHIR-Iris
//
//  Created by Guillaume Rongier on 10/10/2020.
//

import SwiftUI
import HealthKit

struct WelcomeUIView: View {
    
    // Get the business logic from the environment.
    @EnvironmentObject var swiftIrisManager: SwiftFhirIrisManager
    
    var body: some View {
        
        VStack{

            Spacer()
            
            Text("You have not yet authorize this application to use your health data").isHidden(swiftIrisManager.authorizedHK,remove: swiftIrisManager.authorizedHK)

            Text("You have authorize this application to use your health data").isHidden(!swiftIrisManager.authorizedHK,remove: !swiftIrisManager.authorizedHK)
            Spacer()
            
            Button(action: { getAuthorization() }, label: {
              Text("Authorize")
            }).isHidden(swiftIrisManager.authorizedHK,remove: swiftIrisManager.authorizedHK)
            
            Button(action: { self.goHome()  }, label: {
              Text("Continue")
            }).isHidden(!swiftIrisManager.authorizedHK,remove: !swiftIrisManager.authorizedHK)
            
            Spacer()
        }
    }
    
    func goHome() {
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = UIHostingController(rootView: ConfigurationView()
                                                                .environmentObject(swiftIrisManager))
            window.makeKeyAndVisible()
        }
    }
    
    func getAuthorization() {
        swiftIrisManager.requestAuthorization()
    }
    
    
    
}

struct WelcomeUIView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeUIView()
    }
}


