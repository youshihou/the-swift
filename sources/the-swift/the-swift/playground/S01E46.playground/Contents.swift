import UIKit


final class Header {
    let view: UIView
    let setTitle: (String) -> Void
    
    init(view: UIView, setTitle: @escaping (String) -> Void) {
        self.view = view
        self.setTitle = setTitle
    }
}

class ParallaxView: UIView {
    let headerView: Header
    
    init(frame: CGRect, headerView: Header) {
        self.headerView = headerView
        super.init(frame: frame)
        
        headerView.setTitle("Hello")
        addSubview(headerView.view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


let label = UILabel()
let header = Header(view: label) { label.text = $0 }
let p = ParallaxView(frame: .zero, headerView: header)






// S01E52
protocol HeaderView {
    func setTitle(_ string: String)
}

class ParallaxView1: UIView {
    let headerView: UIView & HeaderView
    
    init(frame: CGRect, headerView: UIView & HeaderView) {
        self.headerView = headerView
        super.init(frame: frame)
        
        headerView.setTitle("Hello")
        addSubview(headerView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UILabel: HeaderView {
    func setTitle(_ string: String) {
        text = string
    }
}

let header1 = UILabel()
let p1 = ParallaxView1(frame: .zero, headerView: header1)
