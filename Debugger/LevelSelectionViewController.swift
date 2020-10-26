//
//  LevelSelectionViewController.swift
//  Debugger
//
//  Created by Gerry Low on 2020-06-23.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

import UIKit
import CoreData
import StoreKit

class LevelSelectionViewController: UITableViewController {
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Level>!
    
    var makingTransaction = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        SKPaymentQueue.default().add(self)
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Level> = Level.fetchRequest()
        let sortByDefault = NSSortDescriptor(key: "isCustom", ascending: true)
        let sortByDate = NSSortDescriptor(key: "dateCreated", ascending: true)
        fetchRequest.sortDescriptors = [sortByDefault, sortByDate]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    private func setMakingTransaction(_ purchasing: Bool) {
        makingTransaction = purchasing
    }
    
    private func buyRandomLevels() {
        setMakingTransaction(true)
        if SKPaymentQueue.canMakePayments() {
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = AppDelegate.randomLevelsProductID
            SKPaymentQueue.default().add(paymentRequest)
            
        } else {
            // can't make payments
            setMakingTransaction(false)
            print("User can't make payments")
            showAlert(title: "Purchase Not Successful", message: "Sorry, the purchase you made was not successful due to unsuccessful payment.", on: self)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if makingTransaction {
            showAlert(title: "Transaction in Process", message: "A transaction is in process. Please wait a few seconds and try again.", on: self)
            return
        }
        let object = fetchedResultsController.object(at: indexPath)
        if (object.name == DefaultLevels.randomLevelEasy || object.name == DefaultLevels.randomLevelNormal || object.name == DefaultLevels.randomLevelHard || object.name == DefaultLevels.randomLevelCrazy || object.name == DefaultLevels.randomLevelInsane) && !object.isCustom && !UserDefaults.standard.bool(forKey: AppDelegate.randomLevelsProductID) {
            showAlertTwoActionsWithCancel(title: "Unlock Random Levels?", message: "Get a surprise each time you play for only 0.99 USD!\n\nIf you have previously made the purchase, please use the \"Restore\" button to avoid re-purchasing and wait for a while.", on: self, actionOneTitle: "Buy", actionTwoTitle: "Restore") {
                self.buyRandomLevels()
            } actionTwoCompletion: {
                SKPaymentQueue.default().restoreCompletedTransactions()
            }
        } else {
            let playerVC = storyboard?.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
            playerVC.dataController = dataController
            playerVC.level = fetchedResultsController.object(at: indexPath)
            navigationController?.pushViewController(playerVC, animated: true)
        }
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

extension LevelSelectionViewController: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                // User payment successful
                print("Purchase successful")
                showAlert(title: "Random Levels Unlocked", message: "Your purchase was successful. Thank you for your support!", on: self)
                UserDefaults.standard.set(true, forKey: AppDelegate.randomLevelsProductID)
                SKPaymentQueue.default().finishTransaction(transaction)
                setMakingTransaction(false)
            } else if transaction.transactionState == .failed {
                // Payment failed
                if let error = transaction.error as? SKError {
                    print("Transaction failed due to error: \(error.localizedDescription)")
                    if error.code == .paymentCancelled {
                        showAlert(title: "Transaction Failed", message: "Payment was cancelled.", on: self)
                    } else {
                        showAlert(title: "Transaction Failed", message: "Transaction failed due to error: \(error.localizedDescription)", on: self)
                    }
                }
                SKPaymentQueue.default().finishTransaction(transaction)
                setMakingTransaction(false)
            } else if transaction.transactionState == .restored {
                print("Transaction restored")
                UserDefaults.standard.set(true, forKey: AppDelegate.randomLevelsProductID)
                SKPaymentQueue.default().finishTransaction(transaction)
                showAlert(title: "Purchase Restored", message: "Congratulations! Your purchase was restored successfully.", on: self)
                setMakingTransaction(false)
            }
        }
    }
    
}
