struct APIEnvelopeDTO<Value: Decodable>: Decodable {
    let data: Value
}

struct APIErrorEnvelopeDTO: Decodable {
    let error: APIErrorDTO
}

struct APIErrorDTO: Decodable {
    let code: String
    let message: String
    let details: [String: [String]]?
}
