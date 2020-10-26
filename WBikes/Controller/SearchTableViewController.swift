//
//  SearchTableViewController.swift
//  WBikes
//
//  Created by Diego on 20/10/2020.
//

import UIKit
import CoreData

class SearchTableViewController: UITableViewController {
    var dataController: DataController!
    var filteredStations = [Station]()
    var fetchedResultsController:NSFetchedResultsController<Station>!
    var city: City!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tabBarController = self.tabBarController as! TabBarViewController
        self.city = tabBarController.city
        dataController = tabBarController.dataController
        setupFetchedResultsController()
        self.refreshControl?.addTarget(self, action: #selector(updateData), for: .valueChanged)

    }
    
    @objc fileprivate func updateData(){
        Cliente.getStations(city: city, dataController: dataController) { (stations, error) in
            self.refreshControl?.endRefreshing()
            if error != nil {
                if self.viewIfLoaded?.window != nil {
                    self.alertNetworkFailure(){
                        self.updateData()
                    }
                    
                }
                return
            }
            self.setupFetchedResultsController()
            self.tableView.reloadData()

        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupFetchedResultsController()
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Station> = Station.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "city == %@", city)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        
    }
    
    func setImageStation(station : Station) -> UIImage {
        guard station.freeBikes + station.emptySlots > 0 else{
            return UIImage(named: "redPin")!
        }
        let total = station.freeBikes + station.emptySlots
        let available = (station.freeBikes * 100) / total
        
        if available > 50 {
            return UIImage(named: "greenPin")!
        } else if available > 1 {
            return UIImage(named: "yellowPin")!
        } else {
            return UIImage(named: "redPin")!
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let station = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchViewCell", for: indexPath)
        // Configure cell
        if let name = station.name {
            cell.textLabel?.text = name
        }
        cell.detailTextLabel?.text = "Bikes: \(station.freeBikes)  |  Slots: \(station.emptySlots)"
        cell.imageView?.image = setImageStation(station: station)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let navegation = self.tabBarController?.viewControllers?[0] as? UINavigationController,
              let mapController =  navegation.topViewController as? MapViewController,
              let station = fetchedResultsController.sections?[indexPath.section].objects?[indexPath.row] as? Station else {
            return
        }
        mapController.selectAnotation(station: station)
        self.tabBarController?.selectedIndex = 0
    }
    
}
extension SearchTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var predicate: NSPredicate? = nil
        if searchBar.text?.count != 0 {
            predicate = NSPredicate(format: "(name contains [cd] %@) || (address contains[cd] %@) && city == %@", searchBar.text!, searchBar.text!, city)
        }
        fetchedResultsController.fetchRequest.predicate = predicate
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        fetchedResultsController.fetchRequest.predicate = nil
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
}

extension SearchTableViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert: tableView.insertSections(indexSet, with: .fade)
        case .delete: tableView.deleteSections(indexSet, with: .fade)
        case .update, .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
        default:
            break
        }
    }
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
