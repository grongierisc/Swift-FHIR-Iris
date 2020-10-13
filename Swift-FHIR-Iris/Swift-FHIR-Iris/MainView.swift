//
//  MainView.swift
//  Swift-FHIR-Iris
//
//  Created by Guillaume Rongier on 10/10/2020.
//

import SwiftUI
import HealthKit

struct MainView: View {
    
    // Get the business logic from the environment.
    @EnvironmentObject var swiftFhirIrisManager: SwiftFhirIrisManager
    
    let healthStore = HKHealthStore()
    
    @State var listStepCount: [(step : Double ,date : String)] = [(step :0.0,date: "")]
    
    @State var listHKObject : [HKQuantitySample] = [HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!, quantity: .init(unit: .count(), doubleValue: 0.0), start: Date(), end: Date())]
    
    @State private var showingSuccess = false
    @State private var textSuccess = ""
    @State private var textError = ""
    @State private var showingPopup = false
    @State private var progress : Bool = false
    
    var body: some View {

            VStack{
                List(listStepCount, id: \.step) { item in
                    
                    
                    HStack {
                        Text(String(format: "%.0f steps", item.step))
                        Spacer()
                        Text("\(item.date)")
                    }
                }
            VStack{
                Button(action: {send() }, label: {
                        Text("Send")}).alert(isPresented: $showingPopup) {
                            if showingSuccess {
                                return Alert(title: Text("Done"), message: Text(textSuccess), dismissButton: .default(Text("OK")))
                            } else {
                                return Alert(title: Text("Error"), message: Text("An error occurred"), dismissButton: .default(Text("OK")))
                            }
                            
                        }
                }
            
            Spacer()
            
        }.onAppear(perform: queryStepCount)
         .isHidden(progress, remove: progress)
        VStack {
            ProgressView("Sending…")
        }.isHidden(!progress, remove: !progress)
    }
    
    func queryStepCount(){
        
        //Last week
        let startDate = swiftFhirIrisManager.startDate
        //Now
        let endDate = swiftFhirIrisManager.endDate

        print("Collecting workouts between \(startDate) and \(endDate)")

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.strictEndDate)

        let query = HKSampleQuery(sampleType: HKQuantityType.quantityType(forIdentifier: .stepCount)!, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            
            guard let results = results as? [HKQuantitySample] else {
                   return
            }
       
            process(results, type: .stepCount)
        
        }

        healthStore.execute(query)

    }
    
    private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        
        listStepCount.removeAll()
        
        listHKObject = samples
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:ss"
        
        for sample in samples {
            if type == .stepCount {
                listStepCount.append((sample.quantity.doubleValue(for: .count()),dateFormatter.string(from: sample.endDate)))
            }
            
        }
    }
    
    private func send() {
        
        progress = true
        
        swiftFhirIrisManager.send(hksamples: listHKObject) { (error) in
            if error == nil {
                showingSuccess = true
                textSuccess = "\(listHKObject.count) observations are sent"
            } else {
                textSuccess = ""
            }
            showingPopup = true
            progress = false
        }
    }
}



struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(listStepCount: [(step :0.0,date: "")], listHKObject : [HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!, quantity: .init(unit: .count(), doubleValue: 0.0), start: Date(), end: Date())])
    }
}
