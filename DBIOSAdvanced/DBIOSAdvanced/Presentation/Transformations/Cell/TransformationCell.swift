import UIKit

class TransformationCell: UICollectionViewCell {
    static let identifier = String(describing: TransformationCell.self)
    // MARK: - UI Components
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK: - Binding
    func bind(_ transformation: Transformation) {
        photoImageView.setImage(stringURL: transformation.photo ?? "")
        nameLabel.text = transformation.name
    }
}
