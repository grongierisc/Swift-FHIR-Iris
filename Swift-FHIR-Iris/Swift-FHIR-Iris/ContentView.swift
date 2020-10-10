//
//  ContentView.swift
//  Swift-FHIR-Iris
//
//  Created by Guillaume Rongier on 09/10/2020.
//

import SwiftUI



struct ContentView: View {
    
    @State private var authorise :Bool = false
    
    var body: some View {
            if !authorise {
                WelcomeUIView()
            }else {
                MainView()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
