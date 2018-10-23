pragma solidity ^0.4.24;

contract Remittance {

struct Transaction {
  uint amount;
  address sender;
  address receiver;
  bytes32 passwordHash;
}

mapping(address => uint) balances;
mapping(uint => Transaction) transactions;

address owner;

uint transactionNumber;

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

function fundAccount(address _receiver) public payable {
  require(msg.value > 0);
  require(msg.sender != address(0));

  balances[msg.sender] += msg.value;
  sendPassword(msg.sender, _receiver, msg.value);

}

function getBalance(address account) public returns (uint) {
  return balances[account];
}

function sendFunds(address sender, address receiver, uint amount) internal {
  require(receiver !=0);
  require(amount > 0);
  require(balances[sender] >= amount);

  receiver.transfer(amount);
  balances[receiver] -= amount;
  emit LogSendFunds(receiver, amount);
}

function sendPassword(address _sender, address _receiver, uint _amount) private returns (string, string) {
  string memory passwordSender = "test123";
  string memory passwordReceiver = "test456";

  bytes32 pwHash;
  transactionNumber += 1;

  pwHash = keccak256(passwordSender, passwordReceiver);
  transactions[transactionNumber].amount = _amount;
  transactions[transactionNumber].receiver = _receiver;
  transactions[transactionNumber].sender = _sender;
  transactions[transactionNumber].passwordHash = pwHash;

  emit LogPasswordGenerated(passwordSender, passwordReceiver);

  return (passwordSender, passwordReceiver);
}

function checkPasswords(uint transNo, string password1, string password2) public payable {
   bytes32 passwordHash;
   uint amountToSend;
   address sender;
   address receiver;
   receiver = msg.sender;
   require (receiver == transactions[transNo].receiver);
   sender = transactions[transNo].sender;
   passwordHash = keccak256(password1, password2);
   if (transactions[transNo].passwordHash == passwordHash) {
     amountToSend = transactions[transNo].amount;
     sendFunds(sender, receiver, amountToSend);
   } else {
       LogPasswordError("Password mismatch");
   }

}

function getTransactionHash(uint transNo) public view returns (bytes32) {
    return transactions[transNo].passwordHash;
}


}
