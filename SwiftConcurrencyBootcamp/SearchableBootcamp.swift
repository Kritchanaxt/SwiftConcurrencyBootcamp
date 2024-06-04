//
//  SearchableBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Kritchanat on 4/6/2567 BE.
//

// MARK: searchable
// ใช้เพื่อเพิ่มการค้นหาใน view ซึ่งช่วยให้ผู้ใช้สามารถกรองและค้นหารายการใน view นั้นได้อย่างง่ายดาย โดยทั่วไป searchable จะถูกใช้กับ views ที่แสดงรายการของข้อมูล เช่น List หรือ ScrollView

import SwiftUI
import Combine

struct Restaurant: Identifiable, Hashable {
    let id: String
    let title: String
    let cuisine: CuisineOption
}

// สร้าง enum CuisineOption เพื่อระบุประเภทของอาหาร
enum CuisineOption: String {
    case american, italian, japanese
}

// สร้างคลาส RestaurantManager ที่มีฟังก์ชัน getAllRestaurants เพื่อส่งคืนรายชื่อร้านอาหาร
final class RestaurantManager {
    func getAllRestaurants() async throws -> [Restaurant] {
        [
            Restaurant(id: "1", title: "Burger Shack", cuisine: .american),
            Restaurant(id: "2", title: "Pasta Palace", cuisine: .italian),
            Restaurant(id: "3", title: "Sushi Heaven", cuisine: .japanese),
            Restaurant(id: "4", title: "Local Market", cuisine: .american),
        ]
    }
}

// สร้างคลาส SearchableViewModel ที่ conform กับ ObservableObject เพื่อใช้ในการจัดการข้อมูลสำหรับ view
@MainActor
final class SearchableViewModel: ObservableObject {
    
    // ประกาศ properties ต่างๆ เช่น รายชื่อร้านอาหารทั้งหมด รายชื่อที่กรองแล้ว ข้อความค้นหา และตัวเลือกการค้นหา
    @Published private(set) var allRestaurants: [Restaurant] = []
    @Published private(set) var filteredRestaurants: [Restaurant] = []
    @Published var searchText: String = ""
    @Published var searchScope: SearchScopeOption = .all
    @Published private(set) var allSearchScopes: [SearchScopeOption] = []
    
    let manager = RestaurantManager()
    private var cancellables = Set<AnyCancellable>()
    
    var isSearching: Bool {
        !searchText.isEmpty
    }
    
    var showSearchSuggestions: Bool {
        searchText.count < 5
    }
    
    // สร้าง enum SearchScopeOption เพื่อระบุขอบเขตของการค้นหา
    enum SearchScopeOption: Hashable {
        case all
        case cuisine(option: CuisineOption)
        
        var title: String {
            switch self {
            case .all:
                return "All"
            case .cuisine(option: let option):
                return option.rawValue.capitalized
            }
        }
    }
    
    // ทำการเรียกฟังก์ชัน addSubscribers เพื่อสมัครสมาชิกกับ properties ที่ต้องการ
    init() {
        addSubscribers()
    }
    
    // ฟังก์ชัน addSubscribers ใช้ Combine ในการรวมค่า searchText และ searchScope แล้ว debounce ก่อนจะกรองร้านอาหาร
    private func addSubscribers() {
        $searchText
            .combineLatest($searchScope)
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] (searchText, searchScope) in
                self?.filterRestaurants(searchText: searchText, currentSearchScope: searchScope)
            }
            .store(in: &cancellables)
    }
    
    // ฟังก์ชัน filterRestaurants กรองรายชื่อร้านอาหารตามข้อความค้นหาและขอบเขตการค้นหา
    private func filterRestaurants(searchText: String, currentSearchScope: SearchScopeOption) {
        guard !searchText.isEmpty else {
            filteredRestaurants = []
            searchScope = .all
            return
        }
        
        // Filter on search scope
        var restaurantsInScope = allRestaurants
        switch currentSearchScope {
        case .all:
            break
        case .cuisine(let option):
            restaurantsInScope = allRestaurants.filter({ $0.cuisine == option })
        }
        
        
        // Filter on search text
        let search = searchText.lowercased()
        filteredRestaurants = restaurantsInScope.filter({ restaurant in
            let titleContainsSearch = restaurant.title.lowercased().contains(search)
            let cuisineContainsSearch = restaurant.cuisine.rawValue.lowercased().contains(search)
            return titleContainsSearch || cuisineContainsSearch
        })
    }
    
    // ฟังก์ชัน loadRestaurants โหลดร้านอาหารทั้งหมดและตั้งค่า allSearchScopes
    func loadRestaurants() async {
        do {
            allRestaurants = try await manager.getAllRestaurants()
            
            let allCuisines = Set(allRestaurants.map { $0.cuisine })
            allSearchScopes = [.all] + allCuisines.map({ SearchScopeOption.cuisine(option: $0) })
        } catch {
            print(error)
        }
    }
    
    // ฟังก์ชัน getSearchSuggestions สร้างคำแนะนำการค้นหาจากข้อความค้นหา
    func getSearchSuggestions() -> [String] {
        guard showSearchSuggestions else {
            return []
        }
        
        var suggestions: [String] = []
        
        let search = searchText.lowercased()
        
        if search.contains("pa") {
            suggestions.append("Pasta")
        }
        if search.contains("su") {
            suggestions.append("Sushi")
        }
        if search.contains("bu") {
            suggestions.append("Burger")
        }
        suggestions.append("Market")
        suggestions.append("Grocery")
        
        suggestions.append(CuisineOption.italian.rawValue.capitalized)
        suggestions.append(CuisineOption.japanese.rawValue.capitalized)
        suggestions.append(CuisineOption.american.rawValue.capitalized)

        return suggestions
    }
    
    // ฟังก์ชัน getRestaurantSuggestions สร้างคำแนะนำร้านอาหารจากข้อความค้นหา
    func getRestaurantSuggestions() -> [Restaurant] {
        guard showSearchSuggestions else {
            return []
        }
        
        var suggestions: [Restaurant] = []
        
        let search = searchText.lowercased()
        
        if search.contains("ita") {
            suggestions.append(contentsOf: allRestaurants.filter({ $0.cuisine == .italian }))
        }
        if search.contains("jap") {
            suggestions.append(contentsOf: allRestaurants.filter({ $0.cuisine == .japanese }))
        }

        return suggestions
    }
}

// สร้าง view SearchableBootcamp ที่แสดงรายชื่อร้านอาหาร พร้อมเพิ่มการค้นหาโดยใช้ .searchable, .searchScopes และ .searchSuggestions
struct SearchableBootcamp: View {
    
    @StateObject private var viewModel = SearchableViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(viewModel.isSearching ? viewModel.filteredRestaurants : viewModel.allRestaurants) { restaurant in
                    NavigationLink(value: restaurant) {
                        restaurantRow(restaurant: restaurant)
                    }
                }
            }
            .padding()
            
//            Text("ViewModel is searching: \(viewModel.isSearching.description)")
//            SearchChildView()
        }
        .searchable(text: $viewModel.searchText, placement: .automatic, prompt: Text("Search restaurants..."))
        .searchScopes($viewModel.searchScope, scopes: {
            ForEach(viewModel.allSearchScopes, id: \.self) { scope in
                Text(scope.title)
                    .tag(scope)
            }
        })
        .searchSuggestions({
            ForEach(viewModel.getSearchSuggestions(), id: \.self) { suggestion in
                Text(suggestion)
                    .searchCompletion(suggestion)
            }
            ForEach(viewModel.getRestaurantSuggestions(), id: \.self) { suggestion in
                NavigationLink(value: suggestion) {
                    Text(suggestion.title)
                }
            }
        })
//        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Restaurants")
        .task {
            await viewModel.loadRestaurants()
        }
        .navigationDestination(for: Restaurant.self) { restaurant in
            Text(restaurant.title.uppercased())
        }
    }
    
    private func restaurantRow(restaurant: Restaurant) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(restaurant.title)
                .font(.headline)
                .foregroundColor(.red)
            Text(restaurant.cuisine.rawValue.capitalized)
                .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.05))
        .tint(.primary)
    }
}

// สร้าง view SearchChildView เพื่อแสดงสถานะการค้นหา
struct SearchChildView: View {
    @Environment(\.isSearching) private var isSearching
    
    var body: some View {
        Text("Child View is searching: \(isSearching.description)")
    }
}

#Preview {
    SearchableBootcamp()
}
