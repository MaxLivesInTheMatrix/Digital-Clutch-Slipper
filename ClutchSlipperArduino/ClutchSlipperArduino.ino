int led_pin = 13;
const int buttonPin =2;
boolean buttonState = LOW; // Clutch Switch State Init
boolean laststate = HIGH; // last state Init
ReleaseDelay = 0; //Release Delay Init
HoldDelay = 0; //Hold Delay Init


void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600); //Universal Baud Rate

  pinMode(7, OUTPUT); // Output pin to solenoid
  pinMode(2, INPUT);  // Clutch switch input pin
  pinMode(4, INPUT);  // Launch mode ON/OFF signal TO BE REPLACED BY IOS APP ON/OFF BUTTON

}

void LAUNCH()
{
  delay(500);            //Initial delay for clutch pedal position... Needs to be an input from my iPhone App
  digitalWrite(7, HIGH); // Enables line lock solenoid
  delay(800);            // HOLD time for clutch and solenoid... Needs to be an input from my iPhone App
  digitalWrite(7, LOW);  //Deavtivate linelock solenoid
}

void loop() {
  // put your main code here, to run repeatedly:
buttonState = digitalRead(2); // Check to see if clutch is pressed down all the way
if(buttonState != laststate && digitalRead(4) == LOW) //if this is a new launch AND launch mode is active, Essentially: is the clutch pedal depressed and launch mode active?
{
  if (buttonState == HIGH) //Detects the moment the clutch is released from the ground. ie. State Change
  {
    LAUNCH(); // Begin the launch procedure
  }
  delay(50); // Add in a debounce to debounce button
}
laststate = buttonState; //Update laststate with buttonState

}