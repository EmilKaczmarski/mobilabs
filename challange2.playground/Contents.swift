import UIKit

//+Four hundred people were traveling on a cruise ship with two engines having power of: 2kHP, 4kHP.
//+Fifty people represented the ship crew while others were //tourists.
//+The ship could have both engines operating simultaniosly, only one at a time or keep both off depending on the captain command.
//+Every tourist was //assigned to a two or four person cabin shared with our tourists, which could be his friends.
//+The ship had a restaurant and a two bars of 300, 50 ,50 people
//+capacity correspondigly. Each tourist could visit one of the attractions or stay and his cabin at a time.
//+Tourists under 18 years were not allowed to enter the bar.

//+Goal: implement the ship, engine, person, restaurant, bar, cabin classes reflecting the above case.

//base of names to use
//singleton that is used in further part of code
//to generate people

class RandGenerator {
    private init() {}
    static let shared = RandGenerator()

    func generateName()-> String {
        if Int.random(in: 0...1) == 0{
            return "\(femaleNames[Int.random(in: 0 ..< 12)]) \(femaleSurnames[Int.random(in: 0 ..< 12)])"
        }
        return "\(maleNames[Int.random(in: 0 ..< 12)]) \(maleSurnames[Int.random(in: 0 ..< 12)])"
    }
    
    func generateProfession()-> Worker.Profession {
        let rand = Int.random(in: 0...100)
        if rand < 40 {
            return Worker.Profession.sailor
        }
        if rand < 95 {
            return Worker.Profession.servant
        }
        return Worker.Profession.doctor
    }
    
    func generateDate()-> String {
        let year = Int.random(in: 1950...2019)
        let month = Int.random(in: 1...12)
        let dayBase = [30, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        let day = Int.random(in: 1..<dayBase[month - 1])
        return String(year) + "-" + String(month) + "-" + String(day)
    }
    
    //name base
    var maleSurnames =
    [
    "NOWAK"
    ,"WÓJCIK"
    ,"KOWALCZYK"
    ,"WOŹNIAK"
    ,"MAZUR"
    ,"KRAWCZYK"
    ,"KACZMAREK"
    ,"ZAJĄC"
    ,"KRÓL"
    ,"WIECZOREK"
    ,"WRÓBEL"
    ,"STĘPIEŃ"
    ]

    var femaleSurnames =
    [
    "KOWALSKA"
    ,"WIŚNIEWSKA"
    ,"KAMIŃSKA"
    ,"LEWANDOWSKA"
    ,"ZIELIŃSKA"
    ,"SZYMAŃSKA"
    ,"DĄBROWSKA"
    ,"KOZŁOWSKA"
    ,"JANKOWSKA"
    ,"WOJCIECHOWSKA"
    ,"KWIATKOWSKA"
    ,"PIOTROWSKA"
    ]

    var maleNames =
    [
    "ATONI"
    ,"JAKUB"
    ,"JAN"
    ,"SZYMON"
    ,"ALEKSANDER"
    ,"FRANCISZEK"
    ,"FILIP"
    ,"MIKOŁAJ"
    ,"WOJCIECH"
    ,"KACPER"
    ,"ADAM"
    ,"MARCEL"
    ]

    var femaleNames =
    [
    "ZUZANNA"
    ,"JULIA"
    ,"MAJA"
    ,"ZOFIA"
    ,"HANNA"
    ,"LENA"
    ,"ALICJA"
    ,"MARIA"
    ,"AMELIA"
    ,"OLIWIA"
    ,"ALEKSANDRA"
    ,"WIKTORIA"
    ]
}
//proper code implementation

class CruiseShip {
    let shipName: String
    let captainId: Int
    let captainFullName: String
    
    let capacityOfWorkers: Int
    let capacityOfGuests: Int
    let numberOfCabins: Int
    
    //[ID:TYPE]()
    private var restaurants = [String:Restaurant]()
    private var bars =  [String:Bar]()
    private var cabins = [Int:Cabin]()
    private var engines = [Engine.EngineType:Engine]()
    
    private var activeEngine = [Engine.EngineType:Engine]()
    
    private var guests = [Int:Guest]()
    private var workers = [Int:Worker]()
    
    init (shipName: String, captainName: String, capacityOfWorkers: Int,
          capacityOfGuests: Int, restaurants: [String:Int], bars: [String:Int], engines: [Engine.EngineType]) {
        self.shipName = shipName
        self.captainId = 1
        self.captainFullName = captainName
        workers[1] = Worker(fullName: captainName, id: 1, profession: Worker.Profession.captain)
        
        //create workers
        for i in 2...capacityOfWorkers {
            workers[i] = Worker(fullName: RandGenerator.shared.generateName(), id: i, profession: RandGenerator.shared.generateProfession())
        }
        
        self.capacityOfWorkers = capacityOfWorkers
        self.capacityOfGuests = capacityOfGuests
        self.numberOfCabins = Int(CGFloat(Double(capacityOfGuests)/3.0).rounded(.up))
        
        for i in 1...self.numberOfCabins {
            if i%2 == 1 {
                cabins[i] = Cabin(cabinId: i, cabinSize: Cabin.Size.small)
            } else {
                cabins[i] = Cabin(cabinId: i, cabinSize: Cabin.Size.large)
            }
        }
        
        //create guests
        //free cabins are to make assigement more efficient, it helps to decrease number of iterations
        var freeCabins = cabins
        for i in 1...capacityOfGuests {
            for j in freeCabins {
                if j.value.isFree() {
                    guests[i] = Guest(fullName: RandGenerator.shared.generateName(), id: i,
                                      dateOfBirth: RandGenerator.shared.generateDate() , freeCabin: j.value)
                    break
                }
                if !j.value.isFree() {
                    freeCabins[j.key] = nil
                }
            }
        }
        
        for (k, v) in restaurants {
            self.restaurants[k] = Restaurant(name: k, capacity: v)
        }
        
        for (k, v) in bars {
            self.bars[k] = Bar(name: k, capacity: v)
        }
        
        for i in engines {
            self.engines[i] = Engine(sizeOfEngine: i)
        }
    }
    //captain name need to be provided because of safety reasons
    func turnOnEngine(captainFullName: String, engineToTurnOn: [Engine.EngineType])-> Bool {
        for i in engineToTurnOn {
            if activeEngine.keys.contains(i){
                return false
            }
            
        }
        if captainFullName == self.captainFullName {
            for i in engineToTurnOn {
                activeEngine[i] = engines[i]
            }
            return true
        }
        return false
    }
    func turnOffEngine(captainFullName: String, engineToTurnOff: [Engine.EngineType])-> Bool {
        if captainFullName == self.captainFullName {
            for i in engineToTurnOff {
                activeEngine[i] = nil
            }
            return true
        }
        return false
    }
    
    func display() {
        print("shipName \(self.shipName), captainId \(self.captainId), captainFullName \(self.captainFullName)")
        print("number of workers \(self.capacityOfWorkers), capacity of guests \(capacityOfGuests)")
        print("numberOfCabins \(self.numberOfCabins), number of restaurants \(self.restaurants.count), number of bars \(self.bars.count)")
        print("number of guests \(guests.count)")
    }
    
    func displayGuests() {
        for i in guests.values {
            i.display()
        }
    }
    
    func displayWorkers() {
        for i in workers.values {
            i.display()
        }
    }
    
    func displayBars() {
        for i in bars {
            i.value.display()
        }
    }
    
    func displayRestaurants() {
        for i in restaurants {
            i.value.display()
        }
    }
    
    func displayActiveEngines() {
        if activeEngine.count == 0 {
            print("no active engines")
        }
        for i in activeEngine {
            print("engine: \(i.value.type)")
        }
    }
    
    func addGuestToBar(guestId: Int, barName: String)-> Bool {
        if (bars[barName]?.addGuest(guest: guests[guestId]!))! {
            for i in restaurants {
                if i.value.containsGuest(guest: guests[guestId]!) {
                    i.value.removeGuest(guest: guests[guestId]!)
                }
            }
            return true
        }
        return false
    }
    
    
    func removeGuestFromBar(guestId: Int, barName: String)-> Bool {
        if (bars[barName]?.removeGuest(guest: guests[guestId]!))! {
            guests[guestId]?.setLocation(location: Guest.Location.cabin)
            return true
        }
        return false
    }
    
    func displayGuestsInBar(barName: String) {
        bars[barName]?.displayGuests()
    }
    
    func getNumberOfGuestsInBar(barName: String)-> Int {
        return (bars[barName]?.amountOfGuests())!
    }
    
    func addGuestToRestaurant(guestId: Int, restaurantName: String)-> Bool {
        if (restaurants[restaurantName]?.addGuest(guest: guests[guestId]!))! {
            for i in bars {
                if i.value.containsGuest(guest: guests[guestId]!) {
                    i.value.removeGuest(guest: guests[guestId]!)
                }
            }
            return true
        }
        return false
    }
    
    func removeGuestFromResturant(guestId: Int, restaurantName: String)-> Bool {
        if (restaurants[restaurantName]?.removeGuest(guest: guests[guestId]!))! {
            guests[guestId]?.setLocation(location: Guest.Location.cabin)
        }
        return false
    }
    
    func displayGuestsInRestaurant(restaurantName: String) {
        restaurants[restaurantName]?.displayGuests()
    }
    
    func getNumberOfGuestsInRestaurant(restaurantName: String)-> Int {
        return (restaurants[restaurantName]?.amountOfGuests())!
    }
    
    func displayCabinGuests(CabinId: Int)-> Bool {
        if cabins.keys.contains(CabinId) {
            cabins[CabinId]?.displayGuests()
            return true
        }
        print("no guests in cabin")
        return false
    }
    
    func displayCabins() {
        for i in cabins {
            print("cabin id: \(i.value.id), capacity: \(i.value.capacity), number of guests \(i.value.getNumberOfGuests())")
        }
    }
    
    func addFriends(guestId: Int, friendsIds: [Int]) {
        for i in friendsIds {
            if guests.keys.contains(i) {
                guests[guestId]?.addFrends(friends: [ guests[i]! ])
            }
        }
    }
    
    func removeFriends(guestId: Int, friendsIds: [Int]) {
        for i in friendsIds {
            if guests.keys.contains(i) {
                guests[guestId]?.removeFriends(friends: [ guests[i]! ])
            }
        }
    }
    
    func displayFriends(guestId: Int) {
        guests[guestId]?.displayFriends()
    }
}

protocol Place {
    var capacity: Int { get }
}

protocol Person {
    var fullName: String { get }
    var id: Int { get }
    func display()
}

class Worker: Person{
    enum Profession {
        case waiter, servant, sailor, captain, doctor
    }
    let fullName: String
    let id: Int
    let profession: Profession
    init(fullName: String, id: Int, profession: Profession) {
        self.fullName = fullName
        self.id = id
        self.profession = profession
    }
    
    func display() {
        print("name \(self.fullName), id: \(self.id), profession: \(self.profession)")
    }
}

class Guest: Person{
    enum Location {
        case cabin, bar, restaurant
    }
    private var guestLocation: Location
    let fullName: String
    let id: Int
    let dateOfBirth: Date
    private var friends = [Int: Guest]()
    init(fullName: String, id: Int, dateOfBirth: String, freeCabin: Cabin) {
        self.fullName = fullName
        self.id = id
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.dateOfBirth = dateFormatter.date(from: "\(dateOfBirth) 02:00:00")!
        self.guestLocation = Location.cabin
        freeCabin.assginGuest(guest: self)
    }
    
    func getLocation()->Location {
        return guestLocation
    }
    
    func setLocation(location: Location) {
        self.guestLocation = location
    }
    
    func display() {
        print("name: \(self.fullName), id: \(self.id), date of birth: \(self.dateOfBirth), location: \(self.guestLocation)")
    }
    
    func addFrends(friends: [Guest]) {
        for i in friends {
            if i.id != id {
                self.friends[i.id] = i
            }
        }
    }
    
    func removeFriends(friends: [Guest]) {
        for i in friends {
            self.friends[i.id] = nil
        }
    }
    
    func displayFriends() {
        print("friends of: \(self.fullName), id: \(self.id)")
        if friends.count == 0 {
            print("no friends")
        } else {
            for i in friends {
                i.value.display()
            }
        }
    }
}

class Cabin: Place {
    let id: Int
    let size: Size
    let capacity: Int
    private var guests = [Int: Guest]()
    enum Size {
        case large, small
        var capacity: Int {
            switch self {
            case .large:
                return 4
            case .small:
                return 2
            }
        }
    }
    
    init(cabinId id: Int, cabinSize size: Size) {
        self.id = id
        self.size = size
        self.capacity = size.capacity
    }
    
    func isFree()-> Bool {
        return capacity > guests.count
    }
    
    func assginGuest(guest: Guest) -> Bool {
        if guests.count == capacity {
            return false
        }
        guests[guest.id] = guest
        return true
    }
    
    func displayGuests() {
        for (k, v) in guests {
            print("guest id: \(k) , fullname: \(v.fullName)")
        }
    }
    
    func getNumberOfGuests()-> Int {
        return guests.count
    }
}

class Engine {
    let kiloHorsePower: Int
    let type: EngineType
    enum EngineType{
        case small, large
        var power: Int {
            switch self {
            case .small:
                return 2
            case .large:
                return 4
            }
        }
    }
    init(sizeOfEngine type: EngineType) {
        self.type = type
        self.kiloHorsePower = type.power
    }
}

class EntertainmentPlace: Place {
    let capacity: Int
    let name: String
    private var guests = [Int: Guest]()
    init(name: String, capacity: Int) {
        self.name = name
        self.capacity = capacity
    }
    
    func removeGuest(guest: Guest) -> Bool {
        if guests.keys.contains(guest.id) {
            guests[guest.id] = nil
            return true
        }
        return false
    }
    
    func addGuest(guest: Guest) -> Bool {
        if !guests.keys.contains(guest.id) && guests.count < capacity {
            guests[guest.id] = guest
            return true
        }
        return false
    }
    
    func getGuests()-> Dictionary<Int, Guest>  {
        return self.guests
    }
    
    func setGuest(guestId: Int, guest: Guest) {
        guests[guestId] = guest
    }
    
    func display() {
        print("name: \(self.name), capacity: \(self.capacity), number of guests: \(guests.count)")
    }
    
    func displayGuests() {
        print("guests of restuarant: \(self.name)")
        if guests.count == 0 {
            print("no guests in object")
        }
        for i in guests {
            i.value.display()
        }
    }
    
    func amountOfGuests()-> Int {
        return guests.count
    }
    
    func containsGuest(guest: Guest)-> Bool {
        return guests.keys.contains(guest.id)
    }
}

class Restaurant: EntertainmentPlace {
    override func addGuest(guest: Guest) -> Bool {
        if !super.getGuests().keys.contains(guest.id) && super.getGuests().count < capacity {
            setGuest(guestId: guest.id, guest: guest)
            guest.setLocation(location: Guest.Location.restaurant)
            return true
        }
        return false
    }
}

class Bar: EntertainmentPlace {
    override func addGuest(guest: Guest) -> Bool {
        if !super.getGuests().keys.contains(guest.id) && super.getGuests().count < capacity
            && Calendar.current.date(byAdding: .year, value: -18, to: Date())! > guest.dateOfBirth {
            super.setGuest(guestId: guest.id, guest: guest)
            guest.setLocation(location: Guest.Location.bar)
            return true
        }
        return false
    }
}

var Tytanic = CruiseShip(shipName: "Tytanic", captainName: "Captain Nemo", capacityOfWorkers: 50, capacityOfGuests: 350,
                         restaurants: ["Manekin": 300], bars: ["Nora": 50, "Insinde": 50],
                    engines: [Engine.EngineType.small, Engine.EngineType.large])
print("ship info:")
Tytanic.display()

//engine test()
Tytanic.displayActiveEngines()
print("add first engine:")
Tytanic.turnOnEngine(captainFullName: "Captain Nemo", engineToTurnOn: [Engine.EngineType.large])
Tytanic.displayActiveEngines()
print("add second engine:")
Tytanic.turnOnEngine(captainFullName: "Captain Nemo", engineToTurnOn: [Engine.EngineType.small])
Tytanic.displayActiveEngines()
print("try to add once again engine: ")
Tytanic.turnOnEngine(captainFullName: "Captain Nemo", engineToTurnOn: [Engine.EngineType.small])
Tytanic.displayActiveEngines()
print("remove both engines:")
Tytanic.turnOffEngine(captainFullName: "Captain Nemo", engineToTurnOff: [Engine.EngineType.small, Engine.EngineType.large])
Tytanic.displayActiveEngines()
print("")


//cabins
//Tytanic.displayCabins()

//adding and removing friends
print("")
print("now add friends")
Tytanic.displayFriends(guestId: 10)
Tytanic.addFriends(guestId: 10, friendsIds: [12, 12, 312, 11, 23, 3, 10])
Tytanic.displayFriends(guestId: 10)
print("now remove friends, should left only with id: 3")
Tytanic.removeFriends(guestId: 10, friendsIds: [12, 312, 11, 23])
Tytanic.displayFriends(guestId: 10)


//bar test
print("")

for i in 280...330 {
    Tytanic.addGuestToBar(guestId: i, barName: "Nora")
}
print("amount of guests in bar (tried to add 50)")
print(Tytanic.getNumberOfGuestsInBar(barName: "Nora"))
print("as we can see not everone can go to bar")
//Tytanic.displayGuestsInBar(barName: "Nora")


//restaurants test
print("")

for i in 1...330 {
    Tytanic.addGuestToRestaurant(guestId: i, restaurantName: "Manekin")
}
print("amount of guests in restaurant (tried to add 330)")
print(Tytanic.getNumberOfGuestsInRestaurant(restaurantName: "Manekin"))
//Tytanic.displayGuestsInRestaurant(restaurantName: "Manekin")
print("amount of guests in bar should be lower now because part of them went to restaurant")
print(Tytanic.getNumberOfGuestsInBar(barName: "Nora"))

print("now move everyone to cabin")
for i in 1...330 {
    Tytanic.removeGuestFromBar(guestId: i, barName: "Nora")
    Tytanic.removeGuestFromResturant(guestId: i, restaurantName: "Manekin")
}
Tytanic.displayGuestsInBar(barName: "Nora")
Tytanic.displayGuestsInRestaurant(restaurantName: "Manekin")

