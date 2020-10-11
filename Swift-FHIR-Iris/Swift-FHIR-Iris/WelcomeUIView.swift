//
//  WelcomeUIView.swift
//  Swift-FHIR-Iris
//
//  Created by Guillaume Rongier on 10/10/2020.
//

import SwiftUI

struct WelcomeUIView: View {
    
    // Get the business logic from the environment.
    @EnvironmentObject var swiftIrisManager: SwiftFhirIrisManager
    
    var body: some View {
        
        VStack{

            Spacer()
            
            Text("You have not yet authorise this application to use your health data").isHidden(swiftIrisManager.authorisedHK,remove: swiftIrisManager.authorisedHK)

            Text("You have authorise this application to use your health data").isHidden(!swiftIrisManager.authorisedHK,remove: !swiftIrisManager.authorisedHK)
            Spacer()
            
            Button(action: { swiftIrisManager.requestAuthorization() }, label: {
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
            window.rootViewController = UIHostingController(rootView: ContentView())
            window.makeKeyAndVisible()
        }
    }
    
    
    
}

struct WelcomeUIView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeUIView()
    }
}

extension View {
    
    /// Hide or show the view based on a boolean value.
    ///
    /// Example for visibility:
    /// ```
    /// Text("Label")
    ///     .isHidden(true)
    /// ```
    ///
    /// Example for complete removal:
    /// ```
    /// Text("Label")
    ///     .isHidden(true, remove: true)
    /// ```
    ///
    /// - Parameters:
    ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
    ///   - remove: Boolean value indicating whether or not to remove the view.
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
}
