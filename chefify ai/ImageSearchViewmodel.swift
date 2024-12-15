import Foundation
import Combine

class ImageSearchViewModel: ObservableObject {
    @Published var images: [ImageData] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let cache = ImageCache() // Custom caching mechanism
    
    // Fetch images with caching and advanced error handling
    func fetchImages(for query: String) {
        // Check if the results are cached
        if let cachedImages = cache.getImages(for: query) {
            self.images = cachedImages
            self.errorMessage = nil
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        let parameters = "{\"q\":\"\(query)\"}"
        guard let postData = parameters.data(using: .utf8) else {
            self.errorMessage = "Invalid request data"
            return
        }
        
        var request = URLRequest(url: URL(string: "https://google.serper.dev/images")!, timeoutInterval: Double.infinity)
        request.addValue("f8fd608331e02397876fb3b0af484f7ee75a54b1", forHTTPHeaderField: "X-API-KEY")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData
        
        // Network request with Combine
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: SearchResponse.self, decoder: JSONDecoder())
            .retry(3) // Retry the request 3 times in case of failure
            .map { $0.images }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.isLoading = false
                case .failure(let error):
                    self.isLoading = false
                    self.errorMessage = "Error: \(error.localizedDescription)"
                }
            }, receiveValue: { images in
                // Cache the results
                self.cache.saveImages(images, for: query)
                self.images = images
            })
            .store(in: &cancellables)
    }
    
    // Function to clear cache (optional)
    func clearCache() {
        cache.clearCache()
    }
}

class ImageCache {
    private let cacheKey = "imageCache"
    
    // Save images to cache (UserDefaults for simplicity)
    func saveImages(_ images: [ImageData], for query: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(images) {
            UserDefaults.standard.set(encoded, forKey: "\(cacheKey)_\(query)")
        }
    }
    
    // Get images from cache
    func getImages(for query: String) -> [ImageData]? {
        if let data = UserDefaults.standard.data(forKey: "\(cacheKey)_\(query)"),
           let decoded = try? JSONDecoder().decode([ImageData].self, from: data) {
            return decoded
        }
        return nil
    }
    
    // Clear cache
    func clearCache() {
        let keys = UserDefaults.standard.dictionaryRepresentation().keys
        for key in keys {
            if key.starts(with: cacheKey) {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }
}

