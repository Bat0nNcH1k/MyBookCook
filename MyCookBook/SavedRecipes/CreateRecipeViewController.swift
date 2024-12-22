import UIKit
import SnapKit

final class CreateRecipeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    var onDismiss: (() -> Void)?
    
    private let recipeStore = RecipeStore()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create recipe"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .backgroundGray
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Title"
        textField.backgroundColor = .backgroundGray
        textField.layer.cornerRadius = 8
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.setLeftPaddingPoints(10)
        textField.returnKeyType = .done
        return textField
    }()

    private let instructionsTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Instructions"
        textField.backgroundColor = .backgroundGray
        textField.layer.cornerRadius = 8
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.setLeftPaddingPoints(10)
        textField.contentVerticalAlignment = .top
        textField.returnKeyType = .done
        textField.heightAnchor.constraint(equalToConstant: 100).isActive = true
        return textField
    }()

    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create", for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 8
        button.setTitleColor(.white, for: .normal)
        button.isEnabled = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupUI()
        setupActions()
        setupDismissKeyboardGesture()
    }

    private func setupUI() {
        view.backgroundColor = .background
        
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(titleTextField)
        view.addSubview(instructionsTextField)
        view.addSubview(actionButton)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        imageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(150)
        }

        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }

        instructionsTextField.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        actionButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.height.equalTo(50)
        }
    }

    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        imageView.addGestureRecognizer(tapGesture)

        titleTextField.delegate = self
        instructionsTextField.delegate = self

        titleTextField.addTarget(self, action: #selector(validateInputs), for: .editingChanged)
        instructionsTextField.addTarget(self, action: #selector(validateInputs), for: .editingChanged)
        
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }

    private func setupDismissKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func actionButtonTapped() {
        do {
            guard let image = imageView.image,
                  let title = titleTextField.text,
                  let instructions = instructionsTextField.text else { return }
            let id = UUID().uuidString
                  
            try recipeStore.addNewRecipe(id: id, image: nil, imageData: image, title: instructions, instructions: title, isFavorite: false, isCreated: true)
        } catch {
            print("Error adding new recipe: \(error)")
        }
        dismiss(animated: true) {
            self.onDismiss?()
        }
    }

    @objc private func imageViewTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func validateInputs() {
        let isTitleFilled = !(titleTextField.text?.isEmpty ?? true)
        let isInstructionsFilled = !(instructionsTextField.text?.isEmpty ?? true)
        let isImageSet = imageView.image != nil

        let isFormValid = isTitleFilled && isInstructionsFilled && isImageSet
        actionButton.isEnabled = isFormValid
        actionButton.backgroundColor = isFormValid ? .darkGray : .lightGray
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imageView.image = selectedImage
            validateInputs()
        }
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
