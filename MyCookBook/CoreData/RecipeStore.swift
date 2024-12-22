import UIKit
import CoreData

final class RecipeStore {
    private let context: NSManagedObjectContext
    
    convenience init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Error getting AppDelegate")
        }
        
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addNewRecipe(id: String, image: String?, imageData: UIImage?, title: String, instructions: String, isFavorite: Bool, isCreated: Bool) throws {
        let recipeCoreData = RecipeCoreData(context: context)
        recipeCoreData.title = title
        recipeCoreData.instruction = instructions
        recipeCoreData.isCreated = isCreated
        recipeCoreData.isFavourite = isFavorite
        recipeCoreData.image = image
        recipeCoreData.id = id
        
        if let imageData {
            recipeCoreData.imageData = imageData.jpegData(compressionQuality: 1.0)
        }
        
        try context.save()
    }
    
    func getRecipes() throws -> [RecipeModel] {
        let request = RecipeCoreData.fetchRequest()
        let result = try context.fetch(request)
        
        var recipes: [RecipeModel] = []
        
        result.forEach {
            guard let id = $0.id,
                  let title = $0.title,
                  let instructions = $0.instruction else { return }
            
            recipes.append(RecipeModel(id: id, image: $0.image, imageData: $0.imageData, title: title, instructions: instructions, isFavorite: $0.isFavourite, isCreated: $0.isCreated))
        }
        
        return recipes
    }
    
    func isRecipesFavourite(id: String) -> Bool {
        let fetchRequest = RecipeCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@ AND isFavourite == %@", id as CVarArg, NSNumber(value: true))
        fetchRequest.fetchLimit = 1
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error fetching records: \(error.localizedDescription)")
            return false
        }
    }
    
    func isRecipesCreated(id: String) -> Bool {
        let fetchRequest = RecipeCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@ AND isCreated == %@", id as CVarArg, NSNumber(value: true))
        fetchRequest.fetchLimit = 1
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error fetching records: \(error.localizedDescription)")
            return false
        }
    }
    
    func deleteRecipe(id: String) throws {
        let fetchRequest = RecipeCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        let recipes = try context.fetch(fetchRequest)
        guard let recipe = recipes.first else { return }
        context.delete(recipe)
        
        try context.save()
    }
}
