//
//  SearchView.swift
//  Crypto Analyser
//
//  Created by IE15 on 26/12/24.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var router: Router
    @State private var searchText = ""
    @State private var showCancelButton: Bool = false
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    router.navigateBackInAuth()
                }, label: {
                    Image(.back)
                        .foregroundColor(.black)
                })
                Spacer()
            }
            .padding(.horizontal,20)
            
            HStack {
                Image(systemName: "magnifyingglass")
                
                TextField("search", text: $searchText, onEditingChanged: { isEditing in
                    self.showCancelButton = true
                }, onCommit: {
                    print("onCommit")
                }).foregroundColor(.primary)
                    .accentColor(.black)
                
                Button(action: {
                    self.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill").opacity(searchText == "" ? 0 : 1)
                }
            }
            .padding(EdgeInsets(top: 10, leading: 6, bottom: 10, trailing: 6))
            .foregroundColor(.secondary)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10.0)
            .padding(.horizontal,20)
            Spacer()
        }
    }
}

#Preview {
    SearchView()
}
