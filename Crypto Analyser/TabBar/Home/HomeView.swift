//
//  HomeView.swift
//  Crypto Analyser
//
//  Created by IE15 on 21/12/24.
//

import SwiftUI

struct HomeView: View {
    enum AlertType {
        case delete
        case purchase
    }
    @EnvironmentObject private var subscriptionsManager: SubscriptionsManager
    @EnvironmentObject var router: Router
    
    @State public var image: UIImage? = nil
    @State private var isGallery: Bool = false
    @State private var isLoading: Bool = false
    @State private var recentSearchIsLoading: Bool = false
    @State private var isPlanActive: Bool = true
    @State private var isCamera: Bool = false
    @State private var resentSearches:[SearchDetails] = []
    @State private var showAlert = false
    @State private var itemToDelete: SearchDetails?
    @State private var alertType: AlertType = .delete
    @State private var trail:Int = 0
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        Text(StringConstants.analyseCrypto)
                            .font(.system(size: 25, weight: .semibold))
                        Spacer()
                    }
                    HStack {
//                        Spacer()
                        customButton(imageName: "camera", title: StringConstants.takeAPic, action: {
                            if trail >= 3  && !isPlanActive {
                                showAlert = true
                                alertType = .purchase
                            } else {
                                isCamera = true
                            }
                        })
                        .frame(maxWidth: .infinity)
                        
                        Text(StringConstants.or)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity)
                        customButton(imageName: "photo.on.rectangle", title: StringConstants.uploadFromGallery, action: {
                            if trail >= 3  && !isPlanActive {
                                showAlert = true
                                alertType = .purchase
                            } else {
                                isGallery = true
                            }
                        })
                        .frame(maxWidth: .infinity)
                        
                        Text(StringConstants.or)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity)
                        customButton(imageName: "magnifyingglass", title: StringConstants.searchForCoin, action: {
                            if trail >= 3  && !isPlanActive {
                                showAlert = true
                                alertType = .purchase
                            } else {
                                router.navigateToAuth(.searchView)
                            }
                        })
                        .frame(maxWidth: .infinity)
//                        Spacer()
                    }
                }
                .padding(.horizontal,20)
                
                Text(StringConstants.recentSearches)
                    .font(.system(size: 20, weight: .semibold))
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
                    ScrollView(showsIndicators: false) {
                        VStack(alignment:.leading) {
                            ForEach(resentSearches, id: \.id) { item in
                                let message = item.message
                                VStack(alignment: .leading,spacing: 0) {
                                    HStack(alignment: .center, spacing: 0) {
                                        Text(message.replacingOccurrences(of: "\n", with: ""))
                                            .lineLimit(3)
                                            .font(.system(size: 15, weight: .regular))
                                        Spacer()
                                        Button(action: {
                                            itemToDelete = item
                                            showAlert = true
                                            alertType = .delete
                                        }, label: {
                                            if itemToDelete?.id == item.id && !showAlert{
                                                ProgressView()
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
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 4)
                                .accentColor(.black)
                                .foregroundColor(.black)
                                .font(.system(size: 20))
                                .onTapGesture {
                                    router.navigateToAuth(.dataDescription(image: item.image ?? UIImage(),afterAnalyse: false,title: nil, message: message))
                                }
                                .transition(.move(edge: .leading))
                            }
                        }
                        .padding(.top,2)
                        .padding(.horizontal,6)
                    }
                    .padding(.horizontal,14)
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
                if alertType == .delete {
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
                } else {
                    Alert(
                        title: Text("Free Trial Ended"),
                        message: Text("You've used all 3 free trials. Unlock full access by purchasing the feature."),
                        primaryButton: .default(Text("Buy Now")) {
                            router.navigateToAuth(.subscription)
                        },
                        secondaryButton: .cancel(Text("Cancel"))
                    )
                }
            }
            
        } //.background(Color.midnightBlue.opacity(0.4))
        .onAppear {
            fetchRecentSearches()
            getUserTrails()
        }
        
        .onChange(of: image) { value in
            if let value {
                router.navigateToAuth(.imageAnalyser(image: value, fromSearch: false))
            }
        }
    }
    
    func customButton(imageName: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
        }, label: {
            VStack {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25, alignment: .center)
                Text(title)
                    .font(.system(size: 12, weight: .regular))
            }
        })
        .frame(width: 90, height: 80)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 4)
        .accentColor(.black)
        .foregroundColor(.black)
        .font(.system(size: 20))
        .padding(.bottom)
    }
    
    private func getUserTrails() {
        let email = UserSessionManager.getUserData().email
        FirebaseAuthentication.shared.getTrial(email: email) { result in
            switch result {
            case .success(let trialCount):
                    self.trail = trialCount
                UserSessionManager.saveUserTrail(count: trialCount)
            case .failure(let error):
                print("Error fetching trial: \(error.localizedDescription)")
            }
        }
        if let subscriptionPayload = subscriptionsManager.latestPayload , let dateStr = subscriptionPayload.subscriptionEndDate , let date = convertToDate(from: dateStr) ,date < Date() {
            isPlanActive = false
        } else {
            isPlanActive = true
        }
    }
    
    private func convertToDate(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z" // Format matches the input string
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensure consistent parsing
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Match the +0000 timezone
        
        return dateFormatter.date(from: dateString)
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
    HomeView()
}
