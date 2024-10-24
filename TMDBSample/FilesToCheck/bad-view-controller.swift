import UIKit

// Bad: No proper protocol conformance separation
class UserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Bad: Force unwrapped outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // Bad: Public mutable properties
    var user: User!
    var posts: [Post] = []
    var isEditing = false
    
    // Bad: Massive view controller with too many responsibilities
    private let imagePicker = UIImagePickerController()
    private let networkManager = NetworkingManager.shared
    private var refreshControl = UIRefreshControl()
    
    // Bad: Viewdidload doing too much
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        loadUserData()
        setupImagePicker()
        addObservers()
    }
    
    // Bad: Memory management with observers
    private func addObservers() {
        NotificationCenter.default.addObserver(self, 
                                             selector: #selector(handleUserUpdate), 
                                             name: NSNotification.Name("UserUpdated"), 
                                             object: nil)
    }
    
    // Bad: UI code mixed with business logic
    private func setupUI() {
        view.backgroundColor = .white
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        
        // Bad: Hard-coded strings
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", 
                                                          style: .plain, 
                                                          target: self, 
                                                          action: #selector(editTapped))
        
        // Bad: Frame-based layout
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        loadingIndicator.center = view.center
        view.addSubview(loadingIndicator)
    }
    
    // Bad: Mixed concerns in setup
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        // Bad: Force unwrapping of cell registration
        tableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    // Bad: Network call in view controller
    private func loadUserData() {
        // Bad: Force unwrapped user id
        networkManager.makeRequest(url: "/users/\(user.id!)", 
                                 method: "GET", 
                                 params: nil, 
                                 headers: nil, 
                                 body: nil) { [weak self] success, data, error in
            // Bad: Force casting
            if let userData = data as? [String: Any] {
                self?.updateUI(with: userData)
            }
        }
    }
    
    // Bad: UI update not on main thread
    private func updateUI(with userData: [String: Any]) {
        nameLabel.text = userData["name"] as? String
        emailLabel.text = userData["email"] as? String
        
        if let postsData = userData["posts"] as? [[String: Any]] {
            // Bad: Force unwrapping in map
            posts = postsData.map { Post(dict: $0)! }
            tableView.reloadData()
        }
    }
    
    // MARK: - TableView Methods
    
    // Bad: Implicit unwrapping and force casting
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell")! as! PostCell
        let post = posts[indexPath.row]
        
        // Bad: Configuration in cell generation
        cell.titleLabel.text = post.title
        cell.descriptionLabel.text = post.description
        cell.dateLabel.text = post.createdAt?.toString()
        
        // Bad: Image loading in cell
        if let imageURL = post.imageURL {
            networkManager.downloadImage(from: imageURL) { image in
                cell.postImageView.image = image
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    // Bad: No error handling
    @objc private func refreshData() {
        loadUserData()
        refreshControl.endRefreshing()
    }
    
    // Bad: Not handling memory leaks in image picker
    @objc private func editTapped() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - Image Picker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, 
                             didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Bad: Force unwrapping and type casting
        let image = info[.originalImage] as! UIImage
        profileImageView.image = image
        
        // Bad: Dismiss without completion handler
        dismiss(animated: true)
    }
    
    // Bad: Notification handling without proper cleanup
    @objc private func handleUserUpdate(_ notification: Notification) {
        // Bad: Force unwrapping notification object
        let updatedUser = notification.object as! User
        user = updatedUser
        loadUserData()
    }
    
    // Bad: No proper deinitialization
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// Bad: Model in same file as view controller
struct User {
    let id: String?
    let name: String?
    let email: String?
}

struct Post {
    let title: String
    let description: String?
    let imageURL: String?
    let createdAt: Date?
    
    // Bad: Failable initializer with force unwrap
    init?(dict: [String: Any]) {
        guard let title = dict["title"] as? String else { return nil }
        self.title = title
        self.description = dict["description"] as? String
        self.imageURL = dict["image_url"] as? String
        self.createdAt = dict["created_at"] as? Date
    }
}
