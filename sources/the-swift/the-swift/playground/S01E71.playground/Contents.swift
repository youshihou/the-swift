import UIKit

enum File {
    
}

enum Directory {
    
}

struct Path<FileType> {
    var components: [String]
    
    private init(_ components: [String]) {
        self.components = components
    }
    
    var rendered: String {
        "/" + components.joined(separator: "/")
    }
}

extension Path where FileType == Directory {
    init(directoryComponents: [String]) {
        self.components = directoryComponents
    }
    
    func appending(directory: String) -> Path<Directory> {
        Path(directoryComponents: components + [directory])
    }
    
    func appendingFile(_ file: String) -> Path<File> {
        Path<File>(components + [file])
    }
}


let path = Path(directoryComponents: ["Users", "ankui"])
let path1 = path.appending(directory: "Documents")
let path2 = path1.appendingFile("test.md")
print(path2.rendered)
//let path3 = path2.appendingFile("test.md") // error
//let path4 = path2.appending(directory: "Documents") // error

