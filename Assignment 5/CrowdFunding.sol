// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CrowdFunding {
    // Creating a New Campain With Necessary Details
    struct Campain{
        address owner;
        uint Target;
        mapping (address => uint ) Donators;
        uint deadline;
        uint collection;
        bool End;
    }
    // MApping all Cmapains with A ID to find the campain
    mapping (uint256 => Campain) Campains;
    uint256 totalCampains =0;

    // Modifier to check the Campain is Finalize or not
    modifier notFinalized (uint256 campainId){
        require(!Campains[campainId].End,"Campain has Ended");
        _;
    }

    // Modifier to check user is the creater of modifier or not
    modifier OwnerOnly(uint _campainId){
        require(Campains[_campainId].owner == msg.sender,"You are not the Creator of this Campain");
        _;
    }
    

    // create a campain
    function createCampain(uint _targetAmount, uint _Time) external  returns(uint256){
        // Basic reqirement for campain like target and time must be greater then zero
        require(_targetAmount>0,"Amount Should be more then 0");
        require(_Time>0,"TIme shoud be more then 0");

        // incremanenting campain counter and Intializing A campain
        ++totalCampains;    
        Campain storage newCampain = Campains [totalCampains] ;
        newCampain.owner =msg.sender;
        newCampain.Target = _targetAmount; 
        newCampain.deadline = block.timestamp+_Time;
        newCampain.End = false;
        return totalCampains;
    }

    // to donate in the campain

    function Donate(uint _campainId) external payable notFinalized(_campainId){
        // Accesing the campain 
        Campain storage campain = Campains[_campainId];
        // checking if there is time and funds are greter then 0
        require(campain.deadline>block.timestamp,"Campain Has Ended");
        require(msg.value>0,"Please Donate batter then 0");
        // incresing the value of total fund and recording it in the Donators
        campain.Donators[msg.sender] +=msg.value;
        campain.collection+=msg.value;
    }

    // To finalize the Campain
    function FinalizeTheCampain(uint _campainId)external OwnerOnly(_campainId) notFinalized(_campainId){
        Campain storage campain = Campains[_campainId];
        require(block.timestamp>campain.deadline,"There is still time");
        // if times up then changing end to true
        campain.End = true;
        // cheking if we achive the target 
        if(campain.collection>= campain.Target){
            // if we achive transfer the fund to the owener of campain
            payable (campain.owner).transfer(campain.collection);
        }
    }   
    // withdrawl function
    function WithdrawFunds(uint _campainId)external notFinalized(_campainId){
        Campain storage campain = Campains[_campainId];
        //checking if time is up and funds are lower then trarget
        require(block.timestamp >= campain.deadline, "Campaign is still ongoing");
        require(campain.collection < campain.Target, "Campaign target met");
        //geting the amout the user has donated
        uint256 amount = campain.Donators[msg.sender];
        // checking id amount is bigger then Zero  
        require(amount > 0, "No contributions to withdraw");
        // assigning zero to the withdrowal account
        campain.Donators[msg.sender] = 0;
        // Refunding the account the amount
        payable(msg.sender).transfer(amount);

    }

}