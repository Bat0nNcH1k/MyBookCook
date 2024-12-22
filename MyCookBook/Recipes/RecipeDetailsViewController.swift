import UIKit

final class RecipeDetailsViewController: UIViewController {
    
    private let recipeStore = RecipeStore()
    
    private var isFavorite: Bool = false {
        didSet {
            let imageName = isFavorite ? "star.fill" : "star"
            let starImage = UIImage(systemName: imageName)?.withTintColor(.text, renderingMode: .alwaysOriginal)
            favoriteButton.setImage(starImage, for: .normal)
        }
    }
    
    private var isCreated: Bool = false
    
    private var model: RecipeModel?
    
    private var recipeDetails: RecipeDetails?
    private let recipeId: String
    private let recipeTitle: String
    
    private let networkClient = NetworkClient.shared
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    private let contentView = UIView()
    
    private let recipeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        return imageView
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        let starOutline = UIImage(systemName: "star")?.withTintColor(.text, renderingMode: .alwaysOriginal)
        button.setImage(starOutline, for: .normal)
        button.tintColor = .text
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.numberOfLines = 3
        label.textAlignment = .left
        label.textColor = .text
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = .text
        return label
    }()
    
    init(id: String, recipeTitle: String, model: RecipeModel?) {
        self.recipeId = id
        self.recipeTitle = recipeTitle
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        updateFavoriteState()
        setupActions()
        
        if isCreated {
            guard let model = self.model else { return }
            titleLabel.text = model.title
            descriptionLabel.text = model.instructions
            
            guard let imageData = model.imageData,
                  let image = UIImage(data: imageData) else {
                return
            }
            
            recipeImageView.image = image
        } else {
            fetchData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private func setupUI() {
        view.backgroundColor = .background
        navigationItem.title = ""
        navigationController?.navigationBar.prefersLargeTitles = false
        
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        view.addSubview(recipeImageView)
        view.addSubview(favoriteButton)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        
        recipeImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(200)
            make.width.equalTo(200)
        }
        
        favoriteButton.snp.makeConstraints { make in
            make.top.equalTo(recipeImageView.snp.top).offset(8)
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(44)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(recipeImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    private func fetchData() {
        activityIndicator.startAnimating()
        networkClient.fetchRecipeDetails(by: recipeId) { [weak self] result in
            switch result {
            case .success(let recipe):
                self?.recipeDetails = recipe
                self?.updateViews()
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                }
            case .failure(let error):
                print("Failed to fetch or decode recipes:", error)
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    private func setupActions() {
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTupped), for: .touchUpInside)
    }
    
    @objc private func favoriteButtonTupped() {
        if !isFavorite {
            guard let recipeDetails,
                  let title = recipeDetails.strMeal,
                  let instructions = recipeDetails.strInstructions,
                  let image = recipeDetails.strMealThumb else { return }
            
            do {
                try recipeStore.addNewRecipe(id: recipeDetails.idMeal, image: image, imageData: nil, title: title, instructions: instructions, isFavorite: true, isCreated: false)
            } catch {
                print("Error save recipe:", error.localizedDescription)
            }
        } else {
            do {
                guard let details = recipeDetails else { return }
                try recipeStore.deleteRecipe(id: details.idMeal)
            } catch {
                print("Error delete recipe:", error.localizedDescription)
            }
        }
            
        isFavorite.toggle()
    }
    
    private func updateViews() {
        guard let recipeDetails,
              let image = recipeDetails.strMealThumb else { return }
        
        titleLabel.text = recipeDetails.strMeal
        descriptionLabel.text = recipeDetails.strInstructions
        
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
    
    private func updateFavoriteState() {
        let isFavourite = recipeStore.isRecipesFavourite(id: recipeId)
        if isFavourite {
            self.isFavorite = true
        } else {
            self.isFavorite = false
        }
        
        let isCreated = recipeStore.isRecipesCreated(id: recipeId)
        if isCreated {
            self.isCreated = true
            favoriteButton.isHidden = true
        }
    }
}
