import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var spinSound: AVAudioPlayer?
    private var winSound: AVAudioPlayer?
    private var stopSound: AVAudioPlayer?
    
    private init() {
        setupSounds()
    }
    
    private func setupSounds() {
        // 加载音效资源
        if let spinSoundPath = Bundle.main.path(forResource: "spin", ofType: "wav") {
            let spinSoundUrl = URL(fileURLWithPath: spinSoundPath)
            do {
                spinSound = try AVAudioPlayer(contentsOf: spinSoundUrl)
                spinSound?.prepareToPlay()
            } catch {
                print("Error loading spin sound: \(error)")
            }
        }
        
        if let winSoundPath = Bundle.main.path(forResource: "win", ofType: "wav") {
            let winSoundUrl = URL(fileURLWithPath: winSoundPath)
            do {
                winSound = try AVAudioPlayer(contentsOf: winSoundUrl)
                winSound?.prepareToPlay()
            } catch {
                print("Error loading win sound: \(error)")
            }
        }
        
        if let stopSoundPath = Bundle.main.path(forResource: "stop", ofType: "wav") {
            let stopSoundUrl = URL(fileURLWithPath: stopSoundPath)
            do {
                stopSound = try AVAudioPlayer(contentsOf: stopSoundUrl)
                stopSound?.prepareToPlay()
            } catch {
                print("Error loading stop sound: \(error)")
            }
        }
    }
    
    func playSpinSound() {
        if Settings.shared.isSoundEnabled {
            spinSound?.currentTime = 0
            spinSound?.play()
        }
    }
    
    func playWinSound() {
        if Settings.shared.isSoundEnabled {
            winSound?.currentTime = 0
            winSound?.play()
        }
    }
    
    func playStopSound() {
        if Settings.shared.isSoundEnabled {
            stopSound?.currentTime = 0
            stopSound?.play()
        }
    }
} 