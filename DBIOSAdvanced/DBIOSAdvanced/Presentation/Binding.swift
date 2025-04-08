import Foundation

/// Implement a generic class switch between Global Queue to Main Thread
final class Binding<T: Equatable> {
    typealias Completion = (T) -> Void
    private var completion: Completion?
    
    func bind(completion: @escaping Completion) {
        self.completion = completion
    }
    
    func update(_ state: T) {
        if Thread.current.isMainThread {
            completion?(state)
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.completion?(state)
            }
        }
    }
}
