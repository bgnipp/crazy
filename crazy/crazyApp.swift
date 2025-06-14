//
//  RideRunnerSynth.swift
//  Created 14 Jun 2025
//
//  One‑file synthesis of two prototypes: compact architecture + rich HUD.
//  Xcode 15 / iOS 17
//

import UIKit
import MapKit
import CoreLocation
import Combine
import AVFoundation
import SpriteKit
import UserNotifications

// MARK: ‑‑ Game Settings System (per Design Doc §6) --------------------------

final class GameSettings {
    // Core Game Settings (per design doc Table in §6)
    static var startTime: TimeInterval {
        get { UserDefaults.standard.object(forKey: "rr_startTime") as? TimeInterval ?? 120.0 }
        set { UserDefaults.standard.set(newValue, forKey: "rr_startTime") }
    }
    
    static var pickupRadius: CLLocationDistance {
        get { UserDefaults.standard.object(forKey: "rr_pickupRadius") as? CLLocationDistance ?? 4.572 }
        set { UserDefaults.standard.set(newValue, forKey: "rr_pickupRadius") }
    }
    
    static var minTripDistance: CLLocationDistance {
        get { UserDefaults.standard.object(forKey: "rr_minTripDistance") as? CLLocationDistance ?? 45.72 }
        set { UserDefaults.standard.set(newValue, forKey: "rr_minTripDistance") }
    }
    
    static var maxTripDistance: CLLocationDistance {
        get { UserDefaults.standard.object(forKey: "rr_maxTripDistance") as? CLLocationDistance ?? 300.0 }
        set { UserDefaults.standard.set(newValue, forKey: "rr_maxTripDistance") }
    }
    
    static var fatigueRate: Double {
        get { UserDefaults.standard.object(forKey: "rr_fatigueRate") as? Double ?? 0.97 }
        set { UserDefaults.standard.set(newValue, forKey: "rr_fatigueRate") }
    }
    
    static var avgBikeSpeed: CLLocationSpeed {
        get { UserDefaults.standard.object(forKey: "rr_avgBikeSpeed") as? CLLocationSpeed ?? 4.5 }
        set { UserDefaults.standard.set(newValue, forKey: "rr_avgBikeSpeed") }
    }
    
    static var ridersToMaintain: Int {
        get { UserDefaults.standard.object(forKey: "rr_ridersToMaintain") as? Int ?? 3 }
        set { UserDefaults.standard.set(newValue, forKey: "rr_ridersToMaintain") }
    }
    
    static var areaPerRider: Double {
        get { UserDefaults.standard.object(forKey: "rr_areaPerRider") as? Double ?? 150.0 } // ~1600 sq ft, much sparser
        set { UserDefaults.standard.set(newValue, forKey: "rr_areaPerRider") }
    }
    
    // Difficulty Settings
    static var speedGuardEnabled: Bool {
        get { UserDefaults.standard.object(forKey: "rr_speedGuardEnabled") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "rr_speedGuardEnabled") }
    }
    
    static var maxSpeed: CLLocationSpeed {
        get { UserDefaults.standard.object(forKey: "rr_maxSpeed") as? CLLocationSpeed ?? 8.0 }
        set { UserDefaults.standard.set(newValue, forKey: "rr_maxSpeed") }
    }
    
    static var mapType: Int {
        get { UserDefaults.standard.object(forKey: "rr_mapType") as? Int ?? Int(MKMapType.hybridFlyover.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: "rr_mapType") }
    }
    
    static var highTierChance: Double {
        get { UserDefaults.standard.object(forKey: "rr_highTierChance") as? Double ?? 0.20 }
        set { UserDefaults.standard.set(newValue, forKey: "rr_highTierChance") }
    }
    
    static var mediumTierChance: Double {
        get { UserDefaults.standard.object(forKey: "rr_mediumTierChance") as? Double ?? 0.35 }
        set { UserDefaults.standard.set(newValue, forKey: "rr_mediumTierChance") }
    }
    
    static var soundtrackEnabled: Bool {
        get { UserDefaults.standard.object(forKey: "rr_soundtrackEnabled") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "rr_soundtrackEnabled") }
    }
    
    static var cameraTiltEnabled: Bool {
        get { UserDefaults.standard.object(forKey: "rr_cameraTiltEnabled") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "rr_cameraTiltEnabled") }
    }
    
    static var densityFactor: Int {
        get { UserDefaults.standard.object(forKey: "rr_densityFactor") as? Int ?? 10 }
        set { UserDefaults.standard.set(newValue, forKey: "rr_densityFactor") }
    }
    
    // POI Strategy
    static var poiMode: String {
        get { UserDefaults.standard.object(forKey: "rr_poiMode") as? String ?? "Smart" }
        set { UserDefaults.standard.set(newValue, forKey: "rr_poiMode") }
    }
    
    // Tier Base Rewards
    static var tierGreen: TimeInterval {
        get { UserDefaults.standard.object(forKey: "rr_tierGreen") as? TimeInterval ?? 30.0 }
        set { UserDefaults.standard.set(newValue, forKey: "rr_tierGreen") }
    }
    
    static var tierYellow: TimeInterval {
        get { UserDefaults.standard.object(forKey: "rr_tierYellow") as? TimeInterval ?? 20.0 }
        set { UserDefaults.standard.set(newValue, forKey: "rr_tierYellow") }
    }
    
    static var tierOrange: TimeInterval {
        get { UserDefaults.standard.object(forKey: "rr_tierOrange") as? TimeInterval ?? 10.0 }
        set { UserDefaults.standard.set(newValue, forKey: "rr_tierOrange") }
    }
    
    // Visual Settings
    static var colorBlindMode: Bool {
        get { UserDefaults.standard.object(forKey: "rr_colorBlindMode") as? Bool ?? false }
        set { UserDefaults.standard.set(newValue, forKey: "rr_colorBlindMode") }
    }
    
    static var showRadii: Bool {
        get { UserDefaults.standard.object(forKey: "rr_showRadii") as? Bool ?? false }
        set { UserDefaults.standard.set(newValue, forKey: "rr_showRadii") }
    }
    
    static var forceMockGPS: Bool {
        get { UserDefaults.standard.object(forKey: "rr_forceMockGPS") as? Bool ?? false }
        set { UserDefaults.standard.set(newValue, forKey: "rr_forceMockGPS") }
    }
    
    static var pickupDwellTime: TimeInterval {
        get { UserDefaults.standard.object(forKey: "rr_pickupDwellTime") as? TimeInterval ?? 4.0 }
        set { UserDefaults.standard.set(newValue, forKey: "rr_pickupDwellTime") }
    }
    
    static var minSpawnDistanceFromPlayer: CLLocationDistance {
        get { UserDefaults.standard.object(forKey: "rr_minSpawnDistanceFromPlayer") as? CLLocationDistance ?? 30.48 } // 100 ft
        set { UserDefaults.standard.set(newValue, forKey: "rr_minSpawnDistanceFromPlayer") }
    }
    
    // Computed properties for easy access
    static var dropRadius: CLLocationDistance { pickupRadius } // Same as pickup per design
    static var pickupBonus: TimeInterval { 10.0 } // Fixed bonus
    
    static func restoreDefaults() {
        let defaults = UserDefaults.standard
        let keys = defaults.dictionaryRepresentation().keys.filter { $0.hasPrefix("rr_") }
        keys.forEach { defaults.removeObject(forKey: $0) }
    }
}

// MARK: ‑‑ Enhanced Domain Models (per Design Doc §3-5) ----------------------

enum Tier: String, CaseIterable, Codable {
    case high = "green"
    case medium = "yellow" 
    case low = "orange"
    
    var color: UIColor {
        let isColorBlind = GameSettings.colorBlindMode
        switch self {
        case .high:   return isColorBlind ? .systemBlue : .systemGreen
        case .medium: return isColorBlind ? .systemPurple : .systemYellow
        case .low:    return isColorBlind ? .systemBrown : .systemOrange
        }
    }
    
    var multiplier: Double {
        switch self {
        case .high: return 1.5
        case .medium: return 1.0
        case .low: return 0.75
        }
    }
    
    var sfSymbol: String {
        switch self {
        case .high: return "star.fill"      // High-value riders get star
        case .medium: return "circle.fill"  // Medium riders get circle
        case .low: return "triangle.fill"   // Low riders get triangle
        }
    }
    
    var baseReward: TimeInterval {
        switch self {
        case .high: return GameSettings.tierGreen
        case .medium: return GameSettings.tierYellow
        case .low: return GameSettings.tierOrange
        }
    }
    
    var shouldPulse: Bool {
        self == .high  // Only high-value riders pulse every 1s per design
    }
    
    static func randomTier() -> Tier {
        let randomValue = Double.random(in: 0...1)
        let highChance = GameSettings.highTierChance
        let mediumChance = GameSettings.mediumTierChance
        
        if randomValue < highChance {
            return .high
        } else if randomValue < highChance + mediumChance {
            return .medium
        } else {
            return .low
        }
    }
}

// POI Categories for SmartPOIStrategy (per Design Doc §7.3)
enum POICategory: String, CaseIterable {
    case publicTransport = "MKPointOfInterestCategoryPublicTransport"
    case bicycleParking = "MKPointOfInterestCategoryBicycleParking"
    case foodMarket = "MKPointOfInterestCategoryFoodMarket"
    case viewpoint = "MKPointOfInterestCategoryViewpoint"
    case park = "MKPointOfInterestCategoryPark"
    case trailhead = "MKPointOfInterestCategoryTrailhead"
    
    var weight: Double {
        switch self {
        case .viewpoint: return 1.4
        case .trailhead: return 1.3
        case .bicycleParking: return 1.2
        case .foodMarket: return 1.0
        default: return 0.9
        }
    }
    
    var mkCategory: MKPointOfInterestCategory {
        switch self {
        case .publicTransport: return .publicTransport
        case .bicycleParking: return .park  // Closest equivalent
        case .foodMarket: return .foodMarket
        case .viewpoint: return .park  // Closest equivalent
        case .park: return .park
        case .trailhead: return .park  // Closest equivalent
        }
    }
}

// Enhanced Rider model with POI context
struct Rider: Identifiable, Codable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let tier: Tier
    let spawned: Date
    let poiName: String?
    let poiCategory: String?
    let isReachable: Bool
    
    // Custom Codable for CLLocationCoordinate2D
    enum CodingKeys: CodingKey {
        case id, latitude, longitude, tier, spawned, poiName, poiCategory, isReachable
    }
    
    init(coordinate: CLLocationCoordinate2D, tier: Tier, poiName: String? = nil, poiCategory: String? = nil, isReachable: Bool = true) {
        self.id = UUID()
        self.coordinate = coordinate
        self.tier = tier
        self.spawned = Date()
        self.poiName = poiName
        self.poiCategory = poiCategory
        self.isReachable = isReachable
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(tier, forKey: .tier)
        try container.encode(spawned, forKey: .spawned)
        try container.encodeIfPresent(poiName, forKey: .poiName)
        try container.encodeIfPresent(poiCategory, forKey: .poiCategory)
        try container.encode(isReachable, forKey: .isReachable)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        let lat = try container.decode(Double.self, forKey: .latitude)
        let lon = try container.decode(Double.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        tier = try container.decode(Tier.self, forKey: .tier)
        spawned = try container.decode(Date.self, forKey: .spawned)
        poiName = try container.decodeIfPresent(String.self, forKey: .poiName)
        poiCategory = try container.decodeIfPresent(String.self, forKey: .poiCategory)
        isReachable = try container.decode(Bool.self, forKey: .isReachable)
    }
    
    var shouldDespawn: Bool {
        Date().timeIntervalSince(spawned) > 300  // 5 min despawn per design
    }
}

// Enhanced GameZone for persistence
struct GameZone: Identifiable, Codable {
    let id: UUID
    let name: String
    let coordinates: [CLLocationCoordinate2D]
    let created: Date
    
    var polygon: MKPolygon {
        MKPolygon(coordinates: coordinates, count: coordinates.count)
    }
    
    var areaKm2: Double {
        // Shoelace formula for polygon area
        guard coordinates.count >= 3 else { return 0 }
        var area: Double = 0
        for i in 0..<coordinates.count {
            let j = (i + 1) % coordinates.count
            area += coordinates[i].longitude * coordinates[j].latitude
            area -= coordinates[j].longitude * coordinates[i].latitude
        }
        return abs(area) * 0.5 * 111.32 * 111.32  // ~km²
    }
    
    var initialRiderCount: Int {
        let areaM2 = areaKm2 * 1_000_000
        let count = Int(areaM2 / GameSettings.areaPerRider)
        return max(1, count)
    }
    
    // Codable implementation for CLLocationCoordinate2D array
    enum CodingKeys: CodingKey {
        case id, name, created, coordinates
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(created, forKey: .created)
        let coordData = coordinates.map { ["lat": $0.latitude, "lon": $0.longitude] }
        try container.encode(coordData, forKey: .coordinates)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        created = try container.decode(Date.self, forKey: .created)
        let coordData = try container.decode([[String: Double]].self, forKey: .coordinates)
        coordinates = coordData.compactMap { dict in
            guard let lat = dict["lat"], let lon = dict["lon"] else { return nil }
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
    }
    
    init(name: String, coordinates: [CLLocationCoordinate2D]) {
        self.id = UUID()
        self.name = name
        self.coordinates = coordinates
        self.created = Date()
    }
}

// Enhanced Delivery model
struct Delivery: Identifiable, Codable {
    let id: UUID
    let rider: Rider
    let destination: CLLocationCoordinate2D
    let pickupTime: Date
    var dropoffTime: Date?
    var reward: TimeInterval = 0
    
    var isComplete: Bool { dropoffTime != nil }
    
    var tripDistance: CLLocationDistance {
        rider.coordinate.distance(to: destination)
    }
    
    var estimatedTravelTime: TimeInterval {
        tripDistance / GameSettings.avgBikeSpeed
    }
    
    // Codable implementation
    enum CodingKeys: CodingKey {
        case id, rider, latitude, longitude, pickupTime, dropoffTime, reward
    }
    
    init(rider: Rider, destination: CLLocationCoordinate2D) {
        self.id = UUID()
        self.rider = rider
        self.destination = destination
        self.pickupTime = Date()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(rider, forKey: .rider)
        try container.encode(destination.latitude, forKey: .latitude)
        try container.encode(destination.longitude, forKey: .longitude)
        try container.encode(pickupTime, forKey: .pickupTime)
        try container.encodeIfPresent(dropoffTime, forKey: .dropoffTime)
        try container.encode(reward, forKey: .reward)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        rider = try container.decode(Rider.self, forKey: .rider)
        let lat = try container.decode(Double.self, forKey: .latitude)
        let lon = try container.decode(Double.self, forKey: .longitude)
        destination = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        pickupTime = try container.decode(Date.self, forKey: .pickupTime)
        dropoffTime = try container.decodeIfPresent(Date.self, forKey: .dropoffTime)
        reward = try container.decode(TimeInterval.self, forKey: .reward)
    }
}

// Game Session tracking
struct GameSession: Identifiable, Codable {
    let id: UUID
    let zone: GameZone
    let startTime: Date
    var endTime: Date?
    var score: Int = 0
    var deliveries: [Delivery] = []
    var maxCountdown: TimeInterval = 0
    
    var duration: TimeInterval {
        (endTime ?? Date()).timeIntervalSince(startTime)
    }
    
    var isActive: Bool { endTime == nil }
    
    init(zone: GameZone, startTime: Date) {
        self.id = UUID()
        self.zone = zone
        self.startTime = startTime
    }
}

// Simple persistence using UserDefaults (Design Doc mentions CoreData, but keeping simple for single-file)
final class GameData {
    private let zonesKey = "rr_savedZones"
    private let scoresKey = "rr_gameScores"
    private let currentSessionKey = "rr_currentSession"
    
    static let shared = GameData()
    private init() {}
    
    func saveZone(_ zone: GameZone) {
        var zones = loadZones()
        zones.append(zone)
        if let data = try? JSONEncoder().encode(zones) {
            UserDefaults.standard.set(data, forKey: zonesKey)
        }
    }
    
    func loadZones() -> [GameZone] {
        guard let data = UserDefaults.standard.data(forKey: zonesKey),
              let zones = try? JSONDecoder().decode([GameZone].self, from: data) else {
            return []
        }
        return zones
    }
    
    func saveSession(_ session: GameSession) {
        if let data = try? JSONEncoder().encode(session) {
            UserDefaults.standard.set(data, forKey: currentSessionKey)
        }
    }
    
    func loadCurrentSession() -> GameSession? {
        guard let data = UserDefaults.standard.data(forKey: currentSessionKey),
              let session = try? JSONDecoder().decode(GameSession.self, from: data) else {
            return nil
        }
        return session
    }
    
    func clearCurrentSession() {
        UserDefaults.standard.removeObject(forKey: currentSessionKey)
    }
}

// MARK: ‑‑ Enhanced Location Manager (per Design Doc §4.1) ------------------

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let subject = PassthroughSubject<CLLocation, Never>()
    private let speedViolationSubject = PassthroughSubject<CLLocation, Never>()
    
    @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published private(set) var isActive: Bool = false
    @Published private(set) var currentLocation: CLLocation?
    
    var locationPublisher: AnyPublisher<CLLocation, Never> {
        subject.eraseToAnyPublisher()
    }
    
    var speedViolationPublisher: AnyPublisher<CLLocation, Never> {
        speedViolationSubject.eraseToAnyPublisher()
    }
    
    // Dual-mode operation per Design Doc §4.1
    enum Mode {
        case follow  // ±5m @ 1Hz when cycling (high accuracy)
        case idle    // ±50m, 30s for battery saving (significant location changes)
    }
    
    private var currentMode: Mode = .idle
    private var speedHistory: [CLLocationSpeed] = []
    private let maxSpeedHistoryCount = 10  // Track last 10 speed readings

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.activityType = .fitness
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestPermission() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            // UI layer should handle this
            break
        case .authorizedWhenInUse, .authorizedAlways:
            setMode(.idle)
        @unknown default:
            break
        }
    }
    
    func setMode(_ mode: Mode) {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            return
        }
        
        currentMode = mode
        
        switch mode {
        case .follow:
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 5.0  // 5m minimum movement
            locationManager.stopMonitoringSignificantLocationChanges()
            locationManager.startUpdatingLocation()
            isActive = true
            
        case .idle:
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.distanceFilter = 50.0  // 50m minimum movement
            locationManager.stopUpdatingLocation()
            
            if CLLocationManager.significantLocationChangeMonitoringAvailable() {
                locationManager.startMonitoringSignificantLocationChanges()
            }
            isActive = false
        }
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        isActive = false
        speedHistory.removeAll()
    }
    
    // MARK: - Speed Analysis (per Design Doc §4.2 concept)
    private func updateSpeedAnalysis(with location: CLLocation) {
        guard location.speed >= 0 else { return }
        
        speedHistory.append(location.speed)
        if speedHistory.count > maxSpeedHistoryCount {
            speedHistory.removeFirst()
        }
        
        // Average speed over last 5 readings
        let recentSpeeds = Array(speedHistory.suffix(5))
        let avgSpeed = recentSpeeds.reduce(0, +) / Double(recentSpeeds.count)
        
        if GameSettings.speedGuardEnabled && avgSpeed > GameSettings.maxSpeed && location.horizontalAccuracy < 20 {
            speedViolationSubject.send(location)
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentLocation = location
        updateSpeedAnalysis(with: location)
        subject.send(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            setMode(currentMode)
        case .denied, .restricted:
            stop()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
}

// MARK: ‑‑ Audio & Haptics Manager (per Design Doc §10) --------------------

final class AudioHapticsManager {
    private let speech = AVSpeechSynthesizer()
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let successGenerator = UINotificationFeedbackGenerator()
    private let warningGenerator = UINotificationFeedbackGenerator()
    private var backgroundMusicPlayer: AVAudioPlayer?
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleSettingsChange), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    @objc private func handleSettingsChange() {
        if !GameSettings.soundtrackEnabled {
            backgroundMusicPlayer?.pause()
        }
    }
    
    func say(_ s: String) {
        let utterance = AVSpeechUtterance(string: s)
        utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.voice.premium.en-US.Zoe") ?? AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.52
        utterance.pitchMultiplier = 1.1
        speech.speak(utterance)
    }

    func playPickupSound() {
        say("Rider on board!")
        impactGenerator.impactOccurred()
    }
    
    func playDropoffSound(reward: Int) {
        say("+ \(reward) seconds")
        successGenerator.notificationOccurred(.success)
    }
    
    func playBackgroundMusic() {
        guard GameSettings.soundtrackEnabled, backgroundMusicPlayer == nil else { return }
        
        // Note: The soundtrack file needs to be added to the Xcode project
        guard let url = Bundle.main.url(forResource: "crazy_soundtrack", withExtension: "m4a") else {
            print("RideRunner: crazy_soundtrack.m4a not found in bundle. Please add the soundtrack file to the Xcode project.")
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1
            backgroundMusicPlayer?.volume = 0.5  // 50% volume to not overpower voice
            backgroundMusicPlayer?.play()
        } catch {
            print("RideRunner: Could not load background music: \(error)")
        }
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
    }

    func pauseBackgroundMusic() {
        backgroundMusicPlayer?.pause()
    }
    
    func resumeBackgroundMusic() {
        guard GameSettings.soundtrackEnabled else { return }
        if backgroundMusicPlayer == nil {
            // If player was deallocated for some reason, recreate it
            playBackgroundMusic()
        } else {
            backgroundMusicPlayer?.play()
        }
    }
    
    func playSpeedWarning() {
        say("Slow down!")
        warningGenerator.notificationOccurred(.warning)
    }
    
    func playGameStartedSound() {
        say("Game started")
    }
    
    func playGameOver() {
        say("Game over")
    }
    
    func playTenSecondsRemaining() {
        say("Ten seconds!")
        // Three quick taps
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.impactGenerator.impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.impactGenerator.impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.impactGenerator.impactOccurred()
        }
    }
}

// MARK: ‑‑ Enhanced GameEngine (per Design Doc §3-5) -------------------------

final class GameEngine: ObservableObject {
    
    // Game states per design doc
    enum State {
        case ready, playing, paused, gameOver
    }

    // PUBLIC publishers
    @Published private(set) var countdown: TimeInterval = GameSettings.startTime
    @Published private(set) var score: Int = 0
    @Published private(set) var riders: [Rider] = []
    @Published private(set) var delivery: Delivery?
    @Published private(set) var state: State = .ready
    @Published private(set) var session: GameSession?

    // INTERNAL
    private let zone: GameZone
    private let locationManager: LocationManager
    private let audioHaptics = AudioHapticsManager()
    private var cancellables = Set<AnyCancellable>()
    private var fatigue: Double = 1
    private var timer: AnyCancellable?
    private var riderSelector: RiderSelector
    private var lastSpeedWarning: Date = Date.distantPast
    private let speedWarningCooldown: TimeInterval = 3.0
    private var riderDwellTimers: [UUID: Date] = [:]
    private var settingsObserver: Any?

    init(zone: GameZone, locationManager: LocationManager) {
        self.zone = zone
        self.locationManager = locationManager
        self.riderSelector = RiderSelectorFactory.create(mode: GameSettings.poiMode, zone: zone)
        setupGame()
        observeSettings()
    }
    
    deinit {
        if let observer = settingsObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func observeSettings() {
        settingsObserver = NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
            self?.riderSelector = RiderSelectorFactory.create(mode: GameSettings.poiMode, zone: self!.zone)
        }
    }
    
    private func setupGame() {
        session = GameSession(zone: zone, startTime: Date())
        countdown = GameSettings.startTime
        spawnInitialRiders()
        bindLocation()
        bindSpeedViolations()
    }

    func start() {
        guard state == .ready || state == .paused else { return }
        
        if state == .ready {
            audioHaptics.playBackgroundMusic()
            audioHaptics.playGameStartedSound()
            spawnInitialRiders() // Spawn riders only when game actually starts
        } else {
            audioHaptics.resumeBackgroundMusic()
        }
        
        state = .playing
        locationManager.setMode(.follow)
        
        timer = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }
    
    func pause() {
        guard state == .playing else { return }
        state = .paused
        timer?.cancel()
        timer = nil
        locationManager.setMode(.idle)
        audioHaptics.pauseBackgroundMusic()
    }
    
    func resume() {
        guard state == .paused else { return }
        start()
    }

    func reset() {
        timer?.cancel()
        timer = nil
        locationManager.setMode(.idle)
        
        countdown = GameSettings.startTime
        score = 0
        fatigue = 1
        delivery = nil
        riders.removeAll()
        state = .ready
        
        session = GameSession(zone: zone, startTime: Date())
        GameData.shared.clearCurrentSession()
    }

    // MARK: Timer & Game Loop
    private func tick() {
        guard state == .playing && countdown > 0 else {
        if countdown <= 0 {
                gameOver()
            }
            return
        }
        
        countdown = max(0, countdown - 0.5)
        
        // Despawn old riders and maintain pool
        cleanupRiders()
        maintainRiderPool()
        
        // Save session periodically
        if let session = session {
            GameData.shared.saveSession(session)
        }
        
        // Ten seconds warning
        if countdown <= 10 && countdown > 9.5 {
            audioHaptics.playTenSecondsRemaining()
        }
        
        if countdown <= 0 {
            gameOver()
        }
    }
    
    private func gameOver() {
        state = .gameOver
        timer?.cancel()
        timer = nil
        locationManager.setMode(.idle)
        
        session?.endTime = Date()
        session?.score = score
        if let session = session {
            GameData.shared.saveSession(session)
        }
        
        audioHaptics.playGameOver()
    }

    // MARK: Location binding
    private func bindLocation() {
        locationManager.locationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                if self?.state == .playing {
                    self?.handle(location: location)
                }
            }
            .store(in: &cancellables)
    }

    private func bindSpeedViolations() {
        locationManager.speedViolationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                let now = Date()
                if let self = self, now.timeIntervalSince(self.lastSpeedWarning) > self.speedWarningCooldown {
                    self.lastSpeedWarning = now
                    self.audioHaptics.playSpeedWarning()
                }
            }
            .store(in: &cancellables)
    }

    private func handle(location: CLLocation) {
        // Drop‑off first
        if var d = delivery {
            if location.distance(to: d.destination) <= GameSettings.dropRadius {
                d.dropoffTime = Date()
                complete(delivery: d, currentLocation: location)
            }
            return
        }

        // Check pickups with dwell time
        var riderToPickUp: Rider?
        
        for rider in riders {
            if location.distance(to: rider.coordinate) <= GameSettings.pickupRadius {
                if let dwellStartTime = riderDwellTimers[rider.id] {
                    if Date().timeIntervalSince(dwellStartTime) >= GameSettings.pickupDwellTime {
                        riderToPickUp = rider
                        break
                    }
                } else {
                    riderDwellTimers[rider.id] = Date()
                }
            } else {
                riderDwellTimers.removeValue(forKey: rider.id)
            }
        }
        
        if let rider = riderToPickUp {
            riders.removeAll { $0.id == rider.id }
            countdown += GameSettings.pickupBonus
            audioHaptics.playPickupSound()
            
            let destination = newDestination(from: rider.coordinate)
            delivery = Delivery(rider: rider, destination: destination)
            riderDwellTimers.removeAll()
        }
    }

    // MARK: Completion (per Design Doc §5 formulas)
    private func complete(delivery d: Delivery, currentLocation: CLLocation) {
        score += 1
        
        // Calculate reward using design doc formulas
        let dist = d.tripDistance
        let travel = dist / GameSettings.avgBikeSpeed
        let buffer = max(5, travel * 0.25)
        let reward = (d.rider.tier.baseReward + travel + buffer) * fatigue * d.rider.tier.multiplier
        
        countdown += reward
        fatigue *= GameSettings.fatigueRate
        
        audioHaptics.playDropoffSound(reward: Int(reward))
        delivery = nil
        
        // Add to session
        session?.deliveries.append(d)
        
        maintainRiderPool()
    }

    // MARK: Rider Management
    private func spawnInitialRiders() {
        let targetCount = zone.initialRiderCount
        let playerLocation = self.locationManager.currentLocation
        Task {
            let newRiders = await riderSelector.selectRiders(count: targetCount, existing: [], near: playerLocation)
            await MainActor.run {
                self.riders = newRiders
            }
        }
    }
    
    private func maintainRiderPool() {
        let currentCount = riders.count
        // Use zone's calculated rider count based on area and density setting
        let targetCount = zone.initialRiderCount
        let playerLocation = self.locationManager.currentLocation
        
        if currentCount < targetCount {
            let needed = targetCount - currentCount
            Task {
                let newRiders = await riderSelector.selectRiders(count: needed, existing: riders, near: playerLocation)
                await MainActor.run {
                    self.riders.append(contentsOf: newRiders)
                }
            }
        }
    }
    
    private func cleanupRiders() {
        riders.removeAll { $0.shouldDespawn }
    }

    private func newDestination(from start: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        var coord: CLLocationCoordinate2D
        var attempts = 0
        let maxAttempts = 100
        
        repeat {
            coord = randomPoint(in: zone.polygon)
            attempts += 1
            if attempts > maxAttempts {
                print("Warning: Could not find ideal destination after \(maxAttempts) attempts")
                break
            }
        } while start.distance(to: coord) < GameSettings.minTripDistance ||
                start.distance(to: coord) > GameSettings.maxTripDistance
        return coord
    }

    private func randomPoint(in polygon: MKPolygon) -> CLLocationCoordinate2D {
        let bbox = polygon.boundingMapRect
        var coord: CLLocationCoordinate2D
        var attempts = 0
        let maxAttempts = 1000
        
        repeat {
            coord = MKMapPoint(x: .random(in: bbox.minX...bbox.maxX),
                               y: .random(in: bbox.minY...bbox.maxY)).coordinate
            attempts += 1
            
            if attempts > maxAttempts {
                print("Warning: Could not find point inside polygon after \(maxAttempts) attempts")
                return MKMapPoint(x: bbox.midX, y: bbox.midY).coordinate
            }
        } while !MKMapPoint(coord).inside(polygon: polygon)
        return coord
    }
}

// MARK: ‑‑ Rider Selection Strategies (per Design Doc §7) --------------------

protocol RiderSelector {
    func selectRiders(count: Int, existing: [Rider], near playerLocation: CLLocation?) async -> [Rider]
}

// Factory for creating rider selectors
struct RiderSelectorFactory {
    static func create(mode: String, zone: GameZone) -> RiderSelector {
        switch mode.lowercased() {
        case "random":
            return RandomRiderSelector(zone: zone)
        case "curated":
            return CuratedRiderSelector(zone: zone)
        case "smart":
            return SmartPOIRiderSelector(zone: zone)
        default:
            return SmartPOIRiderSelector(zone: zone)  // Default to Smart
        }
    }
}

// Random Strategy (§7.1)
final class RandomRiderSelector: RiderSelector {
    private let zone: GameZone
    
    init(zone: GameZone) {
        self.zone = zone
    }
    
    func selectRiders(count: Int, existing: [Rider], near playerLocation: CLLocation?) async -> [Rider] {
        var newRiders: [Rider] = []
        let minDistance = GameSettings.minSpawnDistanceFromPlayer
        
        for _ in 0..<count {
            var coordinate: CLLocationCoordinate2D
            var attempts = 0
            let maxAttempts = 50
            
            repeat {
                coordinate = randomAccessiblePoint()
                attempts += 1
                if attempts > maxAttempts {
                    print("Could not find a spawn point far enough from the player.")
                    break
                }
            } while playerLocation != nil && CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude).distance(from: playerLocation!) < minDistance
            
            let tier = Tier.randomTier()
            let rider = Rider(coordinate: coordinate, tier: tier, poiName: nil, poiCategory: "random")
            newRiders.append(rider)
        }
        
        return newRiders
    }
    
    private func randomAccessiblePoint() -> CLLocationCoordinate2D {
        let polygon = zone.polygon
        let bbox = polygon.boundingMapRect
        var attempts = 0
        let maxAttempts = 100
        
        repeat {
            let coord = MKMapPoint(x: .random(in: bbox.minX...bbox.maxX),
                                  y: .random(in: bbox.minY...bbox.maxY)).coordinate
            attempts += 1
            
            if MKMapPoint(coord).inside(polygon: polygon) {
                return coord
            }
            
            if attempts > maxAttempts {
                // Fallback to center
                return MKMapPoint(x: bbox.midX, y: bbox.midY).coordinate
            }
        } while true
    }
}

// Curated Strategy (§7.2) with bundled POI data
final class CuratedRiderSelector: RiderSelector {
    private let zone: GameZone
    
    // Hardcoded Fort Mason demo POIs per design doc
    private let curatedPOIs: [CuratedPOI] = [
        CuratedPOI(id: "fm_viewpoint", name: "Great Meadow Point", 
                  lat: 37.80415, lon: -122.43090, desc: "View of Alcatraz", tier: .high),
        CuratedPOI(id: "fm_parking", name: "Bike Parking Area", 
                  lat: 37.80350, lon: -122.43120, desc: "Secure bike parking", tier: .medium),
        CuratedPOI(id: "fm_pier", name: "Pier 3", 
                  lat: 37.80280, lon: -122.43200, desc: "Historic pier", tier: .low),
        CuratedPOI(id: "fm_entrance", name: "Main Entrance", 
                  lat: 37.80480, lon: -122.43050, desc: "Fort Mason entrance", tier: .medium),
        CuratedPOI(id: "fm_museum", name: "Museum Area", 
                  lat: 37.80420, lon: -122.43150, desc: "Cultural exhibits", tier: .high)
    ]
    
    init(zone: GameZone) {
        self.zone = zone
    }
    
    func selectRiders(count: Int, existing: [Rider], near playerLocation: CLLocation?) async -> [Rider] {
        let minDistance = GameSettings.minSpawnDistanceFromPlayer

        // Filter POIs within zone and away from the player
        let validPOIs = curatedPOIs.filter { poi in
            let coord = CLLocationCoordinate2D(latitude: poi.lat, longitude: poi.lon)
            guard MKMapPoint(coord).inside(polygon: zone.polygon) else { return false }
            if let playerLoc = playerLocation {
                return CLLocation(latitude: coord.latitude, longitude: coord.longitude).distance(from: playerLoc) >= minDistance
            }
            return true
        }
        
        guard !validPOIs.isEmpty else {
            // Fallback to random if no POIs meet criteria
            return await RandomRiderSelector(zone: zone).selectRiders(count: count, existing: existing, near: playerLocation)
        }
        
        var riders: [Rider] = []
        let shuffledPOIs = validPOIs.shuffled()
        
        for i in 0..<count {
            let poi = shuffledPOIs[i % shuffledPOIs.count]
            let coordinate = CLLocationCoordinate2D(latitude: poi.lat, longitude: poi.lon)
            let rider = Rider(coordinate: coordinate, tier: poi.tier, 
                            poiName: poi.name, poiCategory: "curated")
            riders.append(rider)
        }
        
        return riders
    }
}

// Smart POI Strategy (§7.3) - Apple MapKit only
final class SmartPOIRiderSelector: RiderSelector {
    private let zone: GameZone
    private var cachedPOIs: [MKMapItem] = []
    private var lastCacheTime: Date = Date.distantPast
    private let cacheExpirationInterval: TimeInterval = 24 * 60 * 60  // 24 hours
    
    init(zone: GameZone) {
        self.zone = zone
    }
    
    func selectRiders(count: Int, existing: [Rider], near playerLocation: CLLocation?) async -> [Rider] {
        var pois = await fetchPOIs()
        let minDistance = GameSettings.minSpawnDistanceFromPlayer

        if let playerLoc = playerLocation {
            pois.removeAll { $0.placemark.location?.distance(from: playerLoc) ?? 0 < minDistance }
        }
        
        guard !pois.isEmpty else {
            // Fallback to random if no POIs found
            return await RandomRiderSelector(zone: zone).selectRiders(count: count, existing: existing, near: playerLocation)
        }
        
        // Score and sort POIs
        let scoredPOIs = scorePOIs(pois)
        
        var riders: [Rider] = []
        for i in 0..<min(count, scoredPOIs.count) {
            let poi = scoredPOIs[i]
            let tier = assignTierBasedOnScore(poi.score)
            let coordinate = poi.item.placemark.coordinate
            
            let rider = Rider(coordinate: coordinate, tier: tier,
                            poiName: poi.item.name, poiCategory: poi.category)
            riders.append(rider)
        }
        
        // Fill remaining with random if needed
        if riders.count < count {
            let remaining = count - riders.count
            let randomRiders = await RandomRiderSelector(zone: zone).selectRiders(count: remaining, existing: existing + riders, near: playerLocation)
            riders.append(contentsOf: randomRiders)
        }
        
        return riders
    }
    
    private func fetchPOIs() async -> [MKMapItem] {
        // Check cache first
        if !cachedPOIs.isEmpty && Date().timeIntervalSince(lastCacheTime) < cacheExpirationInterval {
            return cachedPOIs
        }
        
        let region = MKCoordinateRegion(zone.polygon.boundingMapRect)
        let request = MKLocalSearch.Request()
        request.region = region
        
        var allPOIs: [MKMapItem] = []
        
        // Search for each POI category
        for category in POICategory.allCases {
            request.pointOfInterestFilter = MKPointOfInterestFilter(including: [category.mkCategory])
            
            do {
                let search = MKLocalSearch(request: request)
                let response = try await search.start()
                
                let filteredItems = response.mapItems.filter { item in
                    guard let coord = item.placemark.location?.coordinate else { return false }
                    return MKMapPoint(coord).inside(polygon: zone.polygon)
                }
                
                allPOIs.append(contentsOf: filteredItems)
            } catch {
                print("POI search failed for \(category): \(error)")
            }
        }
        
        // Cache results
        cachedPOIs = allPOIs
        lastCacheTime = Date()
        
        return allPOIs
    }
    
    private func scorePOIs(_ pois: [MKMapItem]) -> [(item: MKMapItem, score: Double, category: String)] {
        let center = zone.polygon.boundingMapRect.center
        let maxDistance = zone.polygon.boundingMapRect.maxDistance
        
        let scored = pois.compactMap { poi -> (item: MKMapItem, score: Double, category: String)? in
            guard let location = poi.placemark.location else { return nil }
            
            let distance = CLLocation(coordinate: center).distance(from: location)
            let distanceScore = 1.0 - (distance / maxDistance)
            
            // Determine category and weight
            let category = categorizePOI(poi)
            let categoryWeight = POICategory(rawValue: category)?.weight ?? 0.9
            
            // Look Around bonus (simplified check)
            let landmarkBonus = poi.name?.contains("View") == true ? 1.2 : 1.0
            
            let finalScore = distanceScore * categoryWeight * landmarkBonus
            
            return (poi, finalScore, category)
        }
        
        return scored.sorted { $0.score > $1.score }
    }
    
    private func categorizePOI(_ poi: MKMapItem) -> String {
        // Simplified categorization based on name/type
        guard let name = poi.name?.lowercased() else { return "unknown" }
        
        if name.contains("park") || name.contains("trail") { return "park" }
        if name.contains("bike") || name.contains("parking") { return "bicycleParking" }
        if name.contains("view") || name.contains("lookout") { return "viewpoint" }
        if name.contains("market") || name.contains("food") { return "foodMarket" }
        if name.contains("transit") || name.contains("station") { return "publicTransport" }
        
        return "unknown"
    }
    
    private func assignTierBasedOnScore(_ score: Double) -> Tier {
        if score > 0.8 { return .high }
        if score > 0.5 { return .medium }
        return .low
    }
}

// Supporting data structures
struct CuratedPOI {
    let id: String
    let name: String
    let lat: Double
    let lon: Double
    let desc: String
    let tier: Tier
}

// MARK: ‑‑ Extensions helpers -----------------------------------------------

private extension AVSpeechSynthesizer {
    func say(_ s: String) {
        let utterance = AVSpeechUtterance(string: s)
        utterance.rate = 0.5
        speak(utterance)
    }
}

private extension CLLocation {
    /// Convenience distance to CLLocationCoordinate2D
    func distance(to coord: CLLocationCoordinate2D) -> CLLocationDistance {
        distance(from: CLLocation(latitude: coord.latitude, longitude: coord.longitude))
    }
    
    convenience init(coordinate: CLLocationCoordinate2D) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
}
}

private extension CLLocationCoordinate2D {
    func distance(to other: CLLocationCoordinate2D) -> CLLocationDistance {
        CLLocation(latitude: latitude, longitude: longitude)
            .distance(from: CLLocation(latitude: other.latitude, longitude: other.longitude))
    }
}

private extension MKMapPoint {
    func inside(polygon: MKPolygon) -> Bool {
        let renderer = MKPolygonRenderer(polygon: polygon)
        let point = renderer.point(for: self)
        return renderer.path.contains(point)
    }
}

private extension MKMapRect {
    var center: CLLocationCoordinate2D {
        MKMapPoint(x: midX, y: midY).coordinate
    }
    
    var maxDistance: CLLocationDistance {
        let corner1 = MKMapPoint(x: minX, y: minY).coordinate
        let corner2 = MKMapPoint(x: maxX, y: maxY).coordinate
        return CLLocation(coordinate: corner1).distance(from: CLLocation(coordinate: corner2))
    }
}

private extension MKCoordinateRegion {
    init(_ mapRect: MKMapRect) {
        let topLeft = MKMapPoint(x: mapRect.minX, y: mapRect.minY).coordinate
        let bottomRight = MKMapPoint(x: mapRect.maxX, y: mapRect.maxY).coordinate
        
        let center = CLLocationCoordinate2D(
            latitude: (topLeft.latitude + bottomRight.latitude) / 2,
            longitude: (topLeft.longitude + bottomRight.longitude) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: abs(topLeft.latitude - bottomRight.latitude),
            longitudeDelta: abs(topLeft.longitude - bottomRight.longitude)
        )
        
        self.init(center: center, span: span)
    }
}

// MARK: ‑‑ UI Layer ----------------------------------------------------------

final class HUDView: UIView {
    let timerLabel = HUDView.makeLabel(font: .monospacedDigitSystemFont(ofSize: 24, weight: .bold))
    let scoreLabel = HUDView.makeLabel(font: .monospacedSystemFont(ofSize: 18, weight: .medium))
    let statusLabel: UILabel = {
        let l = HUDView.makeLabel(font: .systemFont(ofSize: 16, weight: .semibold))
        l.numberOfLines = 0; return l
    }()
    private static func makeLabel(font: UIFont) -> UILabel {
        let l = UILabel(); l.translatesAutoresizingMaskIntoConstraints = false
        l.font = font
        l.textColor = .white
        l.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        l.textAlignment = .center
        l.layer.cornerRadius = 8; l.clipsToBounds = true
        return l
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        // Make the HUD view itself transparent to touches
        backgroundColor = .clear
        isUserInteractionEnabled = true
        
        addSubview(timerLabel)
        addSubview(scoreLabel)
        addSubview(statusLabel)

        NSLayoutConstraint.activate([
            timerLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            timerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            timerLabel.widthAnchor.constraint(equalToConstant: 160),
            timerLabel.heightAnchor.constraint(equalToConstant: 40),

            scoreLabel.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 8),
            scoreLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            scoreLabel.widthAnchor.constraint(equalTo: timerLabel.widthAnchor),
            scoreLabel.heightAnchor.constraint(equalToConstant: 32),

            statusLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            statusLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            statusLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
    
    // Override hit test to pass through touches except on actual labels
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Check if touch is on any of our labels
        for subview in subviews {
            let convertedPoint = subview.convert(point, from: self)
            if subview.bounds.contains(convertedPoint) {
                return subview
            }
        }
        // Touch is not on any label, pass through to underlying views
        return nil
    }
}

// VC where user draws zone --------------------------------

final class ZoneVC: UIViewController, MKMapViewDelegate {
    private let map = MKMapView()
    private var points: [CLLocationCoordinate2D] = []
    private var overlay: MKOverlay?
    private let locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()
    private var userLocationView: MKAnnotationView?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Draw Zone"
        map.frame = view.bounds; map.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        map.delegate = self; view.addSubview(map)
        map.showsUserLocation = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        map.addGestureRecognizer(tap)
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))
        let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(settingsTapped))
        navigationItem.rightBarButtonItems = [doneButton, settingsButton]
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearTapped))
        
        locationManager.requestPermission()
        
        locationManager.locationPublisher.first().sink { [weak self] location in
            self?.map.setRegion(MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000), animated: true)
        }.store(in: &cancellables)
        
        locationManager.locationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                if let userLocationView = self?.userLocationView, location.course >= 0 {
                    let rotation = (location.course * .pi) / 180.0
                    UIView.animate(withDuration: 0.5) {
                        userLocationView.transform = CGAffineTransform(rotationAngle: CGFloat(rotation))
                    }
                }
            }
            .store(in: &cancellables)
            
        locationManager.setMode(.follow)
    }

    @objc private func tap(_ g: UITapGestureRecognizer) {
        let co = map.convert(g.location(in: map), toCoordinateFrom: map)
        points.append(co)
        overlay.map { map.removeOverlay($0) }
        if points.count > 1 {
            let l = MKPolyline(coordinates: points, count: points.count)
            overlay = l; map.addOverlay(l)
        }
    }
    
    @objc private func clearTapped() {
        points.removeAll()
        overlay.map { map.removeOverlay($0) }
        overlay = nil
    }
    
    @objc private func settingsTapped() {
        let settingsVC = SettingsVC()
        let navController = UINavigationController(rootViewController: settingsVC)
        present(navController, animated: true)
    }

    @objc private func done() {
        guard points.count >= 3 else { 
            showAlert(title: "Invalid Zone", message: "Please create a zone with at least 3 points.")
            return 
        }
        
        // Create GameZone from points
        let zoneName = "Custom Zone \(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none))"
        let gameZone = GameZone(name: zoneName, coordinates: points)
        
        // Validate zone size
        if gameZone.areaKm2 < 0.001 {  // Very small area
            showAlert(title: "Zone Too Small", message: "Please create a larger zone for better gameplay.")
            return
        }
        
        // Save zone and navigate to game
        GameData.shared.saveZone(gameZone)
        navigationController?.pushViewController(GameVC(zone: gameZone), animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func mapView(_ mv: MKMapView, rendererFor o: MKOverlay) -> MKOverlayRenderer {
        if o is MKPolyline {
            let r = MKPolylineRenderer(overlay: o)
            r.strokeColor = .systemTeal; r.lineWidth = 3; return r
        }
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            let identifier = "userLocation"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if view == nil {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            view?.image = UIImage(systemName: "arrow.up.circle.fill")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 24, weight: .bold))
            self.userLocationView = view
            return view
        }
        return nil
    }
}

// Main Game VC -------------------------------------------

final class GameVC: UIViewController, MKMapViewDelegate {
    private let map = MKMapView()
    private let hud = HUDView()
    private let controlPanel = UIStackView()
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Game", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let pauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Pause", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.isHidden = true
        return button
    }()

    private let locationManager = LocationManager()
    private var engine: GameEngine!
    private var cancellables = Set<AnyCancellable>()
    private let zone: GameZone
    private var riderAnnotations: [String: RiderAnnotation] = [:]
    private var userLocationView: MKAnnotationView?
    private var settingsObserver: Any?

    init(zone: GameZone) {
        self.zone = zone
        super.init(nibName: nil, bundle: nil)
        engine = GameEngine(zone: zone, locationManager: locationManager)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "RideRunner"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(settingsTapped))
        checkLocationPermission()
        
        // Setup views in correct order for touch handling
        setupMap()      // Map at bottom
        setupHUD()      // HUD overlay (with touch pass-through)
        setupControls() // Control buttons on top
        
        bindEngine()
        observeSettings()
    }
    
    deinit {
        if let observer = settingsObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func observeSettings() {
        settingsObserver = NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
            self?.updateMapCamera()
        }
    }
    
    private func checkLocationPermission() {
        locationManager.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .notDetermined:
                    self?.locationManager.requestPermission()
                case .denied, .restricted:
                    self?.showLocationPermissionAlert()
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    private func showLocationPermissionAlert() {
        let alert = UIAlertController(
            title: "Location Permission Required",
            message: "RideRunner needs location access to track your cycling movement and detect when you reach pickup/dropoff points during gameplay.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func setupMap() {
        map.frame = view.bounds
        map.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        map.delegate = self
        map.showsUserLocation = true
        
        // Enable user interaction during gameplay
        map.isUserInteractionEnabled = true
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        map.isRotateEnabled = true
        map.isPitchEnabled = true
        
        // Add zone polygon overlay
        map.addOverlay(zone.polygon)
        updateMapCamera()
        
        // Optimize for cycling
        map.pointOfInterestFilter = .excludingAll  // Minimize POI clutter during gameplay
        
        view.addSubview(map)
    }

    private func updateMapCamera() {
        map.mapType = MKMapType(rawValue: UInt(GameSettings.mapType)) ?? .hybridFlyover
        
        // Only set initial camera if game hasn't started yet
        if engine.state == .ready {
            let camera: MKMapCamera
            if GameSettings.cameraTiltEnabled {
                camera = MKMapCamera(lookingAtCenter: zone.polygon.boundingMapRect.center, fromDistance: 2000, pitch: 45, heading: 0)
            } else {
                camera = MKMapCamera(lookingAtCenter: zone.polygon.boundingMapRect.center, fromDistance: 3000, pitch: 0, heading: 0)
            }
            map.setCamera(camera, animated: true)
        }
        // During gameplay, preserve user's camera position
    }

    private func setupHUD() {
        view.addSubview(hud)
        hud.frame = view.bounds
        hud.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // HUD now handles touch pass-through via hitTest override
    }
    
    private func setupControls() {
        controlPanel.axis = .horizontal
        controlPanel.spacing = 16
        controlPanel.distribution = .fillEqually
        controlPanel.translatesAutoresizingMaskIntoConstraints = false
        
        controlPanel.addArrangedSubview(startButton)
        controlPanel.addArrangedSubview(pauseButton)
        view.addSubview(controlPanel)
        
        NSLayoutConstraint.activate([
            controlPanel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controlPanel.bottomAnchor.constraint(equalTo: hud.statusLabel.topAnchor, constant: -20),
            controlPanel.widthAnchor.constraint(equalToConstant: 280),
            controlPanel.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pauseButtonTapped), for: .touchUpInside)
    }

    @objc private func startButtonTapped() {
        switch engine.state {
        case .ready, .paused:
            engine.start()
        case .gameOver:
            engine.reset()
        case .playing:
            break
        }
    }
    
    @objc private func pauseButtonTapped() {
        if engine.state == .playing {
            engine.pause()
        } else if engine.state == .paused {
            engine.resume()
        }
    }

    private func bindEngine() {
        // Bind countdown and score
        engine.$countdown.combineLatest(engine.$score)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] countdown, score in
                self?.hud.timerLabel.text = "Time: \(Int(countdown)) s"
                self?.hud.scoreLabel.text = "Deliveries: \(score)"
            }
            .store(in: &cancellables)

        // Bind game state
        engine.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateUI(for: state)
            }
            .store(in: &cancellables)

        // Bind delivery status
        engine.$delivery
            .receive(on: DispatchQueue.main)
            .sink { [weak self] delivery in
                let statusText = delivery == nil ? "Find a rider!" : "Take rider to destination!"
                self?.hud.statusLabel.text = statusText
                self?.updateDeliveryAnnotation(delivery)
                self?.updateRiderVisibility(hasDelivery: delivery != nil)
            }
            .store(in: &cancellables)

        // Bind riders - efficient update
        engine.$riders
            .receive(on: DispatchQueue.main)
            .sink { [weak self] riders in
                self?.updateRiderAnnotations(riders)
            }
            .store(in: &cancellables)
            
        locationManager.locationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                if let userLocationView = self?.userLocationView, location.course >= 0 {
                    let rotation = (location.course * .pi) / 180.0
                    UIView.animate(withDuration: 0.5) {
                        userLocationView.transform = CGAffineTransform(rotationAngle: CGFloat(rotation))
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(for state: GameEngine.State) {
        switch state {
        case .ready:
            startButton.setTitle("Start Game", for: .normal)
            startButton.backgroundColor = .systemGreen
            startButton.isHidden = false
            pauseButton.isHidden = true
            hud.statusLabel.text = "Tap Start to begin!"
            
        case .playing:
            startButton.isHidden = true
            pauseButton.setTitle("Pause", for: .normal)
            pauseButton.isHidden = false
            
        case .paused:
            startButton.setTitle("Resume", for: .normal)
            startButton.backgroundColor = .systemBlue
            startButton.isHidden = false
            pauseButton.isHidden = true
            hud.statusLabel.text = "Game Paused"
            
        case .gameOver:
        startButton.setTitle("Play Again", for: .normal)
            startButton.backgroundColor = .systemGreen
        startButton.isHidden = false
            pauseButton.isHidden = true
            hud.statusLabel.text = "Game Over! Final Score: \(engine.score) deliveries"
        }
    }
    
    // Efficient annotation management
    private func updateRiderAnnotations(_ riders: [Rider]) {
        let currentRiderIds = Set(riderAnnotations.keys)
        let newRiderIds = Set(riders.map { $0.id.uuidString })
        
        // Remove annotations for riders that no longer exist
        let ridersToRemove = currentRiderIds.subtracting(newRiderIds)
        for riderId in ridersToRemove {
            if let annotation = riderAnnotations.removeValue(forKey: riderId) {
                map.removeAnnotation(annotation)
            }
        }
        
        // Add annotations for new riders
        let ridersToAdd = newRiderIds.subtracting(currentRiderIds)
        for rider in riders where ridersToAdd.contains(rider.id.uuidString) {
            let annotation = RiderAnnotation(rider: rider, kind: .pickup)
            riderAnnotations[rider.id.uuidString] = annotation
            map.addAnnotation(annotation)
        }
    }
    
    private func updateDeliveryAnnotation(_ delivery: Delivery?) {
        // Remove existing delivery annotations
        let deliveryAnnotations = map.annotations.compactMap { $0 as? RiderAnnotation }.filter { $0.kind == .destination }
        map.removeAnnotations(deliveryAnnotations)
        
        // Add new delivery annotation if needed
        if let delivery = delivery {
            let annotation = RiderAnnotation(coordinate: delivery.destination, 
                                           tier: delivery.rider.tier, 
                                           kind: .destination,
                                           poiName: "Drop-off")
            map.addAnnotation(annotation)
        }
    }
    
    private func updateRiderVisibility(hasDelivery: Bool) {
        for annotation in map.annotations {
            guard let riderAnn = annotation as? RiderAnnotation, riderAnn.kind == .pickup else { continue }
            if let view = map.view(for: riderAnn) {
                view.alpha = hasDelivery ? 0.3 : 1.0
                view.isEnabled = !hasDelivery
            }
        }
    }

    // MARK: Map delegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let renderer = MKPolygonRenderer(overlay: overlay)
            renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
            renderer.strokeColor = .systemTeal
            renderer.lineWidth = 2
            return renderer
        }
        return MKOverlayRenderer()
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            let identifier = "userLocation"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if view == nil {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            view?.image = UIImage(systemName: "arrow.up.circle.fill")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 24, weight: .bold))
            self.userLocationView = view
            return view
        }
        
        guard let riderAnnotation = annotation as? RiderAnnotation else { return nil }
        let identifier = "riderAnnotation"
        
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            ?? MKMarkerAnnotationView(annotation: riderAnnotation, reuseIdentifier: identifier)
        
        annotationView.annotation = riderAnnotation
        annotationView.canShowCallout = true
        annotationView.markerTintColor = riderAnnotation.color
        annotationView.glyphImage = UIImage(systemName: riderAnnotation.sfSymbol)
        
        // Add pulsing animation for high-tier riders
        if riderAnnotation.tier.shouldPulse && riderAnnotation.kind == .pickup {
            addPulseAnimation(to: annotationView)
        } else {
            annotationView.layer.removeAnimation(forKey: "pulse")
        }
        
        return annotationView
    }
    
    private func addPulseAnimation(to view: MKAnnotationView) {
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.duration = 1.0
        pulse.fromValue = 1.0
        pulse.toValue = 1.3
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        view.layer.add(pulse, forKey: "pulse")
    }

    // MARK: Enhanced Annotation System
    final class RiderAnnotation: NSObject, MKAnnotation {
        enum Kind { case pickup, destination }
        
        let coordinate: CLLocationCoordinate2D
        let tier: Tier
        let kind: Kind
        let poiName: String?
        let rider: Rider?
        
        var title: String? {
            return poiName ?? (kind == .pickup ? "Rider" : "Destination")
        }
        
        var subtitle: String? {
            return "\(tier.rawValue.capitalized) tier"
        }
        
        var color: UIColor {
            kind == .destination ? .systemRed : tier.color
        }
        
        var sfSymbol: String {
            kind == .destination ? "flag.fill" : tier.sfSymbol
        }
        
        // For pickup riders
        init(rider: Rider, kind: Kind) {
            self.coordinate = rider.coordinate
            self.tier = rider.tier
            self.kind = kind
            self.poiName = rider.poiName
            self.rider = rider
        }
        
        // For destinations
        init(coordinate: CLLocationCoordinate2D, tier: Tier, kind: Kind, poiName: String? = nil) {
            self.coordinate = coordinate
            self.tier = tier
            self.kind = kind
            self.poiName = poiName
            self.rider = nil
        }
    }

    @objc private func settingsTapped() {
        let settingsVC = SettingsVC()
        let navController = UINavigationController(rootViewController: settingsVC)
        present(navController, animated: true)
    }
}

// MARK: ‑‑ Settings Screen (Placeholder) -------------------------------------

final class SettingsVC: UITableViewController {
    
    private enum Section: Int, CaseIterable {
        case coreGame, difficulty, visuals, advanced
    }
    
    private let cellIdentifier = "settingCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
    }
    
    @objc private func doneTapped() {
        dismiss(animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section) {
        case .coreGame: return "Core Gameplay"
        case .difficulty: return "Difficulty"
        case .visuals: return "Visuals & Map"
        case .advanced: return "Advanced"
        case .none: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch Section(rawValue: section) {
        case .coreGame:
            return "Adjust core mechanics like starting time, pickup radius, and how fatigue affects your rewards."
        case .difficulty:
            return "Customize the game's challenge. Rider density controls the area per rider. Tier probabilities adjust the chance of seeing high-value riders."
        case .visuals:
            return "Change the map's appearance, enable accessibility options, and toggle the game's soundtrack."
        case .advanced:
            return "Reset all settings to their original defaults."
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .coreGame: return 4
        case .difficulty: return 4
        case .visuals: return 4  // Changed from 3 to 4 to include soundtrack
        case .advanced: return 1
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
        
        switch Section(rawValue: indexPath.section) {
        case .coreGame:
            configureCoreGameCell(cell, for: indexPath.row)
        case .difficulty:
            configureDifficultyCell(cell, for: indexPath.row)
        case .visuals:
            configureVisualsCell(cell, for: indexPath.row)
        case .advanced:
            configureAdvancedCell(cell, for: indexPath.row)
        default:
            break
        }
        
        return cell
    }
    
    private func configureCoreGameCell(_ cell: UITableViewCell, for row: Int) {
        switch row {
        case 0:
            cell.textLabel?.text = "Start Time"
            addSlider(to: cell, value: Float(GameSettings.startTime), min: 30, max: 300) {
                GameSettings.startTime = TimeInterval($0)
                cell.detailTextLabel?.text = "\(Int($0)) s"
            }
        case 1:
            cell.textLabel?.text = "Pickup Radius"
            addSlider(to: cell, value: Float(GameSettings.pickupRadius), min: 3, max: 15) {
                GameSettings.pickupRadius = CLLocationDistance($0)
                cell.detailTextLabel?.text = "\(Int($0)) m"
            }
        case 2:
            cell.textLabel?.text = "Pickup Dwell Time"
            addSlider(to: cell, value: Float(GameSettings.pickupDwellTime), min: 1, max: 10) {
                GameSettings.pickupDwellTime = TimeInterval($0)
                cell.detailTextLabel?.text = "\(Int($0)) s"
            }
        case 3:
            cell.textLabel?.text = "Fatigue Rate"
            addSlider(to: cell, value: Float(GameSettings.fatigueRate), min: 0.8, max: 1.0) {
                GameSettings.fatigueRate = Double($0)
                cell.detailTextLabel?.text = String(format: "%.2f", $0)
            }
        default: break
        }
    }
    
    private func configureDifficultyCell(_ cell: UITableViewCell, for row: Int) {
        switch row {
        case 0:
            cell.textLabel?.text = "Speed Guard"
            addSwitch(to: cell, isOn: GameSettings.speedGuardEnabled) { GameSettings.speedGuardEnabled = $0 }
        case 1:
            cell.textLabel?.text = "Rider Density"
            addSlider(to: cell, value: Float(GameSettings.areaPerRider), min: 25, max: 500) {
                GameSettings.areaPerRider = Double($0)
                cell.detailTextLabel?.text = "1 per \(Int($0)) m²"
            }
        case 2:
            cell.textLabel?.text = "Min Spawn Distance"
            addSlider(to: cell, value: Float(GameSettings.minSpawnDistanceFromPlayer), min: 15, max: 100) {
                GameSettings.minSpawnDistanceFromPlayer = CLLocationDistance($0)
                cell.detailTextLabel?.text = "\(Int($0)) m"
            }
        case 3:
            cell.textLabel?.text = "High Tier Chance"
            addSlider(to: cell, value: Float(GameSettings.highTierChance), min: 0.05, max: 0.5) {
                GameSettings.highTierChance = Double($0)
                cell.detailTextLabel?.text = "\(Int($0 * 100))%"
            }
        default: break
        }
    }
    
    private func configureVisualsCell(_ cell: UITableViewCell, for row: Int) {
        switch row {
        case 0:
            cell.textLabel?.text = "Map Type"
            addSegmentedControl(to: cell, items: ["Standard", "Satellite", "3D"], selectedIndex: GameSettings.mapType) {
                GameSettings.mapType = $0
            }
        case 1:
            cell.textLabel?.text = "Camera Tilt"
            addSwitch(to: cell, isOn: GameSettings.cameraTiltEnabled) { GameSettings.cameraTiltEnabled = $0 }
        case 2:
            cell.textLabel?.text = "Color-blind Palette"
            addSwitch(to: cell, isOn: GameSettings.colorBlindMode) { GameSettings.colorBlindMode = $0 }
        case 3:
            cell.textLabel?.text = "Soundtrack"
            addSwitch(to: cell, isOn: GameSettings.soundtrackEnabled) { GameSettings.soundtrackEnabled = $0 }
        default: break
        }
    }
    
    private func configureAdvancedCell(_ cell: UITableViewCell, for row: Int) {
        if row == 0 {
            cell.textLabel?.text = "Restore Defaults"
            cell.textLabel?.textColor = .systemRed
            cell.accessoryType = .disclosureIndicator
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if Section(rawValue: indexPath.section) == .advanced && indexPath.row == 0 {
            let alert = UIAlertController(title: "Restore Defaults?", message: "All settings will be reset to their original values.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Restore", style: .destructive) { _ in
                GameSettings.restoreDefaults()
                tableView.reloadData()
            })
            present(alert, animated: true)
        }
    }
    
    private func addSlider(to cell: UITableViewCell, value: Float, min: Float, max: Float, action: @escaping (Float) -> Void) {
        let slider = UISlider()
        slider.minimumValue = min
        slider.maximumValue = max
        slider.value = value
        slider.addAction(UIAction { _ in action(slider.value) }, for: .valueChanged)
        cell.accessoryView = slider
        action(value) // Set initial text
    }
    
    private func addSwitch(to cell: UITableViewCell, isOn: Bool, action: @escaping (Bool) -> Void) {
        let toggle = UISwitch()
        toggle.isOn = isOn
        toggle.addAction(UIAction { _ in action(toggle.isOn) }, for: .valueChanged)
        cell.accessoryView = toggle
    }
    
    private func addSegmentedControl(to cell: UITableViewCell, items: [String], selectedIndex: Int, action: @escaping (Int) -> Void) {
        let segmentedControl = UISegmentedControl(items: items)
        let mapType = MKMapType(rawValue: UInt(selectedIndex))
        switch mapType {
        case .standard: segmentedControl.selectedSegmentIndex = 0
        case .satellite, .hybrid: segmentedControl.selectedSegmentIndex = 1
        case .satelliteFlyover, .hybridFlyover: segmentedControl.selectedSegmentIndex = 2
        default: segmentedControl.selectedSegmentIndex = 2
        }
        segmentedControl.addAction(UIAction { _ in
            let mapType: MKMapType
            switch segmentedControl.selectedSegmentIndex {
            case 0: mapType = .standard
            case 1: mapType = .satelliteFlyover
            case 2: mapType = .hybridFlyover
            default: mapType = .hybridFlyover
            }
            action(Int(mapType.rawValue))
        }, for: .valueChanged)
        cell.accessoryView = segmentedControl
    }
}

// MARK: ‑‑ App entry ---------------------------------------------------------

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ app: UIApplication,
                     didFinishLaunchingWithOptions opts: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: ZoneVC())
        window?.makeKeyAndVisible()
        return true
    }
}
