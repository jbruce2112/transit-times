import UIKit

class RouteDetailsViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView().withAutoLayout()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = segmentedControl
        return tableView
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: nil)
        control.addTarget(self, action: #selector(segmentSelected), for: .valueChanged)
        return control
    }()
    
    private var viewModel: RouteDetailsViewModel
    
    init(viewModel: RouteDetailsViewModel) {
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
            guard let strongSelf = self else {
                return
            }
            strongSelf.segmentedControl.removeAllSegments()
            for direction in strongSelf.viewModel.directionNames {
                strongSelf.segmentedControl.insertSegment(withTitle: direction,
                                                          at: strongSelf.segmentedControl.numberOfSegments,
                                                          animated: true)
            }
            strongSelf.view.setNeedsLayout()
            strongSelf.view.layoutIfNeeded()
            strongSelf.tableView.reloadData()
        }
        self.viewModel.fetchDetails()
    }
    
    @objc private func segmentSelected() {
        viewModel.directionIndex = segmentedControl.selectedSegmentIndex
        print("set index to \(viewModel.directionIndex)")
    }
}

extension RouteDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = viewModel.names[indexPath.row]
        return cell
    }
}

extension RouteDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        viewModel.addFavorite(row: indexPath.row)
        
        
//
//        viewModel.fetchPredictions(stop: Stop(route: name, tag: tag)) { [weak self] predictions in
//            guard let predictions = predictions else {
//                return
//            }
//        }
    }
}
