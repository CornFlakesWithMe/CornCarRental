import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Browse available cars
            CarBrowseView()
                .tabItem {
                    Label("Browse", systemImage: "car.fill")
                }
                .tag(0)
            
            // My listings (for car owners)
            MyListingsView()
                .tabItem {
                    Label("My Listings", systemImage: "list.bullet")
                }
                .tag(1)
            
            // Bookings view (both made and received)
            BookingsView()
                .tabItem {
                    Label("Bookings", systemImage: "calendar")
                }
                .tag(2)
            
            // Profile view
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
    }
}

// Preview provider for SwiftUI Canvas
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
