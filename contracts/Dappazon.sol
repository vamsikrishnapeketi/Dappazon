// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Dappazon {
    address public owner;

    struct Item {
        uint256 id;
        string name;
        string category;
        string image;
        uint256 cost;
        uint256 rating;
        uint256 stock; //like is there any stock of the item available or not
    }

    struct Order {
        uint256 time;
        Item item;
    }

    mapping(uint256 => Item) public items;
    mapping(address => uint256) public orderCount;
    mapping(address => mapping(uint256 => Order)) public orders;

    event List(string name, uint256 cost, uint256 quantity);
    event Buy(address buyer, uint256 orderId, uint256 itemId);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function list(
        uint256 id,
        string memory name,
        string memory category,
        string memory image,
        uint256 cost,
        uint256 rating,
        uint256 stock
    ) public onlyOwner {
        //public means anybody outside the smart contract can call this function

        Item memory item = Item(id, name, category, image, cost, rating, stock);

        items[id] = item;
        emit List(name, cost, stock);
    }

    function buy(uint256 id) public payable {
        //Fetching item
        Item memory item = items[id];

        require(msg.value >= item.cost);
        require(item.stock > 0);

        //creating a order
        Order memory order = Order(block.timestamp, item);

        //save order to chain
        orderCount[msg.sender]++;
        orders[msg.sender][orderCount[msg.sender]] = order;

        //subtract the stock
        items[id].stock = items[id].stock - 1;

        emit Buy(msg.sender, orderCount[msg.sender], item.id);
    }

    function withdraw() public onlyOwner {
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success);
    }
}
