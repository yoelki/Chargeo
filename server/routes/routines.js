var express = require('express');
var router = express.Router();
var mongoose = require('mongoose');
var routine = require('../models/routineSchema');
const axios = require('axios').default;
const serverRoutinesURL = (process.env.REACT_APP_SERVER || "http://localhost:8000/") + "vehicle";
var destination = {name: 'denver+colorado'};
var batteryLevel = .99;
var originLoc;
/* GET specific routine. */
router.get("/route", async (request, response) => {
  var fuel;
  var closestStation;
  var closestStations;
  var api_key = 'ec9R9wRyNs22wNF0qdZS1maHHhUfa4fZ2fUcn0tU';



  // since batteryLevel's are randomized, for demo make sure they are below 30%
  // var batteryLevel = fuel.data.percentRemaining;
  if(!originLoc) {
    try {
      originLoc = await axios.get(serverRoutinesURL + '/location');
      console.log(originLoc.data);
    } catch {
      console.log(error);
    }
  }

  if(batteryLevel < .3) {
    try {
      var radius = 20;
      while(closestStation == null) {
        console.log('https://developer.nrel.gov/api/alt-fuel-stations/v1/nearest.json?api_key='+api_key+'&latitude='+originLoc.data.latitude+'&longitude='+originLoc.data.longitude+'&radius='+radius+'&ev_charging_level');
        closestStations = await axios.get('https://developer.nrel.gov/api/alt-fuel-stations/v1/nearest.json?api_key='+api_key+'&latitude='+originLoc.data.latitude+'&longitude='+originLoc.data.longitude+'&radius='+radius+'&fuel_type=ELEC');
        closestStation = closestStations.data.fuel_stations[0];
        radius+=5;
      }
      console.log(radius);
      console.log(closestStations.data.fuel_stations[0]);
    } catch {
      console.log(error);
    }
    var origin = '&origin='+originLoc.data.latitude+','+originLoc.data.longitude;
    var gasWayPoint = '&waypoints='+closestStation.latitude+','+closestStation.longitude;
    var finalDestination = '&destination='+destination.name;
    var maplink = 'https://www.google.com/maps/dir/?api=1'+origin+gasWayPoint+finalDestination;

    var returnObject = {
      "ev_dc_fast_num": closestStation.ev_dc_fast_num,
      "ev_level1_evse_num": closestStation.ev_level1_evse_num,
      "ev_level2_evse_num": closestStation.ev_level2_evse_num,
      "ev_network": closestStation.ev_network,
      "ev_pricing": closestStation.ev_pricing,
      "maplink": maplink
    };

    response.send(returnObject);
    console.log(returnObject);

  } else {
    var origin = '&origin='+originLoc.data.latitude+','+originLoc.data.longitude;
    var finalDestination = '&destination='+destination.name;
    var maplink = 'https://www.google.com/maps/dir/?api=1'+origin+finalDestination;

    var returnObject = {
      "ev_dc_fast_num": null,
      "ev_level1_evse_num": null,
      "ev_level2_evse_num": null,
      "ev_network": null,
      "ev_pricing": null,
      "maplink": maplink
    };

    response.send(returnObject);
    console.log(returnObject);
  }



  // console.log(location.data.latitude);
  // console.log(location.data.longitude);

});

// router.get("/map", async (request, response) => {
//   var location;
//   var fuel;
//   var closestStation;
//   var closestStations;
//   var api_key = 'ec9R9wRyNs22wNF0qdZS1maHHhUfa4fZ2fUcn0tU';
//
//   try {
//     location = await axios.get(serverRoutinesURL + '/location');
//     console.log(location.data);
//   } catch {
//     console.log(error);
//   }
//
//   try {
//     var radius = 20;
//     closestStations = 'https://api.plugshare.com/locations/nearby?latitude='+location.data.latitude+'&longitude='+location.data.longitude+'&count=1';
//     while(closestStation == null) {
//       closestStations = await axios.get('https://developer.nrel.gov/api/alt-fuel-stations/v1/nearest.json?api_key='+api_key+'&latitude='+location.data.latitude+'&longitude='+location.data.longitude+'&radius='+radius+'&ev_charging_level=all');
//       closestStation = closestStations.data.fuel_stations[0];
//       radius+=5;
//     }
//     console.log(radius);
//     console.log(closestStations.data.fuel_stations[0]);
//   } catch {
//     console.log(error);
//   }
//   var origin = '&origin='+location.data.latitude+','+location.data.longitude;
//   var gasWayPoint = '&waypoints='+closestStation.latitude+','+closestStation.longitude;
//   var finalDestination = '&destination='+destination;
//   var maplink = 'https://www.google.com/maps/dir/?api=1'+origin+gasWayPoint+finalDestination;
//
//   response.send(maplink);
//   console.log(maplink);
//   // console.log(location.data.latitude);
//   // console.log(location.data.longitude);
//
// });

router.get("/battery", async (request, response) => {
  var fuel;
  try {
    fuel = await axios.get(serverRoutinesURL + '/fuel');
    batteryLevel = fuel.data.percentRemaining;
    console.log(fuel.data.percentRemaining);
  } catch {
    console.log(error);
  }
  response.send(''+fuel.data.percentRemaining);
});

router.get("/destination", async (request, response) => {
  response.send(destination);
});

router.put("/destination/:dest", async (request, response) => {
    try {
        destination = {name: request.params.dest}
    } catch (error) {
        response.status(500).send(error);
    }
    console.log(destination);
    response.send(destination);

});

router.get("/batteryreroll", async (request, response) => {
  try {
    fuel = await axios.get(serverRoutinesURL + '/fuel');
    batteryLevel = fuel.data.percentRemaining;
    console.log(fuel.data.percentRemaining);
  } catch {
    console.log(error);
  }
  batteryLevel = fuel.data.percentRemaining < .3 ? fuel.data.percentRemaining : (Math.random() * (+.29 - + .21) + + .21).toFixed(2);
  batteryLevel = batteryLevel < .15 ? batteryLevel += .1 : batteryLevel;
  response.send(''+batteryLevel);
});

router.get("/battery20", async (request, response) => {
  batteryLevel = .2;
  response.send(''+batteryLevel);
});

router.get("/locationreroll", async (request, response) => {
  try {
    originLoc = await axios.get(serverRoutinesURL + '/location');
    console.log(originLoc.data);
  } catch {
    console.log(error);
  }
  response.send(originLoc.data);
});
module.exports = router;
