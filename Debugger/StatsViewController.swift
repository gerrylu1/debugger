//
//  StatsViewController.swift
//  Debugger
//
//  Created by Gerry Low on 2020-06-29.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

import UIKit
import CoreData

class StatsViewController: UITableViewController {
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Stat>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Stat> = Stat.fetchRequest()
        let sortByDate = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortByDate]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    private func deleteStat(at indexPath: IndexPath) {
        let statToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(statToDelete)
        do {
            try dataController.save()
        } catch {
            showAlert(title: "Failed to delete stat", message: error.localizedDescription, on: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatCell", for: indexPath)
        let object = fetchedResultsController.object(at: indexPath)
        var name: String = object.level?.name ?? "(No Name)"
        if let isCustom = object.level?.isCustom {
            if isCustom {
                name += " (Custom)"
            } else {
                name += " (Default)"
            }
        }
        let details = String(format: "Killed: %d | Missed: %d | Total Time Spent: %.2f sec", object.kills, object.misses, object.totalTime)
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = details
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            showAlertOnDelete(title: "Delete A Record For \(fetchedResultsController.object(at: indexPath).level?.name ?? "This Level")?", message: "Are you sure you want to delete this record?", on: self) {
                self.deleteStat(at: indexPath)
            }
        default: () // Unsupported
        }
    }
    
}

extension StatsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert: tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete: tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update: tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move: tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default: fatalError("Invalid change type in controller(_:didChange:at:for:newIndexPath:). Only .insert, .delete, .update or .move should be possible.")
        }
    }
    
}
