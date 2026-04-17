import Foundation
import SwiftUI

class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    private let supabaseURL = "https://your-project.supabase.co"
    private let supabaseKey = "your-anon-key"
    
    private init() {}
    
    func getWeightImageURL(for weight: Int) -> String {
        let imageWeight = determineImageWeight(for: weight)
        return "\(supabaseURL)/storage/v1/object/public/assets/images/weights/\(imageWeight).png"
    }
    
    private func determineImageWeight(for weight: Int) -> Int {
        let weightIntervals = [45, 65, 75, 90, 115, 135]
        
        // Find the highest interval that the weight exceeds
        var selectedWeight = 45 // Default to lowest
        
        for interval in weightIntervals {
            if weight >= interval {
                selectedWeight = interval
            }
        }
        
        return selectedWeight
    }
}
