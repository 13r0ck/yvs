pragma solidity ^0.5.16;

// in tests/ truffle console use:
// const Node1 = await Node.at(await NodeFactory.getNode(accounts[<owner>]))
// to be able to run commands on the child.
import "./NodeFactory.sol";

contract Node {
    mapping (address => uint8) private weight;
    address[] private relationships;
    address owner;
    string name;
    string content;
    address factory;

    constructor(address _owner, string memory _name, string memory _content, address _factory) public {
        owner = _owner;
        name = _name;
        content = _content;
        factory = _factory;
        /*
        factory is the address of the facotry contract that created this node (NodeFactory.sol)
        We save this simple so that any time that a node is referenced it is possible to check that that referenced node is valid
        This is necessary so that Nodes cannot have relationships with contracts that are not within the YVS network
        A contract that is structured similar to a YVS contract could create a relationship and the weight on itself. Which is not possible in YVS contracts
        This would allow for a fake contract to be exactly identical to a real node in a way that is not possible by registering a new node in YVS.
        Meaning that attacker could use similar fake contract to validate personal info on YVS in a way that would be nearly indestinquishable to the end user, thus completely breaking YVS.

        So, verifying that a node was created properly is necessary. Though I do not like this current implementation as it requires that all nodes
        store redendant data. Which creates an uneccessary expense and burden on the eth network. I am not sure what the best fix would be, though one will have to be found.
        */
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
        // Prevent STP-loop like attacks
        require(_newRelationship != address(this), "Cannot create a relationship with oneself");
        Node node = Node(_newRelationship);
        NodeFactory nf = NodeFactory(factory);
        require(nf.getNode(node.getOwner()) == _newRelationship, 'Relationship must be with valid Node');
        // The relationship needs to be a valid node.
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