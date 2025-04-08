import Foundation

// Manages all car listings in the system
class CarListingManager {
    // Singleton pattern for global access
    static let shared = CarListingManager()
    
    private init() {}
    
    // Storage for all car listings
    private var carListings: [UUID: CarListing] = [:]
    
    // Add a new car listing
    func addCarListing(_ listing: CarListing) -> UUID {
        let id = listing.car.id
        carListings[id] = listing
        return id
    }
    
    // Get a car listing by ID
    func getCarListing(by id: UUID) -> CarListing? {
        return carListings[id]
    }
    
    // Update a car listing
    func updateCarListing(_ listing: CarListing) -> Bool {
        let id = listing.car.id
        if carListings[id] != nil {
            carListings[id] = listing
            return true
        }
        return false
    }
    
    // Remove a car listing
    func removeCarListing(by id: UUID) -> Bool {
        if carListings[id] != nil {
            carListings.removeValue(forKey: id)
            return true
        }
        return false
    }
    
    // Search for available cars based on criteria
    func searchAvailableCars(
        from startDate: Date,
        to endDate: Date,
        location: String? = nil,
        make: String? = nil,
        model: String? = nil,
        maxPrice: Double? = nil
    ) -> [CarListing] {
        return carListings.values.filter { listing in
            // Check availability for the requested dates
            let isAvailable = listing.isAvailable(from: startDate, to: endDate)
            
            // Apply other filters if provided
            let matchesLocation = location == nil ||
                                  listing.pickupLocation.city.lowercased().contains(location!.lowercased()) ||
                                  listing.pickupLocation.state.lowercased().contains(location!.lowercased())
            
            let matchesMake = make == nil || listing.car.make.lowercased() == make!.lowercased()
            
            let matchesModel = model == nil || listing.car.model.lowercased().contains(model!.lowercased())
            
            let matchesPrice = maxPrice == nil || listing.rentalPrices.basePrice <= maxPrice!
            
            return isAvailable && matchesLocation && matchesMake && matchesModel && matchesPrice
        }
    }
    
    // Get all listings for a specific owner
    func getListingsForOwner(_ ownerID: UUID) -> [CarListing] {
        return carListings.values.filter { $0.owner.id == ownerID }
    }
}
