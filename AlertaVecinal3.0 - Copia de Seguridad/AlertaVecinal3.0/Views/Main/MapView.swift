// MapView.swift
//  AlertaVecinal3.0
//
//  Created by José Jesús Moreno Ríos on 06/22/25.
//

import SwiftUI
import MapKit
import CoreLocation
import PhotosUI
import AVKit

// MARK: - Extensiones para soporte de protocolos

extension CLLocationCoordinate2D: Equatable, Hashable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        abs(lhs.latitude - rhs.latitude) < 0.000001 &&
        abs(lhs.longitude - rhs.longitude) < 0.000001
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude.rounded(toPlaces: 6))
        hasher.combine(longitude.rounded(toPlaces: 6))
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

// MARK: - Modelos de Datos

enum IncidentType: CaseIterable, Identifiable, Hashable {
    case robbery, accident, fire, medical, suspicious
    case other(String)
    
    static var allCases: [IncidentType] {
        [.robbery, .accident, .fire, .medical, .suspicious]
    }
    
    var id: String {
        switch self {
        case .robbery: return "robbery"
        case .accident: return "accident"
        case .fire: return "fire"
        case .medical: return "medical"
        case .suspicious: return "suspicious"
        case .other(let description): return "other-\(description)"
        }
    }
    
    var title: String {
        switch self {
        case .robbery: return "Robo"
        case .accident: return "Accidente"
        case .fire: return "Incendio"
        case .medical: return "Emergencia Médica"
        case .suspicious: return "Actividad Sospechosa"
        case .other(let description): return description
        }
    }
    
    var color: Color {
        switch self {
        case .robbery: return .red
        case .accident: return .orange
        case .fire: return .yellow
        case .medical: return .green
        case .suspicious: return .purple
        case .other: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .robbery: return "person.fill.xmark"
        case .accident: return "car.fill"
        case .fire: return "flame.fill"
        case .medical: return "cross.fill"
        case .suspicious: return "eye.fill"
        case .other: return "exclamationmark.triangle"
        }
    }
    
    static var predefinedCases: [IncidentType] {
        allCases
    }
}

struct Incident: Identifiable, Hashable {
    let id: Int
    let type: IncidentType
    let coordinate: CLLocationCoordinate2D
    let address: String
    var description: String?
    let timestamp: Date
    var photos: [UIImage]?
    var videoURL: URL?
    
    static func == (lhs: Incident, rhs: Incident) -> Bool {
        lhs.id == rhs.id &&
        lhs.type == rhs.type &&
        lhs.coordinate == rhs.coordinate &&
        lhs.address == rhs.address &&
        lhs.description == rhs.description &&
        abs(lhs.timestamp.timeIntervalSince(rhs.timestamp)) < 1.0
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(type)
        hasher.combine(coordinate)
        hasher.combine(address)
        hasher.combine(description)
        hasher.combine(timestamp.timeIntervalSince1970.rounded(toPlaces: 0))
    }
    
    init(id: Int, type: IncidentType, coordinate: CLLocationCoordinate2D, address: String, description: String? = nil, photos: [UIImage]? = nil, videoURL: URL? = nil) {
        self.id = id
        self.type = type
        self.coordinate = coordinate
        self.address = address
        self.description = description
        self.photos = photos
        self.videoURL = videoURL
        self.timestamp = Date()
    }
}

struct Resource: Identifiable {
    let id: Int
    let type: ResourceType
    let name: String
    let coordinate: CLLocationCoordinate2D
    let phone: String
}

enum ResourceType {
    case police, fire, hospital
    
    var icon: String {
        switch self {
        case .police: return "shield.fill"
        case .fire: return "flame.fill"
        case .hospital: return "cross.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .police: return .blue
        case .fire: return .red
        case .hospital: return .green
        }
    }
}

struct IdentifiableCoordinate: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}

// MARK: - Componentes de Vista

struct IncidentAnnotationView: View {
    let incident: Incident
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: incident.type.icon)
                .foregroundColor(.white)
                .padding(8)
                .background(incident.type.color)
                .clipShape(Circle())
            
            Text(incident.type.title)
                .font(.caption2)
                .padding(4)
                .background(Color.white)
                .cornerRadius(4)
                .foregroundColor(.black)
                .offset(y: -4)
        }
    }
}

struct ResourceAnnotationView: View {
    let resource: Resource
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: resource.type.icon)
                .foregroundColor(.white)
                .padding(8)
                .background(resource.type.color)
                .clipShape(Circle())
            
            Text(resource.name)
                .font(.caption2)
                .padding(4)
                .background(Color.white)
                .cornerRadius(4)
                .foregroundColor(.black)
                .offset(y: -4)
        }
    }
}

struct CustomMapButton: View {
    let icon: String
    let color: Color
    var isSmall: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .symbolVariant(.fill)
                .font(isSmall ? .body : .title3)
                .foregroundColor(.white)
                .frame(width: isSmall ? 40 : 50, height: isSmall ? 40 : 50)
                .background(color)
                .clipShape(Circle())
                .shadow(radius: 3)
        }
    }
}

// MARK: - Vistas Auxiliares

struct IncidentReportsView: View {
    let incidents: [Incident]
    @Binding var selectedIncident: Incident?
    @Binding var showIncidentDetail: Bool
    
    var body: some View {
        NavigationStack {
            List {
                if incidents.isEmpty {
                    Text("No hay reportes recientes")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(incidents) { incident in
                        Button(action: {
                            selectedIncident = incident
                            showIncidentDetail = true
                        }) {
                            HStack {
                                Image(systemName: incident.type.icon)
                                    .foregroundColor(incident.type.color)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading) {
                                    Text(incident.type.title)
                                        .font(.headline)
                                    
                                    Text(incident.address)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Text(incident.timestamp.formatted())
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Detalles de Reportes")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ResourcesView: View {
    let resources: [Resource]
    @StateObject private var locationManager = LocationManager()
    @State private var distances: [Int: CLLocationDistance] = [:]
    
    var body: some View {
        NavigationStack {
            List {
                if distances.isEmpty {
                    Section {
                    }
                }
                
                ForEach(sortedResources) { resource in
                    HStack {
                        Image(systemName: resource.type.icon)
                            .foregroundColor(resource.type.color)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading) {
                            Text(resource.name)
                                .font(.headline)
                            
                            if let distance = distances[resource.id] {
                                Text("\(formatDistance(distance)) - \(estimatedTime(distance: distance))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("Tel: \(resource.phone)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            if let url = URL(string: "tel://\(resource.phone)") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Image(systemName: "phone")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Recursos Cercanos")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                startLocationUpdates()
            }
        }
    }
    
    private var sortedResources: [Resource] {
        resources.sorted { a, b in
            (distances[a.id] ?? .infinity) < (distances[b.id] ?? .infinity)
        }
    }
    
    private func startLocationUpdates() {
        locationManager.startContinuousUpdates { newLocation in
            updateDistances(userLocation: newLocation)
        }
    }
    
    private func updateDistances(userLocation: CLLocationCoordinate2D) {
        let userLoc = CLLocation(latitude: userLocation.latitude,
                                longitude: userLocation.longitude)
        
        for resource in resources {
            let resourceLoc = CLLocation(latitude: resource.coordinate.latitude,
                                       longitude: resource.coordinate.longitude)
            distances[resource.id] = userLoc.distance(from: resourceLoc)
        }
    }
    
    private func formatDistance(_ distance: CLLocationDistance) -> String {
        if distance < 1000 {
            return "\(Int(distance)) metros"
        } else {
            return "\(String(format: "%.1f", distance/1000)) km"
        }
    }
    
    private func estimatedTime(distance: CLLocationDistance) -> String {
        let walkingTime = distance / 80 // 1m/s ≈ 3.6 km/h
        let drivingTime = distance / 250 // ≈ 15 km/h en ciudad
        
        if distance < 500 {
            return "\(Int(walkingTime)) min caminando"
        } else {
            return "\(Int(drivingTime)) min en auto"
        }
    }
}

struct FiltersView: View {
    @Binding var selectedFilter: IncidentType?
    
    var body: some View {
        NavigationStack {
            List(IncidentType.predefinedCases, id: \.self) { type in
                Button(action: {
                    selectedFilter = selectedFilter == type ? nil : type
                }) {
                    HStack {
                        Image(systemName: type.icon)
                            .foregroundColor(type.color)
                            .frame(width: 30)
                        Text(type.title)
                        Spacer()
                        if selectedFilter == type {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("Filtrar Incidentes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Limpiar") {
                        selectedFilter = nil
                    }
                }
            }
        }
    }
}

struct AddMarkerView: View {
    let coordinate: CLLocationCoordinate2D
    @Binding var manualAddress: String
    @Binding var showAddressInput: Bool
    @State private var suggestedAddresses: [String] = []
    @State private var resolvedCoordinate: CLLocationCoordinate2D?
    let onAdd: (Incident) -> Void
    
    @State private var selectedType: IncidentType? = .robbery
    @State private var customIncidentType = ""
    @State private var description = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var selectedVideo: PhotosPickerItem?
    @State private var videoURL: URL?
    
    @Environment(\.dismiss) private var dismiss
    
    private var finalIncidentType: IncidentType {
        if let selectedType = selectedType {
            return selectedType
        } else if !customIncidentType.isEmpty {
            return .other(customIncidentType)
        } else {
            return .other("Otro incidente")
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Tipo de Incidente") {
                    Picker("Tipo predefinido", selection: $selectedType) {
                        ForEach(IncidentType.predefinedCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                    .foregroundColor(type.color)
                                Text(type.title)
                            }
                            .tag(type as IncidentType?)
                        }
                        
                        Text("Otro").tag(nil as IncidentType?)
                    }
                    .pickerStyle(.navigationLink)
                    
                    if selectedType == nil {
                        TextField("Describa el tipo de incidente", text: $customIncidentType)
                    }
                }
                
                Section("Ubicación") {
                    TextField("Ingrese dirección exacta", text: $manualAddress)
                        .onChange(of: manualAddress) { newValue in
                            searchSimilarAddresses(newValue)
                        }
                    
                    if !suggestedAddresses.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Direcciones similares:")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            ForEach(suggestedAddresses.prefix(3), id: \.self) { address in
                                Button(action: {
                                    manualAddress = address
                                    geocodeAddress(address)
                                    suggestedAddresses = []
                                }) {
                                    HStack {
                                        Image(systemName: "mappin.and.ellipse")
                                        Text(address)
                                            .font(.subheadline)
                                    }
                                    .foregroundColor(.blue)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                        .padding(.top, 5)
                    }
                    
                    Group {
                        HStack {
                            Text("Latitud:")
                            Spacer()
                            Text("\(coordinate.latitude, specifier: "%.6f")")
                                .font(.system(.caption, design: .monospaced))
                        }
                        
                        HStack {
                            Text("Longitud:")
                            Spacer()
                            Text("\(coordinate.longitude, specifier: "%.6f")")
                                .font(.system(.caption, design: .monospaced))
                        }
                    }
                    .font(.caption)
                }
                
                Section("Descripción (opcional)") {
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
                
                Section("Multimedia (opcional)") {
                    PhotosPicker(
                        selection: $selectedPhotos,
                        maxSelectionCount: 5,
                        matching: .images
                    ) {
                        Label("Añadir fotos", systemImage: "photo")
                    }
                    .onChange(of: selectedPhotos) { newItems in
                        Task {
                            selectedImages = []
                            for item in newItems {
                                if let imageData = try? await item.loadTransferable(type: Data.self),
                                   let image = UIImage(data: imageData) {
                                    selectedImages.append(image)
                                }
                            }
                        }
                    }
                    
                    if !selectedImages.isEmpty {
                        ScrollView(.horizontal) {
                            HStack(spacing: 10) {
                                ForEach(selectedImages.indices, id: \.self) { index in
                                    Image(uiImage: selectedImages[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                }
                            }
                        }
                    }
                    
                    PhotosPicker(
                        selection: $selectedVideo,
                        matching: .videos
                    ) {
                        Label(videoURL == nil ? "Añadir video" : "Video seleccionado", systemImage: "video")
                    }
                    .onChange(of: selectedVideo) { newItem in
                        Task {
                            if let item = newItem,
                               let videoData = try? await item.loadTransferable(type: URL.self) {
                                videoURL = videoData
                            }
                        }
                    }
                    
                    if let videoURL = videoURL {
                        Text(videoURL.lastPathComponent)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
            }
            .navigationTitle("Nuevo Reporte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Reportar") {
                        let newIncident = Incident(
                            id: Int.random(in: 1000...9999),
                            type: finalIncidentType,
                            coordinate: coordinate,
                            address: manualAddress,
                            description: description.isEmpty ? nil : description,
                            photos: selectedImages.isEmpty ? nil : selectedImages,
                            videoURL: videoURL
                        )
                        onAdd(newIncident)
                        dismiss()
                    }
                    .disabled(manualAddress.isEmpty)
                }
            }
            .onAppear {
                geocodeAddress(manualAddress)
            }
        }
    }
    
    private func searchSimilarAddresses(_ query: String) {
        guard !query.isEmpty else {
            suggestedAddresses = []
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            suggestedAddresses = [
                "\(query), Más adelante de ",
                "Cerca de \(query)",
                "\(query), Casa #",
                "\(query), A la esquina de",
                "\(query), Al Este de"
            ].filter { $0.lowercased().contains(query.lowercased()) }
        }
    }
    
    private func geocodeAddress(_ address: String) {
        guard !address.isEmpty else {
            resolvedCoordinate = nil
            return
        }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let placemark = placemarks?.first {
                resolvedCoordinate = placemark.location?.coordinate
            }
        }
    }
}

struct IncidentDetailView: View {
    let incident: Incident
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: incident.type.icon)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(incident.type.color)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(incident.type.title)
                                .font(.title2.bold())
                            Text(incident.timestamp.formatted())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ubicación GPS del incidente")
                            .font(.headline)
                        Text(incident.address)
                        
                        HStack {
                            Text("Lat: \(incident.coordinate.latitude, specifier: "%.6f")")
                            Text("Lon: \(incident.coordinate.longitude, specifier: "%.6f")")
                        }
                        .font(.system(.caption, design: .monospaced))
                    }
                    
                    if let description = incident.description {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Descripción")
                                .font(.headline)
                            Text(description)
                        }
                    }
                    
                    if let photos = incident.photos, !photos.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Fotos adjuntas")
                                .font(.headline)
                            
                            ScrollView(.horizontal) {
                                HStack(spacing: 10) {
                                    ForEach(photos.indices, id: \.self) { index in
                                        Image(uiImage: photos[index])
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 150, height: 150)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                            }
                        }
                    }
                    
                    if let videoURL = incident.videoURL {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Video adjunto")
                                .font(.headline)
                            
                            VideoPlayerView(videoURL: videoURL)
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Detalles del Reporte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct VideoPlayerView: UIViewControllerRepresentable {
    let videoURL: URL
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let player = AVPlayer(url: videoURL)
        let controller = AVPlayerViewController()
        controller.player = player
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}

struct AddressInputView: View {
    @Binding var address: String
    let onContinue: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Ingresar aspectos de tu dirección") {
                    TextField("Ej: Casa #145, Calle A, Urb. Villa Sol", text: $address)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .navigationTitle("Especificación")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        address = ""
                        onContinue()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Continuar") {
                        onContinue()
                    }
                    .disabled(address.isEmpty)
                }
            }
        }
    }
}

// MARK: - Vista Principal

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 8.38, longitude: -80.15),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var is3DModeEnabled = false
    @State private var incidents: [Incident] = []
    @State private var resources: [Resource] = []
    @State private var showResources = false
    @State private var showFilters = false
    @State private var selectedFilter: IncidentType?
    @State private var userLocation: CLLocationCoordinate2D?
    @State private var selectedLocation: IdentifiableCoordinate?
    @State private var showAddMarker = false
    @State private var showAddressInput = false
    @State private var manualAddress = ""
    @State private var isLocating = true
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var selectedIncident: Incident?
    @State private var showIncidentDetail = false
    @State private var showIncidentReports = false
    
    @StateObject private var locationManager = LocationManager()
    
    private var filteredIncidents: [Incident] {
        selectedFilter == nil ? incidents : incidents.filter { $0.type == selectedFilter }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                MapReader { mapProxy in
                    Map(
                        position: $cameraPosition,
                        interactionModes: [.pan, .zoom, .rotate, .pitch],
                        selection: $selectedIncident
                    ) {
                        if let userLocation = userLocation {
                            UserAnnotation()
                        }
                        
                        ForEach(filteredIncidents) { incident in
                            Annotation(incident.type.title, coordinate: incident.coordinate) {
                                Button(action: {
                                    selectedIncident = incident
                                }) {
                                    IncidentAnnotationView(incident: incident)
                                }
                            }
                        }
                        
                        ForEach(resources) { resource in
                            Annotation(resource.name, coordinate: resource.coordinate) {
                                ResourceAnnotationView(resource: resource)
                            }
                        }
                        
                        if let selectedLocation = selectedLocation {
                            Annotation("Nuevo reporte", coordinate: selectedLocation.coordinate) {
                                ZStack {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 24, height: 24)
                                    Image(systemName: "plus")
                                        .foregroundColor(.white)
                                        .font(.system(size: 12, weight: .bold))
                                }
                            }
                        }
                    }
                    .mapStyle(is3DModeEnabled ? .hybrid(elevation: .realistic) : .standard)
                    .onChange(of: selectedIncident) { oldValue, newValue in
                        showIncidentDetail = newValue != nil
                    }
                    .onTapGesture { location in
                        if let coordinate = mapProxy.convert(location, from: .local) {
                            handleMapTap(at: coordinate)
                        }
                    }
                }

                VStack {
                    HStack {
                        Text("Mapa de Incidentes")
                            .font(.headline.bold())
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Actualizado: \(getCurrentTime())")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 3)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        VStack(spacing: 10) {
                            Button(action: zoomIn) {
                                Image(systemName: "plus")
                                    .font(.body.weight(.bold))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            }
                            
                            Button(action: zoomOut) {
                                Image(systemName: "minus")
                                    .font(.body.weight(.bold))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation {
                                is3DModeEnabled.toggle()
                                updateCamera()
                            }
                        }) {
                            Image(systemName: is3DModeEnabled ? "view.2d" : "view.3d")
                                .padding(15)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        }
                        .padding(.trailing)
                        .padding(.bottom, 15)
                    }
                    
                    VStack(spacing: 15) {
                        HStack(spacing: 10) {
                            VStack(alignment: .center, spacing: 1) {
                                CustomMapButton(icon: "location", color: .blue, isSmall: true) {
                                    centerOnUserLocation()
                                }
                                Text ("Ubicación")
                                    .font(.caption2)
                                    .foregroundColor(.primary)
                                    .opacity(0.8)
                                    .frame(maxWidth: 60)
                                    .minimumScaleFactor(0.5)
                                    .padding(.top, 5)
                            }
                            
                            VStack(alignment: .center, spacing: 1) {
                                CustomMapButton(icon: "slider.horizontal.3", color: .yellow, isSmall: true) {
                                    showFilters.toggle()
                                }
                                Text ("Filtros")
                                    .font(.caption2)
                                    .foregroundColor(.primary)
                                    .opacity(0.8)
                                    .frame(maxWidth: 60)
                                    .minimumScaleFactor(0.5)
                                    .padding(.top, 5)
                            }
                            
                            VStack(alignment: .center, spacing: 1) {
                                CustomMapButton(icon: "clock", color: .red, isSmall: true) {
                                    showRecentIncidents()
                                }
                                Text ("Recientes")
                                    .font(.caption2)
                                    .foregroundColor(.primary)
                                    .opacity(0.8)
                                    .frame(maxWidth: 60)
                                    .minimumScaleFactor(0.5)
                                    .padding(.top, 5)
                            }
                            
                            VStack(alignment: .center, spacing: 1) {
                                CustomMapButton(icon: "exclamationmark.triangle", color: .green, isSmall: true) {
                                    showResources.toggle()
                                }
                                Text ("Recursos")
                                    .font(.caption2)
                                    .foregroundColor(.primary)
                                    .opacity(0.8)
                                    .frame(maxWidth: 60)
                                    .minimumScaleFactor(0.5)
                                    .padding(.top, 5)
                            }
                            
                            VStack(alignment: .center, spacing: 1) {
                                CustomMapButton(icon: "doc.text", color: .purple, isSmall: true) {
                                    showIncidentReports.toggle()
                                }
                                Text ("Reportes")
                                    .font(.caption2)
                                    .foregroundColor(.primary)
                                    .opacity(0.8)
                                    .frame(maxWidth: 60)
                                    .minimumScaleFactor(0.5)
                                    .padding(.top, 5)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(radius: 5)
                        .padding(.bottom, 45)
                    }
                }
                
                if isLocating {
                    ProgressView("Buscando ubicación...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    isLocating = false
                                }
                            }
                        }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showResources) {
                ResourcesView(resources: resources)
            }
            .sheet(isPresented: $showFilters) {
                FiltersView(selectedFilter: $selectedFilter)
            }
            .sheet(isPresented: $showIncidentReports) {
                IncidentReportsView(incidents: incidents, selectedIncident: $selectedIncident, showIncidentDetail: $showIncidentDetail)
            }
            .sheet(item: $selectedLocation) { location in
                AddMarkerView(
                    coordinate: location.coordinate,
                    manualAddress: $manualAddress,
                    showAddressInput: $showAddressInput
                ) { newIncident in
                    incidents.append(newIncident)
                    selectedLocation = nil
                }
            }
            .sheet(isPresented: $showAddressInput) {
                AddressInputView(address: $manualAddress) {
                    showAddressInput = false
                    if let userLocation = userLocation {
                        selectedLocation = IdentifiableCoordinate(coordinate: userLocation)
                    }
                }
            }
            .sheet(isPresented: $showIncidentDetail) {
                if let selectedIncident = selectedIncident {
                    IncidentDetailView(incident: selectedIncident)
                }
            }
            .alert("Aviso", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                loadInitialData()
                centerOnUserLocation()
            }
        }
    }
    
    private func zoomIn() {
        withAnimation {
            region.span = MKCoordinateSpan(
                latitudeDelta: max(region.span.latitudeDelta * 0.5, 0.001),
                longitudeDelta: max(region.span.longitudeDelta * 0.5, 0.001)
            )
            updateCamera()
        }
    }

    private func zoomOut() {
        withAnimation {
            region.span = MKCoordinateSpan(
                latitudeDelta: min(region.span.latitudeDelta * 2, 180),
                longitudeDelta: min(region.span.longitudeDelta * 2, 180)
            )
            updateCamera()
        }
    }
    
    private func handleMapTap(at coordinate: CLLocationCoordinate2D) {
        selectedLocation = IdentifiableCoordinate(coordinate: coordinate)
        geocodeCoordinate(coordinate)
    }
    
    private func geocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        isLocating = true
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            isLocating = false
            if let placemark = placemarks?.first {
                let address = [
                    placemark.thoroughfare,
                    placemark.subThoroughfare,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.country
                ].compactMap { $0 }.joined(separator: ", ")
                
                manualAddress = address.isEmpty ? "Ubicación seleccionada" : address
            } else {
                manualAddress = "Ubicación seleccionada"
            }
        }
    }
    
    private func updateCamera() {
        if is3DModeEnabled {
            cameraPosition = .camera(
                MapCamera(
                    centerCoordinate: region.center,
                    distance: 1000,
                    heading: 0,
                    pitch: 60
                )
            )
        } else {
            cameraPosition = .region(region)
        }
    }
    
    private func loadInitialData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.incidents = [

            ]
            
            self.resources = [
                Resource(id: 1, type: .police, name: "Puesto Policial de Río Hato", coordinate: CLLocationCoordinate2D(latitude: 8.3754, longitude: -80.1589), phone: "993-4250"),
                Resource(id: 2, type: .hospital, name: "Centro de Salud de Río Hato", coordinate: CLLocationCoordinate2D(latitude: 8.3778, longitude: -80.1602), phone: "993-4121"),

                Resource(id: 3, type: .hospital, name: "Centro de Salud de Antón", coordinate: CLLocationCoordinate2D(latitude: 8.3968, longitude: -80.2632), phone: "997-9135"),
                Resource(id: 4, type: .police, name: "Estación de Policía de Antón", coordinate: CLLocationCoordinate2D(latitude: 8.3976, longitude: -80.2636), phone: "997-9106"),
                Resource(id: 5, type: .fire, name: "Cuerpo de Bomberos de Antón", coordinate: CLLocationCoordinate2D(latitude: 8.4003, longitude: -80.2650), phone: "997-9202"),

                Resource(id: 7, type: .police, name: "Puesto Policial de Farallón", coordinate: CLLocationCoordinate2D(latitude: 8.3566, longitude: -80.1372), phone: "993-4567"),

                Resource(id: 9, type: .police, name: "Estación de Policía de Penonomé", coordinate: CLLocationCoordinate2D(latitude: 8.5206, longitude: -80.3573), phone: "997-8501"),
                Resource(id: 10, type: .fire, name: "Cuerpo de Bomberos de Penonomé", coordinate: CLLocationCoordinate2D(latitude: 8.5198, longitude: -80.3560), phone: "997-8602"),
            ]
        }
    }
    
    private func showRecentIncidents() {
        selectedFilter = nil
        if let lastIncident = incidents.last {
            withAnimation {
                region.center = lastIncident.coordinate
                region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                updateCamera()
            }
        }
    }
    
    private func centerOnUserLocation() {
        isLocating = true
        locationManager.requestLocation { coordinate in
            isLocating = false
            userLocation = coordinate
            withAnimation {
                region.center = coordinate
                region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                updateCamera()
            }
        }
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
    
    private func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
}

// MARK: - Location Manager

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var completion: ((CLLocationCoordinate2D) -> Void)?
    private var continuousCompletion: ((CLLocationCoordinate2D) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation(completion: @escaping (CLLocationCoordinate2D) -> Void) {
        self.completion = completion
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func startContinuousUpdates(completion: @escaping (CLLocationCoordinate2D) -> Void) {
        self.continuousCompletion = completion
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func stopContinuousUpdates() {
        locationManager.stopUpdatingLocation()
        continuousCompletion = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first?.coordinate else { return }
        
        if let completion = completion {
            completion(location)
            self.completion = nil
        }
        
        continuousCompletion?(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error al obtener ubicación: \(error.localizedDescription)")
    }
}
