pragma solidity ^0.5.16;

// in tests/ truffle console use:
// const Node1 = await Node.at(await NodeFactory.getNode(accounts[<owner>]))
// to be able to run commands on the child.

import "./Node.sol";

contract ChildNode {
    address owner;
    address parent;
    mapping (address => uint) childrenIndex;
    address[] children;
    string name;
    string content;

    constructor(address _owner, address _parent, string memory _name, string memory _content) public {
        owner = _owner;
        parent = _parent;
        name = _name;
        content = _content;
    }

    modifier _isOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
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

    function getParent() public view returns(address) {
        return parent;
    }

    function getChildren() public view returns(address[] memory) {
        require(children.length > 0, "No Children to return");
        return children;
    }

    /*
    function changeParent(address _newParent) public _isOwner {
        Node newParentNode = Node(_newParent);
        Node oldParentNode = Node(_newParent);
        require(oldParentNode.getOwner() == msg.sender, "You must own the old parent Node to change this Node's parent");
        require(newParentNode.getOwner() == msg.sender, "You must own the new parent Node to change this Node's parent");
        oldParentNode.abandonChild(address(this));
        parent = _newParent;
    }

    function abandonChild(address _childAddress) public _isOwner {
        require(children.length > 1, "There are no children to abandon");
        uint _childIndex = childrenIndex[_childAddress];
        uint _lastIndex = childrenIndex.length --;
        childrenIndex[children[_lastIndex]] = _childIndex;
        children[_childIndex] = children[_lastIndex];
    }

    function addChild(address _newChild) public _isOwner {
        childrenIndex[children.length] = _newChild;
        children.push(_newChild);
    }
    */
}

/*
The goal of a child node is to allow for an imutable spanning tree that can be verified
by other parentNodes w/o 2 party verification.
The owner of the tree should be able to expand the tree (width and depth),
and invalidate+ignore branches, but NEVER be able to delete nor change a branch.
 */