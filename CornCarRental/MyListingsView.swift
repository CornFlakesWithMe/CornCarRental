import SwiftUI

struct MyListingsView: View {
    @State private var listings: [CarListing] = []
    @State private var showingAddCarSheet = false
    
    // Mock user for the current user (in a real app, this would come from authentication)
    private let currentUser = User(
        name: "John Smith",
        email: "john@example.com",
        phoneNumber: "555-123-4567"
    )
    
    var body: some View {
        NavigationView {
            VStack {
                if listings.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "car.2")
                            .font(.system(size: 72))
                            .foregroundColor(.gray)
                        Text("You don't have any car listings yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Button("Add Your First Car") {
                            showingAddCarSheet = true
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(listings, id: \.car.id) { listing in
                            NavigationLink(destination: ListingDetailView(listing: listing)) {
                                MyListingItemView(carListing: listing)
                            }
                        }
                        .onDelete(perform: deleteListings)
                    }
                }
            }
            .navigationTitle("My Car Listings")
            .navigationBarItems(trailing: Button(action: {
                showingAddCarSheet = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddCarSheet) {
                AddCarView(currentUser: currentUser, onSave: { newListing in
                    // Add the new listing to our array
                    listings.append(newListing)
                    
                    // In a real app, you would also save this to a database or API
                    // For now, we'll just add it to our CarListingManager
                    let _ = CarListingManager.shared.addCarListing(newListing)
                    
                    showingAddCarSheet = false
                })
            }
        }
    }
    
    private func deleteListings(at offsets: IndexSet) {
        // Remove from local array
        offsets.forEach { index in
            let listing = listings[index]
            // Remove from CarListingManager too
            CarListingManager.shared.removeCarListing(by: listing.car.id)
        }
        
        listings.remove(atOffsets: offsets)
    }
}

struct ListingDetailView: View {
    let listing: CarListing
    @State private var isEditingListing = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Car image placeholder
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(16/9, contentMode: .fit)
                    
                    Image(systemName: "car.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                }
                .cornerRadius(12)
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(listing.car.year) \(listing.car.make) \(listing.car.model)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text("$\(Int(listing.rentalPrices.basePrice))/day")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        Spacer()
                        
                        Text("Mileage: \(Int(listing.car.mileage)) mi")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Divider()
                    
                    Text("Description")
                        .font(.headline)
                    
                    Text(listing.description)
                        .font(.body)
                        .padding(.top, 2)
                    
                    Divider()
                    
                    Text("Rules")
                        .font(.headline)
                    
                    ForEach(listing.rules, id: \.self) { rule in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                            Text(rule)
                                .font(.subheadline)
                        }
                        .padding(.top, 2)
                    }
                    
                    Divider()
                    
                    Text("Pickup Location")
                        .font(.headline)
                    
                    Text(listing.pickupLocation.formattedAddress)
                        .font(.subheadline)
                }
                .padding(.horizontal)
                
                Button(action: {
                    isEditingListing = true
                }) {
                    Text("Edit Listing")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Listing Details")
        .sheet(isPresented: $isEditingListing) {
            Text("Edit Listing View")
            // In a real app, you would create an edit form here
        }
    }
}

struct MyListingItemView: View {
    let carListing: CarListing
    
    var body: some View {
        HStack {
            // Car image
            Image(systemName: "car.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(carListing.car.year) \(carListing.car.make) \(carListing.car.model)")
                    .font(.headline)
                
                Text("$\(Int(carListing.rentalPrices.basePrice))/day")
                    .font(.subheadline)
                    .foregroundColor(.green)
                
                // Show availability status
                Text(carListing.car.isAvailable ? "Available" : "Unavailable")
                    .font(.caption)
                    .foregroundColor(carListing.car.isAvailable ? .green : .red)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
