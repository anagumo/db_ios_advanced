import UIKit
import OSLog

extension UIImageView {
    
    func setImage(stringURL: String) {
        guard let url = URL(string: stringURL) else {
            Logger.log(APIError.malformedURL(url: "UIImageView+Remote").reason, level: .error, layer: .presentation)
            return
        }
        
        downloadWithURLSession(url: url) { [weak self] result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self?.image = image
                }
            case .failure:
                Logger.log("Unexpected error downloading image", level: .error, layer: .presentation)
            }
        }
    }
    
    private func downloadWithURLSession(url: URL, completion: @escaping (Result<UIImage, Error>)  -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data,
                  let image = UIImage(data: data) else {
                Logger.log("Unexpected error downloading image", level: .error, layer: .presentation)
                completion(.failure(NSError(domain: "Image Download Error", code: 0)))
                return
            }
            
            completion(.success(image))
        }
        .resume()
    }
}
