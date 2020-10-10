//
//  MainView.swift
//  Swift-FHIR-Iris
//
//  Created by Guillaume Rongier on 10/10/2020.
//

import SwiftUI

struct MainView: View {
    
    let disciplines = ["statue", "mural", "plaque"]
    
    var body: some View {
        NavigationView{
            VStack{
                List(disciplines, id: \.self) { discipline in
                  Text(discipline)
                }.listStyle(GroupedListStyle())
                
                Button(action: { }, label: {
                  Text("Send")
                })
                    
                Spacer()

            }
            .navigationBarTitle(Text("Step Count"), displayMode: .inline)
            .navigationBarItems(
                trailing:             NavigationLink(destination: ConfigurationView()) {
                    Text("Config")
                 })
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
