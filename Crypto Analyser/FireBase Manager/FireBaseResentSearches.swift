//
//  FireBaseResentSearches.swift
//  Crypto Analyser
//
//  Created by IE15 on 26/12/24.
//

import Foundation
import FirebaseFirestore

class FireBaseResentSearches {
   static let shared = FireBaseResentSearches()
    
    func addRecentSearch(email: String, image: UIImage,title: String, message: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        
        let recentSearchRef = db.collection("users").document(email).collection("recentSearch")
        let strImage = image.resized(to: 800).toBase64String()
        let searchItem = [
            "image": strImage,
            "title": title,
            "message": message,
            "date": FieldValue.serverTimestamp() // Use Firestore server timestamp
        ] as [String : Any]
        
        recentSearchRef.addDocument(data: searchItem) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func fetchRecentSearches(for email: String, completion: @escaping (Result<[SearchDetails], Error>) -> Void) {
        let db = Firestore.firestore()
        let recentSearchRef = db.collection("users").document(email).collection("recentSearch")
        
        recentSearchRef.order(by: "date", descending: true).getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot {
                let recentSearches = snapshot.documents.compactMap { document -> SearchDetails? in
                    let data = document.data()
                    guard let image = data["image"] as? String , let title = data["title"] as? String,
                          let message = data["message"] as? String,
                          let date = (data["date"] as? Timestamp)?.dateValue() else {
                        return nil
                    }
                    return SearchDetails(
                        id: document.documentID, 
                        image: image.toImage(),
                        title: title,
                        message: message,
                        date: date
                    )
                }
                completion(.success(recentSearches))
            } else {
                completion(.success([]))
            }
        }
    }

    func removeRecentSearch(for email: String, documentID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        
        let documentRef = db.collection("users").document(email).collection("recentSearch").document(documentID)
        documentRef.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
