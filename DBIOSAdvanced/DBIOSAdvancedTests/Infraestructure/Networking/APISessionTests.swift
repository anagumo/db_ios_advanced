import XCTest
@testable import DBIOSAdvanced

final class APISessionTests: XCTestCase {
    var sut: APISessionProtocol?

    override func setUpWithError() throws {
        try super.setUpWithError()
        let urlSessionConfiguration = URLSessionConfiguration.default
        urlSessionConfiguration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: urlSessionConfiguration)
        sut = APISession(urlSession: urlSession)
    }

    override func tearDownWithError() throws {
        MockURLProtocol.requestHandler = nil
        MockURLProtocol.error = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testLoginHTTPRequest() throws {
        // Given
        let successExpectation = expectation(description: "Login succeed")
        var receivedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            receivedRequest = request
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url, statusCode: 200))
            let fileURL = try XCTUnwrap(Bundle(for: APISessionTests.self).url(forResource: "jwt", withExtension: "txt"))
            let data = try XCTUnwrap(Data(contentsOf: fileURL))
            return (httpURLResponse, data)
        }
        
        // When
        var receivedJWT: Data?
        let loginHTTPRequest = LoginHTTPRequest(
            username: "regularuser@keepcoding.es",
            password: "Regularuser1"
        )
        sut?.request(loginHTTPRequest, completion: { result in
            do {
                let jwt = try result.get()
                receivedJWT = jwt
                successExpectation.fulfill()
            } catch {
                XCTFail("Success expected")
            }
        })
        
        // Then
        wait(for: [successExpectation], timeout: 0.1)
        XCTAssertEqual(receivedRequest?.url?.path(), "/api/auth/login")
        XCTAssertEqual(receivedRequest?.httpMethod, "POST")
        XCTAssertEqual(receivedRequest?.value(
            forHTTPHeaderField: "Authorization"), "Basic cmVndWxhcnVzZXJAa2VlcGNvZGluZy5lczpSZWd1bGFydXNlcjE="
        )
        XCTAssertNotNil(receivedJWT)
    }
    
    func testLoginHTTPRequest_ShouldReturnError() throws {
        // Given
        let failureExpectation = expectation(description: "Login failed")
        failureExpectation.assertForOverFulfill = true
        MockURLProtocol.requestHandler = { request in
            let url = try XCTUnwrap(request.url)
            let request = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url, statusCode: 401))
            return (request, Data())
        }
        
        // When
        var receivedError: APIError?
        let loginHTTPRequest = LoginHTTPRequest(
            username: "user@keepcoding.es",
            password: "Regular"
        )
        sut?.request(loginHTTPRequest, completion: { result in
            do {
                let _ = try result.get()
                XCTFail("APIError expected")
            } catch let error as APIError {
                receivedError = error
                failureExpectation.fulfill()
            } catch {
                XCTFail("APIError expected")
            }
        })
        
        // Then
        wait(for: [failureExpectation], timeout: 0.1)
        let unauthorizedAPIError = try XCTUnwrap(receivedError)
        XCTAssertEqual(unauthorizedAPIError.url, "/api/auth/login")
        XCTAssertEqual(unauthorizedAPIError.reason, "Wrong email or password. Please log in again.")
        XCTAssertEqual(unauthorizedAPIError.statusCode, 401)
    }
    
    func testFetchHeros() throws {
        // Given
        let successExpection = expectation(description: "Fetch heros succeed")
        var receivedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            receivedRequest = request
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url, statusCode: 200))
            let fileURL = try XCTUnwrap(Bundle(for: APISessionTests.self).url(forResource:"Heros", withExtension: "json"))
            let data = try XCTUnwrap(Data(contentsOf: fileURL))
            return (httpURLResponse, data)
        }
        
        // When
        var receivedHeroDTOList: [HeroDTO]?
        sut?.request(HerosHTTPRequest(), completion: { result in
            do {
                let heroDTOList = try result.get()
                receivedHeroDTOList = heroDTOList
                successExpection.fulfill()
            } catch {
                XCTFail("Waiting for success")
            }
        })
        
        // Then
        wait(for: [successExpection], timeout: 0.1)
        XCTAssertEqual(receivedRequest?.url?.path(), "/api/heros/all")
        XCTAssertEqual(receivedRequest?.httpMethod, "POST")
        XCTAssertNotNil(receivedHeroDTOList)
        XCTAssertEqual(receivedHeroDTOList?.count, 15)
        XCTAssertEqual(receivedHeroDTOList?.first?.name, "Maestro Roshi")
    }
    
    func testFetchHeros_ShouldReturnError() throws {
        // Given
        let failureExpectation = expectation(description: "Fetch heros failed")
        MockURLProtocol.requestHandler = { request in
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url, statusCode: 500))
            return (httpURLResponse, Data())
        }
        
        // When
        var receivedError: APIError?
        sut?.request(HerosHTTPRequest(), completion: { result in
            do {
                let _ = try result.get()
                XCTFail("Waiting for error")
            } catch let error as APIError {
                receivedError = error
                failureExpectation.fulfill()
            } catch {
                XCTFail("Waiting for api error")
            }
        })
        
        // Then
        wait(for: [failureExpectation], timeout: 0.1)
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError?.statusCode, 500)
        XCTAssertEqual(receivedError?.reason, "There was a server error")
    }
    
    func testFetchHero() throws {
        // Given
        let successExpectation = expectation(description: "Fetch hero succeed")
        var receivedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            receivedRequest = request
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url, statusCode: 200))
            let fileURL = try XCTUnwrap(Bundle(for: APISessionTests.self).url(forResource: "Hero", withExtension: "json"))
            let data = try (Data(contentsOf: fileURL))
            return (httpURLResponse, data)
        }
        
        // When
        let herosHTTPRequest = HerosHTTPRequest(name: "Goku")
        var receivedHeroDTO: HeroDTO?
        sut?.request(herosHTTPRequest, completion: { result in
            do {
                let heroDTO = try result.get().first
                receivedHeroDTO = heroDTO
                successExpectation.fulfill()
            } catch {
                XCTFail("Waiting for success")
            }
        })
        
        // Then
        wait(for: [successExpectation], timeout: 0.1)
        XCTAssertEqual(receivedRequest?.url?.path(), "/api/heros/all")
        XCTAssertEqual(receivedRequest?.httpMethod, "POST")
        XCTAssertNotNil(receivedHeroDTO)
        XCTAssertEqual(receivedHeroDTO?.identifier, "D13A40E5-4418-4223-9CE6-D2F9A28EBE94")
        XCTAssertEqual(receivedHeroDTO?.name, "Goku")
        XCTAssertEqual(receivedHeroDTO?.info, "Sobran las presentaciones cuando se habla de Goku. El Saiyan fue enviado al planeta Tierra, pero hay dos versiones sobre el origen del personaje. Según una publicación especial, cuando Goku nació midieron su poder y apenas llegaba a dos unidades, siendo el Saiyan más débil. Aun así se pensaba que le bastaría para conquistar el planeta. Sin embargo, la versión más popular es que Freezer era una amenaza para su planeta natal y antes de que fuera destruido, se envió a Goku en una incubadora para salvarle.")
        XCTAssertEqual(receivedHeroDTO?.photo, "https://cdn.alfabetajuega.com/alfabetajuega/2020/12/goku1.jpg?width=300")
        XCTAssertEqual(receivedHeroDTO?.favorite, true)
    }
    
    func testFetchHero_ShouldReturnError() throws {
        // Given
        let failureExpectation = expectation(description: "Fetch hero failed")
        MockURLProtocol.requestHandler = { request in
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url, statusCode: 500))
            return (httpURLResponse, Data())
        }
        
        // When
        let herosHTTPRequest = HerosHTTPRequest(name: "Gohan")
        var receivedError: APIError?
        sut?.request(herosHTTPRequest, completion: { result in
            do {
                let _ = try result.get()
                XCTFail("Waiting for error")
            } catch let error as APIError {
                receivedError = error
                failureExpectation.fulfill()
            } catch {
                XCTFail("Waiting for api error")
            }
        })
        
        // Then
        wait(for: [failureExpectation], timeout: 0.1)
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError?.statusCode, 500)
        XCTAssertEqual(receivedError?.reason, "There was a server error")
    }
    
    func testFetchTransformations() throws {
        // Given
        let successExpectation = expectation(description: "Fetch transformations succeed")
        var receivedRequest : URLRequest?
        MockURLProtocol.requestHandler = { request in
            receivedRequest = request
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url, statusCode: 200))
            let fileURL = try XCTUnwrap(Bundle(for: APISessionTests.self).url(forResource: "Transformations", withExtension: "json"))
            let data = try XCTUnwrap(Data(contentsOf: fileURL))
            return (httpURLResponse, data)
        }
        
        // When
        var receivedTransformationDTOList: [TransformationDTO]?
        let transformationsHTTPRequest = TransformationsHTTPRequest(heroID: "5809A7BC-DE77-4DA4-939B-D5F4EB00FAA")
        sut?.request(transformationsHTTPRequest, completion: { result in
            do {
                let transformationDTOList = try result.get()
                receivedTransformationDTOList = transformationDTOList
                successExpectation.fulfill()
            } catch {
                XCTFail("Waiting for success")
            }
        })
        
        // Then
        wait(for: [successExpectation], timeout: 0.1)
        XCTAssertEqual(receivedRequest?.url?.path(), "/api/heros/tranformations")
        XCTAssertEqual(receivedRequest?.httpMethod, "POST")
        XCTAssertNotNil(receivedTransformationDTOList)
        XCTAssertEqual(receivedTransformationDTOList?.count, 14)
        XCTAssertEqual(receivedTransformationDTOList?.first?.name, "1. Oozaru – Gran Mono")
    }
    
    func testFetchTransformations_ShouldReturnError() throws {
        // Given
        let failureExpectation = expectation(description: "Fetch transformations failed")
        MockURLProtocol.requestHandler = { request in
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url, statusCode: 500))
            return (httpURLResponse, Data())
        }
        
        // When
        var receivedError: APIError?
        let transformationsHTTPRequest = TransformationsHTTPRequest(heroID: "5809A7BC-DE77-4DA4-939B-D5F4EB00FAA")
        sut?.request(transformationsHTTPRequest, completion: { result in
            do {
                let _ = try result.get()
                XCTFail("Waiting for error")
            } catch let error as APIError {
                receivedError = error
                failureExpectation.fulfill()
            } catch {
                XCTFail("Waiting for api error")
            }
        })
        
        // Then
        wait(for: [failureExpectation], timeout: 0.1)
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError?.statusCode, 500)
        XCTAssertEqual(receivedError?.reason, "There was a server error")
    }
    
    func testFetchLocations() throws {
        // Given
        let successExpectation = expectation(description: "Fetch locations succeed")
        var receivedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            receivedRequest = request
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url, statusCode: 200))
            let fileURL = try XCTUnwrap(Bundle(for: APISessionTests.self).url(forResource: "Locations", withExtension: "json"))
            let data = try XCTUnwrap(Data(contentsOf: fileURL))
            return (httpURLResponse, data)
        }
        
        // When
        var receivedLocationDTOList: [LocationDTO]?
        let locationsHTTPRequest = LocationsHTTPRequest(heroID: "CBCFBDEC-F89B-41A1-AC0A-FBDA66A33A06")
        sut?.request(locationsHTTPRequest, completion: { result in
            do {
                let locationDTOList = try result.get()
                receivedLocationDTOList = locationDTOList
                successExpectation.fulfill()
            } catch {
                XCTFail("Waiting for success")
            }
        })
        
        // Then
        wait(for: [successExpectation], timeout: 0.1)
        XCTAssertNotNil(receivedRequest)
        XCTAssertEqual(receivedRequest?.url?.path(), "/api/heros/locations")
        XCTAssertEqual(receivedRequest?.httpMethod, "POST")
        XCTAssertNotNil(receivedLocationDTOList)
        XCTAssertEqual(receivedLocationDTOList?.count, 1)
        XCTAssertEqual(receivedLocationDTOList?.first?.latitude, "36.1251954")
        XCTAssertEqual(receivedLocationDTOList?.first?.longitude, "-115.3154276")
    }
    
    func testFetchLocations_ShoulReturnError() throws {
        //Given
        let failureExpectation = expectation(description: "Fetch locations failed")
        MockURLProtocol.requestHandler = { request in
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url, statusCode: 500))
            return (httpURLResponse, Data())
        }
        
        // When
        let locationsHTTPRequest = LocationsHTTPRequest(heroID: "CBCFBDEC-F89B-41A1-AC0A-FBDA66A33A06")
        var receivedError: APIError?
        sut?.request(locationsHTTPRequest, completion: { result in
            do {
                let _ = try result.get()
                XCTFail("Waiting for error")
            } catch let error as APIError {
                receivedError = error
                failureExpectation.fulfill()
            } catch {
                XCTFail("Waiting for api error")
            }
        })
        
        // Then
        wait(for: [failureExpectation], timeout: 0.1)
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError?.statusCode, 500)
        XCTAssertEqual(receivedError?.reason, "There was a server error")
    }
}
