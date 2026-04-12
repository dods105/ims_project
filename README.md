# INVENTORY MANAGEMENT SYSTEM

whats currently done:
- Authentication (Login and Signup w/ database)

To be done:

GUI and Logic and DB
- Adding form
- Inventory
- Purchase
- History / Trasaction
- Settings

---

## install Android Studio Command Line Tools

link: https://developer.android.com/studio?gclsrc=aw.ds&gad_source=1&gad_campaignid=21831783729&gbraid=0AAAAAC-IOZko-Nn0nwFvRup1UObpuiSSs&gclid=CjwKCAjw4ufOBhBkEiwAfuC7-dNE5aFnlNBTIz7IPrRdRx4D-VC7usIV_WhFtbXqcnEe6-WwvMu2jRoCC9EQAvD_BwE


*Note: scroll niyo nalang pababa, hanggang sa makita niyo. Btw, if naka install na kayo ng android studio, ang alam ko is may kasama na rin don yung CMD tools*

Once you've installed it:
- Create a folder named AndroidSDK (C:\AndroidSDK).
- Inside it, create a folder named cmdline-tools.
- Inside cmdline-tools, create a folder named latest.
- unzip the Android Studio CMD tools
- Move all the files into that latest folder.
- Verify if the path must look like this: C:\AndroidSDK\cmdline-tools\latest\bin\sdkmanager.bat


Go to ``` edit system and environment variables``` in your laptop/PC
click ```Environment Variables```


- Under __*System variables*__, 
- click __*New*__
- type ```ANDROID_HOME``` under __*Variable Value*__ and under __*variable value*__, type: ```C:\AndroidSDK``` (or where ever your AndroidSDK folder is located)
- Click Ok
Still, under System Variables, find PATH (or Path)
add these the following:
``` 
    %ANDROID_HOME%\cmdline-tools\latest\bin
    %ANDROID_HOME%\platform-tools
    %ANDROID_HOME%\emulator
```

-----
## download JDK-17 or JDK-21 in adoptium.net
- link (version 17): https://adoptium.net/temurin/releases/?version=17
- link (v21): https://adoptium.net/temurin/releases/?version=21&os=any&arch=any

During Installation, to check the boxes for, click 'Will be installed on local hard drive' for each of the following: 
- Modify PATH variable
- Set JAVA_HOME variable
- JavaSoft Oracle registry keys
- Associate.jar
----
- open CMD, 
- then type: java -version
- make sure it says: ```openjdk version "17.0.18" 2026-01-20```
-----
open Command Prompt as Admin, then type the following:
1. Go to your bin folder
```cd C:\AndroidSDK\cmdline-tools\latest\bin```
2. Install Platform-Tools
```sdkmanager "platform-tools"```
3. Install Build-Tools
```sdkmanager "build-tools;34.0.0"```
4. Install the Android Platform
```sdkmanager "platforms;android-34"```
5. Link Flutter to your the AndroidSDK
```flutter config --android-sdk C:\AndroidSDK```
6. Accept the Licenses
```flutter doctor --android-licenses```
(Note: Press y and Enter for until it says: "All SDK package licenses accepted.")
7. run ```flutter doctor```

------
**(note: if may error, kapag or hindi lahat checked yung results sa flutter doctor, try going to CMD again. tapos try nyo type to:)**

- cd C:\AndroidSDK\cmdline-tools\latest\bin
- sdkmanager "platforms;android-36"
- sdkmanager "build-tools;28.0.3"
(If it asks for a license again, just hit y and Enter until "All SDK package license accepted")
- flutter doctor
-----
### this should be the result when you run flutter doctor
![](assets/instruction/flutter_doctor.png)
-------------
## To my dear classmates:

fork this repository and make a local copy on your laptop/PC

After you have this on your local storage: 
to run the app in debug mode: open the project on VSCode then open terminal using ```CTRL + SHIFT + ~```. Then connect your phone to your Laptop via USB. Make sure you turned on the ```Developer Mode``` go to ```Developer Options``` turn on ```USB debugging``` and turn on ```Install via USB```

After you've done that, go back in your vscode terminal and type ```flutter pub get``` once this finished, type ```flutter run```

Turn on your laptop wifi, as it will download the project packages needed for running the debug session in your phone. Wait for a while. Once it finished downloading and setting up the downloads, a pop up alert will show on your phone. It will ask you whether you want to install the apk package on your phone. Click ok or confirm.

Once the app has been installed, you can then make changes in the app while on debug mode. You can code then save the changes youve make using ```Ctrl + S``` then hit ```r``` on the terminal, the changes, shall be reflected in the app in your phone.

Once you have made changes and you can then commit it to github.

**Note:** 
    You dont have to turn on your Laptop's wifi every time you run the command ```flutter run```. But you need to turn it on if you are running this project for the very first time or if you have added a flutter package in the project.



