int sensorPin = 0; //analog pin 0

int d0 = 0;
int d1 = 1;
int d2 = 2;
int d3 = 3;

void setup(){

}

void loop(){
  int val = analogRead(sensorPin) / 64;
  pinMode(d0, OUTPUT);
  pinMode(d1, OUTPUT);
  pinMode(d2, OUTPUT);
  pinMode(d3, OUTPUT);
  
  digitalWrite(d0, HIGH && (val & B00000001));
  digitalWrite(d1, HIGH && (val & B00000010));
  digitalWrite(d2, HIGH && (val & B00000100));
  digitalWrite(d3, HIGH && (val & B00001000));

  //just to slow down the output
  delay(100);
}
