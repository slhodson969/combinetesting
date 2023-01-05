//
//  CombineTestingTests.swift
//  CombineTestingTests
//
//  Created by Scott Hodson on 05/01/2023.
//

import XCTest
import Combine

final class CombineTestingTests: XCTestCase {

    func test_init_doesNotLoad() {
        var callCount: Int = 0

        _ = SomeService {
            callCount += 1
            return PassthroughSubject().eraseToAnyPublisher()
        }

        XCTAssertEqual(callCount, 0)
    }

    func test_load_doesLoad() {
        var callCount: Int = 0

        let sut = SomeService {
            callCount += 1
            return PassthroughSubject().eraseToAnyPublisher()
        }

        sut.load()

        XCTAssertEqual(callCount, 1)
    }
    
//    func test_init_doesNotLoad2() {
//        let (_, loadCallCount) = makeSUT()
//
//        XCTAssertEqual(loadCallCount, 0)
//    }
//
//    func test_load_doesLoad2() {
//        let (sut, loadCallCount) = makeSUT()
//
//        sut.load()
//
//        XCTAssertEqual(loadCallCount, 1)
//    }
//
//    func makeSUT() -> (service: SomeService, loadCallCount: Int) {
//        var loadCallCount: Int = 0
//
//        let sut = SomeService {
//            loadCallCount += 1
//            return PassthroughSubject().eraseToAnyPublisher()
//        }
//
//        return (sut, loadCallCount)
//    }
}

class SomeService {
    private let loader: () -> AnyPublisher<String, Error>
    private var cancellables: Set<AnyCancellable> = []
    private var value: String?
    
    init(loader: @escaping () -> AnyPublisher<String, Error>) {
        self.loader = loader
    }
    
    func load() {
        loader()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Finished")
                case let .failure(error):
                    print("Failed with error: \(error)")
                }
            }, receiveValue: { [weak self] value in
                self?.value = value
            })
            .store(in: &cancellables)
    }
}
