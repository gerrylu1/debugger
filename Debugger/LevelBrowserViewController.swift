//
//  LevelBrowserViewController.swift
//  Debugger
//
//  Created by Gerry Low on 2020-06-23.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

import UIKit
import CoreData

class LevelBrowserViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Level>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? LevelMakerViewController {
            vc.dataController = dataController
        }
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Level> = Level.fetchRequest()
        let sortById = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortById]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "levels")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    private func deleteLevel(at indexPath: IndexPath) {
        let levelToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(levelToDelete)
        do {
            try dataController.save()
        } catch {
            showAlert(title: "Failed to Delete Level", message: error.localizedDescription, on: self)
        }
    }
    
}

extension LevelBrowserViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LevelCell", for: indexPath)
        let object = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = object.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deleteLevel(at: indexPath)
        default: () // Unsupported
        }
    }
    
}

extension LevelBrowserViewController: NSFetchedResultsControllerDelegate {
    
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
