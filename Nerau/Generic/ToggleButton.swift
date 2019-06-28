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
        #if targetEnvironment(UIKitForMac)
        iconsSFSymbol()
        #else
        if #available(iOS 13, *) {
            iconsSFSymbol()
        } else {
            iconsDefault()
        }
        #endif
        addTarget(self, action: #selector(didToggle(sender:)), for: .touchUpInside)
    }
    
    @available(iOS 13.0, *)
    @available(UIKitForMac 13.0, *)
    private func iconsSFSymbol() {
        setImage(UIImage(systemName: "star"), for: .normal)
        setImage(UIImage(systemName: "star.fill"), for: .selected)
    }
    
    private func iconsDefault() {
        setImage(UIImage(named: "star_inactive"), for: .normal)
        setImage(UIImage(named: "star_active"), for: .selected)
    }
    
    @objc func didToggle(sender: ToggleButton) {
        value = !value
        handler?(value)
    }
}
