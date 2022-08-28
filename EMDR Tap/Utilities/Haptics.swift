//
//  Haptics.swift
//  EMDR Tap
//
//  Created by Eddie Char on 8/27/22.
//

import CoreHaptics

class Haptics {
    static private(set) var supportsHaptics: Bool = false
    static var engine: CHHapticEngine!
    
    @discardableResult static func checkForHaptics() -> Bool {
        let hapticCapability = CHHapticEngine.capabilitiesForHardware()
        
        supportsHaptics = hapticCapability.supportsHaptics
        
        return supportsHaptics
    }
    
    static func configureEngine() {
        guard supportsHaptics else { return print("Haptics not supported") }
        
        do {
            engine = try CHHapticEngine()
        } catch {
            print("Haptic Engine creation error: \(error)")
        }
        
        engine.resetHandler = {
            print("Reset Handler: Restarting the haptic engine.")
            
            do {
                // Try restarting the engine.
                try self.engine.start()
                
                // Register any custom resources you had registered, using registerAudioResource.
                // Recreate all haptic pattern players you had created, using createPlayer.
            } catch {
                print("Failed to restart the engine: \(error)")
            }
        }
        
        engine.stoppedHandler = { reason in
            print("Stop Handler: The engine stopped for reason: \(reason.rawValue)")
            
            switch reason {
            case .audioSessionInterrupt: print("Audio session interrupt")
            case .applicationSuspended: print("Application suspended")
            case .idleTimeout: print("Idle timeout")
            case .systemError: print("System error")
            default: print("Unknown error")
            }
        }
    }
    
    
    // MARK: - Haptic Patterns
    
    static func playButtonTap() {
        let event = CHHapticEvent(eventType: .hapticTransient,
                                  parameters: [CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9),
                                               CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)],
                                  relativeTime: 0)
        
        playHapticPattern(events: [event])
    }
    
    static func playSettingsExpand() {
        let event = CHHapticEvent(eventType: .hapticTransient,
                                  parameters: [CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                                               CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)],
                                  relativeTime: 0)
        
        playHapticPattern(events: [event])
    }
    
    static func playInvalidSessionID() {
        var events = [CHHapticEvent]()
        
        for i in 0..<10 {
            let event = CHHapticEvent(eventType: .hapticTransient,
                                      parameters: [CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                                                   CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)],
                                      relativeTime: TimeInterval(i) / 40)

            events.append(event)
        }
            
        playHapticPattern(events: events)
    }
    
    static func playBounce(_ ball: Int) {
        var event: CHHapticEvent
        var intensity: Float
        var sharpness: Float
        var loop: Int
        var events = [CHHapticEvent]()

        switch ball {
        case 0: //ball
            intensity = 0.9
            sharpness = 0.1
            loop = 1
        case 1: //star
            intensity = 1.0
            sharpness = 1.0
            loop = 1
        case 2: //moon
            intensity = 0.7
            sharpness = 0.3
            loop = 1
        case 3: //atom
            intensity = 0.5
            sharpness = 0.5
            loop = 6
        default: //smile, etc.
            intensity = 0
            sharpness = 0
            loop = 1
        }
        
        for i in 0..<loop {
            print(i)
            event = CHHapticEvent(eventType: .hapticTransient,
                                  parameters: [CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                                               CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)],
                                  relativeTime: TimeInterval(i) / 36)
            
            events.append(event)
        }
        
        playHapticPattern(events: events)
    }
    
    private static func playHapticPattern(events: [CHHapticEvent]) {
        guard supportsHaptics else { return }

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            
            try engine.start() //Call this first!
            try player.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error)")
        }
    }
}
