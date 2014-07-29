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
    "dk.dtu.imm.sensible.battery": [
      {
        "interval": -1
      }
    ],
    "dk.dtu.imm.sensible.proximity": [
      {
        "interval": -1
      }
    ],
    "dk.dtu.imm.sensible.positioning": [
      {
        "interval": -1
      }
    ],
  }
}
```


Commands:

	node Server/server.js

	open OpenSense\ Collector/OpenSense\ Collector.xcodeproj


Mathias Hansen - s093478 &lt;s093478@student.dtu.dk>