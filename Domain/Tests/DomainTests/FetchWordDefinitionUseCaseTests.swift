import XCTest
@testable import Domain

final class FetchWordDefinitionUseCaseTests: XCTestCase {
    private var sut: DefaultFetchWordDefinitionUseCase!
    private var repository: MockWordDefinitionRepository!
    
    override func setUp() {
        super.setUp()
        repository = MockWordDefinitionRepository()
        sut = DefaultFetchWordDefinitionUseCase(repository: repository)
    }
    
    override func tearDown() {
        sut = nil
        repository = nil
        super.tearDown()
    }
    
    func testExecute_WhenRepositorySucceeds_ReturnsDefinition() async throws {
        // Given
        let expectedDefinition = WordDefinition.dummy()
        repository.fetchDefinitionResult = .success(expectedDefinition)
        
        // When
        let result = try await sut.execute(for: "test")
        
        // Then
        XCTAssertTrue(repository.fetchDefinitionCalled)
        XCTAssertEqual(result, expectedDefinition)
    }
    
    func testExecute_WhenRepositoryFails_ThrowsError() async {
        // Given
        let expectedError = NSError(domain: "test", code: 0)
        repository.fetchDefinitionResult = .failure(expectedError)
        
        // When/Then
        do {
            _ = try await sut.execute(for: "test")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as NSError, expectedError)
            XCTAssertTrue(repository.fetchDefinitionCalled)
        }
    }
}
