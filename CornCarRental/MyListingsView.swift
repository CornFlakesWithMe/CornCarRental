import SwiftUI

struct MyListingsView: View {
    @State private var listings: [CarListing] = []
    @State private var showingAddCarSheet = false
    
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
                AddCarView(onSave: { newListing in
                    listings.append(newListing)
                    showingAddCarSheet = false
                })
            }
        }
    }
    
    private func deleteListings(at offsets: IndexSet) {
        listings.remove(atOffsets: offsets)
        // In a real app, you would also update your data source
    }
}

struct ListingDetailView: View {
    let listing: CarListing
    
    var body: some View {
        Text("Listing Detail View")
            .navigationTitle("\(listing.car.make) \(listing.car.model)")
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

// Stub for adding a new car
struct AddCarView: View {
    let onSave: (CarListing) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    // Fields to create a new car
    @State private var make = ""
    @State private var model = ""
    @State private var year = 2023
    @State private var basePrice = 75.0
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Car Details")) {
                    TextField("Make", text: $make)
                    TextField("Model", text: $model)
                    Picker("Year", selection: $year) {
                        ForEach(2010...2025, id: \.self) { year in
                            Text("\(year)").tag(year)
                        }
                    }
                }
                
                Section(header: Text("Pricing")) {
                    HStack {
                        Text("Base Price per Day")
                        Spacer()
                        TextField("Price", value: $basePrice, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("$").font(.headline)
                    }
                }
                
                Button("Save") {
                    // In a real app, you would create a real CarListing here
                    // For now, just dismiss
                    presentationMode.wrappedValue.dismiss()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            }
            .navigationTitle("Add Car")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
