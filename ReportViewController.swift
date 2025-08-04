override func viewDidLoad() {
    super.viewDidLoad()
    // ... existing code ...
    // Add search icon for selecting shifts
    let searchButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(searchShifts))
    self.navigationItem.rightBarButtonItem = searchButton
}

@objc func searchShifts() {
    // TODO: Implement shift selection search functionality
    print("Search shifts tapped")
} 