//
//  LevelSelectionViewController.swift
//  Debugger
//
//  Created by Gerry Low on 2020-06-23.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

import UIKit
import CoreData

class LevelSelectionViewController: UITableViewController {
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Level>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PlayerViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                vc.dataController = dataController
                vc.level = fetchedResultsController.object(at: indexPath)
            }
        }
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Level> = Level.fetchRequest()
        let sortByDate = NSSortDescriptor(key: "dateCreated", ascending: true)
        fetchRequest.sortDescriptors = [sortByDate]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LevelCell", for: indexPath)
        let object = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = object.name
        if object.isCustom {
            cell.detailTextLabel?.text = "Custom"
        } else {
            cell.detailTextLabel?.text = "Default"
        }
        return cell
    }
    
}

extension LevelSelectionViewController: NSFetchedResultsControllerDelegate {
    
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
