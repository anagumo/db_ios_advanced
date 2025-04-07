import Foundation
@testable import DBIOSAdvanced

enum LocationDTOData {
    static let givenList = [
        LocationDTO(
            identifier: "ACB5ABB7-8C85-4A0F-872C-5467EDD23D7F",
            longitude: "-115.3154276",
            latitude: "36.1251954",
            date: "2022-09-26T00:00:00Z",
            hero: HeroDTO(
                identifier: "CBCFBDEC-F89B-41A1-AC0A-FBDA66A33A06",
                name: nil,
                info: nil,
                photo: nil,
                favorite: nil
            )
        )
    ]
}
