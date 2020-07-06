pragma solidity ^0.5.16;

import './Node.sol';

contract NodeFactory {
    mapping (address => Node) private nodes;

    function deploy(string calldata _name, string calldata _content) external {
        require(nodes[msg.sender] == Node(0), "Max Nodes for msg.sender address.");
        nodes[msg.sender] = new Node(msg.sender, _name, _content);
    }

    function getNode(address _ownerAddress) public view returns(address) {
        return address(nodes[_ownerAddress]);
    }
}

/*
Things that I need to test for:

    ## Relationships
    1. Everything compiles 🗸
    2. Node can be created 🗸
    3. Multiple addresses can create individual nodes 🗸
    4. A Node's address can be publicly found from owner's address. 🗸
    5. An address cannot create multiple nodes 🗸
    6. Node name/content/owner can be read 🗸
    7. The Name/content can be modified by owner
    8. The name/content cannot be modified by non-owner
    9. That weights can be modified correctly on each side 🗸
    10. Weights cannot be greater than 100 nor less than 0 🗸
    11. Weights to oneself cannot be changed 🗸
    12. That relationship(s) can be added 🗸
    13. An address cannot add a relationship to a node they do not own 🗸
    14. A node cannot add a relationship to itself.
    15. The relationship must be a valid node.
    16. A relationship can be deleted by owner
    17. A relationship cannot be deleted by someone who is not the owner
    18. Those relationships are publicly readable

    ## Child Nodes
    1. A Node can create a childnode
    3. The children's name/content can be read by owner
    4. The children's name/content can be read by the public
    5. The name/content cannot be change by owner nor public (imutable)
    6. A node can be abandoned
    7. A node can be signed by another address.

    ## Multiple children
    1. A parent can create multiple children at the same level
    2. A parent can create a childNode with a childNode as its parent
    2. A parent can create a spanning tree of children
    3. A node can be reparented if owner owns both previous parent and future parent



*/