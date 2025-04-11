import Foundation
import OSLog

enum TranformationState: Equatable {
    case ready
    case error(String)
}

protocol TransformationViewModelProtocol {
    var onStateChanged: Binding<TranformationState> { get }
    func load()
    func get() -> Transformation?
}

final class TransformationViewModel: TransformationViewModelProtocol {
    private var identifier: String
    private(set) var onStateChanged: Binding<TranformationState>
    private let getTransformationUseCase: GetTransformationUseCaseProtocol
    private var transformation: Transformation?
    
    init(identifier: String, getTransformationUseCase: GetTransformationUseCaseProtocol) {
        self.identifier = identifier
        self.onStateChanged = Binding<TranformationState>()
        self.getTransformationUseCase = getTransformationUseCase
    }
    
    func load() {
        getTransformationUseCase.run(identifer: identifier) { [weak self] result in
            switch result {
            case let .success(transformation):
                self?.transformation = transformation
                self?.onStateChanged.update(.ready)
            case let .failure(error):
                Logger.log(error.reason, level: .error, layer: .presentation)
                self?.onStateChanged.update(.error(error.reason))
            }
        }
    }
    
    func get() -> Transformation? {
        transformation
    }
}
