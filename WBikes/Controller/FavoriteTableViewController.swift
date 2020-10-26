//
//  FavoriteTableViewController.swift
//  WBikes
//
//  Created by Diego on 20/10/2020.
//

import UIKit
import CoreData

class FavoriteTableViewController: UITableViewController {

    var dataController: DataController!
    var filteredStations = [Station]()
    var fetchedResultsController: NSFetchedResultsController<Station>!
    var city: City!
    lazy var noDataLabel: UILabel = {
        let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        noDataLabel.numberOfLines = 1
        noDataLabel.text          = "No Favorites"
        noDataLabel.textColor     = UIColor.black
        noDataLabel.textAlignment = .center
        noDataLabel.font = UIFont(name: "Montserrat-Bold", size: 17)
        return noDataLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tabBarController = self.tabBarController as! TabBarViewController
        self.city = tabBarController.city
        navigationItem.rightBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem?.tintColor = .white
        dataController = tabBarController.dataController
        setupFetchedResultsController()
        self.refreshControl?.addTarget(self, action: #selector(updateData), for: .valueChanged)

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        tableView.reloadData()
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
        updateEditButtonState()
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Station> = Station.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "city == %@ && isFavorite == true", city)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        
    }
    func updateEditButtonState() {
       navigationItem.rightBarButtonItem?.isEnabled = fetchedResultsController.sections![0].numberOfObjects > 0
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
    func deleteFavorite(at indexPath: IndexPath) {
        let favoriteToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(favoriteToDelete)
        dataController.save()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if (self.fetchedResultsController?.fetchedObjects?.count ?? 0) > 0 {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine

        }else{
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle = .none
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
  
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deleteFavorite(at: indexPath)
        default: ()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure cell
        let station = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteViewCell", for: indexPath)
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

extension FavoriteTableViewController: NSFetchedResultsControllerDelegate {
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
            break
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
