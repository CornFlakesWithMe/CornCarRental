import SwiftUI

struct CarBrowseView: View {
    @State private var searchText = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(24 * 60 * 60 * 3) // 3 days later
    @State private var showFilters = false
    @State private var cars: [CarListing] = [] // Would be populated from your data source
    
    var body: some View {
        NavigationView {
            VStack {
                // Date selection
                VStack(alignment: .leading) {
                    Text("When do you need a car?")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack {
                        DatePicker("From", selection: $startDate, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(CompactDatePickerStyle())
                            .padding(.horizontal)
                        
                        DatePicker("To", selection: $endDate, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(CompactDatePickerStyle())
                            .padding(.horizontal)
                    }
                    .padding(.bottom)
                }
                
                // Search button
                Button(action: {
                    // Search logic would be implemented here
                    searchCars()
                }) {
                    Text("Search Available Cars")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.bottom)
                
                // Filter button
                Button(action: {
                    showFilters.toggle()
                }) {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text("Filters")
                    }
                    .foregroundColor(.blue)
                }
                .padding(.bottom)
                
                // Results list
                if cars.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "car")
                            .font(.system(size: 72))
                            .foregroundColor(.gray)
                        Text("Search for available cars")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(cars, id: \.car.id) { carListing in
                            NavigationLink(destination: CarDetailView(carListing: carListing)) {
                                CarListItemView(carListing: carListing)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Find a Car")
            .sheet(isPresented: $showFilters) {
                FilterView(applyFilters: applyFilters)
            }
        }
    }
    
    // Function to search for cars
    private func searchCars() {
        // In a real app, this would fetch data from CarListingManager
        // For now, we'll just set up some dummy data
        let dummyListings = createDummyListings()
        cars = dummyListings.filter { listing in
            listing.isAvailable(from: startDate, to: endDate)
        }
    }
    
    // Function to apply filters from the filter view
    private func applyFilters(make: String?, maxPrice: Double?, features: [Car.Feature]) {
        // This would be implemented to filter the results further
        // For now, just a stub
    }
    
    // Helper function to create dummy data
    private func createDummyListings() -> [CarListing] {
        // This would be replaced with real data in your actual app
        return []
    }
}

// A view for displaying a car listing item in the list
struct CarListItemView: View {
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
                
                Text(carListing.pickupLocation.city)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Rating
            VStack {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", carListing.averageRating))
                }
                .font(.caption)
                
                Text("(\(carListing.numberOfReviews))")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

// Stub for car detail view
struct CarDetailView: View {
    let carListing: CarListing
    
    var body: some View {
        Text("Car Details")
            .navigationTitle("\(carListing.car.make) \(carListing.car.model)")
    }
}

// Stub for filter view
struct FilterView: View {
    let applyFilters: (String?, Double?, [Car.Feature]) -> Void
    @State private var selectedMake: String?
    @State private var maxPrice: Double = 200
    @State private var selectedFeatures: Set<Car.Feature> = []
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Car Make")) {
                    Picker("Make", selection: $selectedMake) {
                        Text("Any").tag(nil as String?)
                        Text("Toyota").tag("Toyota" as String?)
                        Text("Honda").tag("Honda" as String?)
                        Text("Ford").tag("Ford" as String?)
                        Text("BMW").tag("BMW" as String?)
                        Text("Tesla").tag("Tesla" as String?)
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Max Price Per Day")) {
                    Slider(value: $maxPrice, in: 10...500, step: 10) {
                        Text("Max Price: $\(Int(maxPrice))")
                    }
                    Text("$\(Int(maxPrice))")
                }
                
                Section(header: Text("Features")) {
                    ForEach(Car.Feature.allCases, id: \.self) { feature in
                        Toggle(feature.rawValue.capitalized, isOn: Binding(
                            get: { selectedFeatures.contains(feature) },
                            set: { isSelected in
                                if isSelected {
                                    selectedFeatures.insert(feature)
                                } else {
                                    selectedFeatures.remove(feature)
                                }
                            }
                        ))
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarItems(trailing: Button("Apply") {
                applyFilters(selectedMake, maxPrice, Array(selectedFeatures))
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
