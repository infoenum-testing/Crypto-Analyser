//
//  HomeView.swift
//  Crypto Analyser
//
//  Created by IE15 on 21/12/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var router: Router
    
    @State public var image: UIImage? = nil
    @State private var isGallery: Bool = false
    @State private var isLoading: Bool = false
    @State private var recentSearchIsLoading: Bool = false
    @State private var isCamera: Bool = false
    @State private var resentSearches:[SearchDetails] = []
    @State private var showAlert = false
    @State private var itemToDelete: SearchDetails?
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text(StringConstants.analyseCrypto)
                        .font(.system(size: 25, weight: .semibold))
                    HStack {
                        Spacer()
                        Button(action: {
                            isCamera = true
                        }, label: {
                            VStack {
                                Image(systemName: "camera")
                                    .resizable()
                                    .frame(width: 25, height: 25, alignment: .center)
                                Text(StringConstants.takeAPic)
                                    .font(.system(size: 12, weight: .regular))
                            }
                        })
                        .frame(width: 80,height: 80)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 4)
                        .accentColor(.black)
                        .foregroundColor(.black)
                        .font(.system(size: 20))
                        .padding(.bottom)
                        
                        Text(StringConstants.or)
                            .lineLimit(1)
                        
                        Button(action: {
                            isGallery = true
                        }, label: {
                            VStack {
                                Image(systemName: "photo.on.rectangle")
                                    .resizable()
                                    .frame(width: 25, height: 25, alignment: .center)
                                Text(StringConstants.uploadFromGallery)
                                    .font(.system(size: 12, weight: .regular))
                            }
                        })
                        .frame(width: 80,height: 80)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 4)
                        .accentColor(.black)
                        .foregroundColor(.black)
                        .font(.system(size: 20))
                        .padding(.bottom)
                        
                        Text(StringConstants.or)
                            .lineLimit(1)
                        
                        Button(action: {
                            router.navigateToAuth(.searchView)
                        }, label: {
                            VStack {
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .frame(width: 25, height: 25, alignment: .center)
                                Text(StringConstants.searchForCoin)
                                    .font(.system(size: 12, weight: .regular))
                            }
                        })
                        .frame(width: 80,height: 80)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 4)
                        .accentColor(.black)
                        .foregroundColor(.black)
                        .font(.system(size: 20))
                        .padding(.bottom)
                        Spacer()
                    }
                }
//                .padding(.top,10)
                .padding(.horizontal,20)
                
                Text(StringConstants.recentSearches)
                    .font(.system(size: 25, weight: .semibold))
                    .padding(.bottom,5)
                    .padding(.horizontal,20)
                if recentSearchIsLoading || resentSearches.count == 0{
                    HStack {
                        Spacer()
                        if recentSearchIsLoading {
                            VStack {
                                Spacer()
                                ProgressView()
                                    .controlSize(.large)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                        } else {
                            VStack(alignment:.center, spacing: 5) {
                                Spacer()
                                Text("No recent search available")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                                Text("Please Search by using the options above.")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal,20)
                }  else {
                    ScrollView {
                        VStack {
                                ForEach(0..<resentSearches.count, id: \.self) { index in
                                    let title = resentSearches[index].title
                                    let message = resentSearches[index].message
                                    VStack(alignment: .leading,spacing: 0) {
                                        HStack {
                                            Spacer()
                                            Button(action: {
                                                itemToDelete = resentSearches[index]
                                                showAlert = true
                                            }, label: {
                                                Image(systemName: "xmark")
                                                    .resizable()
                                                    .frame(width: 10, height: 10, alignment: .center)
                                            })
                                        }
                                        .padding(.horizontal,8)
                                        Text(message)
                                            .lineLimit(2)
                                            .font(.system(size: 15, weight: .regular))
                                            .padding(.horizontal)
                                            .padding(.bottom)
                                        
                                    }
                                    .padding(.top,8)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 4)
                                    .accentColor(.black)
                                    .foregroundColor(.black)
                                    .font(.system(size: 20))
                                    .onTapGesture {
                                        router.navigateToAuth(.dataDescription(image: resentSearches[index].image ?? UIImage(),afterAnalyse: false,title: nil, message: message))
                                    }
                                    
                                }
                        }
                        .padding(.horizontal,20)
                        .padding(.top,2)
                    }
                }
            }
            .fullScreenCover(isPresented: $isGallery) {
                GalleryView(isGallery: $isGallery, capturedImage: $image)
            }
            .fullScreenCover(isPresented: $isCamera) {
                CameraView(isCamera: $isCamera, captureImage: { image in
                    self.image = image
                })
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Confirm Deletion"),
                    message: Text("Are you sure you want to delete search"),
                    primaryButton: .destructive(Text("Delete")) {
                        removeRecentSearch(id:itemToDelete?.id ?? "")
                    },
                    secondaryButton: .cancel() // Cancel button to dismiss alert
                )
            }
        }
        //.background(Color.midnightBlue.opacity(0.4))
        .onAppear {
            fetchRecentSearches()
        }
        
        .onChange(of: image) { value in
            if let value {
                router.navigateToAuth(.imageAnalyser(image: value, fromSearch: false))
            }
        }
    }
    
    func fetchRecentSearches() {
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
    
    func removeRecentSearch(id:String) {
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
    
    func removeItem(withId id: String) {
        if let index = resentSearches.firstIndex(where: { $0.id == id }) {
            resentSearches.remove(at: index)
        }
    }
}

#Preview {
    HomeView()
}
