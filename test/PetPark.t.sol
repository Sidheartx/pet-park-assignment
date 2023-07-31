// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../lib/forge-std/lib/ds-test/src/test.sol"; ////change path so we can detect the VM.sol functionality 
import "../src/PetPark.sol";
import "../lib/forge-std/src/test.sol";


contract PetParkTest is DSTest, PetPark, Test {
    PetPark petPark;
    
    address testOwnerAccount;

    address testPrimaryAccount = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    address testSecondaryAccount;

    function setUp() public {
        petPark = new PetPark();

        testOwnerAccount = msg.sender;
        testPrimaryAccount = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        testSecondaryAccount = address(0xABDC);
    }
/// contract owner needs to add animal types 
    function testOwnerCanAddAnimal() public {
        petPark.addAnimalType(1, "Cat", 0); 
        petPark.add(1, 5);
    }

    function testCannotAddAnimalWhenNonOwner() public {
        // 1. Complete this test and remove the assert line below
        petPark.addAnimalType(1, "Cat", 0); 
        vm.prank(testPrimaryAccount);
        vm.expectRevert("Not the owner"); // "next" call reverts, so the expectRevert should be above the call which is expexted to revert 
        petPark.add(1, 1);  
    }

    function testCannotAddInvalidAnimal() public {
        petPark.addAnimalType(1, "Cat", 0); 
        vm.expectEmit(false, false, false, true);
        emit InvalidAnimal(2, "Invalid animal"); 
        petPark.add(2, 5);
    }

    function testExpectEmitAddEvent() public {
        petPark.addAnimalType(2, "Cat", 0); // need to add first, animal types are not hardcoded onto the contract or initalised on the constructor
        vm.expectEmit(false, false, false, true);
        emit added(2, 5);
        petPark.add(2, 5);
    }

    function testCannotBorrowWhenAgeZero() public {
        petPark.addAnimalType(1, "Cat", 10); 
        petPark.add(1, 5); 
        vm.expectRevert("Cannot borrow");
        petPark.borrow(0, "male", 1); ///borrow with zero age to test failure 
    }

    function testCannotBorrowUnavailableAnimal() public {
        petPark.addAnimalType(2, "Dog", 0); //create the animal type
        ///petPark.add(1, 5); commenting out the add as the animal should be unavailable
        vm.expectRevert("Selected animal not available");
        petPark.borrow(24, "male", 2);
    }

    function testCannotBorrowInvalidAnimal() public {
        petPark.addAnimalType(1, "Cat", 0); 
        petPark.add(1, 5); 
        vm.expectRevert("Invalid animal type");
        petPark.borrow(24, "male", 2);
    }

    function testCannotBorrowCatForMen() public {
        petPark.addAnimalType(1, "Cat", 0); 
        petPark.add(1, 5); 
        vm.expectRevert("Invalid animal for men");
        petPark.borrow(24, "male", 1);
    }

    function testCannotBorrowRabbitForMen() public {
        petPark.addAnimalType(1, "Rabbit", 0); 
        petPark.add(1, 5);
        vm.expectRevert("Invalid animal for men");
        petPark.borrow(24, "male", 1);
    }

    function testCannotBorrowParrotForMen() public {
        petPark.addAnimalType(1, "Parrot", 0); 
        petPark.add(1, 5);
        vm.expectRevert("Invalid animal for men");
        petPark.borrow(24, "male", 1);
    }

    function testCannotBorrowForWomenUnder40() public {
        petPark.addAnimalType(1, "Cat", 0); 
        petPark.add(1, 5);
        vm.expectRevert("Invalid animal for women under 40");
        petPark.borrow(24, "female", 1);
    }

    function testCannotBorrowTwiceAtSameTime() public {
        petPark.addAnimalType(1, "Dog", 0);
        petPark.add(1, 5);
        petPark.addAnimalType(2, "Fish", 0);
        petPark.add(2, 5);

        vm.prank(testPrimaryAccount);
        petPark.borrow(24, "male", 2);

		vm.expectRevert("Already adopted a pet");
        vm.prank(testPrimaryAccount);
        petPark.borrow(24, "male", 1);

        vm.expectRevert("Already adopted a pet");
        vm.prank(testPrimaryAccount);
        petPark.borrow(24, "male", 1);
    }

    function testCannotBorrowWhenAddressDetailsAreDifferent() public {
        
        petPark.addAnimalType(1, "Fish", 0);
        petPark.add(1, 5);
        vm.prank(testPrimaryAccount);
        petPark.borrow(24, "male", 1);

		vm.expectRevert("invalid user details");
        vm.prank(testPrimaryAccount);
        petPark.borrow(23, "male", 1);

		vm.expectRevert("invalid user details");
        vm.prank(testPrimaryAccount);
        petPark.borrow(24, "female", 1);
    }

    function testExpectEmitOnBorrow() public {
        petPark.addAnimalType(1, "Fish", 0);
        petPark.add(1, 5);
        vm.expectEmit(false, false, false, true);
        emit borrowed(1);
        petPark.borrow(24, "male", 1);
    }

    function testBorrowCountDecrement() public {
        // 3. Complete this test and remove the assert line below
        petPark.addAnimalType(1, "Fish", 0);
        petPark.add(1, 1);///adding 1 Fish to the petpark
        petPark.borrow(24, "male", 1); // borrowing the 1 and only 
        vm.expectRevert("Selected animal not available"); // asserting that animal should not be available to borrow
        vm.prank(testPrimaryAccount);
        petPark.borrow(24, "male", 1);

        
    }

    function testCannotGiveBack() public {
        petPark.addAnimalType(1, "Fish", 0);
        vm.expectRevert("No borrowed pets");
        petPark.giveBackAnimal();
    }
}
