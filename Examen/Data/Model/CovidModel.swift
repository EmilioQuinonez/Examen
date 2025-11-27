//
//  CovidModel.swift
//  Examen
//
//  Created by Emilio Santiago López Quiñonez on 27/11/25.
//

import Foundation

// CovidaData recibe todos los datos recibidos por la Api
// @param country: String        Nombre del Pais de los datos
// @param region: String         Region del pais de donde son los datos
// @param cases: [String]        Diccionario que contiene los datos de los casos
struct CovidData: Codable {
    var country: String
    var region: String
    var cases: [String: CaseData]
}

// CaseData representa los datos totales y nuevos que van ocurriendo por pais
// @param total: String          Numero de casos totales hasta la fecha
// @param new: String            Casos nuevos que se han resgistrado
struct CaseData: Codable {
    var total: Int
    var new: Int
}

// CovidRegion que ayuda a separar las regiones
// @param id: UUID               Numero identificador unico de la region
// @param covidData              Datos de la region en especifico
struct CovidRegion: Identifiable {
    var id = UUID()
    var covidData: CovidData
}

// CovidStats nos ayuda a juntar los datos del pais
// @param totalCases: Int         Numero de casos totales del pais
// @param newCases: Int           Numero de nuevos casos de ese pais
// @param region: Int             Numero de regiones que tiene el pais
struct CovidStats {
    var totalCases: Int
    var newCases: Int
    var regions: Int
}
