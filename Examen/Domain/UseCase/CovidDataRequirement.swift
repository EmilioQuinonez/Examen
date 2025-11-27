//
//  CovidDataRequirement.swift
//  Examen
//
//  Created by Emilio Santiago López Quiñonez on 27/11/25.
//

import Foundation

protocol CovidDataRequirementProtocol {
    func getCovidData(country: String) async -> [CovidData]?
}

class CovidDataRequirement: CovidDataRequirementProtocol {
    static let shared = CovidDataRequirement()
    
    let dataRepository: CovidRepository

    init(dataRepository: CovidRepository = CovidRepository.shared) {
        self.dataRepository = dataRepository
    }
    
    func getCovidData(country: String) async -> [CovidData]? {
        return await dataRepository.getCovidData(country: country)
    }
}
