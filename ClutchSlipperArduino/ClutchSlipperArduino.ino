#include "Arduino.h"
#include <SoftwareSerial.h>

SoftwareSerial HM10(2, 3);      // RX = 2, TX = 3
const byte numChars = 32;       // 32 character maximum
char receivedChars[numChars];   // an array to store the received data
char tempChars[numChars];       // temporary array for use when 
boolean newData = false;


int clutchDelay = 0;            // The clutch enable delay
int holdDelay = 0;              // The clutch hold delay
int armDisarm = 0;              // The ARM/Disarm switch

const int buttonPin =4;
boolean buttonState = LOW;      // Clutch Switch State Init
boolean laststate = HIGH;       // last state Init



void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600); //Universal Baud Rate
  HM10.begin(9600);   // set HM10 serial at 9600 baud rate
  pinMode(7, OUTPUT); // Output pin to solenoid
  pinMode(4, INPUT);  // Clutch switch input pin
  digitalWrite(4, HIGH); //Turn on pullup resistors
  pinMode(LED_BUILTIN, OUTPUT);
  Serial.println("Connected");

}

void LAUNCH()
{
  delay(clutchDelay);         //Initial delay for clutch pedal position... Needs to be an input from my iPhone App
  digitalWrite(LED_BUILTIN, HIGH);
  digitalWrite(7, HIGH);      // Enables line lock solenoid
  delay(holdDelay);           // HOLD time for clutch and solenoid... Needs to be an input from my iPhone App
  digitalWrite(LED_BUILTIN, LOW);
  digitalWrite(7, LOW);       //Deavtivate linelock solenoid
  armDisarm = 0;              // Launch is complete, disable until user reenables via app
  Serial.println("Launch Complete");
}

void loop() {

  HM10.listen();              // listen the HM10 port
  recvWithStartEndMarkers();  

  if (newData == true)
  {
    strcpy(tempChars, receivedChars);
        // this temporary copy is necessary to protect the original data
        //   because strtok() used in parseData() replaces the commas with \0
    parseData();
    showParsedData();
    newData = false;
  }


  // put your main code here, to run repeatedly:
  buttonState = digitalRead(4); // Check to see if clutch is pressed down all the way, this is hardware
  if(buttonState != laststate && armDisarm == 1) //if this is a new launch AND launch mode is active, Essentially: is the clutch pedal depressed and launch mode active/we are armed?
  {
   if (buttonState == HIGH) //Detects the moment the clutch is released from the ground. ie. State Change
   {
    LAUNCH(); // Begin the launch procedure
    }
    delay(50); // Add in a debounce to debounce button
  }
  laststate = buttonState; //Update laststate with buttonState

}


// This function is able to recognize the start and end of a bluetooth transmission using < to start and > to end. Every BT message sent through 
// the ios app will need to be in the format:  < 1, 500, 1000 > 
void recvWithStartEndMarkers() {
    static boolean recvInProgress = false;
    static byte ndx = 0;
    char startMarker = '<';
    char endMarker = '>';
    char rc;
 
    while (HM10.available() > 0 && newData == false) {
        rc = HM10.read();

        if (recvInProgress == true) {
            if (rc != endMarker) {
                receivedChars[ndx] = rc;
                ndx++;
                if (ndx >= numChars) {
                    ndx = numChars - 1;
                }
            }
            else {
                receivedChars[ndx] = '\0'; // terminate the string
                recvInProgress = false;
                ndx = 0;
                newData = true;
            }
        }

        else if (rc == startMarker) {
            recvInProgress = true;
        }
    }
}

// This funciton is used to show the parsed data recieved
void showParsedData() {
    Serial.print("Armed? ");
    Serial.println(armDisarm);
    Serial.print("Clutch Delay: ");
    Serial.println(clutchDelay);
    Serial.print("Hold Delay: ");
    Serial.println(holdDelay);
}


// This function parses the input data and also has some protections making sure the user does not blow up their vehicle by accident
void parseData() {      
    char *strtokIndx; // this is used by strtok() as an index

    strtokIndx = strtok(tempChars, ","); // get the first part - the ARM/Disarm
    if (strtokIndx != NULL) {
        armDisarm = atoi(strtokIndx); // convert this part to an integer
        if (armDisarm != 1 && armDisarm !=0) // Protection if somehow arm/disarm is not equal to 1 or 0
        {
          armDisarm = 0;
        }
        
        strtokIndx = strtok(NULL, ","); // move to the next token
        if (strtokIndx != NULL) {
            clutchDelay = atoi(strtokIndx); // convert this part to an integer
            if (clutchDelay > 1500) // No Clutch will ever take 1500 ms to return back home
            {
              armDisarm = 0;
            }

            strtokIndx = strtok(NULL, ","); // move to the next token
            if (strtokIndx != NULL) {
                holdDelay = atoi(strtokIndx); // convert this part to an integer
                if (holdDelay > 3000) // You should not be slipping for more that 3 seconds. You'll burn up the clutch
                {
                  armDisarm = 0;
                }
            }
        }
    }
}