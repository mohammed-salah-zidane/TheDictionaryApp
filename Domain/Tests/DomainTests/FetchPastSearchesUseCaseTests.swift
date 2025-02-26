import XCTest
@testable import Domain

final class FetchPastSearchesUseCaseTests: XCTestCase {
    private var sut: DefaultFetchPastSearchesUseCase!
    private var repository: MockWordDefinitionRepository!
    
    override func setUp() {
        super.setUp()
        repository = MockWordDefinitionRepository()
        sut = DefaultFetchPastSearchesUseCase(repository: repository)
    }
    
    override func tearDown() {
        sut = nil
        repository = nil
        super.tearDown()
    }
    
    func testExecute_WhenRepositorySucceeds_ReturnsPastSearches() async throws {
        // Given
        let expectedDefinitions = [WordDefinition.dummy()]
        repository.getPastSearchesResult = .success(expectedDefinitions)
        
        // When
        let result = try await sut.execute()
        
        // Then
        XCTAssertTrue(repository.getPastSearchesCalled)
        XCTAssertEqual(result, expectedDefinitions)
    }
    
    func testExecute_WhenRepositoryFails_ThrowsError() async {
        // Given
        let expectedError = NSError(domain: "test", code: 0)
        repository.getPastSearchesResult = .failure(expectedError)
        
        // When/Then
        do {
            _ = try await sut.execute()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as NSError, expectedError)
            XCTAssertTrue(repository.getPastSearchesCalled)
        }
    }
}
