//
//  AudioPlayer.swift
//  EMDR Tap
//
//  Created by Eddie Char on 8/15/22.
//

import AVFoundation

/**
 A simple audio player.
 */
struct AudioPlayer {
    static var player: AVAudioPlayer?
    
    static func playSound(filename: String, volume: Float = 1, pan: BallDirection = .center) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = player else { return }
            
            switch pan {
            case .left: player.pan = -1
            case .center: player.pan = 0
            case .right: player.pan = 1
            }

            player.volume = volume
            player.play()
        }
        catch {
            print("Error loading \(filename)")
        }
    }
}
