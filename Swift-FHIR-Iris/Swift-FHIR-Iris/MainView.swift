//
//  MainView.swift
//  Swift-FHIR-Iris
//
//  Created by Guillaume Rongier on 10/10/2020.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationView{
            VStack{
                List {
                    Text("Hello World")
                    Text("Hello World2")
                }.listStyle(GroupedListStyle())
                
                Button(action: { }, label: {
                  Text("Send")
                })
                    
                Spacer()

            }
            .navigationBarTitle(Text("Step Count"), displayMode: .inline)
            .navigationBarItems(
                trailing: Button("Settings",action: { }))
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
