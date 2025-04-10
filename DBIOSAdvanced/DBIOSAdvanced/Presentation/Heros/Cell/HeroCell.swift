import UIKit

class HeroCell: UICollectionViewCell {
    static let identifier = String(describing: HeroCell.self)
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    func bind(_ hero: Hero) {
        contentStackView.layer.cornerRadius = 8
        photoImageView.layer.cornerRadius = 8
        photoImageView.setImage(stringURL: hero.photo ?? "")
        nameLabel.text = hero.name
    }
}
