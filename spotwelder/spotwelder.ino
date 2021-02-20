const bool POWER_CONTROLL = false;

const int interruptPin = 2;
const int buttonPin = 4;
const int powerLedPin = 5;
const int weldLedPin = 6;
const int weldPin = 7;    
const int setWeldTimerPin = A0;
const int setWeldPoerPin = A1;

const int MIN_BRIGHTNERR = 5;
const int MAX_BRIGHTNERR = 255;

const int MIN_WELD_ON_MS = 8;
const int MAX_WELD_ON_MS = 1000;

const int MIN_WELD_DUTY = 8000;
const int MAX_WELD_DUTY = 0;

// Variables will change:
int buttonState;             // the current reading from the input pin
int lastButtonState = LOW;   // the previous reading from the input pin

// the following variables are unsigned longs because the time, measured in
// milliseconds, will quickly become a bigger number than can be stored in an int.
unsigned long lastDebounceTime = 0;  // the last time the output pin was toggled
unsigned long debounceDelay = 50;    // the debounce time; increase if the output flickers

int weldOnTimer = 0;
int weldPower = 0;

void setup() {
  pinMode(buttonPin, INPUT);
  Serial.begin(9600);

  // set power on LED state
  pinMode(powerLedPin, OUTPUT);
  digitalWrite(powerLedPin, HIGH);
  pinMode(13, OUTPUT);
  digitalWrite(13, HIGH);

  pinMode(weldPin, OUTPUT);
  pinMode(weldLedPin, OUTPUT);
  setWeld(false);
}

void loop() {
  weldOnTimer = map(analogRead(setWeldTimerPin), 0, 1023, MIN_WELD_ON_MS, MAX_WELD_ON_MS);
  analogWrite(powerLedPin, map(weldOnTimer, MIN_WELD_ON_MS, MAX_WELD_ON_MS, MIN_BRIGHTNERR, MAX_BRIGHTNERR));
  weldPower = map(analogRead(setWeldPoerPin), 0, 1023, MIN_WELD_DUTY, MAX_WELD_DUTY);
  
  // read the state of the switch into a local variable:
  int reading = digitalRead(buttonPin);

  // check to see if you just pressed the button
  // (i.e. the input went from LOW to HIGH), and you've waited long enough
  // since the last press to ignore any noise:

  // If the switch changed, due to noise or pressing:
  if (reading != lastButtonState) {
    // reset the debouncing timer
    lastDebounceTime = millis();
  }

  if ((millis() - lastDebounceTime) > debounceDelay) {
    // whatever the reading is at, it's been there for longer than the debounce
    // delay, so take it as the actual current state:

    // if the button state has changed:
    if (reading != buttonState) {
      buttonState = reading;

      // only toggle the LED if the new button state is HIGH
      if (buttonState == HIGH) {
        Serial.println(weldOnTimer);
        doWeld();
      }
    }
  }


  // save the reading. Next time through the loop, it'll be the lastButtonState:
  lastButtonState = reading;
}

void doWeld() {
  setWeld(true);
  Serial.println("welding on");
  Serial.println(weldOnTimer);
  Serial.println(weldPower);
  delay(weldOnTimer);
  setWeld(false);
  Serial.println("welding off");
}

void setWeld(bool state) {
  if (state) {
    digitalWrite(weldLedPin, HIGH);
    digitalWrite(powerLedPin, LOW);
	if (POWER_CONTROLL) {
      attachInterrupt(digitalPinToInterrupt(interruptPin), zeroCrossing, RISING);
    } else {
      digitalWrite(weldPin, HIGH);
    }
  } else {
    detachInterrupt(digitalPinToInterrupt(interruptPin));
    digitalWrite(weldPin, LOW); //make sure triac is off
    digitalWrite(weldLedPin, LOW);
    digitalWrite(powerLedPin, HIGH);
  }
}

void zeroCrossing() {
  Serial.println("interupt");

  delayMicroseconds(weldPower);
  digitalWrite(weldPin, HIGH);
  delayMicroseconds(200);  
  // delay 200 uSec on output pulse to turn on triac
  digitalWrite(weldPin, LOW);
}
