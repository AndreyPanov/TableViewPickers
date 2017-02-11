class ViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView! {
    didSet { director = TableDirector(tableView: tableView) }
  }
  @IBOutlet weak var heightTableViewConstraint: NSLayoutConstraint!
  
  var director: TableDirector!
  var section: TableSection = TableSection()
  
  let text = TableRow<TextCell>(item: "title")
  let selectorOne = TableRow<SelectorOneCell>(item: 0)
  let selectorTwo = TableRow<SelectorTwoCell>(item: 0)
  let pickerOne = TableRow<PickerOneCell>(item: 0)
  let pickerTwo = TableRow<PickerTwoCell>(item: 0)
  let button = TableRow<ButtonCell>(item: 0)
  
  var isPickerOneShow = false
  var isPickerTwoShow = false
  var indexPathForPickerOne: IndexPath?
  var indexPathForPickerTwo: IndexPath?
  
  var tableViewHeightWithoutPickers: CGFloat = 0.0
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    text.on(.click) { [weak self] options in
      let title = options.cell?.title.text ?? ""
      options.cell?.configure(with: title + title)
      self?.view.setNeedsLayout()
      self?.view.layoutIfNeeded()
    }
    selectorOne.on(.click) { [weak self] options in
      self?.interactPickerOne(with: options.indexPath)
    }
    selectorTwo.on(.click) { [weak self] options in
      self?.interactPickerTwo(with: options.indexPath)
    }
    button.on(.click) { [weak self] options in
      self?.removePickers()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    section.append(rows: [text, selectorOne, selectorTwo, button])
    director.append(section: section)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    if tableViewHeightWithoutPickers == 0.0 { // we set initial tableView size once
      tableViewHeightWithoutPickers = tableView.contentSize.height
    }
    heightTableViewConstraint.constant = tableView.contentSize.height
  }
 
  func interactPickerOne(with indexPath: IndexPath) {
    isPickerOneShow = !isPickerOneShow
    
    if isPickerOneShow {
      indexPathForPickerOne = IndexPath(row: indexPath.row+1, section: indexPath.section)
      insertPicker(with: indexPathForPickerOne!)
    } else {
      removePicker(with: indexPathForPickerOne!)
      indexPathForPickerOne = nil
    }
    changeIndexPathForPicker(with: &indexPathForPickerTwo, positive: isPickerOneShow)
  }
  
  func interactPickerTwo(with indexPath: IndexPath) {
    isPickerTwoShow = !isPickerTwoShow
    
    if isPickerTwoShow {
      indexPathForPickerTwo = IndexPath(row: indexPath.row+1, section: indexPath.section)
      insertPicker(with: indexPathForPickerTwo!)
    } else {
      removePicker(with: indexPathForPickerTwo!)
      indexPathForPickerTwo = nil
    }
  }
  
  func removePickers() {
    if let indexPathForPickerOne = indexPathForPickerOne, isPickerOneShow {
      removePicker(with: indexPathForPickerOne, animated: false)
      self.indexPathForPickerOne = nil
      isPickerOneShow = false
      changeIndexPathForPicker(with: &indexPathForPickerTwo, positive: false)
    }
    if let indexPathForPickerTwo = indexPathForPickerTwo, isPickerTwoShow {
      removePicker(with: indexPathForPickerTwo, animated: false)
      self.indexPathForPickerTwo = nil
      isPickerTwoShow = false
    }
  }
  
  func changeIndexPathForPicker(with indexPath: inout IndexPath?, positive: Bool) {
    guard let path = indexPath else { return }
    
    let row = path.row + (positive ? 1 : -1)
    let updatedIndexPath = IndexPath(row: row, section: path.section)
    indexPath = updatedIndexPath
  }
 
  func insertPicker(with indexPath: IndexPath) {
    
    section.insert(row: pickerOne, at: indexPath.row)
    
    tableView.insertRows(at: [indexPath], with: .fade)
    
    let height = tableView.contentSize.height
    UIView.animate(withDuration: 0.3) {
      self.heightTableViewConstraint.constant = height
      self.view.layoutIfNeeded()
    }
  }
  
  func removePicker(with indexPath: IndexPath, animated: Bool = true) {
    
    section.delete(rowAt: indexPath.row)
    
    tableView.deleteRows(at: [indexPath], with: animated ? .fade : .none)
    
    if animated {
      UIView.animate(withDuration: 0.3) {
        self.updateConstraint()
      }
    } else {
      updateConstraint()
    }
  }
  
  func updateConstraint() {
    heightTableViewConstraint.constant = tableViewHeightWithoutPickers
    view.layoutIfNeeded()
  }
}
