import UIKit
import SnapKit

final class SavedRecipesViewController: UIViewController {
    
    private var favouriteRecipes: [Recipe] = []
    private var createdRecipes: [RecipeModel] = []
    private let recipeStore = RecipeStore()
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Favourites", "Created"])
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = .darkGray
        control.setTitleTextAttributes([.foregroundColor: UIColor.background], for: .selected)
        control.setTitleTextAttributes([.foregroundColor: UIColor.text], for: .normal)
        return control
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        fetchData()
        setupAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    private func setupUI() {
        view.backgroundColor = .background
        navigationItem.title = "Categories"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .text
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.text
        ]
        
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        
        tableView.register(RecipeCell.self, forCellReuseIdentifier: RecipeCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
    }
    
    private func fetchData() {
        do {
            
            var updateFavourite: [Recipe] = []
            var updateCreated: [RecipeModel] = []
            
            let recipes = try recipeStore.getRecipes()
            
            recipes.forEach {
                if $0.isFavorite {
                    guard let image = $0.image else { return }
                    updateFavourite.append(Recipe(strMeal: $0.title, strMealThumb: image, idMeal: $0.id))
                } else {
                    updateCreated.append($0)
                }
            }
            
            favouriteRecipes = updateFavourite
            createdRecipes = updateCreated
            tableView.reloadData()
        } catch {
            print("Error get recipe:", error.localizedDescription)
        }
    }
    
    private func setupAction() {
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    private func hideAddRecipeButton(in navigationController: UINavigationController) {
        let emptyButton = UIBarButtonItem()
        navigationItem.rightBarButtonItem = emptyButton
    }
    
    private func showAddRecipeButton(in navigationController: UINavigationController) {
        let plusButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addRecipeButtonTapped)
        )
        navigationItem.rightBarButtonItem = plusButton
    }
    
    @objc func addRecipeButtonTapped() {
        let createRecipeVC = CreateRecipeViewController()
        
        createRecipeVC.onDismiss = { [weak self] in
            self?.fetchData()
        }
        
        createRecipeVC.modalPresentationStyle = .pageSheet
        present(createRecipeVC, animated: true)
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            fetchData()
            hideAddRecipeButton(in: navigationController!)
        case 1:
            fetchData()
            showAddRecipeButton(in: navigationController!)
        default:
            break
        }
    }
}

extension SavedRecipesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count = 0
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            count = favouriteRecipes.count
        case 1:
            count = createdRecipes.count
        default:
            count = 0
        }
        
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecipeCell.identifier, for: indexPath) as? RecipeCell else {
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            let recipe = favouriteRecipes[indexPath.row]
            cell.configure(image: recipe.strMealThumb, imageData: nil, text: recipe.strMeal!)
        case 1:
            let recipe = createdRecipes[indexPath.row]
            guard let imageData = createdRecipes[indexPath.row].imageData,
                  let image = UIImage(data: imageData) else {
                return cell
            }
            cell.configure(image: nil, imageData: image, text: recipe.instructions)
        default:
            break
        }
        
        return cell
    }
}

extension SavedRecipesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        RecipeCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            let detailsViewController = RecipeDetailsViewController(id: favouriteRecipes[indexPath.row].idMeal!, recipeTitle: favouriteRecipes[indexPath.row].strMeal!, model: nil)
            navigationController?.pushViewController(detailsViewController, animated: true)
        case 1:
            let detailsViewController = RecipeDetailsViewController(id: createdRecipes[indexPath.row].id, recipeTitle: createdRecipes[indexPath.row].title, model: createdRecipes[indexPath.row])
            navigationController?.pushViewController(detailsViewController, animated: true)
        default:
            break
        }
    }
}
