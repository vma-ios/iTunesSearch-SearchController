
import UIKit

class StoreItemListTableViewController: UITableViewController {
    
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    
    let searchController = UISearchController(searchResultsController: nil)
    let itemController = StoreItemController()
    
    var items = [StoreItem]()
    
    let queryOptions = ["movie", "music", "software", "ebook"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "enter search term"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMatchingItems("Love")
    }
    
    func fetchMatchingItems(_ queryText: String = "") {
        
        self.items = []
//        self.tableView.reloadData()
        
        let searchTerm = !queryText.isEmpty ? queryText : (searchController.searchBar.text ?? queryText)
        let mediaType = queryOptions[filterSegmentedControl.selectedSegmentIndex]
        
        if !searchTerm.isEmpty {
            
            let query = [
                "term": searchTerm,
                "lang": "en_us",
                "media": mediaType
            ]
            
            itemController.fetchItems(matching: query, completion: { (items) in
                
                DispatchQueue.main.async {
                    
                    if let items = items {
                        self.items = items
                        self.tableView.reloadData()
                    } else {
                        print("Unable to load data.")
                    }
                }
            })
        }
    }
    
    func configure(cell: UITableViewCell, forItemAt indexPath: IndexPath) {
        
        let item = items[indexPath.row]
        
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = item.artist
        cell.imageView?.image = #imageLiteral(resourceName: "gray")
        
        let task = URLSession.shared.dataTask(with: item.artworkURL) { (data, response, error) in
            
            guard let imageData = data else {
                return
            }
            
            DispatchQueue.main.async {
                let image = UIImage(data: imageData)
                cell.imageView?.image = image
            }
        }
        
        task.resume()
    }
    
    @IBAction func filterOptionUpdated(_ sender: UISegmentedControl) {
        
        fetchMatchingItems()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        configure(cell: cell, forItemAt: indexPath)

        return cell
    }
    
    // MARK: - Table view delegate
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension StoreItemListTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        fetchMatchingItems()
    }
}

