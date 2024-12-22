import Alamofire
import UIKit

final class NetworkClient {
    
    static let shared = NetworkClient()
    private init() {}
    
    private let baseURL = "https://www.themealdb.com/api/json/v1/1/"
    
    enum Endpoint: String {
        case categories = "list.php?c=list"
        case recipes = "filter.php"
        case recipeDetail = "lookup.php"
    }
    
    // MARK: - Methods
    
    func listCategories(completion: @escaping (Result<[String], Error>) -> Void) {
        let url = baseURL + Endpoint.categories.rawValue
        
        AF.request(url).responseDecodable(of: CategoryListResponse.self) { response in
            switch response.result {
            case .success(let data):
                let categories = data.meals.map { $0.strCategory }
                completion(.success(categories))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchRecipes(category: String, completion: @escaping (Result<[Recipe], Error>) -> Void) {
        let url = baseURL + Endpoint.recipes.rawValue
        let parameters: Parameters = ["c": category]
        
        AF.request(url, parameters: parameters).responseDecodable(of: RecipesListResponse.self) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data.meals))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchRecipeDetails(by id: String, completion: @escaping (Result<RecipeDetails, Error>) -> Void) {
        let url = baseURL + Endpoint.recipeDetail.rawValue
        let parameters: Parameters = ["i": id]
        
        AF.request(url, parameters: parameters).responseDecodable(of: RecipeDetailsResponse.self) { response in
            switch response.result {
            case .success(let data):
                if let details = data.meals.first {
                    completion(.success(details))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchImage(from url: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        AF.request(url)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    if let image = UIImage(data: data) {
                        completion(.success(image))
                    } else {
                        let error = NSError(domain: "ImageDecodingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to decode image"])
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}

