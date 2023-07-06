import UIKit

struct HTTPSClient {
    enum ErrorType: String {
        case connection = "Code003", server = "Code002", wrongData = "Code001"
        case noError = ""
    }

    private let timeout = 5.0

    typealias completeClosure = ( _ data: Data?) -> Void
    
    func getEncodedData(_ urlString: String, token: String?, completion: @escaping completeClosure) {
        print(urlString)
        guard let url = URL(string: urlString.urlEncoded()) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 15

        let session = URLSession.shared
        session.dataTask(with: request) {data, response, error in
            if error == nil {
                if let httpResponse = response as? HTTPURLResponse {
                    print("httpResponse=\(httpResponse.statusCode)")
                    if let data = data {
                        completion(data)
                    }else {
                        print(error?.localizedDescription ?? "error with no description")
                        completion(nil)
                    }
                }
            }else {
                completion(nil)
            }
        }.resume()
    }
    
    func getData(_ urlString: String, completion: @escaping completeClosure) {
        print(urlString)
        
        guard let url = URL(string: urlString) else {
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 15

        let session = URLSession.shared
        session.dataTask(with: request) {data, response, error in
            if error == nil {
                if let httpResponse = response as? HTTPURLResponse {
                    print("httpResponse=\(httpResponse.statusCode)")
                    
                    if let data = data {
                        completion(data)
                    }else {
                        print(error?.localizedDescription ?? "error with no description")
                        completion(nil)
                    }
                }
            }else {
                completion(nil)
            }
        }.resume()
    }
    
    func postData(_ urlString: String, body: String, completion: @escaping completeClosure) {
        guard let url = URL(string: urlString) else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.httpBody = body.data(using: String.Encoding.utf8)
        print("url = \(String(describing: urlString)) post = \(body)")
        
        let session = URLSession.shared
        session.dataTask(with: request) {data, response, error in
            if error == nil {
                if let httpResponse = response as? HTTPURLResponse {
                    print("httpResponse=\(httpResponse.statusCode)")
                    if let data = data {
                        completion(data)
                    }else {
                        print(error?.localizedDescription ?? "error with no description")
                        completion(nil)
                    }
                }
            }else {
                print(error?.localizedDescription ?? "error with no description")
                completion(nil)
            }
        }.resume()
    }
    
    func postCollectionListData(_ urlString: String, body: String, completion: @escaping completeClosure) {
        guard let url = URL(string: urlString) else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: String.Encoding.utf8)
        print("url = \(String(describing: urlString)) post = \(body)")
        
        let session = URLSession.shared
        session.dataTask(with: request) {data, response, error in
            if error == nil {
                if let httpResponse = response as? HTTPURLResponse {
                    print("httpResponse=\(httpResponse.statusCode)")
                    if let data = data {
                        completion(data)
                    }else {
                        print(error?.localizedDescription ?? "error with no description")
                        completion(nil)
                    }
                }
            }else {
                print(error?.localizedDescription ?? "error with no description")
                completion(nil)
            }
        }.resume()
    }
    
    func postLocation(_ urlString: String, body: String, completion: @escaping (_ json: [String: Any])->()) {
        guard let url = URL(string: urlString) else {
            return
        }
        print("post url=\(url), body=\(body)")
        
        var request = URLRequest(url: url, timeoutInterval: 3.0)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        URLSession.shared.dataTask(with: request) {data, response, error in
            if let error = error {
                print("Post Location Error: \(error.localizedDescription)")
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("Post Location Code: \(httpResponse.statusCode)")
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(json)
                }
            }
        }.resume()
    }
    
    
    func downloadImage(_ url: String) -> UIImage? {
        let aUrl = URL(string: url)
        guard
            let data = try? Data(contentsOf: aUrl!),
            let image = UIImage(data: data)
        else {
            return nil
        }
        return image
    }
    
    
    func postDataOnce(_ urlString: String, body: String, completion: @escaping (_ json: [String: Any])->(), errorHandler: @escaping ((_: UIAlertAction) -> Void) = {_ in}) {
        print("Post URL = \(String(describing: urlString))\n Post Body = \(body)")
        
        guard let request = postRequest(urlString,body: body) else {
            assertionFailure()
            return
        }
        URLSession.shared.dataTask(with: request) {data, response, error in
            let result = self.errors(from: data, response, error)
            if let code = result.code{print("Post Once Code: \(code)")}
            if let error = result.error{print("Post Once Error: \(error)")}
            switch result.type {
            case .noError:
                completion(result.json!)
            default:
                NaviUtility.ShowAlert(withTitle: result.type.rawValue, message: nil, confirmHandler: errorHandler)
            }
        }.resume()
    }
    
    private func postRequest(_ urlString: String, body: String) -> URLRequest? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        var request = URLRequest(url: url, timeoutInterval: self.timeout)
        request.httpMethod = "POST"
        let newBody = body + "&platform=iOS"
        request.httpBody = newBody.data(using: String.Encoding.utf8)
        return request
    }

    private func errors(from data: Data?, _ response: URLResponse?, _ error: Error?) -> (json: [String: Any]?, type: ErrorType, error: String?, code: String?) {
        if let error = error {
            let description = error.localizedDescription
            return (nil,.connection,description,nil)
        }
        let httpResponse = response as! HTTPURLResponse
        let code = String(httpResponse.statusCode)
        
        guard let data = data else {
            let header = String(describing: httpResponse.allHeaderFields)
            return (nil,.server,header,code)
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            let description = String(data: data, encoding: .utf8)
            return (nil,.wrongData,description,code)
        }
        
        return (json,.noError,nil,code)
    }
}
