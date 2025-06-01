//
//  RecipeDetailView.swift
//  FetchRecipes
//
//  Created by RMT on 4/30/25.
//

import SwiftUI

struct RecipeDetailView: View {
    @ObservedObject var recipe:Recipe
    @State private var wikiSummary: WikiSummary?
    @State private var fetchError: Error?
    @State private var animateBounce:Bool = false
    private let cacheManager = MyNSCacheManager.shared
    
    
    var body: some View {
        NavigationStack{
            ZStack{
                //BACKGROUND
                Color.yellow.ignoresSafeArea().opacity(0.5)
                BackgroundPatternView()
            
                //SCROLLVIEW
                ScrollView {
                    VStack{
                        Divider()
                        //TOP LARGE IMAGE
                        ZStack{
                            
                            //IMAGE
                            AsyncImage(url: URL(string:recipe.photoURLLarge)) { phase in
                                if let image = phase.image {
                                    //Success Image
                                    ZStack{
                                        image.resizable()
                                            .scaledToFit()
                                            .frame(height: 350)
                                    }
                                    
                                } else if phase.error != nil {
                                    //Error/No Image
                                    ZStack{
                                        Image(systemName: "fork.knife.circle")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 350)
                                            .foregroundStyle(Color.purple)
                                        Text("Image Unavailable")
                                            .font(.headline).bold()
                                            .fontWeight(.heavy)
                                            .scaleEffect(2.0)
                                            .foregroundStyle(Color.pink.opacity(0.75))
                                            .shadow(color:.white,radius: 1, x:2 , y:2)
                                    }.background(Color.clear) // debug only
                                    
                                } else {
                                    // Loading Image
                                    Text("Loading Image...")
                                    ProgressView()
                                        .scaleEffect(3.0)
                                        .frame(height: 350)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            //HEART "Favourite"
                            Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .scaleEffect(1.0)
                                .foregroundStyle(Color.pink.opacity(0.75))
                                .shadow(color:.white,radius: 1, x:2 , y:2)
                                .offset(x:120, y: animateBounce ? -150 : -130)
                                .onTapGesture {
                                    withAnimation(.linear(duration: 0.15)) {
                                        recipe.isFavorite.toggle()
                                        animateBounce = true
                                    }
                                    animateBounce = false
                                }
                            
                        }
                        .padding()
                        .frame(width: 350)
                        .background(Color.white.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay{
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 10)
                                .foregroundStyle(Color.purple)
                        }
                        
                        Divider()
                        
                        //NAME & FLAG
                        VStack(spacing: 5){
                            if recipe.name == "No Name"{
                                Text("The Source Failed to Provide a Name")
                                    .font(.headline)
                                    .underline()
                                    .padding(.top)
                                    .foregroundStyle(Color.pink.opacity(0.75))
                                    .shadow(color:.white,radius: 1, x:2 , y:2)
                                
                                Text("( \(recipe.cuisine) Cuisine ) ")
                                    .foregroundStyle(Color.pink.opacity(0.75))
                                    .shadow(color:.white,radius: 1, x:2 , y:2)
                                
                                let cuisineName = recipe.cuisine.capitalized
                                let flagEmoji = CuisineFlag.flag(for: cuisineName)
                                Text(flagEmoji)
                                    .scaleEffect(2.0)
                                    .padding(.bottom)
                            } else {
                                Text(recipe.name)
                                    .font(.headline)
                                    .underline()
                                    .padding(.top)
                                    .foregroundStyle(Color.pink.opacity(0.75))
                                    .shadow(color:.white,radius: 1, x:2 , y:2)
                                
                                Text(wikiSummary?.description ?? "")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.pink.opacity(0.75))
                                    .shadow(color:.white,radius: 1, x:2 , y:2)
                                
                                Text("( \(recipe.cuisine) Cuisine ) ")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.pink.opacity(0.75))
                                    .shadow(color:.white,radius: 1, x:2 , y:2)
                                
                                let cuisineName = recipe.cuisine.capitalized
                                let flagEmoji = CuisineFlag.flag(for: cuisineName)
                                Text(flagEmoji)
                                    .scaleEffect(2.0)
                                    .shadow(color:.black,radius: 2, x:2 , y:2)
                                
                                Text(wikiSummary?.extract ?? "")
                                    .font(.callout)
                                    .multilineTextAlignment(.leading)
                                    .padding([.horizontal,.bottom])
                                    .foregroundStyle(Color.pink.opacity(0.75))
                                    .shadow(color:.white,radius: 1, x:2 , y:2)
                                
                            }
                            
                            
                        }
                        .frame(width: 350)
                        .background(Color.white.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay{
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 10)
                                .foregroundStyle(Color.purple)
                        }
                        .onAppear{
                            Task{
                                do{
                                    wikiSummary = try await fetchWikiSummary(forItem: recipe.name)
                                    fetchError = nil
                                }catch{
                                    print("\(error.localizedDescription)")
                                    fetchError = error
                                    
                                    ///If theres an error try to fetch a 2nd time by trimming words
                                    let secondSearchTerm = fallbackTerm(from: recipe.name)
                                    
                                    do{
                                        wikiSummary = try await fetchWikiSummary(forItem: secondSearchTerm)
                                        fetchError = nil
                                    }catch{
                                        print("Fallback fetch failed too: \(error.localizedDescription)")
                                        fetchError = error
                                    }
                                    
                                }
                            }
                        }
                        
                        Divider()
                        
                        //YOUTUBE LINK
                        HStack {
                            //YOUTUBE LINK: LEFT IMAGE
                            ZStack{
                                //SMALL IMAGE
                                AsyncImage(url: URL(string:recipe.photoURLSmall)) { phase in
                                    if let image = phase.image {
                                        //Success Image
                                        image.resizable()
                                            .scaledToFit()
                                            .frame(height: 100)
                                        
                                    } else if phase.error != nil {
                                        //Error/No Image
                                        Image(systemName: "fork.knife.circle")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 100)
                                            .foregroundStyle(Color.purple)
                                        
                                    } else {
                                        // Loading Image
                                        Text("Loading Image...")
                                        ProgressView()
                                            .scaleEffect(1.0)
                                            .frame(height: 100)
                                    }
                                }
                                
                                //YOUTUBE LINK: PLAY BUTTON
                                Image(systemName: "play.square.fill") // Play button icon
                                    .foregroundStyle(.red)
                                    .font(.largeTitle)
                                    .scaleEffect(2.0)
                                    .shadow(color:.black, radius:1, x:1, y:1)
                                    .padding()
                                
                            }
                            .padding([.leading,.top, .bottom])
                            
                            ///YOUTUBE LINK: CENTER TEXTS & YOUTUBE LINK BUTTON
                            VStack(alignment: .center) {
                                if recipe.name == "No Name"{
                                    Text("Watch Video for this Item")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                        .foregroundStyle(Color.pink.opacity(0.75))
                                        .shadow(color:.white,radius: 1, x:2 , y:2)
                                        
                                    
                                    NavigationLink(destination:YouTubePlayerView(recipe: recipe)) {
                                        Text("Tap to watch")
                                            .foregroundStyle(.selection).bold()
                                            .padding(.horizontal,10)
                                            .background(Color.white.opacity(0.75))  //*GRADIENT
                                            .clipShape(RoundedRectangle(cornerRadius: 5))
                                    }
                                }else{
                                    Text("Watch Video for \(recipe.name)")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                        .foregroundStyle(Color.pink.opacity(0.75))
                                        .shadow(color:.white,radius: 1, x:2 , y:2)
                                    
                                    NavigationLink(destination: YouTubePlayerView(recipe: recipe)) {
                                        Text("Tap to watch")
                                            .foregroundStyle(.selection).bold()
                                            .padding(.horizontal,10)
                                            .background(Color.white.opacity(0.5)) //*GRADIENT
                                            .clipShape(RoundedRectangle(cornerRadius: 5))
                                    }
                                }
                            }
                            //.padding(.horizontal)
                            
                            Spacer()
                            
                            ///YOUTUBE LINK: RIGHT IMAGE
                            Image(systemName: "play.display") // Play button icon
                                .foregroundStyle(.secondary)
                                .font(.largeTitle)
                                .scaleEffect(1.5)
                                .padding()
                            
                            
                        }
                        .frame(width: 350)
                        .background(Color.white.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay{
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 10)
                                .foregroundStyle(Color.purple)
                        }
                        
                        Divider()
                        
                        //SOURCE LINK
                        VStack{
                            ///Description
                            VStack(alignment: .center) {
                                if recipe.name == "No Name" {
                                    Text("View Recipe for this Item")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color.pink.opacity(0.75))
                                        .shadow(color:.white,radius: 1, x:2 , y:2)
                                    
                                    HStack{
                                        Image(systemName: "fork.knife")
                                        Image(systemName: "list.bullet.rectangle")
                                    }
                                    .font(.title)
                                    .foregroundStyle(.secondary)
                                }else{
                                    Text("View Recipe for \(recipe.name)")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color.pink.opacity(0.75))
                                        .shadow(color:.white,radius: 1, x:2 , y:2)
                                    
                                    HStack{
                                        Image(systemName: "fork.knife")
                                        Image(systemName: "list.bullet.rectangle")
                                    }
                                    .font(.title)
                                    .foregroundStyle(.secondary)
                                    
                                }
                                
                            }
                            .padding(.top)
                            
                            //RECIPE LINKS HERE
                            if recipe.sourceURL != "No Source URL" {
                                ///Go to Provided URL
                                let url = URL(string: recipe.sourceURL)!
                                NavigationLink(destination: WebView(url: url)) {
                                    Text("Tap to watch")
                                        .foregroundStyle(.selection).bold()
                                        .padding(.horizontal,10)
                                        .background(Color.white.opacity(0.5))
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                        .padding(.bottom)
                                }
                            } else {
                                ///No Source URL --> Query google for Item.
                                let recipeQuery = "recipe for \(recipe.name)"
                                if let encodedQuery = recipeQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                   let url = URL(string: "https://www.google.com/search?q=\(encodedQuery)") {
                                    NavigationLink(destination: WebView(url: url)) {
                                        Text("Tap to watch")
                                            .foregroundStyle(.selection).bold()
                                            .padding(.horizontal,10)
                                            .background(Color.white.opacity(0.5))
                                            .clipShape(RoundedRectangle(cornerRadius: 5))
                                            .padding(.bottom)
                                    }
                                }
                                
                            }
                            
                            
                            
                        }
                        .frame(width: 350)
                        .background(Color.white.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay{
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 10)
                                .foregroundStyle(Color.purple)
                        }
                        
                        
                        Divider()
                        
                    } //END VSTACK (MAIN)
                }//END ScrollView
            }//END MAIN ZStack
        }//END NavigationStack
    }//END Body
    
    // Function to get VideoID from Full Youtube URL
    func extractVideoID(from url: String) -> String? {
        // Handles typical YouTube watch URL
        if let components = URLComponents(string: url),
           components.host?.contains("youtube.com") == true,
           let queryItems = components.queryItems {
            return queryItems.first(where: { $0.name == "v" })?.value
        }
        print("COULD NOT GET VIDEO ID for Recipe: \(recipe.name)")
        return nil
    }
}

#Preview {
    RecipeDetailView(recipe: Response.malformedSample[1])
}


extension RecipeDetailView{
    enum CuisineFlag: String, CaseIterable {
        case Malaysian = "🇲🇾"
        case British = "🇬🇧"
        case American = "🇺🇸"
        case Canadian = "🇨🇦"
        case Italian = "🇮🇹"
        case Tunisian = "🇹🇳"
        case French = "🇫🇷"
        case Greek = "🇬🇷"
        case Polish = "🇵🇱"
        case Portuguese = "🇵🇹"
        case Russian = "🇷🇺"
        case Croatian = "🇭🇷"
        
        
        //Find Matching Case
        static func ethnicFlag(name:String) -> CuisineFlag?{
            return CuisineFlag.allCases.first(where: {"\($0)" == name.capitalized})
        }
        
        //Get Raw Value "Flag"
        var emoji:String{
            return self.rawValue
        }
        
        //If No Matches found, default to Pirate
        static func flag(for name: String) -> String {
            return ethnicFlag(name: name)?.emoji ?? "🏴‍☠️"
        }
        
        //Call
        /*
         let cuisineName = recipe.cuisine.capitalized
         let flagEmoji = CuisineFlag.flag(for: cuisineName)
         Text(flagEmoji)
         */
        
        
    }
    
}

extension RecipeDetailView{

    func fetchWikiSummary(forItem:String) async throws -> WikiSummary{
        
        let foodItem = forItem.replacingOccurrences(of: " ", with: "_").lowercased()
        
        //---- *CHECK IF WE ALREADY CACHED THE DATA & EXIT FUNC...-----
        if let cachedWikiData = cacheManager.getCachedWikiData(forKey: foodItem){
            print("- CACHE HIT: USING DATA FROM CACHE")
            return  cachedWikiData //Function exits here if cache exists
        }
        
        //------IF WE'RE HERE, WE DID NOT CACHE THE DATA YET...-----
        
        guard let wikiURL = URL(string: "https://en.wikipedia.org/api/rest_v1/page/summary/\(foodItem)") else {
            ///Throw Runtime error
            throw NSError(domain: "Cannot convert String into URL", code: 1, userInfo: nil)
        }
        print (wikiURL)
        
        do {
            let (data,response) = try await URLSession.shared.data(from: wikiURL)
            
            ///Check Valid HTTP Response or Throw runtime Error
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NSError(domain: "Invalid HTTP Response", code: 500, userInfo: nil)
                
            }
            
            ///Check we have something coming back as response
            if (200...299).contains(httpResponse.statusCode) {
                //print("Data received: \(String(data: data, encoding: .utf8) ?? "No data")")
                let wikiData = try JSONDecoder().decode(WikiSummary.self, from: data)
                                    //*...We Got Data...
                //SAVE TO SPECIFIC CACHE
                cacheManager.cacheWikiData(wikiData, forKey: foodItem)
                //return the data
                return wikiData
            } else {
                throw NSError(domain: "HTTP Error", code: httpResponse.statusCode, userInfo: nil)
            }
            
        } catch {
            print("Error: \(error.localizedDescription)") // Print error description
            print("COULD NOT FIND DATA FOR: \(foodItem), Will Do Second Search by parsing the search term: \(foodItem). EX: 'American Apple Pie' ---> 'Pie' ")
            throw error
        }
    }
    
    //Func Fallback Search Term. "American Apple Pie" ---> "Pie"
    func fallbackTerm(from original: String) -> String {
        return original.components(separatedBy: " ").last?.lowercased() ?? original
        ///let fallback = fallbackTerm(from: "Apple Frangipan Tart") // returns "tart"
    }
    
    //Sample Wiki/ Mock Data
    static let sampleWikiResponse = WikiSummary(title: "Apam balik", description: "Asian pancake", extract: "Apam balik also known as martabak manis, terang bulan, peanut pancake or mànjiānguǒ, is a sweet dessert originating in Fujian cuisine which now consists of many varieties at specialist roadside stalls or restaurants throughout Brunei, Indonesia, Malaysia and Singapore. It can also be found in Hong Kong as, Taiwan as, Southern Thailand as Khanom Thang Taek (ขนมถังแตก) and in the Sulu Archipelago, Philippines as Tarambulan.")
    
    
}//end Extension
