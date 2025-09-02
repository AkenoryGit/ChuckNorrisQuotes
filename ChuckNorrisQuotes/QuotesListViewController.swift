//
//  QuotesListViewController.swift
//  ChuckNorrisQuotes
//
//  Created by Дмитрий Дудник on 02.09.2025.
//

import UIKit
import RealmSwift

class QuotesListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var quotes: Results<Quote>!
    private var tableView: UITableView!
    private var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Цитаты"

        setupTableView()
        loadQuotes()
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
    }
    
    private func loadQuotes() {
        do {
            let realm = try Realm()
            quotes = realm.objects(Quote.self).sorted(byKeyPath: "createdAt", ascending: false)

            notificationToken = quotes.observe { [weak self] changes in
                guard let tableView = self?.tableView else { return }
                switch changes {
                case .initial:
                    tableView.reloadData()
                case .update(_, let deletions, let insertions, let modifications):
                    tableView.performBatchUpdates {
                        tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                        tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                        tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    } completion: { _ in
                        tableView.reloadData()
                    }
                case .error(let error):
                    print("Ошибка наблюдения Realm: \(error.localizedDescription)")
                }
            }

        } catch {
            print("Ошибка загрузки цитат из Realm: \(error.localizedDescription)")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotes?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let quote = quotes[indexPath.row]
        cell.textLabel?.text = quote.text
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let realm = try! Realm()
            let quoteToDelete = quotes[indexPath.row]

            let category = quoteToDelete.category

            try! realm.write {
                realm.delete(quoteToDelete)

                if let category = category {
                    let quotesInCategory = realm.objects(Quote.self)
                        .filter("category.name == %@", category.name)

                    if quotesInCategory.isEmpty {
                        if let categoryToDelete = realm.object(ofType: Category.self, forPrimaryKey: category.name) {
                            realm.delete(categoryToDelete)
                        }
                    }
                }
            }
        }
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
}
