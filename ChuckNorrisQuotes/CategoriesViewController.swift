//
//  CategoriesViewController.swift
//  ChuckNorrisQuotes
//
//  Created by Дмитрий Дудник on 02.09.2025.
//

import UIKit
import RealmSwift

class CategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var categories: Results<Category>!
    private var tableView: UITableView!
    private var notificationToken: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Категории"

        setupTableView()
        loadCategories()
    }

    private func setupTableView() {
        tableView = UITableView(frame: view.bounds)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
    }

    private func loadCategories() {
        do {
            let realm = try Realm()
            categories = realm.objects(Category.self).sorted(byKeyPath: "name")

            notificationToken = categories.observe { [weak self] changes in
                guard let tableView = self?.tableView else { return }

                switch changes {
                case .initial:
                    tableView.reloadData()
                case .update(_, let deletions, let insertions, let modifications):
                    tableView.performBatchUpdates {
                        tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                        tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                        tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    }
                case .error(let error):
                    print("Ошибка наблюдения за категориями: \(error.localizedDescription)")
                }
            }

        } catch {
            print("Ошибка загрузки категорий из Realm: \(error.localizedDescription)")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < categories.count else {
            tableView.reloadData()
            return
        }
        
        let selectedCategory = categories[indexPath.row]
        let quotesVC = QuotesByCategoryViewController(category: selectedCategory)
        navigationController?.pushViewController(quotesVC, animated: true)
    }

    deinit {
        notificationToken?.invalidate()
    }
}
