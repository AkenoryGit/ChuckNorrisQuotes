//
//  QuotesByCategoryViewController.swift
//  ChuckNorrisQuotes
//
//  Created by Дмитрий Дудник on 02.09.2025.
//

import UIKit
import RealmSwift

class QuotesByCategoryViewController: UIViewController, UITableViewDataSource {
    
    private let category: Category
    private var quotes: Results<Quote>!
    private var tableView: UITableView!

    init(category: Category) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
        title = category.name
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) не поддерживается")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupTableView()
        loadQuotes()
    }

    private func setupTableView() {
        tableView = UITableView(frame: view.bounds)
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
    }

    private func loadQuotes() {
        do {
            let realm = try Realm()
            quotes = realm.objects(Quote.self)
                .filter("category.name == %@", category.name)
                .sorted(byKeyPath: "createdAt", ascending: false)
            tableView.reloadData()
        } catch {
            print("Ошибка при загрузке цитат по категории: \(error.localizedDescription)")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotes?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let quote = quotes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = quote.text
        cell.textLabel?.numberOfLines = 0
        return cell
    }
}
