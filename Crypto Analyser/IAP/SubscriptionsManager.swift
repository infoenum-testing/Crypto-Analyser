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
    @Published var  title = "Purchase"
    
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
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            if transaction.revocationDate == nil {
                self.purchasedProductIDs.insert(transaction.productID)
            } else {
                self.purchasedProductIDs.remove(transaction.productID)
            }
        }
        
        self.entitlementManager?.hasPro = !self.purchasedProductIDs.isEmpty
        returnPurchaseTitle()
    }
    
    
    
    func restorePurchases() async {
        isLoading = true
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
    
    
    func saveTransactionToFirebase(transaction: SubscriptionPayload) async {
        
        let email = UserSessionManager.getUserEmail()
        
        
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
    
     func getSubscriptionDetails(for userEmail: String) async  {
            let db = Firestore.firestore()
            let docRef = db.collection("users").document(userEmail).collection("Subscriptions").document("SubscriptionDetails")
            
            do {
                let documentSnapshot = try await docRef.getDocument()
                
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
                    print(subscriptionPayload)
                    /// save the details to user defaults ...
                }
            } catch {
                print("Error fetching subscription details from Firestore: \(error)")
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
        switch purchasedProductIDs.count {
        case 0:
            setSelectedProduct(IAPConstants.Products.yearlySubscription, title: "Purchase")
        case 1:
            handleSinglePurchasedProduct()
        case 2:
            handleMultiplePurchasedProducts()
        default:
            setSelectedProduct(IAPConstants.Products.yearlySubscription, title: "Purchase")
        }
    }

    private func handleSinglePurchasedProduct() {
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
            targetTitle = "Purchase"
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
                targetTitle = "Purchase"
            }
            
            setSelectedProduct(targetProductID, title: targetTitle)
            return
        }
        
        setSelectedProduct(IAPConstants.Products.yearlySubscription, title: "Purchase")
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
