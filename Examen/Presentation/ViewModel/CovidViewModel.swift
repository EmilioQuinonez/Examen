//
//  CovidViewModel.swift
//  Examen
//
//  Created by Emilio Santiago López Quiñonez on 27/11/25.
//

import Foundation
import Combine

class CovidViewModel: ObservableObject {
    @Published var country = ""
    @Published var covidRegions = [CovidRegion]()
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var startDate = ""
    @Published var endDate = ""
    @Published var availableDates = [String]()
    
    var covidDataRequirement: CovidDataRequirementProtocol
    var cacheRequirement: CacheRequirementProtocol
    
    init(
        covidDataRequirement: CovidDataRequirementProtocol = CovidDataRequirement.shared,
        cacheRequirement: CacheRequirementProtocol = CacheRequirement.shared
    ) {
        self.covidDataRequirement = covidDataRequirement
        self.cacheRequirement = cacheRequirement
    }
    
    @MainActor
    func getCovidData() async {
        if country.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Por favor ingresa un nombre de país"
            showError = true
            return
        }
        
        isLoading = true
        errorMessage = ""
        showError = false
        covidRegions = []
        
        let result = await covidDataRequirement.getCovidData(country: country)
        
        if let data = result, !data.isEmpty {
            for covidData in data {
                let region = CovidRegion(covidData: covidData)
                self.covidRegions.append(region)
            }
            
            extractAvailableDates()
            cacheRequirement.setLastCountry(country: country)
        } else {
            errorMessage = "No se encontraron datos para este país. Verifica el nombre e intenta nuevamente."
            showError = true
        }
        
        isLoading = false
    }
    
    @MainActor
    func loadLastCountry() {
        if let lastCountry = cacheRequirement.getLastCountry(), !lastCountry.isEmpty {
            country = lastCountry
            Task {
                await getCovidData()
            }
        }
    }
    
    func extractAvailableDates() {
        guard let firstRegion = covidRegions.first else { return }
        
        availableDates = Array(firstRegion.covidData.cases.keys).sorted()
        
        if let first = availableDates.first, let last = availableDates.last {
            startDate = first
            endDate = last
        }
    }
    
    func getStats() -> CovidStats? {
        guard !covidRegions.isEmpty, !endDate.isEmpty else { return nil }
        
        var totalCases = 0
        var newCases = 0
        
        for region in covidRegions {
            if let caseData = region.covidData.cases[endDate] {
                totalCases += caseData.total
                newCases += caseData.new
            }
        }
        
        return CovidStats(totalCases: totalCases, newCases: newCases, regions: covidRegions.count)
    }
    
    func getFilteredRegions() -> [CovidRegion] {
        guard !startDate.isEmpty, !endDate.isEmpty else { return covidRegions }
        
        var filteredRegions = [CovidRegion]()
        
        for region in covidRegions {
            var filteredCases = [String: CaseData]()
            
            for (date, caseData) in region.covidData.cases {
                if date >= startDate && date <= endDate {
                    filteredCases[date] = caseData
                }
            }
            
            let filteredData = CovidData(
                country: region.covidData.country,
                region: region.covidData.region,
                cases: filteredCases
            )
            filteredRegions.append(CovidRegion(covidData: filteredData))
        }
        
        return filteredRegions
    }
}
