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
                            Text("Send")})
                }
            
            Spacer()
            
        }.onAppear(perform: queryStepCount)
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
        swiftFhirIrisManager.send(hksamples: listHKObject) { (error) in  }
    }
}



struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(listStepCount: [(step :0.0,date: "")], listHKObject : [HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!, quantity: .init(unit: .count(), doubleValue: 0.0), start: Date(), end: Date())])
    }
}
