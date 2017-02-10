class TextCell: UITableViewCell, ConfigurableCell {

  @IBOutlet var title: UILabel!
  
  func configure(with text: String) {
    title.text = text
  }
}
