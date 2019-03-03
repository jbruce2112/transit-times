import UIKit

class RouteListViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView().withAutoLayout()
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private var viewModel: RouteListViewModel
    init(viewModel: RouteListViewModel = RouteListViewModelImpl()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = viewModel.name
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        NSLayoutConstraint.activate(tableView.constraintsToFillSuperview())
        
        self.viewModel.reload = { [weak self] in
            self?.tableView.reloadData()
        }
        self.viewModel.fetchRoutes()
    }
}

extension RouteListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.routes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let route = viewModel.routes[indexPath.row]
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = route.title
        return cell
    }
}

extension RouteListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let route = viewModel.routes[indexPath.row]
        
        let detailsViewModel = RouteDetailsViewModelImpl(routeTag: route.tag, name: route.title)
        let viewController = RouteDetailsViewController(viewModel: detailsViewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
