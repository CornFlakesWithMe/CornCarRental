import Foundation

// Car model that represents a vehicle in the system
struct Car {
    let id: UUID
    let make: String
    let model: String
    let year: Int
    let mileage: Double
    let transmission: TransmissionType
    let fuelType: FuelType
    let licensePlate: String
    let images: [URL]
    let features: [Feature]
    
    // Additional properties
    var isAvailable: Bool = true
    
    enum TransmissionType: String, Codable {
        case automatic
        case manual
    }
    
    enum FuelType: String, Codable {
        case gasoline
        case diesel
        case hybrid
        case electric
    }
    
    enum Feature: String, Codable, CaseIterable {
        case airConditioning
        case gps
        case bluetooth
        case backupCamera
        case sunroof
        case leatherSeats
        case heatedSeats
        case premiumSoundSystem
    }
}

// Extension for convenience methods
extension Car {
    // No reference to rentalPrices here since it's part of CarListing, not Car
    // If needed, we can create a default base price for the car
    var suggestedBasePrice: Double {
        // This could have logic based on car make, model, year, etc.
        // For now, just a simple calculation
        let baseAmount = 50.0
        let yearFactor = Double(max(0, 2025 - year)) * 2.0 // Older cars cost less
        return baseAmount - yearFactor
    }
}
