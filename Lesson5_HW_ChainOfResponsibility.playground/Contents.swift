import UIKit


struct PersonsResult: Codable {
    let result: [Person]
    enum CodingKeys: String, CodingKey {
        case result
    }
}

struct PersonsData: Codable {
    let data: [Person]
    enum CodingKeys: String, CodingKey {
        case data
    }
}

struct Person: Codable {
    let name: String
    let age: Int
    let isDeveloper: Bool
    
    enum CodingKeys: String, CodingKey {
        case name
        case age
        case isDeveloper
    }
}

protocol DataHandler {
    var next: DataHandler? { get set }
    func handleReceivedData(_ data: Data) -> [Person]
}

class FirstTypeDataHandler: DataHandler {
    var next: DataHandler?

    func handleReceivedData(_ data: Data) -> [Person] {
        var persons: [Person] = []
        let decoder = JSONDecoder()
        do {
            let json = try decoder.decode(PersonsData.self, from: data)
            persons = json.data
        } catch {
            if let next = next  {
                persons = next.handleReceivedData(data)
            }
        }
         return persons
    }
}

class SecondTypeDataHandler: DataHandler {
    var next: DataHandler?

    func handleReceivedData(_ data: Data) -> [Person] {
        var persons: [Person] = []
        let decoder = JSONDecoder()
        do {
            let json = try decoder.decode(PersonsResult.self, from: data)
            persons = json.result
        } catch {
            if let next = next  {
                persons = next.handleReceivedData(data)
            }
        }
         return persons
    }
}

class ThirdTypeDataHandler: DataHandler {
    var next: DataHandler?

    func handleReceivedData(_ data: Data) -> [Person] {
        var persons: [Person] = []
        let decoder = JSONDecoder()
        do {
            let json = try decoder.decode([Person].self, from: data)
            persons = json
        } catch {

        }
         return persons
    }
}

func data(from file: String) -> [Person] {
    let path1 = Bundle.main.path(forResource: file, ofType: "json")!
    let url = URL(fileURLWithPath: path1)
    var persons: [Person] = []
    do {
        var firstTypeDataHandler: DataHandler = FirstTypeDataHandler()
        var secondTypeDataHandler: DataHandler = SecondTypeDataHandler()
        var thirdTypeDataHandler: DataHandler = ThirdTypeDataHandler()
        let receiveDataHandler: DataHandler = firstTypeDataHandler
        firstTypeDataHandler.next = secondTypeDataHandler
        secondTypeDataHandler.next = thirdTypeDataHandler
        thirdTypeDataHandler.next = nil
        
        let data = try! Data(contentsOf: url)
        persons = receiveDataHandler.handleReceivedData(data)
    }
    return persons
}

var persons = data(from: "1")
persons = data(from: "2")
persons = data(from: "3")


