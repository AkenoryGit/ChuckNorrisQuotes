//
//  LoadQuoteViewController.swift
//  ChuckNorrisQuotes
//
//  Created by Дмитрий Дудник on 02.09.2025.
//

import UIKit
import RealmSwift

final class LoadQuoteViewController: UIViewController {
    
    private let loadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Загрузить", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Цитата дня"
        
        view.addSubview(loadButton)
        NSLayoutConstraint.activate([
            loadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadButton.heightAnchor.constraint(equalToConstant: 50),
            loadButton.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        loadButton.addTarget(self, action: #selector(loadQuote), for: .touchUpInside)
    }
    
    @objc private func loadQuote() {
        guard let url = URL(string: "https://api.chucknorris.io/jokes/random") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let id = json["id"] as? String,
                let text = json["value"] as? String
            else {
                print("Ошибка при загрузке цитаты")
                return
            }

            let categoryName = (json["categories"] as? [String])?.first ?? "без категории"

            let realm: Realm
            do {
                realm = try Realm()
            } catch {
                print("Ошибка при создании Realm: \(error.localizedDescription)")
                return
            }

            if realm.object(ofType: Quote.self, forPrimaryKey: id) != nil {
                print("Цитата уже существует в базе: \(text)")
                return
            }

            let quote = Quote()
            quote.id = id
            quote.text = text

            do {
                try realm.write {
                    let category: Category

                    if let existing = realm.object(ofType: Category.self, forPrimaryKey: categoryName) {
                        category = existing
                    } else {
                        let newCategory = Category()
                        newCategory.name = categoryName
                        realm.add(newCategory)
                        category = newCategory
                    }

                    quote.category = category
                    realm.add(quote)
                }
            } catch {
                print("Ошибка при записи в Realm: \(error.localizedDescription)")
            }
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name("QuoteSaved"), object: nil)
            }

            print("Цитата сохранена в Realm: \(text)")
        }.resume()
    }
}
