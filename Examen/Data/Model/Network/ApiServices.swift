//
//  ApiServices.swift
//  Examen
//
//  Created by Emilio Santiago López Quiñonez on 27/11/25.
//

import Foundation
import Alamofire

// NetworkAPIService se encarga de la comunicacion de red externa usando Alamofire
// @param shared: NetworkAPIService  Instancia singleton para realizar las peticiones
class NetworkAPIService {
    static let shared = NetworkAPIService()
    
    // getCovidData realiza la peticion GET al endpoint para traer datos por pais
    // @param url: URL                   Direccion URL del servicio a consumir
    // @param country: String            Parametro del pais para filtrar la busqueda
    // @return: [CovidData]?             Arreglo de datos decodificados o nil si falla
    func getCovidData(url: URL, country: String) async -> [CovidData]? {
        
        // Configuracion de los parametros de la query (ej. ?country=Mexico)
        let parameters: Parameters = [
            "country": country
        ]
        
        // Configuracion de las cabeceras incluyendo la API Key de autorizacion
        let headers: HTTPHeaders = [
            "X-Api-Key": "6XcREqfCyW6/GZ9CpzXZiw==ZkFPTNtoijT3Lfkg"
        ]
        
        // Creacion de la solicitud HTTP con metodo GET y validacion de respuesta
        let taskRequest = AF.request(url, method: .get, parameters: parameters, headers: headers).validate()
        
        // Ejecucion asincrona esperando la serializacion de los datos
        let response = await taskRequest.serializingData().response
        
        // Manejo del resultado (Exito o Fallo)
        switch response.result {
        case .success(let data):
            do {
                // Intento de decodificar el JSON crudo al modelo [CovidData]
                return try JSONDecoder().decode([CovidData].self, from: data)
            } catch {
                debugPrint("Decoding error: \(error)")
                return nil
            }
        case let .failure(error):
            debugPrint(error.localizedDescription)
            return nil
        }
    }
}
