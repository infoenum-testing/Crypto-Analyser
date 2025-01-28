//
//  SubscriptionsManager.swift
//  Crypto Analyser Dev
//
//  Created by IE MacBook Pro 2014 on 02/01/25.
//

import Foundation
import StoreKit
import Firebase
import FirebaseAuth

@MainActor
class SubscriptionsManager: NSObject, ObservableObject {
    let productIDs: [String] = Array(IAPConstants.Products.all)
    var purchasedProductIDs: Set<String> = []
    @Published  var selectedProduct: Product? = nil
    @Published var products: [Product] = []
    @Published var  title = "Continue"
    @Published var latestPayload: SubscriptionPayload?
    @Published var isPlanActive: Bool?
    @Published var latestTransactionId: String?
    @Published var isLoading: Bool = false
    @Published var alertMessage: String = ""
    @Published var alertType: String = ""
    @Published var showAlert: Bool = false
    
    private var entitlementManager: EntitlementManager? = nil
    private var updates: Task<Void, Never>? = nil
    
    init(entitlementManager: EntitlementManager) {
        self.entitlementManager = entitlementManager
        super.init()
        self.updates = observeTransactionUpdates()
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        updates?.cancel()
    }
    
    func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await _ in Transaction.updates {
                await self.updatePurchasedProducts()
            }
        }
    }
}

// MARK: StoreKit2 API
extension SubscriptionsManager {
    func loadProducts() async {
        do {
            self.products = try await Product.products(for: productIDs)
                .sorted(by: { $0.price > $1.price })
        } catch {
            print("Failed to fetch products!")
        }
    }
    
    
    func buyProduct(_ product: Product) async {
        isLoading = true
        do {
            let result = try await product.purchase()
            
            switch result {
            case let .success(.verified(transaction)):
                // Successful purhcase
                print("transactionId",transaction.id)
                print("originalTransactionId",transaction.originalID)
                print("subscriptionStartDate",transaction.purchaseDate)
                print("subscriptionEndDate",transaction.expirationDate as Any)
                print("productId",transaction.productID)
                
                let payload = SubscriptionPayload(transactionId: "\(transaction.id)",
                                                  originalTransactionId: "\(transaction.originalID)", subscriptionStartDate: "\(transaction.purchaseDate)", subscriptionEndDate: "\(transaction.expirationDate ?? Date())",
                                                  productId: "\(transaction.productID)")
                
                
                await transaction.finish()
                await saveTransactionToFirebase(transaction: payload)
                await self.updatePurchasedProducts()
                isLoading = false
            case let .success(.unverified(_, error)):
                // Successful purchase but transaction/receipt can't be verified
                // Could be a jailbroken phone
                print("Unverified purchase. Might be jailbroken. Error: \(error)")
                self.showAlert(with: error.localizedDescription, alertTitle: "Error")
                break
            case .pending:
                // Transaction waiting on SCA (Strong Customer Authentication) or
                // approval from Ask to Buy
                self.showAlert(with: "Transaction waiting or might be pending", alertTitle: "Error")
                break
            case .userCancelled:
                print("User cancelled!")
                isLoading = false
                break
            @unknown default:
                print("Failed to purchase the product!")
                self.showAlert(with: "Failed to purchase the product!", alertTitle: "Error")
                break
            }
        } catch {
            self.showAlert(with: error.localizedDescription, alertTitle: "Error")
            print("Failed to purchase the product!")
        }
    }
    
    func updatePurchasedProducts() async {
        var tempLatestPayload: SubscriptionPayload?
        
        for product in productIDs {
            if let result = try? await Transaction.latest(for: product),
               case .verified(let transaction) = result {
                print("transactionId",transaction.id)
                print("originalTransactionId",transaction.originalID)
                print("subscriptionStartDate",transaction.purchaseDate)
                print("subscriptionEndDate",transaction.expirationDate as Any)
                print("productId",transaction.productID)
                self.purchasedProductIDs.insert(transaction.productID)
                if tempLatestPayload == nil {
                    latestTransactionId = "\(transaction.originalID)"
                    tempLatestPayload = SubscriptionPayload(transactionId: "\(transaction.id)",
                                                        originalTransactionId: "\(transaction.originalID)", subscriptionStartDate: "\(transaction.purchaseDate)", subscriptionEndDate: "\(transaction.expirationDate ?? Date())",
                                                        productId: "\(transaction.productID)")
                } else if let payload = tempLatestPayload, transaction.purchaseDate >= convertToDate(from: payload.subscriptionStartDate ?? "") ?? Date() {
                    latestTransactionId = "\(transaction.originalID)"
                    tempLatestPayload = SubscriptionPayload(transactionId: "\(transaction.id)",
                                                        originalTransactionId: "\(transaction.originalID)", subscriptionStartDate: "\(transaction.purchaseDate)", subscriptionEndDate: "\(transaction.expirationDate ?? Date())",
                                                        productId: "\(transaction.productID)")
                }
                try? await transaction.finish()
            } else {
                self.purchasedProductIDs.remove(product)
            }
        }
        
       
        if let payload = tempLatestPayload {
            let email = UserSessionManager.getUserEmail()
           updateSubscriptionDetails(for: email, newSubscription: payload, completion: { result in
               switch result {
               case .success():
                   print("updated")
                       self.latestPayload = tempLatestPayload
                   if let subscriptionPayload = tempLatestPayload , let dateStr = subscriptionPayload.subscriptionEndDate , let date = self.convertToDate(from: dateStr) ,date > Date() {
                       self.isPlanActive = true
                   } else {
                       self.isPlanActive = false
                   }

               case .failure(_):
                   print("update apple id")
                   self.isPlanActive = false
                   self.purchasedProductIDs.removeAll()
                   self.latestPayload = nil
               }
               self.entitlementManager?.hasPro = !self.purchasedProductIDs.isEmpty
               self.returnPurchaseTitle()
                })
        }
       
       
    }
    
    func convertToDate(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z" // Format matches the input string
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensure consistent parsing
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Match the +0000 timezone
        
        return dateFormatter.date(from: dateString)
    }
    
    func restorePurchases() async {
        // isLoading = true
        do {
            try await AppStore.sync()
            isLoading = false
        } catch {
            print(error.localizedDescription)
            self.showAlert(with: error.localizedDescription, alertTitle: "Error")
            showAlert = true
            isLoading = false
        }
    }
}

extension SubscriptionsManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
}

//MARK: - Firebase Subscription Api's
extension SubscriptionsManager {
    func updateSubscriptionDetails(
        for userEmail: String,
        newSubscription: SubscriptionPayload,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        if userEmail.isEmpty {
            completion(.failure(NSError(domain: "NoDataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid email."])))
            return
        }
        
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(userEmail).collection("Subscriptions").document("SubscriptionDetails")
        
        docRef.getDocument { documentSnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documentSnapshot = documentSnapshot, documentSnapshot.exists,
                  let data = documentSnapshot.data(),
                  let savedOriginalTransactionId = data["originalTransactionId"] as? String else {
                completion(.failure(NSError(domain: "NoDataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document not found or invalid data."])))
                return
            }
            
            // Check if the saved originalTransactionId matches the new one
            if savedOriginalTransactionId == newSubscription.originalTransactionId {
                // Update Firestore document
                let updatedData: [String: Any] = [
                    "transactionId": newSubscription.transactionId ?? "",
                    "subscriptionStartDate": newSubscription.subscriptionStartDate ?? "",
                    "subscriptionEndDate": newSubscription.subscriptionEndDate ?? "",
                    "productId": newSubscription.productId ?? ""
                ]
                
                docRef.updateData(updatedData) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            } else {
                // If originalTransactionId doesn't match, return an error
                completion(.failure(NSError(domain: "UpdateError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Original Transaction ID does not match."])))
            }
        }
    }
    
    func saveTransactionToFirebase(transaction: SubscriptionPayload) async {
        
        let email = UserSessionManager.getUserEmail()
        if email == "" {
            return
        }
        
        let db = Firestore.firestore()
        let docData: [String: Any] = [
            "transactionId": transaction.transactionId ?? "",
            "originalTransactionId": transaction.originalTransactionId ?? "",
            "subscriptionStartDate": transaction.subscriptionStartDate ?? "",
            "subscriptionEndDate": transaction.subscriptionEndDate ?? "",
            "productId": transaction.productId ?? ""
        ]
        
        do {
            let docRef = db.collection("users").document(email).collection("Subscriptions").document("SubscriptionDetails")
            try await docRef.setData(docData)
            print("Transaction saved to Firestore successfully.")
            UserSessionManager.saveUserSubscriptionDetail(transaction)
        } catch {
            print("Error saving transaction to Firestore: \(error)")
        }
    }
    
    func getSubscriptionDetails(
        for userEmail: String,
        completion: @escaping (Result<SubscriptionPayload, Error>) -> Void
    ) {
        if userEmail == "" {
            completion(.failure(NSError(domain: "NoDataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document not found."])))
            return
        }
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(userEmail).collection("Subscriptions").document("SubscriptionDetails")
        
        // Add a real-time listener
        docRef.addSnapshotListener { documentSnapshot, error in
            if let error = error {
                // Handle errors in the listener
                completion(.failure(error))
                return
            }
            
            guard let documentSnapshot = documentSnapshot, documentSnapshot.exists else {
                // If the document doesn't exist
                completion(.failure(NSError(domain: "NoDataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document not found."])))
                return
            }
            
            // Parse the document data
            if let data = documentSnapshot.data() {
                let transactionId = data["transactionId"] as? String
                let originalTransactionId = data["originalTransactionId"] as? String
                let subscriptionStartDate = data["subscriptionStartDate"] as? String
                let subscriptionEndDate = data["subscriptionEndDate"] as? String
                let productId = data["productId"] as? String
                
                let subscriptionPayload = SubscriptionPayload(
                    transactionId: transactionId,
                    originalTransactionId: originalTransactionId,
                    subscriptionStartDate: subscriptionStartDate,
                    subscriptionEndDate: subscriptionEndDate,
                    productId: productId
                )
                
                // Pass the updated payload to the completion handler
                completion(.success(subscriptionPayload))
            } else {
                // Handle case where data is nil
                completion(.failure(NSError(domain: "NoDataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data found in document."])))
            }
        }
    }
}

//MARK: Purchase Subscription Title
extension SubscriptionsManager {
    
    func showAlert(with message: String, alertTitle : String) {
        self.alertMessage = message
        self.alertType = alertTitle
        self.showAlert = true
        self.isLoading = false
    }
}

//MARK: Purchase Subscription Title
extension SubscriptionsManager {
    
    func returnPurchaseTitle() {
        if let subscriptionPayload = latestPayload , let dateStr = subscriptionPayload.subscriptionEndDate , let date = convertToDate(from: dateStr) ,date < Date() {
            purchasedProductIDs.removeAll()
            setSelectedProduct(IAPConstants.Products.yearlySubscription, title: "Continue")
            return
        }
        switch purchasedProductIDs.count {
        case 0:
            setSelectedProduct(IAPConstants.Products.yearlySubscription, title: "Continue")
        case 1:
            handleSinglePurchasedProduct()
        case 2:
            handleMultiplePurchasedProducts()
        default:
            setSelectedProduct(IAPConstants.Products.yearlySubscription, title: "Continue")
        }
    }
    
    private func handleSinglePurchasedProduct() {
        if let subscriptionPayload = latestPayload , let dateStr = subscriptionPayload.subscriptionEndDate , let date = convertToDate(from: dateStr) ,date < Date() {
            purchasedProductIDs.removeAll()
            setSelectedProduct(IAPConstants.Products.yearlySubscription, title: "Continue")
            return
        }
        guard let currentProductID = purchasedProductIDs.first else { return }
        
        let targetProductID: String
        let targetTitle: String
        
        switch currentProductID {
        case IAPConstants.Products.monthlySubscription:
            targetProductID = IAPConstants.Products.yearlySubscription
            targetTitle = "Upgrade"
        case IAPConstants.Products.yearlySubscription:
            targetProductID = IAPConstants.Products.monthlySubscription
            targetTitle = "Downgrade"
        default:
            targetProductID = IAPConstants.Products.yearlySubscription
            targetTitle = "Continue"
        }
        
        setSelectedProduct(targetProductID, title: targetTitle)
    }
    
    private func handleMultiplePurchasedProducts() {
        guard let subscription = UserSessionManager.getUserSubscriptionDetail() else { return }
        
        for productID in purchasedProductIDs where subscription.productId == productID {
            let targetProductID: String
            let targetTitle: String
            
            switch productID {
            case IAPConstants.Products.monthlySubscription:
                targetProductID = IAPConstants.Products.yearlySubscription
                targetTitle = "Upgrade"
            case IAPConstants.Products.yearlySubscription:
                targetProductID = IAPConstants.Products.monthlySubscription
                targetTitle = "Downgrade"
            default:
                targetProductID = IAPConstants.Products.yearlySubscription
                targetTitle = "Continue"
            }
            
            setSelectedProduct(targetProductID, title: targetTitle)
            return
        }
        
        setSelectedProduct(IAPConstants.Products.yearlySubscription, title: "Continue")
    }
    
    private func setSelectedProduct(_ productID: String, title: String) {
        DispatchQueue.main.async {
            self.selectedProduct = self.products.first { $0.id == productID }
            self.title = title
        }
    }
    
    func isViewDisabled(title: String, product: String) -> Bool {
        return (title == "Upgrade" && product == IAPConstants.Products.monthlySubscription) ||
        (title == "Downgrade" && product == IAPConstants.Products.yearlySubscription) ||
        false
    }
}

extension SubscriptionsManager {
    func fetchActiveProducts(
        originalTransactionId: String,
        isSandbox: Bool = true,
        completion: @escaping (Result<[[String: Any]], Error>) -> Void
    ) {
        // Define the base URL depending on the environment
        let baseURL = isSandbox
        ? "https://api.storekit-sandbox.itunes.apple.com/inApps/v1/subscriptions/"
        : "https://api.storekit.itunes.apple.com/inApps/v1/subscriptions/"
        
        guard let url = URL(string: baseURL + originalTransactionId) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        // Retrieve the app's StoreKit receipt token
        guard let token = AppStore.appStoreReceiptToken else {
            completion(.failure(NSError(domain: "No App Store token", code: -1, userInfo: nil)))
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Execute the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                  let data = data else {
                completion(.failure(NSError(domain: "Invalid response", code: -1, userInfo: nil)))
                return
            }
            
            do {
                // Decode the response JSON
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let dataDict = json["data"] as? [[String: Any]] else {
                    completion(.failure(NSError(domain: "Invalid JSON structure", code: -1, userInfo: nil)))
                    return
                }
                
                // Filter active subscriptions
                let activeProducts = dataDict.filter { subscription in
                    guard let status = subscription["status"] as? String, status == "ACTIVE" else { return false }
                    return true
                }
                
                completion(.success(activeProducts))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

/// A helper to fetch the App Store receipt token (StoreKit 2).
private extension AppStore {
    static var appStoreReceiptToken: String? {
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
              let receiptData = try? Data(contentsOf: receiptURL) else { return nil }
        
        return receiptData.base64EncodedString()
    }
}
