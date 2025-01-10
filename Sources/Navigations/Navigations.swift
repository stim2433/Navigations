// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

struct ContentView: View {
    @State private var test = Path()
    var body: some View {
        Navigations(path: $test) {
            VStack {
                Button {
                    test.push("test")
                } label: {
                    Text("push")
                }

            }
            .setTitle(.constant("test"))
//            .destination(for: String.self) { value in
//                TwoContentView()
//            }
        }
    }
}

struct TwoContentView: View {
    var body: some View {
        Text("screen 2")
    }
}

struct Navigations<Root: View>: View {
    @Binding var path: Path
    @State private var title: String = ""
    
    @ViewBuilder var root: ()->Root
    @State private var views: ViewsStack<Root>?
    
    @State private var dragOffset: CGFloat = 0.0
    
    init(path: Binding<Path>, root: @escaping () -> Root) {
        self._path = path
        self.root = root
    }
    
    init(root: @escaping () -> Root) {
        self._path = .constant(Path())
        self.root = root
    }
    
    fileprivate init(title: Binding<String>, root: @escaping () -> Root) {
        self._path = .constant(Path())
        self.root = root
        self._title = State(wrappedValue: title.wrappedValue)
    }
    
    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    HStack{
                        Text(title)
                    }
                    
                    BackButton()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
            VStack {
                if let view = views?.currentView {
                    view
                }
            }
            .onAppear{
                initStack()
            }
        }
        .offset(x: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.width > 0, path.count >= 1 {
                        dragOffset = value.translation.width
                    }
                }
                .onEnded { value in
                    if dragOffset > 100, path.count >= 1 {
                        path.pop()
                    }
                    dragOffset = 0
                }
        )
        .environment(\.path, $path)
        
    }
    
    private func initStack() {
        views = ViewsStack(for: root())
    }
    
    @ViewBuilder
    private func BackButton() -> some View {
        HStack {
            if path.count >= 1 {
                Button  {
                    path.pop()
                } label: {
                    Image (systemName: "chevron.left")
                    Text("Back")
                }

            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
    }
}

struct TitleNavigationsLabel: ViewModifier {
    @Binding var title: String
    
    init(title: Binding<String>) {
        self._title = title
    }
    
    func body(content: Content) -> some View {
        Navigations(title: $title) {
            content
        }
    }
}

struct ViewsStack<Item: View> {
    
    private var items: [StackItem<Item>] = []
    
    
    
    init(for item: Item) {
        let item = StackItem(id: UUID().uuidString, view: item)
        items = [item]
        print(currentView)
//        print(items)
    }
    
    var currentView: Item? {
        items.last?.view
    }
    
    func syncViews(id: String?) {
//        print(id)
//        guard let id = items.lastIndex(where: { $0.id == id })
//        else { return }
    }
}

struct StackItem<Item: View> {
    var id: String = UUID().uuidString
    var view: Item
}

extension View {
    func setTitle(_ title: Binding<String>) -> some View {
        self.modifier(TitleNavigationsLabel(title: title))
    }
    
    func destination<T: Hashable, Destination: View>(for item: T.Type, @ViewBuilder value: @escaping (T) -> Destination) -> some View {
        DestinationView(itemType: item.self, destination: value)
    }
    
    func testDestination<T: Hashable> (for type: T.Type) -> some View {
        modifier(DestinationViewModifier(type: type))
    }
}

struct DestinationViewModifier<T: Hashable>: ViewModifier {
//    @Environment private var path: Path
    var type: T.Type
    func body(content: Content) -> some View {
        content
    }
}

struct DestinationView<T: Hashable, Destination: View>: View {
    var itemType: T.Type
    @ViewBuilder var destination: (T)->Destination
    
    @Environment(\.path) private var path: Binding<Path>
    
    @State private var lastItem: T?
    var body: some View {
        Text("time view")

        if let lastItem = path.wrappedValue.last as? T {
            destination(lastItem)
        }
    }
}

public struct Path {
    public var count: Int {
        items.count
    }
    
    private var items: [PathItem]
    
    init() {
        items = []
    }
    
    init<S> (_ element: S) where S : Sequence, S.Element: Hashable {
        items = element.map { PathItem(item: $0)}
    }
    
    public mutating func push(_ item: any Hashable) {
        items.append(PathItem(item: item))
    }
    
    public mutating func pop() {
        guard let _ = items.popLast()?.item else { return }
    }
    
    public var last: (any Hashable)? {
        items.last?.item
    }
}

extension Path: Equatable {
    public static func == (lhs: Path, rhs: Path) -> Bool {
        return lhs.items.last?.id == rhs.items.last?.id
    }
}

struct PathItem: Equatable {
    
    let id = UUID().uuidString
    var item: any Hashable
    
    static func == (lhs: PathItem, rhs: PathItem) -> Bool {
        lhs.id == rhs.id
    }
}

private struct PathEnvironmentKey: EnvironmentKey {
    static let defaultValue: Binding<Path> = .constant(Path())
}

extension EnvironmentValues {
    var path: Binding<Path> {
        get { self[PathEnvironmentKey.self]}
        set { self[PathEnvironmentKey.self] = newValue }
    }
}

#Preview {
    ContentView()
}
