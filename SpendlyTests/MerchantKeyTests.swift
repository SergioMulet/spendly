import Testing
@testable import Spendly

struct MerchantKeyTests {
    @Test func ignoresCaseAccentsAndExtraSpaces() {
        #expect(MerchantKey.make("  CAFÉ   Central ") == MerchantKey.make("cafe central"))
    }
    
    @Test func differentMerchantsHaveDifferentKeys() {
        #expect(MerchantKey.make("Mercadona") != MerchantKey.make("Lidl"))
    }
}
