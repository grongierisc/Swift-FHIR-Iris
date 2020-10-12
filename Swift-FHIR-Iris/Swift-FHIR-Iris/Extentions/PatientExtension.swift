//
//  PatientExtension.swift
//  Swift-FHIR-Iris
//
//  Created by Guillaume Rongier on 12/10/2020.
//

import Foundation
import FHIR

extension Patient {
    public static func createPatient(given: String, family: String, dateOfBirth: Date, gender: String) -> Patient? {
        let humanName = HumanName()
        humanName.given = [FHIRString(given)]
        humanName.family = FHIRString(family)
        
        let patient = Patient()
        patient.name = [humanName]
        patient.birthDate = dateOfBirth.fhir_asDate()
        patient.gender = AdministrativeGender(rawValue: gender)
        
        return patient
    }
}
