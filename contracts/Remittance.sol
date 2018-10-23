pragma solidity ^0.4.24;

contract Remittance {

struct Box {
  uint amount;
  bytes32 passwordHash;
}

mapping(uint => Box) boxes;

address owner;

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

function createBox() public payable {
  require(msg.value > 0);
  require(msg.sender != address(0));
  bytes32 pwHash;
  string password1 = "test123";
  string password2 = "test456";

  boxNumber += 1;
  boxes[boxNumber].amount = msg.value;

  pwHash = keccak256(password1, password2);
  boxes[boxNumber].passwordHash = pwHash;
  emit LogPasswordGenerated(passwordSender, passwordReceiver);
}

function openBox(uint boxNo, string password1, string password2) public payable {
   bytes32 passwordHash;
   uint amountToRelease;

   passwordHash = keccak256(password1, password2);

   if (boxes[boxNo].passwordHash == passwordHash) {
     amountToRelease = boxes[boxNo].amount;
     msg.sender.transfer(amount);
     boxes[boxNo].amount = 0;
   } else {
       LogPasswordError("Password mismatch");
   }

}

}
