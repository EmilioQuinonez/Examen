//
//  CovidRepository.swift
//  Examen
//
//  Created by Emilio Santiago López Quiñonez on 27/11/25.
//

import Foundation

// Api contiene las constantes de configuracion para las peticiones
// @param base: String               URL base del endpoint de la API
struct Api {
    static let base = "https://api.api-ninjas.com/v1/covid19"
}

// CovidAPIProtocol define los metodos requeridos para obtener datos de la API
protocol CovidAPIProtocol {
    func getCovidData(country: String) async -> [CovidData]?
}

// CovidRepository gestiona la logica de comunicacion con el servicio de red
// @param shared: CovidRepository    Instancia compartida del repositorio
// @param nservice: NetworkAPIService Servicio de red inyectado para las llamadas
class CovidRepository: CovidAPIProtocol {
    static let shared = CovidRepository()
    let nservice: NetworkAPIService

    // Inicializa el repositorio permitiendo inyeccion de dependencias
    // @param nservice: NetworkAPIService Servicio de red a utilizar (por defecto shared)
    init(nservice: NetworkAPIService = NetworkAPIService.shared) {
        self.nservice = nservice
    }

    // getCovidData ejecuta la peticion asincrona a la API
    // @param country: String            Nombre del pais del cual se requieren datos
    // @return: [CovidData]?             Lista de datos obtenidos o nil si falla
    func getCovidData(country: String) async -> [CovidData]? {
        return await nservice.getCovidData(
            url: URL(string: "\(Api.base)")!,
            country: country
        )
    }
}
