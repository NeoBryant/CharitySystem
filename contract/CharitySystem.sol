pragma solidity ^0.5.0;

contract CharitySystem { 
    enum Identity {Unidentified, Charity, Benefiary, Donator}
    
    struct Person{
        uint identity; //the identity of the person('unidentified'0 , 'charity'1 , 'benefiary'2, 'donator'3)
        uint256 balance; //the balance of the person
        uint256 totalGiveDonation; //the total donation of the person who give
        uint256 totalGetDonation; //the total donation of the person who get
    }
    
    /* This creates an array with all person */   
    mapping (address => Person) private persons;
    address charity; //the charity is the creator and only one
    
    /* Initializes contract with initial supply tokens to the creator of the contract */ 
    constructor(uint256 initialSupply) public {  
        charity = msg.sender; //there is only one charity
        persons[charity].balance = initialSupply; // Give the charity all initial tokens 
        persons[charity].identity = 1;
        persons[charity].totalGetDonation = 0;
        persons[charity].totalGiveDonation = 0;
    }
    
    function setIdentity(address _addr, uint _iden) public { //only charity can identity and give the identity of person 
        require(msg.sender == charity && _addr != charity); //only charity has the right
        
        //the identity only can be set to Donate or Benefiary
        if (_iden == 2) { //the identity is set to Benefiary
            persons[_addr].identity = 2;
        } else if (_iden == 3){ //the identity is set to Donator
            if (persons[_addr].identity == 0) { //if the person is Unidentified before setting
                persons[_addr].balance = 10000; //the donator's balance is set to 10000
            }
            persons[_addr].identity = 3;
        } else {
            persons[_addr].identity = 0; 
        }
    }
    
    
    /* Donate to benefiary from charity*/ 
    function donateToBenefiary(address _to, uint256 _value) public payable { 
        require(msg.sender == charity); //only the charity can donate to the benefiary
        require(persons[_to].identity == 2); //only the benefiary can be donated
        
        require(persons[charity].balance >= _value); // Check if the sender has enough 
        require(persons[_to].balance + _value >= persons[_to].balance); // Check for overflows     
        
        persons[msg.sender].balance -= _value; // Subtract from the sender        
        persons[_to].balance += _value; // Add the same to the recipient 
        
        persons[msg.sender].totalGiveDonation += _value;
        persons[_to].totalGetDonation += _value;
    } 
    
    /* donate to charity from donator */
    function donateToCharity(uint256 _value) public payable {
        require(msg.sender != charity);
        require(persons[msg.sender].identity == 3);
        
        require(persons[msg.sender].balance >= _value);
        require(persons[charity].balance + _value >= persons[charity].balance);
        
        persons[msg.sender].balance -= _value;
        persons[charity].balance += _value;
        
        persons[msg.sender].totalGiveDonation += _value;
        persons[charity].totalGetDonation += _value;
    }

    
    /* return the identity of the person (int->byte32) */
    function showIdentity(address _addr) public view returns (string memory) {
        string memory identity;
        if (persons[_addr].identity == 0) {
            identity = "Unidentified";
        } else if (persons[_addr].identity == 1){
            identity = "Charity";
        } else if (persons[_addr].identity == 2) {
            identity = "Benefiary";
        } else {
            identity = "Donator";
        }
        return identity;
    }
    
    /* return the balance of the person */
    function showBalance(address _addr) private view returns (uint256) {
        return persons[_addr].balance;
    }
    
    /* return the totalGiveDonation of the person */
    function showTotalGiveDonation(address _addr) private view returns (uint256) {
        return persons[_addr].totalGiveDonation;
    }
    
    /* return the totalGetDonation of the person */
    function showTotalGetDonation(address _addr) private view returns (uint256) {
        return persons[_addr].totalGetDonation;
    }
    
    /* return the all information of the person */
    function showInformationOf(address _addr) public view returns (string memory, uint256, uint256, uint256) {
        require(msg.sender == charity && _addr != charity);
        return (showIdentity(_addr), showBalance(_addr), showTotalGiveDonation(_addr), showTotalGetDonation(_addr));
    }
    
    /* return the information of the charity */
    function showInformationOfCharity() public view returns (string memory, uint256, uint256, uint256, address) {
        return (showIdentity(charity), showBalance(charity), showTotalGiveDonation(charity), showTotalGetDonation(charity), charity);
    }
}


