// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

struct Navigations<Root: View>: View {
    var root: ()->Root
    @Binding var path: Path
    
    init(path: Binding<Path>, root: @escaping () -> Root) {
        self._path = path
        self.root = root
    }
    
    init(root: @escaping () -> Root) {
        self._path = .constant(Path())
        self.root = root
    }
    
    var body: some View {
        VStack {
            HStack{
                Text("title")
            }
            
            root()
        }
    }
}

public struct Path {
    
}

#Preview {
    Navigations(root: {Text("")})
}
