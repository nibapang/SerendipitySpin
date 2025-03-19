import Foundation

class Settings {
    static let shared = Settings()
    
    private let defaults = UserDefaults.standard
    private let soundEnabledKey = "soundEnabled"
    private let animationEnabledKey = "animationEnabled"
    
    var isSoundEnabled: Bool {
        get {
            return defaults.bool(forKey: soundEnabledKey)
        }
        set {
            defaults.setValue(newValue, forKey: soundEnabledKey)
        }
    }
    
    var isAnimationEnabled: Bool {
        get {
            return defaults.bool(forKey: animationEnabledKey)
        }
        set {
            defaults.setValue(newValue, forKey: animationEnabledKey)
        }
    }
    
    private init() {
        // 设置默认值
        if defaults.object(forKey: soundEnabledKey) == nil {
            defaults.set(true, forKey: soundEnabledKey)
        }
        
        if defaults.object(forKey: animationEnabledKey) == nil {
            defaults.set(true, forKey: animationEnabledKey)
        }
    }
} 