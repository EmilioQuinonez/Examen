//
//  CovidView.swift
//  Examen
//
//  Created by Emilio Santiago López Quiñonez on 27/11/25.
//

import SwiftUI
import Charts

struct CovidView: View {
    @StateObject var covidViewModel = CovidViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.indigo.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        searchSection
                        
                        if covidViewModel.showError {
                            errorView
                        }
                        
                        if !covidViewModel.covidRegions.isEmpty {
                            dateFilterSection
                            
                            if let stats = covidViewModel.getStats() {
                                statsSection(stats: stats)
                            }
                            
                            chartSection
                            regionListSection
                        }
                        
                        if covidViewModel.covidRegions.isEmpty && !covidViewModel.isLoading && !covidViewModel.showError {
                            emptyStateView
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("COVID-19 Tracker")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            covidViewModel.loadLastCountry()
        }
        .alert(isPresented: $covidViewModel.showError) {
            Alert(
                title: Text("Error"),
                message: Text(covidViewModel.errorMessage),
                primaryButton: .default(Text("Reintentar")) {
                    Task {
                        await covidViewModel.getCovidData()
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    var searchSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Ingresa el país (ej: Canada)", text: $covidViewModel.country)
                    .textInputAutocapitalization(.never)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            
            Button {
                Task {
                    await covidViewModel.getCovidData()
                }
            } label: {
                HStack {
                    if covidViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text("Cargando...")
                    } else {
                        Image(systemName: "magnifyingglass")
                        Text("Buscar")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(covidViewModel.isLoading ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(covidViewModel.isLoading)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 5)
    }
    
    var errorView: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text(covidViewModel.errorMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.red.opacity(0.1))
        .cornerRadius(16)
    }
    
    var dateFilterSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                Text("Filtrar por Fecha")
                    .font(.headline)
            }
            
            VStack(spacing: 12) {
                // Fecha Inicio
                VStack(alignment: .leading, spacing: 8) {
                    Text("Fecha Inicio")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Menu {
                        ForEach(covidViewModel.availableDates, id: \.self) { date in
                            Button(date) {
                                covidViewModel.startDate = date
                            }
                        }
                    } label: {
                        HStack {
                            Text(covidViewModel.startDate.isEmpty ? "Selecciona fecha" : covidViewModel.startDate)
                                .foregroundColor(covidViewModel.startDate.isEmpty ? .gray : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                
                // Fecha Fin
                VStack(alignment: .leading, spacing: 8) {
                    Text("Fecha Fin")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Menu {
                        ForEach(covidViewModel.availableDates, id: \.self) { date in
                            Button(date) {
                                covidViewModel.endDate = date
                            }
                        }
                    } label: {
                        HStack {
                            Text(covidViewModel.endDate.isEmpty ? "Selecciona fecha" : covidViewModel.endDate)
                                .foregroundColor(covidViewModel.endDate.isEmpty ? .gray : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                
                // Botones rápidos
                HStack(spacing: 8) {
                    Button {
                        if let first = covidViewModel.availableDates.first,
                           let last = covidViewModel.availableDates.last {
                            covidViewModel.startDate = first
                            covidViewModel.endDate = last
                        }
                    } label: {
                        Text("Todo el período")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(6)
                    }
                    
                    Button {
                        let dates = covidViewModel.availableDates
                        if dates.count >= 30 {
                            covidViewModel.startDate = dates[dates.count - 30]
                            covidViewModel.endDate = dates.last ?? ""
                        }
                    } label: {
                        Text("Últimos 30 días")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .cornerRadius(6)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 5)
    }
    
    func statsSection(stats: CovidStats) -> some View {
        VStack(spacing: 12) {
            statCard(
                title: "Casos Totales",
                value: "\(stats.totalCases)",
                icon: "chart.line.uptrend.xyaxis",
                color: .blue
            )
            
            statCard(
                title: "Casos Nuevos",
                value: "\(stats.newCases)",
                icon: "exclamationmark.circle.fill",
                color: .orange
            )
            
            statCard(
                title: "Regiones",
                value: "\(stats.regions)",
                icon: "map.fill",
                color: .green
            )
        }
    }
    
    func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(color.opacity(0.3))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 3)
    }
    
    var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Evolución de Casos")
                .font(.headline)
            
            if #available(iOS 16.0, *) {
                let filteredRegions = covidViewModel.getFilteredRegions().prefix(3)
                
                Chart {
                    ForEach(Array(filteredRegions), id: \.id) { region in
                        let sortedCases = region.covidData.cases.sorted { $0.key < $1.key }
                        let sampledCases = stride(from: 0, to: sortedCases.count, by: max(1, sortedCases.count / 50)).map { sortedCases[$0] }
                        
                        ForEach(sampledCases, id: \.key) { date, caseData in
                            LineMark(
                                x: .value("Fecha", date),
                                y: .value("Casos", caseData.total)
                            )
                            .foregroundStyle(by: .value("Región", region.covidData.region))
                        }
                    }
                }
                .frame(height: 250)
            } else {
                Text("Gráficos disponibles en iOS 16+")
                    .foregroundColor(.secondary)
                    .frame(height: 250)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 5)
    }
    
    var regionListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Datos por Región")
                .font(.headline)
            
            ForEach(covidViewModel.getFilteredRegions()) { region in
                if let caseData = region.covidData.cases[covidViewModel.endDate] {
                    HStack {
                        Text(region.covidData.region)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(caseData.total)")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            Text("+\(caseData.new)")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 5)
    }
    
    var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "globe.americas.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue.opacity(0.3))
            
            Text("Busca datos de COVID-19")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Ingresa el nombre de un país para ver estadísticas detalladas")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}

#Preview {
    CovidView()
}
