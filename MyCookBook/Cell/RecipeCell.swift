import UIKit
import SwiftUI

final class RecipeCell: UITableViewCell {
    
    static let identifier: String = "RecipeCell"
    static let cellHeight: CGFloat = 120
    
    private let networkClient = NetworkClient.shared
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.backgroundGray
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let recipeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.tintColor = UIColor.background
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.text
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(image: String?, imageData: UIImage?, text: String) {
        
        if let image = image {
            networkClient.fetchImage(from: image) { result in
                switch result {
                case .success(let image):
                    DispatchQueue.main.async { [weak self] in
                        self?.recipeImageView.image = image
                    }
                case .failure(let error):
                    print("Failed to load image:", error)
                }
            }
        }
        
        if let imageData = imageData {
            self.recipeImageView.image = imageData
        }
        
        titleLabel.text = text
    }

    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(recipeImageView)
        containerView.addSubview(titleLabel)

        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().inset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
        }

        recipeImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.height.equalTo(120)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(recipeImageView.snp.trailing).offset(20)
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
    }
}
