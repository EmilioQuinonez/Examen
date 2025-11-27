//
//  CovidApiResponse.swift
//  Examen
//
//  Created by Emilio Santiago López Quiñonez on 27/11/25.
//

import Foundation

struct CovidApiResponse: Codable, Identifiable {
    var id: String { "\(country)-\(region)" }

    let country: String
    let region: String
    let cases: [String: CaseData]

    struct CaseData: Codable {
        let total: Int
        let new: Int
    }
}
