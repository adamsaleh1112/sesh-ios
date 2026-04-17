import SwiftUI

struct WeightImageView: View {
    let weight: Int
    @State private var isLoading = true
    
    private var imageURL: String {
        let imageWeight = determineImageWeight(for: weight)
        return "https://your-project.supabase.co/storage/v1/object/public/assets/images/weights/\(imageWeight).png"
    }
    
    var body: some View {
        AsyncImage(url: URL(string: imageURL)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .overlay(
                    Group {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "dumbbell")
                                .foregroundColor(.gray)
                        }
                    }
                )
        }
        .frame(width: 60, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isLoading = false
            }
        }
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
