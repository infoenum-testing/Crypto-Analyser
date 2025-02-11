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
class SubscriptionsManager: NSObject, ObservableObject, SKRequestDelegate {
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
                print("\n \n Success Purchase :")
                print("transactionId",transaction.id)
                print("originalTransactionId",transaction.originalID)
                print("subscriptionoriginalStartDate",transaction.originalPurchaseDate)
                print("subscriptionStartDate",transaction.purchaseDate)
                print("subscriptionEndDate",transaction.expirationDate as Any)
                print("productId",transaction.productID,"\n\n")
                
                let payload = SubscriptionPayload(transactionId: "\(transaction.id)",
                                                  originalTransactionId: "\(transaction.originalID)", subscriptionStartDate: "\(transaction.purchaseDate)", subscriptionEndDate: "\(transaction.expirationDate ?? Date())",
                                                  productId: "\(transaction.productID)")
                
                
                await transaction.finish()
                await saveTransactionToFirebase(transaction: payload)
                await self.updatePurchasedProducts()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.isLoading = false
                }
                
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
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                print("\n \n Product history :")
                print("transactionId", transaction.id)
                print("originalTransactionId", transaction.originalID)
                print("subscriptionStartDate", transaction.originalPurchaseDate)
                print("purchaseDate", transaction.purchaseDate)
                print("subscriptionEndDate", transaction.expirationDate as Any)
                print("productId", transaction.productID, "\n\n")

                self.purchasedProductIDs.insert(transaction.productID)

                if tempLatestPayload == nil {
                    latestTransactionId = "\(transaction.originalID)"
                    tempLatestPayload = SubscriptionPayload(
                        transactionId: "\(transaction.id)",
                        originalTransactionId: "\(transaction.originalID)",
                        subscriptionStartDate: "\(transaction.purchaseDate)",
                        subscriptionEndDate: "\(transaction.expirationDate ?? Date())",
                        productId: "\(transaction.productID)"
                    )
                } else if let payload = tempLatestPayload,
                          transaction.purchaseDate >= convertToDate(from: tempLatestPayload?.subscriptionStartDate ?? "") ?? Date() {
                    latestTransactionId = "\(transaction.originalID)"
                    tempLatestPayload = SubscriptionPayload(
                        transactionId: "\(transaction.id)",
                        originalTransactionId: "\(transaction.originalID)",
                        subscriptionStartDate: "\(transaction.purchaseDate)",
                        subscriptionEndDate: "\(transaction.expirationDate ?? Date())",
                        productId: "\(transaction.productID)"
                    )
                }

                try? await transaction.finish() // Optional: Only necessary for non-consumables.
            }
        }

        let email = UserSessionManager.getUserEmail()
        if let payload = tempLatestPayload {
            checkIfTransactionExists(originalTransactionId: payload.originalTransactionId ?? "", userEmail: email) { exists in
                if exists {
                    self.isPlanActive = false
                    self.latestPayload = nil
                    print("Transaction already exists for another user!")
                } else {
                    print("Transaction is unique; proceed with saving.")
                    self.updateSubscriptionDetails(for: email, newSubscription: payload, completion: { result in
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
                            self.isPlanActive = false
                            self.purchasedProductIDs.removeAll()
                            self.latestPayload = nil
                        }
                        self.entitlementManager?.hasPro = !self.purchasedProductIDs.isEmpty
                        self.returnPurchaseTitle()
                    })
                }
            }
        } else {
            self.isPlanActive = false
        }
    }
    
    func refreshReceipt() async throws {
        let request = SKReceiptRefreshRequest(receiptProperties: nil)
        request.delegate = self // Make sure you implement SKRequestDelegate
        request.start()
    }
    
    func checkActiveSubscription() async -> Bool {
        do {
            for await result in Transaction.currentEntitlements {
                let transaction = try result.payloadValue // Verify transaction first
                
                if transaction.productType == .autoRenewable {
                    print("Active subscription: \(transaction.productID)")
                    
                    // Check expiration date (only available for subscriptions)
                    if let expirationDate = transaction.expirationDate, expirationDate > Date() {
                        return true
                    }
                }
            }
        } catch {
            print("Failed to get current entitlements: \(error)")
        }
        return false
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
    func updateSubscriptionDetails(for userEmail: String, newSubscription: SubscriptionPayload, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !userEmail.isEmpty else {
            completion(.failure(NSError(domain: "NoDataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid email."])))
            return
        }
        
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(userEmail).collection("Subscriptions").document("SubscriptionDetails")
        
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
    }
    
    
    func saveSubscriptionDetails(userEmail: String, subscription: SubscriptionPayload, completion: @escaping (Result<String, Error>) -> Void) {
        guard let originalTransactionId = subscription.originalTransactionId else {
            completion(.failure(NSError(domain: "FirestoreError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Missing original transaction ID"])))
            return
        }
        
        let db = Firestore.firestore()
        let subscriptionRef = db.collection("users")
            .document(userEmail)
            .collection("Subscriptions")
            .document(originalTransactionId) // Store as document ID
        
        // Check if transaction ID already exists
        subscriptionRef.getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let document = document, document.exists {
                completion(.failure(NSError(domain: "FirestoreError", code: 409, userInfo: [NSLocalizedDescriptionKey: "Transaction ID already exists"])))
                return
            }
            
            // Data to save
            let data: [String: Any] = [
                "transactionId": subscription.transactionId ?? "",
                "originalTransactionId": originalTransactionId,
                "subscriptionStartDate": subscription.subscriptionStartDate ?? "",
                "subscriptionEndDate": subscription.subscriptionEndDate ?? "",
                "productId": subscription.productId ?? "",
                "userId": userEmail
            ]
            
            // Save data
            subscriptionRef.setData(data) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success("Subscription saved successfully!"))
                }
            }
        }
    }
    
    func checkIfTransactionExists(originalTransactionId: String, userEmail: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("users").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print(" Error fetching users: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
                return
            }
            
            var exists = false
            
            let group = DispatchGroup()
            
            for document in documents {
                let email = document.documentID // Each user's email
                
                //  Skip checking for the current user
                if email == userEmail {
                    continue
                }
                
                group.enter()
                
                db.collection("users")
                    .document(email)
                    .collection("Subscriptions")
                    .whereField("originalTransactionId", isEqualTo: originalTransactionId)
                    .getDocuments { subSnapshot, subError in
                        
                        if let subDocs = subSnapshot?.documents, !subDocs.isEmpty {
                            print(" Transaction ID \(originalTransactionId) already exists for user: \(email)")
                            exists = true
                        }
                        
                        group.leave()
                    }
            }
            
            group.notify(queue: .main) {
                completion(exists)
            }
        }
    }
    
    
    func saveTransactionToFirebase(transaction: SubscriptionPayload) async {
        let email = UserSessionManager.getUserEmail()
        if email.isEmpty { return }
        
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(email).collection("Subscriptions").document("SubscriptionDetails")
        
        do {
            let document = try await docRef.getDocument()
            
            if document.exists {
                print("SubscriptionDetails already exists. Skipping save.")
                return
            }
            
            let docData: [String: Any] = [
                "transactionId": transaction.transactionId ?? "",
                "originalTransactionId": transaction.originalTransactionId ?? "",
                "subscriptionStartDate": transaction.subscriptionStartDate ?? "",
                "subscriptionEndDate": transaction.subscriptionEndDate ?? "",
                "productId": transaction.productId ?? ""
            ]
            
            try await docRef.setData(docData)
            print("Transaction saved to Firestore successfully.")
            UserSessionManager.saveUserSubscriptionDetail(transaction)
            
        } catch {
            print("Error checking/saving transaction: \(error)")
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
        if isPlanActive ==  false {
            setSelectedProduct(IAPConstants.Products.yearlySubscription, title: "Continue")
            return
        }
        
        let id = latestPayload?.productId ?? ""
        switch  id {
        case "com.infoenum.Crypto.autoRenewableOneMonth" :
            setSelectedProduct(IAPConstants.Products.yearlySubscription, title: "Upgrade")
        case  "com.infoenum.Crypto.autoRenewableOneYear" :
            setSelectedProduct(IAPConstants.Products.monthlySubscription, title: "Downgrade")
        default:
            setSelectedProduct(IAPConstants.Products.yearlySubscription, title: "Continue")
        }
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

