//
//  WelcomeUIView.swift
//  Swift-FHIR-Iris
//
//  Created by Guillaume Rongier on 10/10/2020.
//

import SwiftUI

struct WelcomeUIView: View {
    
    @State private var authorise :Bool = false
    
    var body: some View {
        
        VStack{
            Spacer()
            Text("Hi, welcome to Swift FHIR and IRIS")
            Spacer()
            
            Text("You have not yet authorise this application to use your health data").isHidden(authorise,remove: authorise)

            Text("You have authorise this application to use your health data").isHidden(!authorise,remove: !authorise)
            Spacer()
            
            Button(action: { self.authorise = !self.authorise  }, label: {
              Text("Authorise")
            }).isHidden(authorise,remove: authorise)
            
            Button(action: { self.authorise = !self.authorise }, label: {
              Text("Continue")
            }).isHidden(!authorise,remove: !authorise)
            
            Spacer()
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
