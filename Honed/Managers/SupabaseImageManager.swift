import Foundation
import SwiftUI

class SupabaseImageManager: ObservableObject {
    static let shared = SupabaseImageManager()
    
    private let supabaseURL = "https://tzkgjsfuvgnajpayeagb.supabase.co"
    private let supabaseAnonKey = "YOUR_ANON_KEY_HERE" // Add your anon key
    
    private init() {}
    
    func getSignedImageURL(for weight: Int) async -> String? {
        let imageWeight = determineImageWeight(for: weight)
        let filePath = "assets/images/weights/\(imageWeight).png"
        
        // Create signed URL request
        let signURL = "\(supabaseURL)/storage/v1/object/sign/\(filePath)"
        
        guard let url = URL(string: signURL) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Request body for signed URL (expires in 1 hour)
        let body = ["expiresIn": 3600]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let signedURL = json["signedURL"] as? String {
                return "\(supabaseURL)\(signedURL)"
            }
        } catch {
            print("Error generating signed URL: \(error)")
        }
        
        return nil
    }
    
    private func determineImageWeight(for weight: Int) -> Int {
        let weightIntervals = [45, 65, 75, 90, 115, 135]
        var selectedWeight = 45
        
        for interval in weightIntervals {
            if weight >= interval {
                selectedWeight = interval
            }
        }
        
        return selectedWeight
    }
}
