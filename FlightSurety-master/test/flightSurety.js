
var Test = require('../config/testConfig.js');
var BigNumber = require('bignumber.js');

contract('Test Flight Surety Tests', async (accounts) => {

  var config;
  before('set-up contract', async () => {
    console.log('first step');
    config = await Test.Config(accounts);
   
    console.log('second step');
    await config.flightSuretyData.authorizeCaller(config.flightSuretyApp.address);
  });

  /****************************************************************************************/
  /* Operations and Settings                                                              */
  /****************************************************************************************/

  it(`(multiparty) has correct initial isOperational() value`, async function () {

    // Get operating status
    let status = await config.flightSuretyData.isOperational.call();
    console.log('the status is', status);
    assert.equal(status, true, "Incorrect initial operating status value");

  });

  it(`(multiparty) can block access to setOperatingStatus() for non-Contract Owner account`, async function () {

      // Ensure that access is denied for non-Contract Owner account
      let accessDenied = false;
      try 
      {
          await config.flightSuretyData.setOperatingStatus(false, { from: config.testAddresses[2] });
      }
      catch(e) {
          accessDenied = true;
      }
      assert.equal(accessDenied, true, "Access not restricted to Contract Owner");
            
  });

  it(`(multiparty) can allow access to setOperatingStatus() for Contract Owner account`, async function () {

      // Ensure that access is allowed for Contract Owner account
      let accessDenied = false;
      try 
      {
          await config.flightSuretyData.setOperatingStatus(false);
      }
      catch(e) {
          accessDenied = true;
      }
      assert.equal(accessDenied, false, "Access not restricted to Contract Owner");
      
  });

  it(`(multiparty) can block access to functions using requireIsOperational when operating status is false`, async function () {

      await config.flightSuretyData.setOperatingStatus(false);

      let reverted = false;
      try 
      {
          await config.flightSurety.setTestingMode(true);
      }
      catch(e) {
          reverted = true;
      }
      assert.equal(reverted, true, "Access not blocked for requireIsOperational");      

      // Set it back for other tests to work
      await config.flightSuretyData.setOperatingStatus(true);

  });

  it('(airline)- Airline Ante cannot register an Airline using registerAirline() if it is not funded', async () => {
    
    // ARRANGE
    let newAirline = accounts[2];

    // ACT
    try {
        await config.flightSuretyApp.registerAirline(newAirline, {from: config.firstAirline});
    }
    catch(e) {
        console.log('there is de', e.message);
    }
    let result = await config.flightSuretyData.isAirline.call(newAirline); 

    // ASSERT
    assert.equal(result, false, "Airline should not be able to register another airline if it hasn't provided funding");

  });

  it('(airline)- Airline Ante can register an Airline using registerAirline() if it is funded', async () => {
    
    // ARRANGE
    let newAirline = accounts[2];

    // ACT
    try {
        //{ from: config.testAddresses[2] }
        await config.flightSuretyApp.registerAirline(newAirline, {from: config.firstAirline});
        
    }
    catch(e) {
        // console.log(e);
        // console.log('there is eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee', e.message);
        
    }
    await config.flightSuretyData.fund({from: newAirline}); 
    let result = await config.flightSuretyData.isAirline.call(newAirline); 
    

    // ASSERT
    assert.equal(result, true, "Airline should not be able to register another airline if it hasn't provided funding");

  });

  it('(airline) M of N, in which M = 5', async () => {
    
    // ARRANGE
    let na1 = accounts[2];
    let na2 = accounts[3];
    let na3 = accounts[4];
    let na4 = accounts[5];
    let na5 = accounts[6];
    let na6 = accounts[7];

    // ACT
    try {
        for (var i = 2; i <=7; i++ ) {
            await config.flightSuretyApp.registerAirline(accounts[i], {from: config.firstAirline});
            // await config.flightSuretyApp.fund({from: accounts[i]});
        }
    }
    catch(e) {

    }
    // let result = await config.flightSuretyData.isAirline.call(na1); 
    for (var i = 2; i <=7; i++ ) {
        let result = await config.flightSuretyData.isAirline.call(accounts[i]); 
        console.log('index is', i, result);
        // assert.equal(result, true, "Airline should not be able to register another airline if it hasn't provided funding");
    }

    // ASSERT
    // assert.equal(result, true, "Airline should not be able to register another airline if it hasn't provided funding");

  });
 

});
