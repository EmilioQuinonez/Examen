//
//  LocalService.swift
//  Examen
//
//  Created by Emilio Santiago López Quiñonez on 27/11/25.
//

import Foundation

// LocalService gestiona el almacenamiento de datos locales del usuario
// @param shared: LocalService       Instancia compartida para usar el servicio
final class LocalService {
    static let shared = LocalService()
    
    // getLastCountry obtiene el nombre del ultimo pais guardado
    // @return: String?                  Nombre del pais recuperado de memoria
    func getLastCountry() -> String? {
        return UserDefaults.standard.string(forKey: "lastCountry")
    }

    // setLastCountry guarda el pais seleccionado en UserDefaults
    // @param country: String            Nombre del pais que se quiere guardar
    func setLastCountry(country: String) {
        UserDefaults.standard.set(country, forKey: "lastCountry")
    }

    // removeLastCountry elimina la informacion del pais guardado
    func removeLastCountry() {
        UserDefaults.standard.removeObject(forKey: "lastCountry")
    }
}
