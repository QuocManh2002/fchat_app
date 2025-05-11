
import Foundation
import StreamVideo

class TokenManager{
    
    lazy var urlToken = ""
    
    static let shared = TokenManager()
    
    lazy var tokenURL = "\(baseURL)/api/auth/create-token?user_id="
    let baseURL = "https://stream-calls-dogfood.vercel.app"
        
    private let httpClient: HTTPClient = URLSessionClient()
    
    private init(){}
    
    func fetchToken(for userId: String, completion: @escaping (Bool, String?) -> Void) {
        let payload: [String: Any] = [
            "id": userId
        ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
            completion(false, "Failed to encode JSON")
            return
        }
        
        guard let baseUrl = URL(string: "https://asia-southeast2-fchat-app-6dd34.cloudfunctions.net/generateToken") else {
            completion(false, "Invalid URL")
            return
        }
        
        var request = URLRequest(url: baseUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Fail to generate token with error: \(error.localizedDescription)")
                completion(false, error.localizedDescription)
                return
            }
            
            guard let data = data else {
                completion(false, "No data received")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("token: \(responseString)")
                    completion(true, responseString)
                    return
                } else {
                    completion(false, "Fail to parse response")
                    return
                }
            } else {
                completion(false, "Fail to generate token")
                return
            }
        }.resume()
    }
    
    struct TokenResponse: Codable{
        let userId: String
        let token: String
    }
}
