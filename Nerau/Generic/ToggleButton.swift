import UIKit

public final class ToggleButton: UIButton {
    
    public var value: Bool = false {
        didSet {
            isSelected = value            
        }
    }
    
    public var handler: ((Bool) -> Void)?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setImage(UIImage(named: "star_inactive"), for: .normal)
        setImage(UIImage(named: "star_active"), for: .selected)
        addTarget(self, action: #selector(didToggle(sender:)), for: .touchUpInside)
    }
    
    @objc func didToggle(sender: ToggleButton) {
        value = !value
        handler?(value)
    }
}
