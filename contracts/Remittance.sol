pragma solidity ^0.4.24;

import "https://github.com/Arachnid/solidity-stringutils/src/strings.sol";

contract Remittance {

using strings for *;

// Struct to represent a digital safety deposity box.
// Deciding whether an instance of Box needs an owner or not.
struct Box {
  uint amount;
  bytes32 passwordHash;
}

// Data structure to hold all instances of Box, with the key being used
// as the unique box number for reference.
mapping(uint => Box) boxes;

// The owner of the contract for admin purposes.
address owner;

// State variable that is incremented every time a new Box is created.
// Variable should be unique.
uint boxNumber;

event LogSendFunds(address, uint);
event LogPasswordError(string);
event LogPasswordGenerated(string, string);

constructor() public {
  owner = msg.sender;
}

modifier isOwner() {
  require(msg.sender == owner);
  _;
}

/// @notice Instantiate a new Box when funds are sent to the contract,
/// generate two OTPs, send to users (to be done off-chain), hash the concat
/// of those strings and store the 'secret' hash in the instance, along with
/// the amount sent to the function. State variable boxNumber is incremented
/// to create a unique key for each box.
/// @dev Password generation (and sending to user) I expect will be done
/// off-chain, with the secret hash sent back to the function and stored in
/// instance.
/// Undecided whether an instance of Box should have an owner (ie msg.sender
/// or 'Alice' in this case).
/// @return boxNumber to the creator, to used later to 'open' the box.
function createBox() public payable returns (uint) {
  require(msg.value > 0);
  require(msg.sender != address(0));
  bytes32 pwHash;
  string memory password1 = "test123";
  string memory password2 = "test456";
  string memory concatPasswords;

  boxNumber += 1;
  boxes[boxNumber].amount = msg.value;

  concatPasswords = password1.toSlice().concat(password2.toSlice());

  pwHash = keccak256(concatPasswords);

  boxes[boxNumber].passwordHash = pwHash;
  emit LogPasswordGenerated(password1, password2);
  return boxNumber;
}

/// @notice Unlocks a box from a request from the sender (ie. the admin
/// of the escrow exchange, in this case 'Carol'
/// The funds registered in the box are only sent once the password hashes
/// match
/// @dev Once funds are sent, delete the mapping which resets to 0.
/// @param boxNo identifies which box is to be opened
/// @param password1 the password of 'Bob'
/// @param password2 the password of 'Carol'
function openBox(uint boxNo, string password1, string password2) public payable {
   bytes32 passwordHash;
   uint amountToRelease;

   string memory concatPasswords;
   concatPasswords = password1.toSlice().concat(password2.toSlice());
   passwordHash = keccak256(concatPasswords);

   if (boxes[boxNo].passwordHash == passwordHash) {
     amountToRelease = boxes[boxNo].amount;
     msg.sender.transfer(amountToRelease);
     delete boxes[boxNo];
   } else {
       LogPasswordError("Password mismatch or invalid box numher!");
   }

}

/// @notice Getter functions for testing purposes
function getContractBalance() public view returns (uint) {
  return this.balance;
}

function getBox(uint key) public view returns (uint, bytes32) {
  return (boxes[key].amount, boxes[key].passwordHash);
}


}
