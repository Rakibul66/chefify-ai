import Foundation

class SearchService {
    
    // The function to fetch images based on a search term
    func fetchImages(query: String, completion: @escaping (Result<[ImageData], Error>) -> Void) {
        
        let parameters = ["q": query]
        guard let postData = try? JSONSerialization.data(withJSONObject: parameters) else {
            return
        }
        
        var request = URLRequest(url: URL(string: "https://google.serper.dev/images")!, timeoutInterval: Double.infinity)
        request.addValue("f8fd608331e02397876fb3b0af484f7ee75a54b1", forHTTPHeaderField: "X-API-KEY")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in

            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }
            
            do {
                let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
                completion(.success(searchResponse.images))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
