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
            
            Text("You have not yet authorise this application to use your health data").isHidden(swiftIrisManager.authorisedHK,remove: swiftIrisManager.authorisedHK)

            Text("You have authorise this application to use your health data").isHidden(!swiftIrisManager.authorisedHK,remove: !swiftIrisManager.authorisedHK)
            Spacer()
            
            Button(action: { getAuthorization() }, label: {
              Text("Authorise")
            }).isHidden(swiftIrisManager.authorisedHK,remove: swiftIrisManager.authorisedHK)
            
            Button(action: { self.goHome()  }, label: {
              Text("Continue")
            }).isHidden(!swiftIrisManager.authorisedHK,remove: !swiftIrisManager.authorisedHK)
            
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


