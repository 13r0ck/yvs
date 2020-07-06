pragma solidity ^0.5.16;

//import './Realational.sol';

contract Source {
    
    mapping(address => uint) private addressToId;
    uint[] private sources;
    
    struct data {
        string title;
        string content;
        // This needs some way of having children.
        mapping (uint => bool) validators;
        uint expiresOn;
        bool ownerValidates;
        uint index;
    }

    struct source {
        string name;
        string content;
        address sourceAddress;
        uint id;
        data[] datas;
        uint[] relatedIds;
        // This relationship weight will require a lot of tweaking to know what are the correct numbers. Setting current values to be "resistance" to cross that connectio, 0 being infinite resistance,100 being no resistance. Default being 50.
        mapping (uint => uint) relationshipWeight;
    }
    
    modifier _sourceExists() {
        require(sources[addressToId[msg.sender].index] == msg.sender, "There is no source to modify");
        _;
    }
    
    modifier _sourceNotExists() {
        require(sourceIndexes.length == 0 || sources[addressToId[msg.sender].index] != msg.sender, "There is already a source associated with this address");
        _;
    }
    
    // Create Functions
    function addSource(string memory _name, string memory _content) public _sourceNotExists{
        source _newSource;
        _newSource.name = _name;
        _newSource.content = _content;
        _newSource.sourceAddress = msg.sender;
        _newSource.id = sources.length;
        sources.push(_newSource);
        addressToId[msg.sender] = _newSource.id;
    }
    
    function adddata(string _title, string _content, uint _expiresOn) public _sourceExists {
        data _newData;
        uint _id = addressToId[msg.sender];
        _newData.title = _title;
        _newData.content = _content;
        _newData.expiresOn = _expiresOn;
        _newData.ownerValidates = true;
        _newData.index = sources[_id].datas.length;
        sources[_id].datas.push(_newData);
    }

    // Modify functions
    function validateData(address _parentAddress, uint _dataIndex) public _sourceExists {
        require(msg.sender != _parentAddress);
        uint _parentId = addressToId[_parentId];
        uint _senderId = addressToId[msg.sender];
        sources[_parentId].datas[_dataIndex].validators[_senderId] = true;;
        if 
    }

    function invalidateData(address _parentAddress, uint _dataIndex) public _sourceExists {
        require(msg.sender != _parentAddress);
        sources[_parentAddress].datas[_dataIndex].validators[msg.sender] = false;
    }

    function updateSourceName(string memory _name) public _sourceExists{
        sources[msg.sender].name = _name;
    }
    
    function updateSourceDescription(string memory _description) public _sourceExists{
        sources[msg.sender].description = _description;
    }

    // Get functions

    // Get type of relationship between two addresses. Note: Relationship will not necessarily be parent/child. Parent/child  naming convention is used with regard to the data storage.
    function getRelationshipStatus(address _parentAddress, address _childAddress) public view returns(string) {
        require(sources[_parentAddress].relationships[_childAddress].verified == true);
        return sources[_parentAddress].relationships[_childAddress].relationship;
    }

    // Allows for child address to check with the parent what the requested relationship is. Note: Relationship will not necessarily be parent/child. Parent/child  naming convention is used with regard to the data storage.
    function getUnverifiedRelationship(address _relatedAddress) public view _sourceExists {
        require(sources[_relatedAddress].relationships[msg.sender].validated == false);
        return sources[_relatedAddress].relationships[msg.sender].relationship;
    }


    function getSource(address _address) public view returns(string memory, string memory, uint, uint, address[] memory){
        source memory _source = sources[_address];
        return (_source.name, _source.description, _source.timeCreated, _source.index, _source.realationalIndex);
    }
}

/*
I am not going to be able to implement this tonight, but basically the separation between source/data is not necessary. It might be for data management, but not logically

Basically the relationship between people and data is the same ignoring the resistance of the relationship.

There are degrees of separation between people with a weight. That weight is esentially arbitrary, but both physically and logically it takes time to go from person to person.
This weight can add up to create a distance between people that creates each persons sphere of influence.
Following the logic of "six degrees of separation" it is possible to trace the logical cost to travel between people (A* algorithm)
This distance is also similar to how we evaluate trust, the more familiarized we are with someone the more likely we are to trust their word.

We gain trust in groups by their relationships with us, what is the "cost" to travel between people (Total = num of jumps * total jump weights).
Hypothetically if we wholly 100% trust a person then we will also 100% trust what they say, meaing that the cost to jump to a person and then their ideas is 0.
Meaning that the cost of the relationship between a person and their ideas is 0.

Emulating this human way of trusting data we are able to verify sources and verify data.
Rather than having the modern database model of requiring a unique key for each user we are able to have sources with identical keys but with different values based on our relationship to the key.

This allows for data models that are simply not possible with modern technology.
With modern infrastructure if I want to message a highschool friend I need to know their uniqie id whether that be phone number/ email / etc, when that is not how we think.
To descript the sitation I said "a highschool friend" meaning that the friend and I would have 2 degrees of separation. From myself to the highschool and then to them.
Meaning that YVS functions more similarly to human interactions than any other from of data managment.

This also functions for authentication. For ecample when trying to enter a building what the person entering says does not matter. What matters is the id that they carry,
So what values is not the persons word, but rather the word of the person(s) who own(s) the building. Much like a physical Id the owner needs to produce an item proving that someone is granted access.
This can simply be a peice of data that the source has a 0 resistance relationship with, then the Security trusting their employer they can see in a weighted step of 1 to prove that the
entrant is permited.

This also solves spam and scams. Spam is usually from sources who are usually several degrees of separation away from the recipient, currently they hide behind
poor evaluations from the recipient. Because blockchain requires that all users have a pk/sk then signing all messages becomes trivialy simple.
Meaining that an email can be linked to a source, and becaouse humans are naturally very good at thinking in degrees of separation it is much easier to see that an email came from
a source that is not the degrees of separation that they are familiar with.
Similarly it becomes easy to block spam messages without restricting messages from desired sources. Simply be blocking messages that have a weighted distance greater than any arbitrary value.
99% of people try to contact someone that they were in contact with personaly or 1/2 degrees of separation away from. Meaning that if a recipient receives a message with to high
of a degree of separation then it can automatically be ignored.

As well because the weight of each relationship can be manually configured it allows for setting relationships with large organizations and individual people.
Meaining that setting the resistance low enough can mean that someone can have a relationship with an individual person and then get mesages from people with a larger
degree of separation. Then with a large coperation the relationship can be configured with a high cost meaing that the person can have a relationship and receive
messages from the corperation, but the cost is too high for other people associated with the organization to message the recipient without the message being auto-disgarded.

Because trust is a pointer with a weight it also allows for a trusted source to cite another source and automattically be trusted by others who trust that organization.
If a organization creates a pointer with 0 resistance then the original creator can still have ownership, but to all who trust the organization now see the data as being one step closer.
This allows for trust and data to migrate in the same way that it does in a natural human society.

 */