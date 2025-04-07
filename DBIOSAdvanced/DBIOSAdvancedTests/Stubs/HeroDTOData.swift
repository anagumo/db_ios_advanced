import Foundation
@testable import DBIOSAdvanced

enum HeroDTOData {
    static let givenList = [
        HeroDTO(
            identifier: "D13A40E5-4418-4223-9CE6-D2F9A28EBE94",
            name: "Goku",
            info: "Sobran las presentaciones cuando se habla de Goku.",
            photo: "https://cdn.alfabetajuega.com/alfabetajuega/2020/12/goku1.jpg?width=300",
            favorite: false
        ),
        HeroDTO(
            identifier: "D13A40E5-4418-4223-9CE6-D2F9A28EBE95",
            name: "Vegeta",
            info: "Sobran las presentaciones cuando se habla de Vegeta.",
            photo: "https://cdn.alfabetajuega.com/alfabetajuega/2020/12/vegeta1.jpg?width=300",
            favorite: true
        ),
        HeroDTO(
            identifier: "64143856-12D8-4EF9-9B6F-F08742098A18",
            name: "Bulma",
            info: "Sobran las presentaciones cuando se habla de Bulma.",
            photo: "https://cdn.alfabetajuega.com/alfabetajuega/2021/01/Bulma-Dragon-Ball.jpg?width=300",
            favorite: false
        ),
        HeroDTO(identifier: "CBCFBDEC-F89B-41A1-AC0A-FBDA66A33A06",
                name: "Piccolo",
                info: "Sobran las presentaciones cuando se habla de Piccolo.",
                photo: "https://cdn.alfabetajuega.com/alfabetajuega/2021/01/Piccolo.jpg?width=300",
                favorite: true
               ),
        HeroDTO(
            identifier: "CBCFBDEC-F89B-41A1-AC0A-FBDA66A33A03",
            name: "Krilin",
            info: "Sobran las presentaciones cuando se habla de Krilin.",
            photo: "https://cdn.alfabetajuega.com/alfabetajuega/2021/01/Krilin.jpg?width=300",
            favorite: false
        )
    ]
}
