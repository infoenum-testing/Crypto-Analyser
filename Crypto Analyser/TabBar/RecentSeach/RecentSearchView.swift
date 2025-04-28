//
//  RecentSearchView.swift
//  Crypto Analyser Dev
//
//  Created by IE15 on 04/02/25.
//

import SwiftUI

struct RecentSearchView: View {
    @EnvironmentObject var router: Router
    @State private var resentSearches:[SearchDetails] = []
    @State private var showAlert = false
    @State private var itemToDelete: SearchDetails?
    @State private var recentSearchIsLoading: Bool = false
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(StringConstants.recentSearches)
                        .foregroundStyle(.white)
                        .font(.system(size: 25, weight: .semibold))
                    Spacer()
                }
                .padding(.horizontal,20)
                if recentSearchIsLoading || resentSearches.count == 0{
                    HStack {
                        Spacer()
                        if recentSearchIsLoading {
                            VStack {
                                Spacer()
                                ProgressView()
                                    .controlSize(.large)
                                    .tint(Color.pink)
                                Spacer()
                            }
                        } else {
                            VStack(alignment:.center, spacing: 5) {
                                Spacer()
                                Text("No recent search available")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                Text("Please Search by using the options above.")
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal,20)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment:.leading) {
                            ForEach(resentSearches, id: \.id) { item in
                                let confidenceLavel = item.confidenceLavel
                                let message = item.message
                                VStack(alignment: .leading,spacing: 0) {
                                    HStack(alignment: .center, spacing: 0) {
                                        Text(message.replacingOccurrences(of: "\n", with: ""))
                                            .foregroundStyle(.white)
                                            .lineLimit(3)
                                            .font(.system(size: 15, weight: .regular))
                                        Spacer()
                                        Button(action: {
                                            itemToDelete = item
                                            showAlert = true
                                        }, label: {
                                            if itemToDelete?.id == item.id && !showAlert{
                                                ProgressView()
                                                    .tint(Color.pink)
                                            } else {
                                                Image(systemName: "trash")
                                                    .resizable()
                                                    .foregroundStyle(.red.opacity(0.8))
                                                    .frame(width: 20, height: 20, alignment: .center)
                                            }
                                        })
                                        .frame(width: 20, height: 20)
                                        
                                    }
                                    .padding(.horizontal,8)
                                }
                                .padding(.vertical,8)
                                .background(Color.cellcolortheme)
                                .cornerRadius(8)
                                .accentColor(.black)
                                .foregroundColor(.black)
                                .font(.system(size: 20))
                                .onTapGesture {
                                    router.navigateToAuth(.dataDescription(image: item.image ?? UIImage(),afterAnalyse: false,confidenceLevel:confidenceLavel, message: message))
                                }
                                .transition(.move(edge: .leading))
                            }
                        }
                        .padding(.top,15)
                        .padding(.horizontal,12)
                    }
                }
            }
        }
        .background(.themecolorprimary)
        .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Delete?"),
                    message: Text("Are you sure you want to delete search.."),
                    primaryButton: .destructive(Text("Delete")) {
                        removeRecentSearch(id:itemToDelete?.id ?? "")
                    },
                    secondaryButton: .cancel() {
                        itemToDelete = nil
                    }
                )
        }
        .onAppear {
            fetchRecentSearches()
        }
    }
    
    private  func fetchRecentSearches() {
        recentSearchIsLoading = true
        let email = UserSessionManager.getUserData().email
        FireBaseResentSearches.shared.fetchRecentSearches(for: email) { result in
            recentSearchIsLoading = false
            switch result {
            case .success(let recentSearches):
                self.resentSearches = recentSearches.sorted(by: { $0.date > $1.date })
            case .failure(let error):
                print("Failed to fetch recent searches: \(error.localizedDescription)")
            }
        }
    }
    
    private func removeRecentSearch(id:String) {
        let email = UserSessionManager.getUserData().email
        FireBaseResentSearches.shared.removeRecentSearch(for: email, documentID: id) { result in
            switch result {
            case .success:
                removeItem(withId: id)
            case .failure(let error):
                print("Failed to remove recent search: \(error.localizedDescription)")
            }
        }
    }
    
    private func removeItem(withId id: String) {
        if let index = resentSearches.firstIndex(where: { $0.id == id }) {
            withAnimation {
                resentSearches.remove(at: index)
            }
        }
    }
}

#Preview {
    RecentSearchView()
}
