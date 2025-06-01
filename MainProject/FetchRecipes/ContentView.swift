//
//  ContentView.swift
//  FetchRecipes
//
//  Created by RMT on 4/29/25.
//

import SwiftUI

//*Test that Cache is working by Fetching Using the Same* Endpoint.
//*Refresh by Pulling Screen down or Clicking Same Endpoint Twice.


struct ContentView: View {
    let apiService:APIServicesProtocol = APIServices.shared
    @State private var recipes:[Recipe] = [] /// The working array
    @State private var originalRecipes:[Recipe] = [] /// Allows fallback to original
    @State private var lastEndpointUsed:String?
    @State private var isShowingSearchBar:Bool = false
    @State private var searchText:String = ""
    @State private var selectedEndpointButton:String? = ""
    
    ///Allows for Multiple Alerts (b/c only one .alert{ } allowed)
    @State private var activeAlert: ActiveAlertType?
    enum ActiveAlertType: Identifiable {
        case favoritesEmpty
        case searchEmpty
        case recipesEmpty
        case firstTimeNoFetch
        //req.
        var id: Int {
            hashValue
        }
    }
    
    var searchFilteredRecipes: [Recipe] {
        if searchText.isEmpty{
            return recipes
        }else{
            return recipes.filter{
                ///Search by Filtered name or cuisine
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.cuisine.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    let columns = [
        GridItem(.adaptive(minimum: 150))
    ]
    
    var body: some View {
        NavigationStack{
            ZStack{
                //BACKGROUND COLOR
                Color.yellow
                    .opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                
                // BACKGROUND DOG PATTERN
                BackgroundPatternView()
                
                //MAIN SCROLLVIEW
                ScrollView {
                    //SEARCH BAR
                    if isShowingSearchBar{
                        SearchBar(seachText: $searchText,searchAction:{
                            ///Make sure not empty & show alert
                            if searchFilteredRecipes.isEmpty{
                                //isSearchEmpty = true
                                activeAlert = .searchEmpty
                                return //early exit
                            }
                            ///Assign filtered results
                            recipes = searchFilteredRecipes
                        })
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.easeInOut, value: isShowingSearchBar)
                    }
                    
                    //RECIPES GRID
                    LazyVGrid(columns: columns) {
                        ForEach(recipes){ recipe in
                            NavigationLink{
                                RecipeDetailView(recipe: recipe)
                            } label:{
                                //THE TAPPABLE SQUARES
                                RecipeCardView(recipe: recipe)
                                
                            }
                        }
                    }
                    //END LAZYVGRID
                    .padding([.horizontal,.bottom])
                    
                    Spacer()
                    
                }//END SCROLLVIEW
                
            }//END MAIn ZSTACK
            .onAppear{
                if recipes.isEmpty{
                    activeAlert = .firstTimeNoFetch
                }
            }
            .toolbar {
                ToolbarItem(placement:.navigation) {
                    HStack(spacing: 5) {
                        Text("fetch")
                            .font(.title).fontWeight(.heavy)
                            .foregroundStyle(recipes.isEmpty ? Color.secondary : Color.purple)
                        Image(systemName: recipes.isEmpty ? "dog.fill" : "dog.fill").fontWeight(.heavy)
                            .foregroundStyle(recipes.isEmpty ? Color.secondary : Color.purple)
                    }
                }
            }
            .toolbar{
                Menu {
                    //sort:updates current array VS sorted:creates new array
                    Text("Sort By:")
                    Button("Name A to Z", systemImage: "fork.knife") {
                        recipes = recipes.sorted{$0.name < $1.name}
                    }
                    Button("Name Z to A", systemImage: "fork.knife") {
                        recipes = recipes.sorted{$0.name > $1.name}
                    }
                    Button("Country A to Z", systemImage: "globe") {
                        recipes = recipes.sorted{$0.cuisine < $1.cuisine}
                    }
                    Button("Country Z to A", systemImage: "globe") {
                        recipes = recipes.sorted{$0.cuisine > $1.cuisine}
                    }
                    Button("Favorite", systemImage: "heart.fill") {
                        let favorites = recipes.filter{$0.isFavorite}
                        if favorites.isEmpty{
                            activeAlert = .favoritesEmpty
                            return //Exit out. don't assing an empty array
                        }
                        recipes = recipes.filter{$0.isFavorite}
                    }
                    Button("Show All", systemImage: "list.bullet.rectangle.portrait") {
                        recipes = originalRecipes
                    }
                } label: {
                    Image(systemName: "list.bullet")
                }
                .foregroundColor(recipes.isEmpty ? Color.secondary : Color.purple)
                .bold()
                .disabled(recipes.isEmpty) // Don't Sort if empty
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        isShowingSearchBar.toggle()
                    }) {
                        Image(systemName: "magnifyingglass")
                    }
                    .foregroundStyle(recipes.isEmpty ? Color.secondary : Color.purple)
                    .bold()
                    .disabled(recipes.isEmpty)
                }
                
            }
            .alert(item: $activeAlert) { type in
                switch type {
                case .favoritesEmpty:
                    return Alert(
                        title: Text("No Favorites"),
                        message: Text("You have no favorites yet!"),
                        dismissButton: .default(Text("OK"))
                    )
                case .searchEmpty:
                    return Alert(
                        title: Text("No Results for \(searchText)"),
                        message: Text("Try a different search"),
                        dismissButton: .default(Text("OK"), action: {
                            searchText = ""
                        })
                    )
                case .recipesEmpty:
                    return Alert(
                        title: Text("Your Recipes List is Empty"),
                        message: Text("Try fetching from a different endpoint"),
                        dismissButton: .default(Text("OK"), action: {})
                    )
                case .firstTimeNoFetch:
                    return Alert(
                        title: Text("Welcome"),
                        message: Text("Please choose an endpoint to fetch from"),
                        dismissButton: .default(Text("OK"), action: {})
                    )
                    
                }
            }
            .refreshable {
                if let lastendpoint = lastEndpointUsed{
                    Task {
                        do {
                            print("- REFRESHING DATA WITH LAST KNOWN END POINT: \(lastendpoint)")
                            try await fetchFoodItems(forEndPoint: lastendpoint)
                        } catch {
                            print("Error Fetching Complete Endpoint: \(error)")
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom, content: {
                HStack{
                    Spacer()
                    
                    VStack{
                        Text("Select an Endpoint")
                            .font(.title).bold().textCase(.uppercase).fontWeight(.medium)
                            .foregroundStyle(Color.white)
                            .shadow(color:.black ,radius: 1, x:2 , y: 2)
                        
                        //THREE BUTTONS
                        HStack{
                            Button {
                                selectedEndpointButton = "COMPLETE"
                                Task {
                                    do {
                                        try await fetchFoodItems(forEndPoint: APIServices.completeEndPoint)
                                    } catch {
                                        print("Error Fetching Complete Endpoint: \(error)")
                                    }
                                }
                            } label: {
                                Text("COMPLETE")
                                    .font(.subheadline).bold()
                                    .foregroundStyle(selectedEndpointButton == "COMPLETE" ? Color.white : Color.secondary)
                                    .shadow(color:.purple ,radius: 1, x:1 , y: 1)
                                
                            }
                            
                            Button {
                                selectedEndpointButton = "MALFORMED"
                                Task {
                                    do {
                                        try await fetchFoodItems(forEndPoint: APIServices.malformedEndPoint)
                                    } catch {
                                        print("Error Fetching Malformed Endpoint: \(error)")
                                    }
                                }
                            } label: {
                                Text("MALFORMED")
                                    .font(.subheadline).bold()
                                    .foregroundStyle(selectedEndpointButton == "MALFORMED" ? Color.white : Color.secondary)
                                    .shadow(color:.purple ,radius: 1, x:1 , y: 1)
                            }
                            
                            Button {
                                selectedEndpointButton = "EMPTY"
                                Task {
                                    do {
                                        try await fetchFoodItems(forEndPoint: APIServices.emptyEndPoint)
                                    } catch {
                                        print("Error Fetching Complete Data: \(error)")
                                    }
                                }
                            } label: {
                                Text("EMPTY")
                                    .font(.subheadline).bold()
                                    .foregroundStyle(selectedEndpointButton == "EMPTY" ? Color.white : Color.secondary)
                                    .shadow(color:.purple,radius: 1, x:1 , y: 1)
                            }
                        }
                        .padding(.horizontal)
                        .font(.caption).bold()
                        .foregroundStyle(.blue).bold()
                        .background(Color.white.opacity(0.3))
                        .clipShape(.capsule)
                        
                    }
                    .padding(.top)
                    
                    Spacer()
                }
                .background(
                    //BOTTOM GRADIENT
                    LinearGradient(
                           colors: [
                               .orange,
                               .pink,
                               .purple
                           ],
                           startPoint: .bottom,
                           endPoint: .top
                       )
                    .opacity(0.75)
                       .ignoresSafeArea()
                )
                
            })//END SAFE AREA INSET
        }//END NAVIGATIONSTACK
    }//END BODY
    
    func fetchFoodItems(forEndPoint:String) async throws{
        let response = try await apiService.fetchRecipes(for:forEndPoint)
        await MainActor.run{
            lastEndpointUsed = forEndPoint // Track Last Endpoint
            recipes = response.recipes
            originalRecipes = response.recipes
            //Error if fetching from Empty endpoint
            if recipes.isEmpty{
                activeAlert = .recipesEmpty
            }
            ///Debug Print Names
            //print(recipes.map{$0.name})
        }
        
    }
    
    
}

#Preview {
    ContentView()
    
}

