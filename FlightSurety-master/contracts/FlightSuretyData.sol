pragma solidity >=0.4.25;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyData {

    event Funded (string ok, address ad);
    using SafeMath for uint256;

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    uint constant M = 5;
    address[] multiCalls = new address[](0);

    /** Multiparty Consensus counter */
    mapping(address => uint256) originAirline;


    address private contractOwner;                                      // Account used to deploy contract
    bool private operational = true;                                    // Blocks all state changes throughout the contract if false

    /** used for authorizeCaller */
    mapping(address => uint256) authorizedContracts;




    struct AirLine {
        // string id;
        bool isRegistered;
        bool isFund;
        uint256 fund;
        // bool isAdmin;
        // uint256 sales;
        // address wallet;
    }
    mapping(address => AirLine) airlines;

    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/


    /**
    * @dev Constructor
    *      The deploying account becomes contractOwner
    */
    constructor
                                (
                                    // address newAirline
                                )
                                public
    {
        contractOwner = msg.sender;
        airlines[contractOwner] = AirLine ({
            // id: 0,
            isRegistered: true,
            isFund: false,
            fund: 0
        });
    }

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "operational" boolean variable to be "true"
    *      This is used on all state changing functions to pause the contract in
    *      the event there is an issue that needs to be fixed
    */
    modifier requireIsOperational()
    {
        require(operational, "Contract is currently not operational");
        _;  // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner()
    {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    modifier isCallerAuthorized()
    {
        require(authorizedContracts[msg.sender] == 1, "Caller is not authorized");
        _;
    }

    function authorizeCaller(address dataContract) external requireContractOwner{
        authorizedContracts[dataContract] = 1;
    }

    function deauthorizeCaller(address dataContract) external requireContractOwner{
        delete authorizedContracts[dataContract];
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    /**
    * @dev Get operating status of contract
    *
    * @return A bool that is the current operating status
    */
    function isOperational()
                            public
                            view
                            returns(bool)
    {
        return operational;
    }


    /**
    * @dev Sets contract operations on/off
    *
    * When operational mode is disabled, all write transactions except for this one will fail
    */
    function setOperatingStatus
                            (
                                bool mode
                            )
                            external
                            // requireContractOwner
    {
        operational = mode;
        // require(mode != operational, "New mode must be different from existing mode");
        // bool isDuplicate = false;
        // for (uint c = 0; c < multiCalls.length; c++) {
        //     if (multiCalls[c] == msg.sender) {
        //         isDuplicate = true;
        //         break;
        //     }
        // }
        // require(!isDuplicate, "Caller has already called this function.");
        // multiCalls.push(msg.sender);
        // if (multiCalls.length >= M) {
        //     // operational = mode;
        //     multiCalls = new address[](0);
        // }
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

    // function isAirline(address newAirline) external pure returns (bool){
    //     return false;
    // }

    function isAirline
                            (
                                address newAirline
                            )
                            external
                            view
                            returns (bool)
    {
        // return airlines[newAirline].isAirline;
        return airlines[newAirline].isFund;
        // return airlines[newAirline].fund == 0;
        // return false;
    }

   /**
    * @dev Add an airline to the registration queue
    *      Can only be called from FlightSuretyApp contract
    *
    */
    function registerAirline
                            (   address newAirline
                            )
                            external
                            // pure
                            requireIsOperational
                            requireContractOwner
    {
        require(airlines[msg.sender].isRegistered, "Only existing airline may register a new airline.");
        require(!airlines[newAirline].isRegistered, "Airline is already registered.");
        originAirline[msg.sender] = originAirline[msg.sender].add(1);
        airlines[newAirline] = AirLine ({
            // id: 0,
            isRegistered: true,
            isFund: false,
            fund: 0
        });
    }


   /**
    * @dev Buy insurance for a flight
    *
    */
    function buy
                            (
                            )
                            external
                            payable
    {

    }

    /**
     *  @dev Credits payouts to insurees
    */
    function creditInsurees
                                (
                                )
                                external
                                pure
    {
    }

    /**
     *  @dev Transfers eligible payout funds to insuree
     *
    */
    function pay
                            (
                            )
                            external
                            pure
    {
    }

   /**
    * @dev Initial funding for the insurance. Unless there are too many delayed flights
    *      resulting in insurance payouts, the contract should be self-sustaining
    *
    */
    function fund
                            (
                                // address newAirline
                            )
                            public
                            payable
    {
        // require(airlines[msg.sender].isRegistered, "airLine has to be register before using");
        // require(!airlines[msg.sender].isFund, "the airline is already funded");
        airlines[msg.sender].isFund = true;
        airlines[msg.sender].fund = 10 ether;
        // msg.sender.transfer(0 ether);
        emit Funded('founded', msg.sender);
    }

    function getFlightKey
                        (
                            address airline,
                            string memory flight,
                            uint256 timestamp
                        )
                        pure
                        internal
                        returns(bytes32)
    {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    /**
    * @dev Fallback function for funding smart contract.
    *
    */
    function()
                            external
                            payable
    {
        fund();
    }


}

