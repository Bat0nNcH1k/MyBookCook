import UIKit
import SnapKit

final class CategoryCell: UITableViewCell {
    
    static let identifier: String = "CategoryCell"
    static let cellHeight: CGFloat = 100

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.backgroundGray
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.text
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        return label
    }()

    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = UIColor.text
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with text: String) {
        titleLabel.text = text
    }

    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(arrowImageView)

        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().inset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }

        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }
}
