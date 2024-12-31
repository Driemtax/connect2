# Connect2

## Add Test Contacts to your emulator.
To add the provided Test Contacts to the default Android Contacts App do the following steps:
1. Start your emulator
2. In your Terminal type 'adb devices'. You should see a list with one or more active emulators
3. cd into connect2
4. In your Terminal type 'adb push test_contacts.vcf /sdcard/Download/
'. 
5. In the emulator go to the Contacts App. Go to 'Fix&Manage', then to 'Import from file' and select the test_contacts.vcf

Now your emulator has 10 Test Contacts that you can import to connect2. Have fun!