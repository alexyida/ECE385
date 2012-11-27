int sensorPin = 0; //analog pin 0

int d0 = 0;
int d1 = 1;
int d2 = 2;
int d3 = 3;

int d4 = 4;

int BUZZER = 11;

void setup(){
    pinMode(d0, OUTPUT);
    pinMode(d1, OUTPUT);
    pinMode(d2, OUTPUT);
    pinMode(d3, OUTPUT);
    pinMode(d4, OUTPUT);
    pinMode(BUZZER, OUTPUT);
}

void loop(){
    digitalWrite(d4, HIGH);
    int val = analogRead(sensorPin) / 64;
  
    digitalWrite(d0, HIGH && (val & B00000001));
    digitalWrite(d1, HIGH && (val & B00000010));
    digitalWrite(d2, HIGH && (val & B00000100));
    digitalWrite(d3, HIGH && (val & B00001000));
    
    digitalWrite(d4, LOW);
    
    buzzer(val);

    //just to slow down the output
    delay(100);
}

void buzzer(int val){
    if (val > 1){
        digitalWrite(11, HIGH);
        delay(200 - 20 * val);
        digitalWrite(11, LOW);
        delay(200 - 20 * val);
    }
    else{  // off if there is no obstacle
        digitalWrite(11,LOW);
    }
}
