import UIKit

final class RecipesListViewController: UIViewController {
    
    private var recipes: [Recipe] = []
    private let category: String
    
    private let networkClient = NetworkClient.shared
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        return tableView
    }()
    
    init(category: String) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        fetchData()
    }

    private func setupUI() {
        navigationItem.title = category
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.backgroundColor = .background
        
        view.addSubview(tableView)
        
        tableView.register(RecipeCell.self, forCellReuseIdentifier: RecipeCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    private func fetchData() {
        activityIndicator.startAnimating()
        networkClient.fetchRecipes(category: category) {  [weak self] result in
            switch result {
            case .success(let recipes):
                self?.recipes = recipes
                self?.tableView.reloadData()
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
}

extension RecipesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecipeCell.identifier, for: indexPath) as? RecipeCell else {
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        let recipe = recipes[indexPath.row]
        cell.configure(image: recipe.strMealThumb ?? nil, imageData: nil, text: recipe.strMeal!)
        return cell
    }
}

extension RecipesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        RecipeCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailsViewController = RecipeDetailsViewController(id: recipes[indexPath.row].idMeal!, recipeTitle: recipes[indexPath.row].strMeal!, model: nil)
        navigationController?.pushViewController(detailsViewController, animated: true)
    }
}
