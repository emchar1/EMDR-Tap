//
//  DataService.swift
//  EMDR Tap
//
//  Created by Eddie Char on 8/10/22.
//

import FirebaseFirestore

struct DataService {
    static private(set) var sessionID: Int?
    static var sessionType: SessionType?
    static var guestModel: FIRModel?
    
    static func setSessionID(_ id: Int) {
        sessionID = id
    }

    
    // MARK: - Firebase
    
    //Used for if sessionType is guest
    static var listener: ListenerRegistration?
    
    static var docRef: DocumentReference {
        let docRef = Firestore.firestore().collection("HostSession").document(String(format: "%04d", sessionID ?? 9999))
        return docRef
    }
}
