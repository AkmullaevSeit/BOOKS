//
//  BookListScreenVC.swift
//  Books
//
//  Created by 1 on 14.11.2021.
//

import UIKit

enum HTTPMethodType: String {
    case post = "POST"
    case get = "GET"
}

class BookListScreenVC: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    private let cellReuseIdentifier = String(describing: self)
    private var counter = 1
    private var selectedIndexPath: IndexPath? = nil
    private lazy var model: BooksModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.dataSource = self
        loadData(method: .get)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc private func refreshTable() {
        tableView.reloadData()
    }
    
     private func refreshData() {
        loadData(method: .get, refresh: true)
        tableView.reloadData()
    }
    
    func loadData(method: HTTPMethodType = .get, refresh: Bool = false) {
        var baseUrl = URL(string: "https://demo.api-platform.com/books?page=1")
        if refresh {
            baseUrl = changePage(url: baseUrl ?? URL(fileURLWithPath: ""))
        }
        var request = URLRequest.init(url: baseUrl ?? URL(fileURLWithPath: "failed"))
        request.httpMethod = method.rawValue

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.global().async { [weak self] in
                if let error = error {
                    print(error)
                }
                if let response = response {
                    print(response,"---response---")
                }
                if let data = data {
                    do {
                        let subModel = try JSONDecoder().decode(BooksModel.self, from: data)
                        print(subModel)
                        if refresh {
                            self?.model?.hydraMember.append(contentsOf: subModel.hydraMember)
                        } else {
                            self?.model = subModel
                        }
                        DispatchQueue.main.async {
                            self?.tableView.reloadData()
                            if refresh {
                                self?.tableView.refreshControl?.endRefreshing()
                            }
                        }
                    } catch {
                        print("Decoding error: \(error)")
                    }
                }
            }
        }
        task.resume()
    }
    
    private func changePage(url: URL) -> URL {
        var string = url.absoluteString
        string.removeLast()
        
        string.append(contentsOf: String(describing: counter + 1))
        return URL(string: string) ?? URL(fileURLWithPath: "failed")
    }
}

extension BookListScreenVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model?.hydraMember.count ?? 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle , reuseIdentifier: cellReuseIdentifier)
        cell.textLabel?.text = model?.hydraMember[indexPath.row].title
        cell.detailTextLabel?.text = model?.hydraMember[indexPath.row].description
        cell.detailTextLabel?.textColor = .clear
        cell.selectionStyle = .none
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y + scrollView.frame.size.height
        if position > scrollView.contentSize.height {
            refreshData()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch selectedIndexPath {
        case nil:
            selectedIndexPath = indexPath
        default:
            if selectedIndexPath! == indexPath {
                selectedIndexPath = nil
            } else {
                selectedIndexPath = indexPath
            }
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let smallHeight: CGFloat = 70.0
        let expandedHeight: CGFloat = 200.0
        let ip = indexPath
        if selectedIndexPath != nil {
            if ip == selectedIndexPath! {
                tableView.cellForRow(at: indexPath)?.detailTextLabel?.textColor = .black
                tableView.cellForRow(at: indexPath)?.detailTextLabel?.frame.size.height = expandedHeight
                tableView.cellForRow(at: indexPath)?.detailTextLabel?.numberOfLines = 4
                tableView.cellForRow(at: indexPath)?.detailTextLabel?.frame.size.width = view.frame.size.width - 50
                return expandedHeight
            } else {
                tableView.cellForRow(at: indexPath)?.detailTextLabel?.textColor = .clear
                tableView.cellForRow(at: indexPath)?.detailTextLabel?.numberOfLines = 1
                return smallHeight
            }
        } else {
            tableView.cellForRow(at: indexPath)?.detailTextLabel?.numberOfLines = 1
            tableView.cellForRow(at: indexPath)?.detailTextLabel?.textColor = .clear
            return smallHeight
        }
    }

}

