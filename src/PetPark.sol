// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract PetPark {
    address owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // Struct
    struct petparkbase {
        string animal_name;
        uint256 animal_count;
    }

    mapping(uint256 => petparkbase) animalIdRef; //Id to animal data mapping
    mapping(address => uint256) userBorrowCount; // users borrowCount
    mapping(address => uint256) usersBorrowedAnimalTypeId; // Users Borrowed Animal Id ref
    event added(uint256 _type, uint256 _count);
    event borrowed(uint256 _type);
    event Returned(uint256 _type);
    event InvalidAnimal(uint256 typeId, string message);

    // Add an animal type
    function addAnimalType(
        uint256 _typeID,
        string memory _name,
        uint256 _default_count
    ) public onlyOwner {
        animalIdRef[_typeID] = petparkbase({
            animal_name: _name,
            animal_count: _default_count
        });
    }

    // Anybody can check current data for any animal id
    function getAnimalData(
        uint256 _typeID
    ) public view returns (petparkbase memory) {
        return animalIdRef[_typeID];
    }

    // Only owner can add animals to the pet park
    function add(uint256 _typeId, uint256 _count) public onlyOwner {
        //need to check if the animal is valid
        if (bytes(animalIdRef[_typeId].animal_name).length > 0) {
            animalIdRef[_typeId].animal_count =
                animalIdRef[_typeId].animal_count +
                _count;
            emit added(_typeId, _count);
        } else {
            emit InvalidAnimal(_typeId, "Invalid animal");
        }
    }

    // borrow a pet - make sure user has not borrowed a pet earlier
    function borrow(uint256 age, string memory gender, uint256 _typeId) public {
        require(userBorrowCount[msg.sender] == 0, "User has already borrowed");

        if (keccak256(bytes(gender)) == keccak256(bytes("male"))) {
            require(
                _validateMaleBorrow(_typeId),
                "Invalid animal type for male borrower"
            );
        } else if (keccak256(bytes(gender)) == keccak256(bytes("female"))) {
            require(
                _validateFemaleBorrow(age, _typeId),
                "Invalid animal type for female borrower"
            );
        } else {
            revert("Invalid gender provided");
        }

        require(
            animalIdRef[_typeId].animal_count > 0,
            "That animal breed is on the verge of extinction"
        ); ///assuming valid Id has been entered by user
        animalIdRef[_typeId].animal_count =
            animalIdRef[_typeId].animal_count -
            1;
        userBorrowCount[msg.sender] += 1;
        usersBorrowedAnimalTypeId[msg.sender] = _typeId;
        emit borrowed(_typeId);
    }

    // give back aninmal, update user and animal database
    function giveBackAnimal() public {
        require(
            userBorrowCount[msg.sender] == 1,
            "You haven't borrowed any animals yet"
        );
        userBorrowCount[msg.sender] -= 1;
        uint _userBorrowedAnimal = usersBorrowedAnimalTypeId[msg.sender];
        animalIdRef[_userBorrowedAnimal].animal_count =
            animalIdRef[_userBorrowedAnimal].animal_count +
            1;
        emit Returned(_userBorrowedAnimal);
    }

    function _validateMaleBorrow(uint256 _typeId) internal view returns (bool) {
        string[] memory maleBorrowableAnimals = new string[](2);
        maleBorrowableAnimals[0] = "Dog";
        maleBorrowableAnimals[1] = "Fish";
        string memory animal_name = animalIdRef[_typeId].animal_name;

        for (uint256 i = 0; i < maleBorrowableAnimals.length; i++) {
            if (
                keccak256(bytes(animal_name)) ==
                keccak256(bytes(maleBorrowableAnimals[i]))
            ) {
                return false;
            }
        }
        return true;
    }

    function _validateFemaleBorrow(
        uint256 age,
        uint256 _typeId
    ) internal view returns (bool) {
        string memory disallowed_animal_name = "Cat";
        string memory animal_name = animalIdRef[_typeId].animal_name;

        if (
            age < 40 &&
            keccak256(bytes(animal_name)) ==
            keccak256(bytes(disallowed_animal_name))
        ) {
            return false; // Disallow borrowing for females under age 40 if the animal is "Cat"
        }

        return true; // Allow borrowing for females over age 40 or for any animals
    }
}
