import UIKit

final class RecipesCategoriesViewController: UIViewController {
    
    private var categories: [String] = []
    
    private let networkClient = NetworkClient.shared
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setAppTheme()
    }
    
    private func setupUI() {
        navigationItem.title = "Categories"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .text
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.text
        ]
        
        view.backgroundColor = .background
        view.addSubview(tableView)
        
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
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
        networkClient.listCategories { [weak self] result in
            switch result {
            case .success(let recipes):
                self?.categories = recipes
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
    
    private func setAppTheme() {
        let defaults = UserDefaults.standard
        let isSystemTheme = defaults.bool(forKey: "isSystemTheme")
        let isDarkMode = defaults.bool(forKey: "isDarkMode")

        if isSystemTheme {
            if #available(iOS 13.0, *) {
                let style = UITraitCollection.current.userInterfaceStyle
                if style == .dark {
                    UIWindow.appearance().overrideUserInterfaceStyle = .dark
                } else {
                    UIWindow.appearance().overrideUserInterfaceStyle = .light
                }
            }
        } else {
            if isDarkMode {
                UIWindow.appearance().overrideUserInterfaceStyle = .dark
            } else {
                UIWindow.appearance().overrideUserInterfaceStyle = .light
            }
        }
    }
}

extension RecipesCategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        cell.configure(with: categories[indexPath.row])
        
        return cell
    }
}

extension RecipesCategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        CategoryCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailsViewController = RecipesListViewController(category: categories[indexPath.row])
        navigationController?.pushViewController(detailsViewController, animated: true)
    }
}
