import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        UITabBar.appearance().tintColor = .text
        
        let recipesCategoriesNC = UINavigationController(rootViewController: RecipesCategoriesViewController())
        let savedRecipesNC = UINavigationController(rootViewController: SavedRecipesViewController())
        let profileNC = UINavigationController(rootViewController: ProfileViewController())
        
        recipesCategoriesNC.tabBarItem = UITabBarItem(
            title: "Recipes",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: nil
        )
        
        savedRecipesNC.tabBarItem = UITabBarItem(
            title: "Saved",
            image: UIImage(systemName: "list.bullet.rectangle.portrait"),
            selectedImage: nil
        )
        
        profileNC.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person.crop.circle"),
            selectedImage: nil
        )

        self.viewControllers = [recipesCategoriesNC, savedRecipesNC, profileNC]
    }
    
}
