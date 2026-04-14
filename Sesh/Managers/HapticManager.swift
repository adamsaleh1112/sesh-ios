import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    
    private init() {
        prepareLight()
        prepareSoft()
        prepareMedium()
        prepareHeavy()
    }
    
    func prepareLight() {
        lightImpact.prepare()
    }
    
    func prepareSoft() {
        softImpact.prepare()
    }
    
    func prepareMedium() {
        mediumImpact.prepare()
    }
    
    func prepareHeavy() {
        heavyImpact.prepare()
    }
    
    func light() {
        lightImpact.impactOccurred()
    }
    
    func soft() {
        softImpact.impactOccurred()
    }
    
    func medium() {
        mediumImpact.impactOccurred()
    }
    
    func heavy() {
        heavyImpact.impactOccurred()
    }
}
