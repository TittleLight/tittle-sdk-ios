# Tittle Framework

	Name: TittleFramework
	Version: 1.0
	Deployment Target: 10.3
	Devices: Universal


## Overview

	This is the firt vesion of the Tittle Light Framework.
	Tittle SDK allows you to set up, search and control Tittle lights.

This frmamework is using [CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket) for socket connections. Check it out if you want to know more.

## Installation

- Please download the Framework from [here](https://github.com/clarityhk/tittle-sdk-samples/tree/master/distribution)

- Simply drag the "TittleFramework.framework" to your poject in Xcode:

![drag_to_your_project](https://github.com/clarityhk/tittle-sdk-samples/blob/master/assets/ios/drag_to_your_project.png)

- In your app `TARGETS` -> your project -> `Build Phases`, add this `TittleFramework` in `Link Binary With Libraries` and `Embed Frameworks`

![link_library](https://github.com/clarityhk/tittle-sdk-samples/blob/master/assets/ios/link_library.png)

- import the Framework to the place you want to use it.

		import TittleFramework

That is it! You can now use this Framework to connect your TittleLight!

## Functions

	This framework currently has the following functions:

1. [Connect](#connect)
2. [Disconnect](#disconnect)
3. [Set Light Mode](#light_mode)
4. [Standard Config](#standard_config)
5. [Search Tittles](#search_tittles)



<span id="connect"></span>
### Connect

- Assume you know the ip of your Tittle. You can connect the Tittle as below:


		import TittleFramework

		let tittleLightCtrl = TittleLightControl()

		tittleLightCtrl.delegate = self

		connectToTittle(ip: "192.168.1.1")



		// MARK: TittleLightControl delegate

	    func socket(_ sock:GCDAsyncSocket, didConnectToHost host:String, port:UInt16) {
	        //add your code here. e.g showing connection status
	    }

	    func socketDidDisconnect(_ sock:GCDAsyncSocket, withError err:Error?) {
	        //add your code here.  e.g showing connection status
	    }


<span id="disconnect"></span>
### Disconnect

- In some cases you may need to disconnect the current Tittle connection. e.g disconnect when the current page disappear:

		override func viewWillDisappear(_ animated: Bool) {
	       super.viewWillDisappear(animated)
	       tittleLightCtrl.disconnectTittle()
	    }

<span id="light_mode"></span>
### Set Light Mode

Function to set the Tittle Light as light mode with color and intensity.
> We will add more features in the future.

	lightMode(withR: UInt8, g: UInt8, b: UInt8, intensity: UInt8)


| params    | type  | description     |
| --------- |:-----:| ---------------:|
| withR     | UInt8 | color RGB's R   |
| g         | UInt8 | color RGB's G   |
| b         | UInt8 | color RGB's B   |
| intensity | UInt8 | light intensity. range 0 - 255 |


	// Turn off
	tittleLightCtrl.lightMode(withR: colorR, g: colorG, b: colorB, intensity: intensity)

	// Turn on with color RGB = (25, 255, 255), intensity = 100
	tittleLightCtrl.lightMode(withR: 25, g: 255, b: 255, intensity: 100)



<span id="standard_config"></span>
### Standard Config

Tittle Light support Smart Config or standard config for wifi configuration. This Framework now only support Standard Config.

- Step 1. Switch the Tittle Light to AP mode.

	You need to do the following steps for your Tittle

	- Press and hold the power button for 5 seconds until your tittle blinks in white color then release.

	- Press and hold again the power button for 3 seconds until your tittle blinks in yellow.

	- Please go to the wifi setting in your phone and connect a network called "Tittle-AP".

- Step 2. Once your phone is connecting to "Tittle-AP", setup connection with this Tittle

		let tittleLightCtrl = TittleLightControl()

		tittleLightCtrl.delegate = self

		tittleLightCtrl.connectTittleForStandardConfig()

	    // delegate
	    func socket(_ sock:GCDAsyncSocket, didConnectToHost host:String, port:UInt16) {
	        DispatchQueue.main.async{
	            self.statusLabel.text = "Connected to Tittle"
	        }
	    }

	    func socketDidDisconnect(_ sock:GCDAsyncSocket, withError err:Error?) {
	        DispatchQueue.main.async{
	            self.statusLabel.text = "Please go to connect wifi 'Tittle-AP'"
	        }
	    }


- Step 3. If in Step 2 the connection is created successfully,  send the name and the password of the wifi network that you would like Tittle to connect with to the Tittle

		tittleLightCtrl.standardConfig(wifiName, password: password)

		// delegate
		func didReceivedResponsed(fromStandardConfigMode ackCode: Int32) 		{
        if (ackCode != TITTLE_ACK_SUCCESS) {
            DispatchQueue.main.async{
                //resend
                self.configTittle()
                self.statusLabel.text = "Re-sending data to Tittle"
            }
        }else {
            DispatchQueue.main.async{
                self.performSegue(withIdentifier: "ToVerifyConfigPage", sender: self)
            }
        }
    }

- Step 4. Once you got `TITTLE_ACK_SUCCESS` ackCode from the callback, it means the Tittle has already gotten the wifi credential and is trying to connect to the wifi.

	> At this point, you should see the Tittle starts blinking in Blue to Orange

	Your app should start the verify config proccess.

		tittleLightCtrl.verifyStandardConfig()

		// delegate
	    func standardConfigVerified(_ tittle: TittleData?) {
	        if tittle != nil {
	            self.tittle = tittle
	            self.confirmHintLabel.isHidden = false;
	            self.confirmButton.isHidden = false;
	        }
	    }

	 > If the Tittle succefully connected to the wifi, you will see it is blinking in Purple.

	  - There may be chance you sent the wrong wifi credential and the Tittle will not be able to connect the wifi. You may need to create timeout function or show alert to users asking them to double check the wifi credential.

- Step 5. If you got callback from `standardConfigVerified` and the return `TittleData` object is valid. You should confirm the config with the Tittle:
	- Please go to the wifi settings in your phone and connect to the network that your Tittle has connected to

	- After connected your phone with the wifi, confirm the config by passing the ip of the TittleData object you got

			tittleLightCtrl.confirmStandardConfig(self.tittle?.ip)

			//delegate
			func standardConfigDone(_ ackCode: Int32) {

    		}

> At this point, the process of Standard config is completed

<span id="search_tittles"></span>
### Search Tittles

If there are Tittles connected to your wifi, you can find them out.

	let tittleLightCtrl = TittleLightControl()

	tittleLightCtrl.delegate = self

	//Start searching
	tittleLightCtrl.startSearchingTittles()

	//delegate
	func receivedNewTittle(_ tittle: TittleData?) {
	 if tittle != nil {
	     self.tittles.append(tittle!)
	     self.tittleListTableView.reloadData()
	  }
	}

	// Stop searching
	tittleLightCtrl.stopSearchingTittles()

> After you found out a Tittle, you can connect with it via its IP and using the Light Mode function `lightMode`.
