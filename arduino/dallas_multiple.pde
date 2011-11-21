#include <OneWire.h>
#include <DallasTemperature.h>

// Data wire is plugged into port 2 on the Arduino
#define ONE_WIRE_BUS 8
#define TEMPERATURE_PRECISION 9

// Setup a oneWire instance to communicate with any OneWire devices (not just Maxim/Dallas temperature ICs)
OneWire oneWire(ONE_WIRE_BUS);

// Pass our oneWire reference to Dallas Temperature. 
DallasTemperature sensors(&oneWire);

// arrays to hold device addresses
DeviceAddress temp1, temp2 , temp3, temp4 , temp5, temp6;


const int relay1_pin =  9;     
const int status_led_pin = 13;

int relay1_state;             
int status_led_state = LOW;

const int DELAY = 30000;



void setup(void)
{
  


  pinMode(relay1_pin, OUTPUT);
  pinMode(status_led_pin, OUTPUT);
  
  // start serial port
  Serial.begin(9600);
  
  Serial.println("INIT");

  // Start up the library
  sensors.begin();

  // locate devices on the bus
  Serial.print("Locating devices...");
  Serial.print("Found ");
  Serial.print(sensors.getDeviceCount(), DEC);
  Serial.println(" devices.");

  // report parasite power requirements
  Serial.print("Parasite power is: "); 
  if (sensors.isParasitePowerMode()) Serial.println("ON");
  else Serial.println("OFF");

  // assign address manually.  the addresses below will beed to be changed
  // to valid device addresses on your bus.  device address can be retrieved
  // by using either oneWire.search(deviceAddress) or individually via
  // sensors.getAddress(deviceAddress, index)
  //insideThermometer = { 0x28, 0x1D, 0x39, 0x31, 0x2, 0x0, 0x0, 0xF0 };
  //outsideThermometer   = { 0x28, 0x3F, 0x1C, 0x31, 0x2, 0x0, 0x0, 0x2 };

  // search for devices on the bus and assign based on an index.  ideally,
  // you would do this to initially discover addresses on the bus and then 
  // use those addresses and manually assign them (see above) once you know 
  // the devices on your bus (and assuming they don't change).
  // 
  // method 1: by index
  if (!sensors.getAddress(temp1, 0)) Serial.println("Unable to find address for Device 0"); 
  if (!sensors.getAddress(temp2, 1)) Serial.println("Unable to find address for Device 1"); 
  if (!sensors.getAddress(temp3, 2)) Serial.println("Unable to find address for Device 2"); 
  if (!sensors.getAddress(temp4, 3)) Serial.println("Unable to find address for Device 3"); 
  if (!sensors.getAddress(temp5, 4)) Serial.println("Unable to find address for Device 4"); 
  if (!sensors.getAddress(temp6, 5)) Serial.println("Unable to find address for Device 5"); 

  // method 2: search()
  // search() looks for the next device. Returns 1 if a new address has been
  // returned. A zero might mean that the bus is shorted, there are no devices, 
  // or you have already retrieved all of them.  It might be a good idea to 
  // check the CRC to make sure you didn't get garbage.  The order is 
  // deterministic. You will always get the same devices in the same order
  //
  // Must be called before search()
  //oneWire.reset_search();
  // assigns the first address found to insideThermometer
  //if (!oneWire.search(insideThermometer)) Serial.println("Unable to find address for insideThermometer");
  // assigns the seconds address found to outsideThermometer
  //if (!oneWire.search(outsideThermometer)) Serial.println("Unable to find address for outsideThermometer");

  // show the addresses we found on the bus
  Serial.print("Device 0 Address: ");
  printAddress(temp1);
  Serial.println();

  Serial.print("Device 1 Address: ");
  printAddress(temp2);
  Serial.println();
  
  Serial.print("Device 2 Address: ");
  printAddress(temp3);
  Serial.println();
  
  Serial.print("Device 3 Address: ");
  printAddress(temp4);
  Serial.println();
  
  Serial.print("Device 4 Address: ");
  printAddress(temp5);
  Serial.println();
  
  Serial.print("Device 5 Address: ");
  printAddress(temp6);
  Serial.println();
  


  // set the resolution to 9 bit
  sensors.setResolution(temp1, 12);
  sensors.setResolution(temp2, 12);
  sensors.setResolution(temp3, 12);
  sensors.setResolution(temp4, 12);
  sensors.setResolution(temp5, 12);
  sensors.setResolution(temp6, 12);

  Serial.print("Device 0 Resolution: ");
  Serial.print(sensors.getResolution(temp1), DEC); 
  Serial.println();

  Serial.print("Device 1 Resolution: ");
  Serial.print(sensors.getResolution(temp2), DEC); 
  Serial.println();
  
  Serial.print("Device 2 Resolution: ");
  Serial.print(sensors.getResolution(temp3), DEC); 
  Serial.println();
  
  Serial.print("Device 3 Resolution: ");
  Serial.print(sensors.getResolution(temp4), DEC); 
  Serial.println();
  
  Serial.print("Device 4 Resolution: ");
  Serial.print(sensors.getResolution(temp5), DEC); 
  Serial.println();
  
  Serial.print("Device 5 Resolution: ");
  Serial.print(sensors.getResolution(temp6), DEC); 
  Serial.println();
  Serial.print("INITEND");
}

// function to print a device address
void printAddress(DeviceAddress deviceAddress)
{
  for (uint8_t i = 0; i < 8; i++)
  {
    // zero pad the address if necessary
    if (deviceAddress[i] < 16) Serial.print("0");
    Serial.print(deviceAddress[i], HEX);
  }
}

// function to print the temperature for a device
void printTemperature(DeviceAddress deviceAddress)
{
  float tempC = sensors.getTempC(deviceAddress);

  //Serial.print(" Temp F: ");
  //Serial.print(DallasTemperature::toFahrenheit(tempC));
  Serial.print("T: ");
  Serial.print(tempC);
}

// function to print a device's resolution
void printResolution(DeviceAddress deviceAddress)
{
  Serial.print("Resolution: ");
  Serial.print(sensors.getResolution(deviceAddress));
  Serial.println();    
}

// main function to print information about a device
void printData(DeviceAddress deviceAddress)
{
  Serial.print("A:");
  printAddress(deviceAddress);
  Serial.print(",");
  printTemperature(deviceAddress);
  Serial.println();
}










//delay(1000);

void loop(void)
{ 
 

  // call sensors.requestTemperatures() to issue a global temperature 
  // request to all devices on the bus
  Serial.println();
  Serial.print("Requesting temperatures...");
  sensors.requestTemperatures();
  Serial.println();
  Serial.println("DATA");
   
   // print the device information
  //Serial.println();
  

  printData(temp1);
  printData(temp2);
  printData(temp3);
  printData(temp4);
  printData(temp5);
  printData(temp6);
  Serial.println("ENDDATA");  
  //printData(temp5);
  
  float temp1_reading = sensors.getTempC(temp1);
  Serial.print("Temp1 reading : ");  
  Serial.print(temp1_reading);
  Serial.print(" ");  
  
  if (temp1_reading > 30.0) {
    relay1_state = LOW;
      Serial.print("temp1 > 30 , so heating is OFF");  
      Serial.println(); 
  
  }
  else {
    relay1_state = HIGH;
      Serial.print("temp1 < 30, so heating is ON");  
      Serial.println(); 
  
  }
  //digitalWrite(relay1_pin, relay1_state);
  
// relay1_state = HIGH;
//status_led_state = HIGH;
//digitalWrite(relay1_pin, relay1_state);
//digitalWrite(status_led_pin,status_led_state);






  Serial.println("DELAY:");
  Serial.print(DELAY);
  //for printing
  delay(50);
  delay(DELAY);
//relay1_state = LOW;
//status_led_state = LOW;

//digitalWrite(relay1_pin, relay1_state);

//digitalWrite(status_led_pin,status_led_state);
//delay(10000);
}

