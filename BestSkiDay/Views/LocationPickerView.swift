import SwiftUI
import CoreLocation
import CoreLocationUI

struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        Circle()
            .trim(from: 0, to: progress)
            .stroke(
                Color.accentColor,
                style: StrokeStyle(
                    lineWidth: 2,
                    lineCap: .round
                )
            )
            .rotationEffect(.degrees(-90))
            .frame(width: 16, height: 16)
    }
}

struct LocationPickerView: View {
    let currentLocation: Location
    let onLocationSelected: (Location) -> Void
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager()
    @StateObject private var geocodingService = GeocodingService()
    @State private var searchText = ""
    @State private var searchProgress = 0.0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search locations...", text: $searchText)
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .submitLabel(.search)
                    
                    if geocodingService.isSearching {
                        CircularProgressView(progress: searchProgress)
                            .onAppear {
                                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                                    searchProgress = 1.0
                                }
                            }
                            .onDisappear {
                                searchProgress = 0.0
                            }
                    } else if !searchText.isEmpty {
                        Button {
                            searchText = ""
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                List {
                    if !searchText.isEmpty {
                        ForEach(geocodingService.searchResults) { location in
                            Button {
                                onLocationSelected(location)
                                dismiss()
                            } label: {
                                HStack {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(.accentColor)
                                    Text(location.name)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    } else {
                        LocationButton(.currentLocation) {
                            Task {
                                locationManager.requestLocation()
                                // Try for 5 seconds (10 attempts * 0.5s)
                                for _ in 0..<10 {
                                    if let location = locationManager.currentLocation {
                                        onLocationSelected(location)
                                        dismiss()
                                        break
                                    }
                                    try? await Task.sleep(nanoseconds: 500_000_000)
                                }
                            }
                        }
                        .symbolVariant(.fill)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .frame(maxWidth: .infinity)
                        .listRowInsets(EdgeInsets())
                        .padding()
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Choose Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: searchText) { oldValue, newValue in
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000) // Debounce search
                await geocodingService.searchLocations(query: newValue)
            }
        }
    }
}