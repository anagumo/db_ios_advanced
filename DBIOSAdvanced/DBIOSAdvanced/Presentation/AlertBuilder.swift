import UIKit

final class AlertBuilder {
    func build(title: String, message: String) -> UIAlertController {
        let controller = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        
        controller.addAction(
            UIAlertAction(
                title: "OK",
                style: .default
            )
        )
        
        return controller
    }
}
