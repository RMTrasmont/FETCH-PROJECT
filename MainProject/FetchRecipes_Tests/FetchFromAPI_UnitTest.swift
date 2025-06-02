//
//  FetchFromAPI_UnitTest.swift
//  FetchRecipes_Tests
//
//  Created by RMT on 5/16/25.
//
//TWO MOCKING TESTS ARE BEING DONE.
//1. Using Mock API Service to simply create a Mock fetch Service to test the Logic. (MockAPIServices:APIServicesProtocol)
//2. Using the Real Fetch function but with a Mock URL Session to test the Actual fetching function. (MockURLProtocol: URLProtocol)

import Foundation
import XCTest
@testable import FetchRecipes

final class FetchFromAPI_UnitTest: XCTestCase {

    //MARK: - TESTING MOCK API SERVICE FETCH
    //TESTING MOCK API SERVICE RETURNING A MOCK RESPONSE (Using *MockAPIService* testing just the logic.)
    func test_FetchRecipes_Succeeds_WithCompleteData() async throws {
        let mockAPIServices:APIServicesProtocol = MockAPIServices()
        let response = try await mockAPIServices.fetchRecipes(for: "completeEndPoint")
        let recipes = response.recipes
        
        XCTAssertEqual(recipes.count, 1)
        XCTAssertEqual(recipes[0].name, "Mock Pasta")
        XCTAssertEqual(recipes[0].cuisine, "Italian")
        XCTAssertEqual(recipes[0].photoURLLarge,"https://example.com/large.jpg")
        XCTAssertEqual(recipes[0].photoURLSmall,"https://example.com/small.jpg")
        XCTAssertEqual(recipes[0].sourceURL,"https://example.com")
        XCTAssertEqual(recipes[0].uuid,"mock-uuid-123")
        XCTAssertEqual(recipes[0].youtubeURL,"https://youtube.com/mockvideo")
        
    }
    
    func test_FetchRecipes_Succeeds_WithMalformedData() async throws {
        let mockAPIServices = MockAPIServices()
        let response = try await mockAPIServices.fetchRecipes(for: "malformedEndPoint")
        let recipes = response.recipes
        
        XCTAssertEqual(recipes.count, 1)
        XCTAssertEqual(recipes[0].name, "No Name", "a nil name-value should return 'No Name' string ")
        XCTAssertEqual(recipes[0].cuisine, "Italian")
        XCTAssertEqual(recipes[0].photoURLLarge,"https://example.com/large.jpg")
        XCTAssertEqual(recipes[0].photoURLSmall,"https://example.com/small.jpg")
        XCTAssertEqual(recipes[0].sourceURL, "No Source URL", "a nil sourceURL-value should return 'No Source URL' string")
        XCTAssertEqual(recipes[0].uuid,"mock-uuid-123")
        XCTAssertEqual(recipes[0].youtubeURL, "No Youtube URL", "a nil youtubeURL-value should return 'No Youtube URL' string")
        
    }
    
    func test_FetchRecipes_Succeds_WithEmptyData() async throws {
        let mockAPIServices = MockAPIServices()
        let response = try await mockAPIServices.fetchRecipes(for: "emptyEndPoint")
        let recipes = response.recipes
        
        XCTAssertEqual(recipes.count, 0)
    }
    
    func test_FetchRecipes_ThrowsError_InvalidURL() async throws {
        let mockAPIService = MockAPIServices()
        
        let invalidEndpoint = "Invalid-Non-Existent-EndPoint"
        
        do {
            _ = try await mockAPIService.fetchRecipes(for: invalidEndpoint)
            XCTFail("Expected error not thrown")
        } catch let error as NSError {
            /// catches "throw NSError(domain: "Cannot convert String into URL", code: 1, userInfo: nil)" ln.221 below.
            XCTAssertEqual(error.domain, "Cannot convert String into URL")
            XCTAssertEqual(error.code, 1)
        }
        
    }
    
    
    
    //MARK: - TESTING REAL "APIService"(TESTING THE REAL NETWORK BUT RETURNING A MOCK RESPONSE w/ help of *MockURLProtocol* below)
    
    //Simulate a Successful fetch with Complete Data Decoded into our Response Object,Using Real APIService fetchRecipe but MockURLresponse
    func test_RealAPIService_With_Complete_MockedResponse() async throws {
        // A mock endpoint
        let testEndpoint = "https://mockapi.com/recipesComplete"
        
        // And: A mock recipe
        let mockRecipe = Recipe(
            cuisine: "Mock",
            name: "Mock Dish",
            photoURLLarge: "https://example.com/large.jpg",
            photoURLSmall: "https://example.com/small.jpg",
            sourceURL: "https://example.com",
            uuid: "12345",
            youtubeURL: "https://youtube.com/mock"
        )
        
        // A full mock response
        let mockResponse = Response(recipes: [mockRecipe])
        let mockData = try JSONEncoder().encode(mockResponse)
        let mockHTTPResponse = HTTPURLResponse(
            url: URL(string: testEndpoint)!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        // Inject values into mock response we created
        MockURLProtocol.mockResponses = [
            ///Inject Values here
            URL(string: testEndpoint)!: (mockData, mockHTTPResponse)
        ]
        
        //Call fetchRecipe on Real APIService but using mockSession
        let service = APIServices(session: .mockedSession())
        let response = try await service.fetchRecipes(for: testEndpoint)
        
        //Check the Mock Response
        XCTAssertEqual(response.recipes.count, 1)
        XCTAssertEqual(response.recipes[0].cuisine, "Mock")
        XCTAssertEqual(response.recipes[0].name, "Mock Dish")
        XCTAssertEqual(response.recipes[0].photoURLLarge, "https://example.com/large.jpg")
        XCTAssertEqual(response.recipes[0].photoURLSmall, "https://example.com/small.jpg")
        XCTAssertEqual(response.recipes[0].sourceURL, "https://example.com")
        XCTAssertEqual(response.recipes[0].uuid, "12345")
        XCTAssertEqual(response.recipes[0].youtubeURL, "https://youtube.com/mock")
        XCTAssertEqual(response.recipes[0].isFavorite, false)
        
    }
    
    //Simulate a Successful fetch with Incomplete Data Decoded into our Response Object,Using Real APIService fetchRecipe but MockURresponse
    func test_RealAPIService_With_Incomplete_MockedResponse() async throws {
        // A mock endpoint
        let testEndpoint = "https://mockapi.com/recipesIncomplete"
        
        // A mock recipe
        let mockRecipe = Recipe(
            cuisine: nil,
            name: nil,
            photoURLLarge: nil,
            photoURLSmall: nil,
            sourceURL: nil,
            uuid: nil,
            youtubeURL: nil
        )
        
        // A full mock response
        let mockResponse = Response(recipes: [mockRecipe])
        let mockData = try JSONEncoder().encode(mockResponse)
        let mockHTTPResponse = HTTPURLResponse(
            url: URL(string: testEndpoint)!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        // Inject values into mock response we created
        MockURLProtocol.mockResponses = [
            ///inject values here
            URL(string: testEndpoint)!: (mockData, mockHTTPResponse)
        ]
        
        //Call fetchRecipe on Real APIService but using mockSession
        let service = APIServices(session: .mockedSession())
        let response = try await service.fetchRecipes(for: testEndpoint)
        
        //Check the Mock Response
        XCTAssertEqual(response.recipes.count, 1)
        XCTAssertEqual(response.recipes[0].cuisine, "No Cuisine")
        XCTAssertEqual(response.recipes[0].name, "No Name")
        XCTAssertEqual(response.recipes[0].photoURLLarge, "No Large Photo URL")
        XCTAssertEqual(response.recipes[0].photoURLSmall, "No Small Photo URL")
        XCTAssertEqual(response.recipes[0].sourceURL, "No Source URL")
        XCTAssertNotNil(response.recipes[0].uuid, "UUID should never be nil, new one is created if Value is missing in JSON")
        XCTAssertEqual(response.recipes[0].youtubeURL, "No Youtube URL")
        XCTAssertEqual(response.recipes[0].isFavorite, false)
        
    }
    
    //Simulates an invalid URL, Using Real APIService fetchRecipe but MockURresponse
    func test_fetchRecipes_withInvalidURLString_throwsURLError() async {
        let invalidEndpoint = "ht^tp://%%%" // <- Purposely fail the Endpoint url

        let service = APIServices(session: .mockedSession())
        
        // Call fetchRecipe on Real APIService but using mockSession
        do {
            _ = try await service.fetchRecipes(for: invalidEndpoint)
            XCTFail("Expected error to be thrown for invalid URL")
        } catch {
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "*Cannot convert String into URL")
            XCTAssertEqual(nsError.code, 1)
        }
    }
    
    //Simulate an Invalid HTTPResponse,  Using Real APIService fetchRecipe but MockURresponse
    func test_fetchRecipes_withInvalidHTTPResponse_throwsError() async {
        // Mock endpoint
        let mockEndpoint = "https://mock-invalid-http-response.com"
        
        let mockResponseData =  """
            {
                "recipes": []
            }
        """.data(using: .utf8)!

        // Instead of HTTPURLResponse, we use URLResponse to simulate invalid type to throw Error
        //Force to throw:  "NSError(domain: "Invalid HTTP Response", code: 500, userInfo: nil)"
        let invalidResponse = URLResponse(url: URL(string: mockEndpoint)!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)

        // Inject values into mock response we created
        MockURLProtocol.mockResponses = [
            ///Inject our values
            URL(string: mockEndpoint)!: (mockResponseData, invalidResponse)
        ]

        let service = APIServices(session: .mockedSession())

        // Call fetchRecipe on Real APIService but using mockSession
        do {
            _ = try await service.fetchRecipes(for: mockEndpoint)
            XCTFail("Expected error to be thrown for invalid HTTP response")
        } catch {
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "*Invalid HTTP Response")
            XCTAssertEqual(nsError.code, 500)
        }
    }
    
    //Simulate 404 or Server Error, Using Real APIService fetchRecipe but MockURresponse
    func test_fetchRecipes_withNonSuccessStatusCode_throwsHTTPError() async {
        // Mock Endpoint
        let endpoint = "https://example.com/invalid-status"
        let mockResponseData = Data() // data can be anything, cannot decode into Response Object
        
        // Create a valid HTTPURLResponse with 404 status
        let badHttpResponse = HTTPURLResponse(
            url: URL(string: endpoint)!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )!
        
        // Inject values into mock response we created
        MockURLProtocol.mockResponses = [
            ///Inject out Values
            URL(string: endpoint)!: (mockResponseData, badHttpResponse)
        ]
        
        
        let service = APIServices(session: .mockedSession())
        
        // Call fetchRecipe on Real APIService but using mockSession
        do {
            _ = try await service.fetchRecipes(for: endpoint)
            XCTFail("Expected HTTP error to be thrown for 404 status")
        } catch {
            // Then
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "*HTTP Error*")
            XCTAssertEqual(nsError.code, 404)
        }
    }
    
    
    
    //MARK: - SETUP & TEAR DOWN
    override func tearDown() {
        super.tearDown()
        MockURLProtocol.mockResponses = [:] /// clear MockURLProtocol.mockResponse after every test b/c MockURLResponse is static and shared across all tests
        MockURLProtocol.thrownError = nil
        MockURLProtocol.reset()
    }
    override func setUp() {
        super.setUp()
        MockURLProtocol.mockResponses = [:] /// reset MockURLProtocol.mockResponse before every test b/c MockURLResponse is static and shared across all tests
    }
    
    
    
}

//MARK: MOCK API FETCH CLASS
final class MockAPIServices:APIServicesProtocol{
    
    func fetchRecipes(for endPoint: String) async throws -> Response {
        
        var recipes: [Recipe] = []
        
        let completeRecipe = Recipe(
            cuisine: "Italian",
            name: "Mock Pasta",
            photoURLLarge: "https://example.com/large.jpg",
            photoURLSmall: "https://example.com/small.jpg",
            sourceURL: "https://example.com",
            uuid: "mock-uuid-123",
            youtubeURL: "https://youtube.com/mockvideo"
        )
        
        let malformedRecipe = Recipe(
            cuisine: "Italian",
            name: nil,
            photoURLLarge: "https://example.com/large.jpg",
            photoURLSmall: "https://example.com/small.jpg",
            sourceURL: nil,
            uuid: "mock-uuid-123",
            youtubeURL: nil
        )
        
        if endPoint == "completeEndPoint" {
            recipes = [completeRecipe]
        } else if endPoint == "malformedEndPoint" {
            recipes = [malformedRecipe]
        } else if endPoint == "emptyEndPoint" {
            recipes = []
        } else {
            ///Throw Runtime error
            throw NSError(domain: "Cannot convert String into URL", code: 1, userInfo: nil)
        }
        
        return Response(recipes:recipes)
    }
    
    
}


//MARK: MOCK URL SESSION (But Will use Real API Fetch function)
//Allows Call of Real APIService.fetchRecipe(for:) without* hitting actual network service
//This Allows the Use of the real API Fetch Call function but using a Mock-URL-Session instead of a Real URLSession.
final class MockURLProtocol: URLProtocol {
    /// A dictionary of mock responses mapped by URL
    static private var _mockResponses: [URL: (Data, URLResponse)] = [:]
    /// A simulated error to throw instead of returning a mock response
    static private var _thrownError: Error?
    /// Queue for thread-safe access
    private static let queue = DispatchQueue(label: "MockURLProtocol.queue")
    
    //- Thread-safe Accessors for mockResponses
    static var mockResponses: [URL: (Data, URLResponse)] {
        get {
            queue.sync { _mockResponses }
        }
        set {
            queue.sync { _mockResponses = newValue }
        }
    }
    
    //Used in Code:
    /*  MockURLProtocol.mockResponses = [
            URL(string: endpoint)!: (mockResponseData, badHttpResponse)
        ]
    */
    
    /// Thread-safe Accessors for thrownError
    static var thrownError: Error? {
        get {
            queue.sync { _thrownError }
        }
        set {
            queue.sync { _thrownError = newValue }
        }
    }
    
    //Use in Code:
    /*
        MockURLProtocol.thrownError = URLError(.timeOut)
    */
    
    
    /// Resets all mock data and error state (typically used between tests)
    static func reset() {
        queue.sync {
            _mockResponses = [:]
            _thrownError = nil
        }
    }
    
    // - URLProtocol Overrides
    /// Indicates whether this protocol can handle the given request
    override class func canInit(with request: URLRequest) -> Bool {
        return true // intercept all requests
    }

    /// Returns a canonical version of the request (unchanged here)
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    /// Called when the network task starts
    override func startLoading() {
        if let error = MockURLProtocol.thrownError {
            //* Simulate network error:
            self.client?.urlProtocol(self, didFailWithError: error)
        } else if let url = request.url, let (data, response) = MockURLProtocol.mockResponses[url] {
            //* Return your existing mocked response data and HTTPURLResponse:
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            self.client?.urlProtocol(self, didLoad: data)
            self.client?.urlProtocolDidFinishLoading(self)
        } else {
            //* Simulate No mocked response found — send 404 Not Found fallback:
            let fallbackResponse = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)!
            self.client?.urlProtocol(self, didReceive: fallbackResponse, cacheStoragePolicy: .notAllowed)
            self.client?.urlProtocol(self, didLoad: Data())
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {}
    
    //USAGE:
    /*
         // 1. Register your mock URLProtocol
             let config = URLSessionConfiguration.ephemeral
             config.protocolClasses = [MockURLProtocol.self]
             let mockSession = URLSession(configuration: config)

         // 2. Assign mock responses
             MockURLProtocol.mockResponses = [
                 URL(string: "https://api.example.com/data")!: (mockData, mockHTTPResponse)
             ]

         // 3. Use the mock session in your API service and run tests
            let service = APIServices(session: mockSession)
     */
    
    
}

//Extension to Allow for Mock URL Session.
extension URLSession {
    static func mockedSession() -> URLSession {
        ///Use a temporary session with no disk caching or persistent storage.
        let config = URLSessionConfiguration.ephemeral
        ///tells this session to use your MockURLProtocol to intercept all requests. No real network calls will be made.
        config.protocolClasses = [MockURLProtocol.self]
        ///Returns a new session configured to use your mock protocol.
        return URLSession(configuration: config)
    }
}
