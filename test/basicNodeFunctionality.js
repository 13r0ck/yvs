const NodeFactory = artifacts.require("NodeFactory");
const Node = artifacts.require("Node");
const truffleAssert = require('truffle-assertions');
// https://github.com/rkalis/truffle-assertions

contract("Node test", async accounts => {
    it("should allow wallet to create a Node", async () => {
        let nf = await NodeFactory.deployed();
        await nf.deploy('Node0', 'Content0', {from: accounts[0]});
        let node0 = await Node.at(await nf.getNode(accounts[0]));
        assert.equal(await node0.getOwner(), accounts[0]);
    });
    it("should allow public and owner to find Node's address from owner's address", async () => {
        let nf = await NodeFactory.deployed();
        let ownerTest = await nf.getNode(accounts[0], {from: accounts[0]});
        let publicTest;
        for (let i = 0; i < 10; i++) {
            publicTest =  await nf.getNode(accounts[0], {from: accounts[i]})
            assert.equal(ownerTest, publicTest);
        }
    });
    it("should allow for each address to create a unique node", async () => {
        let nf = await NodeFactory.deployed();
        const nodeAddresses = [];
        let currentNode;
        //let testAddress;
        for (let i = 1; i < 10; i++) {
            await nf.deploy(`Node${i}`, `Content${i}`, {from: accounts[i]});
            currentNode = await nf.getNode(accounts[i]);
            // verify that two nodes are never created with same address.
            for (testAddress in nodeAddresses) {
                assert.notEqual(currentNode, testAddress);  
            }
            testNodeOwner = await (await Node.at(await nf.getNode(accounts[i]))).getOwner();
            assert.equal(accounts[i], testNodeOwner);
            nodeAddresses.push(currentNode);
        }
    });
    it("should NOT allow for an address to own more than one Node", async () => {
        let nf = await NodeFactory.deployed();
        await truffleAssert.reverts(nf.deploy("should", "fail", {from: accounts[0]}), 'Max Nodes for msg.sender address.');
    });
    it("should allow for name, content, and owner to be read from a Node", async () => {
        let nf = await NodeFactory.deployed();
        let currentTestNode;
        for (let i = 0; i < 10; i++) {
            currentTestNode = await Node.at(await nf.getNode(accounts[i]));
            assert.equal(await currentTestNode.getName(),`Node${i}`);
            assert.equal(await currentTestNode.getContent(), `Content${i}`);
            assert.equal(await currentTestNode.getOwner(), accounts[i]);
        }
    });
    it("should allow for address to modify weights no another node", async () => {
        let nf = await NodeFactory.deployed();
        node0 = await Node.at(await nf.getNode(accounts[0]));
        node1 = await Node.at(await nf.getNode(accounts[1]));
        await node0.setWeight(50, {from: accounts[1]});
        await node1.setWeight(50, {from: accounts[0]});
        assert.equal(await node0.getWeight(accounts[1]), 50);
        assert.equal(await node1.getWeight(accounts[0]), 50);
    });
    it("should restrict weights to be between 0-199", async () => {
        let nf = await NodeFactory.deployed();
        node0 = await Node.at(await nf.getNode(accounts[0]));
        await truffleAssert.reverts(node0.setWeight(101, {from: accounts[1]}), 'Weight can only vary from 0 -> 100');
        await truffleAssert.reverts(node0.setWeight(-1, {from: accounts[1]}), 'Weight can only vary from 0 -> 100');
    });
    it("should NOT allow for an addres to modify weights to itself on personal node", async () => {
        let nf = await NodeFactory.deployed();
        node0 = await Node.at(await nf.getNode(accounts[0]));
        await truffleAssert.reverts(node0.setWeight(51, {from: accounts[0]}), "Weight can only be modified by related address");
    });
    it("should allow for owner to add relationship to list", async () => {
        let nf = await NodeFactory.deployed();
        let node0 = await Node.at(await nf.getNode(accounts[0]));
        let node1Address = await nf.getNode(accounts[1]);
        let node2Address = await nf.getNode(accounts[2]);
        let nodeAddresses = [node1Address, node2Address];
        await node0.addRelationship(node1Address, {from: accounts[0]});
        await node0.addRelationship(node2Address, {from: accounts[0]});
        let node0Relationships = await node0.getRelationships();
        for (let i = 0; i <= 2; i++) {
            assert.equal(node0Relationships[i], nodeAddresses[i]);
        }
    });
    it("should NOT allow adding to relationships to a Node by an address that is not the owner", async () => {
        let nf = await NodeFactory.deployed();
        let node0 = await Node.at(await nf.getNode(accounts[0]));
        let node1Address = await nf.getNode(accounts[1]);
        await truffleAssert.reverts(node0.addRelationship(node1Address, {from: accounts[1]}), 'Only the owner can perform this action');
    });
    it("should NOT allow adding relationship of node to itself", async () => {
        let nf = await NodeFactory.deployed();
        let node0 = await Node.at(await nf.getNode(accounts[0]));
        let node0Address = await nf.getNode(accounts[0]);
        await truffleAssert.reverts(node0.addRelationship(node0Address, {from: accounts[0]}), 'Cannot create a relationship with oneself');
    });
    it("should require relationship be to a vaild node", async () => {
        let nf = await NodeFactory.deployed();
        let node0 = await Node.at(await nf.gerNode(accounts[0]));
        
    })
});