import UIKit
import SnapKit

final class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle")
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .backgroundGray
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 75
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.backgroundGray.cgColor
        return imageView
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Your Name"
        textField.font = UIFont.systemFont(ofSize: 18)
        textField.textAlignment = .center
        textField.borderStyle = .none
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        textField.returnKeyType = .done
        textField.isUserInteractionEnabled = true
        return textField
    }()
    
    private let editIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "pencil")
        imageView.tintColor = .text
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupActions()
        loadProfileImage()
        loadName()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            profileImageView.image = selectedImage
            saveProfileImage(selectedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func setupUI() {
        view.backgroundColor = .background
        view.addSubview(profileImageView)
        view.addSubview(nameTextField)
        view.addSubview(editIcon)
        
        nameTextField.addTarget(self, action: #selector(nameTextFieldEditingDidEnd), for: .editingDidEnd)
        
        profileImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            make.width.height.equalTo(150)
        }
        
        nameTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(profileImageView.snp.bottom).offset(16)
            make.height.equalTo(40)
        }
        
        editIcon.snp.makeConstraints { make in
            make.centerY.equalTo(nameTextField.snp.centerY)
            make.leading.equalTo(nameTextField.snp.trailing).offset(8)
            make.width.height.equalTo(20)
        }
    }
    
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImage))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGesture)
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        nameTextField.delegate = self
        let tapKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapKeyboardGesture)
    }
    
    private func applySystemTheme() {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .unspecified
        }
    }
    
    private func applyManualTheme(isDarkMode: Bool) {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        }
    }
    
    private func saveProfileImage(_ image: UIImage) {
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(imageData, forKey: "profileImage")
        }
    }
    
    private func loadProfileImage() {
        if let imageData = UserDefaults.standard.data(forKey: "profileImage"),
           let image = UIImage(data: imageData) {
            profileImageView.image = image
        }
    }
    
    private func loadName() {
        let name = UserDefaults.standard.string(forKey: "profileName") ?? ""
        nameTextField.text = name.isEmpty ? nil : name
        nameTextField.placeholder = name.isEmpty ? "Your Name" : nil
    }
    
    @objc private func nameTextFieldEditingDidEnd() {
        if let text = nameTextField.text?.trimmingCharacters(in: .whitespaces) {
            UserDefaults.standard.set(text, forKey: "profileName")
        }
        
        guard let text = nameTextField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty else {
            nameTextField.text = nil
            nameTextField.placeholder = "Your Name"
            return
        }
    }
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func didTapProfileImage() {
        present(imagePicker, animated: true, completion: nil)
    }
}

