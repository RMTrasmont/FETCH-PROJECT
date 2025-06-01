//
//  SearchBar.swift
//  FetchRecipes
//
//  Created by RMT on 5/9/25.
//

import SwiftUI

struct SearchBar: View {
    @Binding var seachText: String //Passed to content View
    @State var inputText: String = "" //Local
    var searchAction: () -> Void
    
    var body: some View {
        HStack{
            TextField("Search by Name or Ethnicity", text: $inputText)
                .padding(.vertical)
                .padding(.leading)
                .autocorrectionDisabled(true)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(10)
                .clipShape(RoundedRectangle(cornerRadius: 10.0))
                .overlay(alignment: .centerLastTextBaseline) {
                ///Use in Overlay,b/c .offset clicks original spot, instead of image location
                    HStack{
                        Spacer()
                        Button {
                            print("ERASE TAPPED")
                            inputText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .padding()
                        }
                        .disabled(inputText.isEmpty)
                    }
                    
                }
                //END TextField
            Button {
                print("SEARCH TAPPED")
                seachText = inputText
                searchAction()
            } label: {
                //Image(systemName: "magnifyingglass")
                Text("Search")
                    .font(.caption.bold())
                    .padding()
                    .background(inputText.isEmpty ? Color.gray : Color.blue)
                    .foregroundStyle(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .disabled(inputText.isEmpty)
        
        }
        .padding(.horizontal)
    }
        
}

//#Preview {
//    // Use a State variable wrapper to simulate Preview with @Binding
//    struct PreviewWrapper: View {
//        @State private var searchText = ""
//        
//        var body: some View {
//            SearchBar(seachText: $searchText, inputText: "")
//        }
//    }
//    
//    return PreviewWrapper()
//}



