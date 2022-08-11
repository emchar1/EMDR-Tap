//
//  DataService.swift
//  EMDR Tap
//
//  Created by Eddie Char on 8/10/22.
//

import FirebaseFirestore

struct DataService {
    static private(set) var sessionID: Int?

    static var sessionType: SessionType? {
        didSet {
            if sessionType == .host {
                sessionID = Int.random(in: 0...9998)
            }
        }
    }
    
    
    // MARK: - Firebase
    
    static var docRef: DocumentReference {
        let docRef = Firestore.firestore().collection("HostSession").document(String(format: "%04d", sessionID ?? 9999))
        return docRef
    }
}
