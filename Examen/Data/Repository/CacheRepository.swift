//
//  CacheRepository.swift
//  Examen
//
//  Created by Emilio Santiago López Quiñonez on 27/11/25.
//

import Foundation

// CacheServiceProtocol define los contratos para las operaciones de cache
protocol CacheServiceProtocol {
    func getLastCountry() -> String?
    func setLastCountry(country: String)
    func removeLastCountry()
}

// CacheRepository actua como intermediario para gestionar los datos locales
// @param shared: CacheRepository        Instancia unica del repositorio
// @param localService: LocalService     Servicio encargado de la persistencia directa
class CacheRepository: CacheServiceProtocol {
    static let shared = CacheRepository()
    var localService = LocalService()
    
    // init inicializa el repositorio con la inyeccion de dependencias
    // @param localService: LocalService Servicio local a utilizar (por defecto shared)
    init(localService: LocalService = LocalService.shared) {
        self.localService = localService
    }
    
    // getLastCountry llama al servicio local para obtener el dato
    // @return: String?                  El nombre del pais recuperado o nil
    func getLastCountry() -> String? {
        self.localService.getLastCountry()
    }
    
    // setLastCountry delega al servicio local el guardado del pais
    // @param country: String            El nombre del pais a guardar en cache
    func setLastCountry(country: String) {
        self.localService.setLastCountry(country: country)
    }
    
    // removeLastCountry solicita al servicio local eliminar el dato
    func removeLastCountry() {
        self.localService.removeLastCountry()
    }
}
