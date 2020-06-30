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
    
}
