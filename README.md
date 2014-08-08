sensible-opensense-collector
============================

###To Build the Collector App

Prerequisites (OSX only):

  * xCode 4 or higher

  * iOS 7x

  * NodeJS

To build, you will need to create a new config.json file in OpenSense Collector/OpenSense Collector. Use these defaults:

```javascript
{
  "name": "awesome2",
  "version": 2,
  "dataUploadOnWifiOnly": true,
  "baseUrl": "http://localhost:4000/",
  "configUpdatePeriod": 21600,
  "dataArchivePeriod": 300,
  "dataUploadPeriod": 7200,
  "maxDataFileSizeKb": 1024,
  "dataRequests": {
    "battery": [
      {
        "interval": -1
      }
    ],
    "proximity": [
      {
        "interval": -1
      }
    ],
    "positioning": [
      {
        "interval": -1
      }
    ],
    "stepcounter": [
      {
        "interval": -1
      }
    ],
    "motion": [
      {
        "interval": -1,
        "frequency": 1800,
        "duration": 5,
        "updateInterval":0.02
      }
    ],
    "deviceinfo": [
      {
        "interval": -1,
        "frequency":10
      }
    ],
    "activitymanager": [
      {
        "interval": -1,
        "frequency": 15
      }
    ],
  }
}
```


Commands:

  node Server/server.js

  open OpenSense\ Collector/OpenSense\ Collector.xcodeproj


Notes on the probes:
================

Probes are grouped into two categories "OnChange" and "Periodic."  "OnChange" probes update only when the state of the device changes.  "Periodic" probes update at defined intervals based on their ```frequency``` double, as specified in config.json.

###OnChange:

  * Positioning

  * Battery

  * Proximity

###Periodic:

  * DeviceInfo

  * Activity

  * StepCounter

  * Motion

The ```OSMotionProbe``` is a special case in that it turns on and _remains_ on for a predefined period (```duration```).  During this period, it takes many data readings, at ```kMotionUpdateInterval``` frequency. As with other probes, ```frequency`` determines the length of time between when it starts taking samples. 

Think of it as filling up a cup of water.  You go ```frequency``` seconds between wanting water. When you start filling up your cup, the water flows at ```updateInterval``` units per second. After ```duration```, your cup is full, and you stop filling it. In ```frequency``` minus ```duration``` seconds, you will want water again.

Mathias Hansen - s093478 &lt;s093478@student.dtu.dk>

Al Carter - arcarter@mit.edu