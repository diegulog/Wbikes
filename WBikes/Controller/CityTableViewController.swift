//
//  CityTableViewController.swift
//  WBikes
//
//  Created by Diego on 14/10/2020.
//

import UIKit
import CoreData

class CityTableViewController: UIViewController, UISearchBarDelegate  {
    
    @IBOutlet weak var tableViewCitys: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var infoStackView: UIStackView!
    let refreshControl = UIRefreshControl()
    var onSelected: (() -> Void)?
    var citys = [CitysByCountry]()
    var filteredCitys = [CitysByCountry]()
    var dataController: DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate
        else {
            return
        }
        self.dataController = sceneDelegate.dataController
        loadData()
        addRefreshControl()
        self.navigationController?.navigationBar.tintColor = .white
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    fileprivate func loadData() {
        self.loadingUI(true)
        infoStackView.isHidden = true
        Cliente.getCitys{ networksResponse, error in
            self.loadingUI(false)
            self.refreshControl.endRefreshing()
            if error != nil {
                self.infoStackView.isHidden = false
                return
            }
            self.citys = networksResponse
            self.filteredCitys = self.citys
            self.tableViewCitys.reloadData()
        }
    }
    
    fileprivate func addRefreshControl(){
        refreshControl.attributedTitle = NSAttributedString(string: "Refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableViewCitys.addSubview(refreshControl)
    }
    
    func loadingUI(_ loading: Bool){
        if loading {
            loadingIndicator.startAnimating()
        }else{
            loadingIndicator.stopAnimating()
        }
    }
    
    // MARK: - Actions
    
    @objc func refresh(_ sender: AnyObject) {
        loadData()
    }
    
    @IBAction func retryAction(_ sender: Any) {
        loadData()
    }

    
    // MARK: - Search Bar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredCitys = searchText.isEmpty ? citys : citys.compactMap {
            let citys = $0.citys.filter { $0.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil }
            if citys.count > 0 {
                return CitysByCountry(country: $0.country, citys: citys)
            } else {
                return nil
            }
        }
        tableViewCitys.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        filteredCitys = citys
        tableViewCitys.reloadData()
    }
    
}

extension CityTableViewController:  UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredCitys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  filteredCitys[section].citys.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        deleteLastRegion()
        let cityResponse = filteredCitys[indexPath.section].citys[indexPath.row]
        saveSelectCity(cityResponse: cityResponse)
        
        guard let idCity = UserDefaults.standard.object(forKey: Constants.idCity.rawValue)as? String,
              let city = getCity(id: idCity) else {
            return
        }
        let tapBarViewController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        tapBarViewController.city = city
        tapBarViewController.dataController = dataController
        self.present(tapBarViewController, animated: true, completion: nil)
  
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let city = filteredCitys[indexPath.section].citys[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)
        cell.textLabel?.text = city.name
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return filteredCitys[section].country
    }
    
    
    
    fileprivate func getCity(id: String) -> City?{
        let fetchRequest: NSFetchRequest<City> = City.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        if let result = try? dataController.viewContext.fetch(fetchRequest).first {
            return result
        }
        return nil
    }
    
    fileprivate func saveSelectCity(cityResponse: CityResponse) {        
        UserDefaults.standard.set(cityResponse.id, forKey: Constants.idCity.rawValue)
        if getCity(id: cityResponse.id) == nil {
            let city = City(context: dataController.viewContext)
            city.id = cityResponse.id
            city.name = cityResponse.name
            city.latitude = cityResponse.latitude
            city.longitude = cityResponse.longitude
            try? dataController.viewContext.save()
        }
    }
    
    fileprivate func deleteLastRegion() {
        let defaults =  UserDefaults.standard
        defaults.set(nil, forKey: Constants.latitude.rawValue)
        defaults.set(nil, forKey: Constants.longitude.rawValue)
        defaults.set(nil, forKey: Constants.latitudeDelta.rawValue)
        defaults.set(nil, forKey: Constants.longitudeDelta.rawValue)
        
    }
}
