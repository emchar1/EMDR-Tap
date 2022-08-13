//
//  FIRModel.swift
//  EMDR Tap
//
//  Created by Eddie Char on 8/10/22.
//

import Foundation
import FirebaseFirestoreSwift

struct FIRModel: Codable, Identifiable {
    @DocumentID public var id: String?
    
    var isPlaying: Bool
    var speed: Float
    var duration: TimeInterval
    var currentImage: Int
}
