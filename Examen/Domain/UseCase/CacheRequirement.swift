//
//  CacheRequirement.swift
//  Examen
//
//  Created by Emilio Santiago López Quiñonez on 27/11/25.
//

import Foundation

protocol CacheRequirementProtocol {
    func setLastCountry(country: String)
    func getLastCountry() -> String?
    func removeLastCountry()
}

class CacheRequirement: CacheRequirementProtocol {
    static let shared = CacheRequirement()
    let dataRepository: CacheRepository

    init(dataRepository: CacheRepository = CacheRepository.shared) {
        self.dataRepository = dataRepository
    }
    
    func setLastCountry(country: String) {
        self.dataRepository.setLastCountry(country: country)
    }
    
    func getLastCountry() -> String? {
        return self.dataRepository.getLastCountry()
    }
    
    func removeLastCountry() {
        self.dataRepository.removeLastCountry()
    }
}
