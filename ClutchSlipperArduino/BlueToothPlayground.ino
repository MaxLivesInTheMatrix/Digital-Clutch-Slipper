#include <SoftwareSerial.h>

SoftwareSerial HM10(2, 3); // RX = 2, TX = 3
const byte numChars = 32;        
char receivedChars[numChars];    // an array to store the received data
char tempChars[numChars];        // temporary array for use when parsing

// variables to hold the parsed data
char messageFromPC[numChars] = {0};
int clutchDelay = 0;
int holdDelay = 0;
int armDisarm = 0;

char receivedChar;

int dataNumber = 0;             // Working with ints


boolean newData = false;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  Serial.println("HM10 serial started at 9600");
  //Serial.println("Enter data in this style <1,400,324>  ");

  HM10.begin(9600); // set HM10 serial at 9600 baud rate

}

void loop() {
  // put your main code here, to run repeatedly:
  HM10.listen();  // listen the HM10 port
  recvWithStartEndMarkers();
  //recvWithEndMarker();
  //recvOneChar();
  //showNewData();
  if (newData == true)
    {
      strcpy(tempChars, receivedChars);
          // this temporary copy is necessary to protect the original data
          //   because strtok() used in parseData() replaces the commas with \0
      parseData();
      showParsedData();
      newData = false;
    }
  //showNewNumber();
}

void recvOneChar() {
  if (HM10.available() > 0)
    {
      receivedChar = HM10.read();
      newData = true;
    }
}

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

void recvWithEndMarker() {
    static byte ndx = 0;
    char endMarker = '>';
    char rc;
    
    if (HM10.available() > 0) {
        rc = HM10.read();

        if (rc != endMarker) {
            receivedChars[ndx] = rc;
            ndx++;
            if (ndx >= numChars) {
                ndx = numChars - 1;
            }
        }
        else {
            receivedChars[ndx] = '\0'; // terminate the string
            ndx = 0;
            newData = true;
        }
    }
}

void showNewData(){
  if (newData == true) 
    {
      Serial.print("This just in: ");
      Serial.println(receivedChars);
      newData = false;
    }
}

void showNewNumber() {
    if (newData == true) {
        dataNumber = 0;             // new for this version
        dataNumber = atoi(receivedChars);   // new for this version
        Serial.print("This just in: ");
        Serial.println(receivedChars);
        Serial.print("Data as Number: ");    // new for this version
        Serial.println(dataNumber);     // new for this version
        newData = false;
    }
}

void showParsedData() {
    Serial.print("Armed? ");
    Serial.println(armDisarm);
    Serial.print("Clutch Delay: ");
    Serial.println(clutchDelay);
    Serial.print("Hold Delay: ");
    Serial.println(holdDelay);
}