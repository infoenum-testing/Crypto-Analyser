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
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("Analyse Crypto")
                        .font(.system(size: 25, weight: .semibold))
                    HStack {
                        Button(action: {
                            isCamera = true
                        }, label: {
                            VStack {
                                Image(systemName: "camera")
                                    .resizable()
                                    .frame(width: 25, height: 25, alignment: .center)
                                Text("Take a \n picture")
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
                        
                        Text("or")
                            .lineLimit(1)
                        
                        Button(action: {
                            isGallery = true
                        }, label: {
                            VStack {
                                Image(systemName: "photo.on.rectangle")
                                    .resizable()
                                    .frame(width: 25, height: 25, alignment: .center)
                                Text("Upload from gallery")
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
                        
                        Text("or")
                            .lineLimit(1)
                        
                        Button(action: {
                            router.navigateToAuth(.searchView)
                        }, label: {
                            VStack {
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .frame(width: 25, height: 25, alignment: .center)
                                Text("Search for a coin")
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
                .padding(.top,30)
                .padding(.horizontal,20)
                
                Text("Recent Searches")
                    .font(.system(size: 25, weight: .semibold))
                    .padding(.bottom,5)
                    .padding(.horizontal,20)
                
                ScrollView {
                    VStack {
                        if !recentSearchIsLoading {
                            ForEach(0..<resentSearches.count, id: \.self) { index in
                                let title = resentSearches[index].title
                                let message = resentSearches[index].message
                                VStack(alignment: .leading,spacing: 0) {
                                    HStack {
                                        Text(title)
                                            .foregroundStyle(.black)
                                            .font(.system(size: 20, weight: .semibold))
                                        Spacer()
                                        Button(action: {
                                            let id = resentSearches[index].id
                                            removeRecentSearch(id:id)
                                        }, label: {
                                            Image(systemName: "xmark")
                                                .resizable()
                                                .frame(width: 10, height: 10, alignment: .center)
                                        })
                                    }
                                    .padding(.horizontal)
                                    Text(message)
                                        .lineLimit(2)
                                        .font(.system(size: 15, weight: .regular))
                                        .padding(.horizontal)
                                }
                                .padding(.vertical,4)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 4)
                                .accentColor(.black)
                                .foregroundColor(.black)
                                .font(.system(size: 20))
                                
                            }
                        } else {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .controlSize(.large)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.top,20)
                        }
                    }
                    .padding(.horizontal,20)
                }
                Spacer()
            }
            .fullScreenCover(isPresented: $isGallery) {
                GalleryView(isGallery: $isGallery, capturedImage: $image)
            }
            .fullScreenCover(isPresented: $isCamera) {
                CameraView(isCamera: $isCamera, captureImage: { image in
                    self.image = image
                })
            }
        }
        //.background(Color.midnightBlue.opacity(0.4))
        .onAppear {
            fetchRecentSearches()
        }
        .onChange(of: image) { value in
            if let value {
                router.navigateToAuth(.imageAnalyser(image: value))
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
                self.resentSearches = recentSearches
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
                fetchRecentSearches()
            case .failure(let error):
                print("Failed to remove recent search: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    HomeView()
}
