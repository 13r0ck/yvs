pragma solidity ^0.5.16;

// in tests/ truffle console use:
// const Node1 = await Node.at(await NodeFactory.getNode(accounts[<owner>]))
// to be able to run commands on the child.

contract Node {
    mapping (address => uint8) private weight;
    address[] private relationships;
    address owner;
    string name;
    string content;

    constructor(address _owner, string memory _name, string memory _content) public {
        owner = _owner;
        name = _name;
        content = _content;
    }

    modifier _isOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function getRelationships() public view returns(address[] memory) {
        return relationships;
    }

    function getWeight(address _address) public view returns(uint8) {
        return weight[_address];
    }

    function getName() public view returns(string memory) {
        return name;
    }

    function getContent() public view returns(string memory) {
        return content;
    }

    function getOwner() public view returns(address) {
        return owner;
    }

    function setWeight(uint8 _weight) external {
        require(_weight < 100, "Weight can only vary from 0 -> 100");
        require(msg.sender != owner, "Weight can only be modified by related address");
        weight[msg.sender] = _weight;
    }

    function addRelationship(address _newRelationship) external _isOwner {
        require(_newRelationship != address(this), "Cannot create a relationship with oneself");
        /*
        ---- Oh boy do I have to figure this one out... ----
        Node node = Node(_newRelationship);
        require(node.getOwner() == msg.sender, 'Sender must be the owner');
        // The relationship needs to be a valid node.
        */
        relationships.push(_newRelationship);
    }

    function setContent(string calldata _newContent) external _isOwner {
        content = _newContent;
    }

    function setName(string calldata _newName) external _isOwner {
        name = _newName;
    }

    function setOwner(address _newOwner) external _isOwner {
        owner = _newOwner;
    }

    function removeRelationship(uint _index) external _isOwner {
        require(relationships.length > 0, "There are no relationships to remove");
        uint _lastIndex = relationships.length --;
        relationships[_index] = relationships[_lastIndex];
        delete relationships[_lastIndex];
    }
}