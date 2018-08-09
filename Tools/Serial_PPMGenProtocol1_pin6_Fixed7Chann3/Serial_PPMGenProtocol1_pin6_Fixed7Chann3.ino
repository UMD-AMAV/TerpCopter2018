

#include <avr/io.h>			
#include <avr/interrupt.h>  



char serialinput;
char sentence[35];                  



char number1[5] ; //  Extra space for null characters
char number2[5] ;
char number3[5] ;
char number4[5] ;
char number5[5] ;
char number6[5] ;
char number7[5] ;


int updateFlag=0;
int ledout=13;
int size=0;
int end=0;


int i=0;
int j=0;
int num1=0;int num2=0;
int num3=0;int num4=0;
int num5=0;int num6=0;
int num7=0;


// Servo drive variables
volatile int state=1;
volatile int outputPin=6;



volatile int chann1Command=0;volatile int chann2Command=0;
volatile int chann3Command=0;volatile int chann4Command=0;
volatile int chann5Command=0;volatile int chann6Command=0;
volatile int chann7Command=0;

volatile int ch1Pulse=32000;volatile int ch2Pulse=32000;
volatile int ch3Pulse=32000;volatile int ch4Pulse=32000;
volatile int ch5Pulse=32000;volatile int ch6Pulse=32000;
volatile int ch7Pulse=32000;

       ISR (TIMER1_COMPA_vect) 
           {	
		cli(); //Disable Interrupts 
		//note default servo command pulse is at 1.5ms or 24000 counts
		
		if (state==1)
		{
		//First falling edge denoting start of ppm comms and channel 1 sequence.
                digitalWrite(outputPin,LOW);
                OCR1A = 6400; // set pin low for standard 0.4ms pulsetime
                state = 2; // Set state for next interrupt 
		}
		
		else if (state==2)
		{
                //Denotes end of standard 0.4ms lowpulse for channel 1 and sets timer for next falling edge.
                digitalWrite(outputPin,HIGH);		
                digitalWrite(ledout,HIGH);		
                
                //digitalWrite(ledoutpin,LOW);		
                
                OCR1A = ch1Pulse-6400;   //Channel 1command pulsetime minus 0.4ms		
                state = 3; // Set state for next interrupt 
		}

		else if (state==3)
		{
                //Falling edge denoting start of channel 2 sequence.
                digitalWrite(outputPin,LOW);
                digitalWrite(ledout,LOW);		

                OCR1A = 6400; // set pin low for standard 0.4ms pulsetime
                state = 4; // Set state for next interrupt 
		}
		
		else if (state==4)
		{
                //Denotes end of standard 0.4ms lowpulse for channel 2 and sets timer for next falling edge.
                digitalWrite(outputPin,HIGH);		
                OCR1A = ch2Pulse-6400;   //Channel 2 command pulsetime minus 0.4ms		
		state = 5; // Set state for next interrupt 
		}
		
                else if (state==5)
		{
                //Falling edge denoting start of channel 3 sequence.
                digitalWrite(outputPin,LOW);
                OCR1A = 6400;
		state = 6; // Set state for next interrupt 
		}
			
        	else if (state==6)
		{
                //Denotes end of standard 0.4ms lowpulse for channel 3 and sets timer for next falling edge.
                digitalWrite(outputPin,HIGH);
                OCR1A = ch3Pulse-6400;   //Channel 3 command pulsetime minus 0.4ms	
                state = 7; // Set state for next interrupt 
		}
		
		else if (state==7)
		{
        	//Falling edge denoting start of channel 4 sequence.
                digitalWrite(outputPin,LOW);
                OCR1A = 6400;
		state =8;
		}

		else if (state==8)
		{
		//Denotes end of standard 0.4ms lowpulse for channel 4 and sets timer for next falling edge.
                digitalWrite(outputPin,HIGH);
                OCR1A = ch4Pulse-6400;   //Channel 4 command pulsetime minus 0.4ms	
		state=9;
		}
		
		else if (state==9)
		{
        	//Falling edge denoting start of channel 5 sequence.
                digitalWrite(outputPin,LOW);
                OCR1A = 6400;
                state=10;
		}

		else if (state==10)
		{
                //Denotes end of standard 0.4ms lowpulse for channel 5 and sets timer for next falling edge.
                digitalWrite(outputPin,HIGH);
                OCR1A = ch5Pulse-6400;   //Channel 5 command pulsetime minus 0.4ms	
		state=11;
		}

                else if (state==11)
		{
                //Falling edge denoting start of channel 6 sequence.
                digitalWrite(outputPin,LOW);
                OCR1A = 6400;
		state=12;
		}
      
                else if (state==12)
		{
                //Denotes end of standard 0.4ms lowpulse for channel 6 and sets timer for next falling edge.
                digitalWrite(outputPin,HIGH);
                OCR1A = ch6Pulse-6400;   //Channel 6 command pulsetime minus 0.4ms	
		state=13;
		}
		
                else if (state==13)
		{
                //Falling edge denoting start of channel 7 sequence.
                digitalWrite(outputPin,LOW);
                OCR1A = 6400;
		state=14;
  		}
		
                else if (state==14)
		{
                //Denotes end of standard 0.4ms lowpulse for channel 7 and sets timer for next falling edge.
                digitalWrite(outputPin,HIGH);
                OCR1A = ch7Pulse-6400;   //Channel 7 command pulsetime minus 0.4ms	
		state=15;
                }

                else if (state==15)
		{
                //Falling edge denoting end of channel 7 sequence and start of ghost channel   8 sequence, or a Stop Pulse
                digitalWrite(outputPin,LOW);
                OCR1A = 6400;
		state=16;
  		}
  
                //ghost channel8 state needs to make up to 2.0ms with a 1.6ms count
            
                // need an 8th stop edge for channel 7

                //8 "mirror" states including the ghost 8th channel   -  the OCR1A=0 case causes trouble so 5counts are added
                
                else if (state==16)
		{
                //Mirror state for channel 1 .
                digitalWrite(outputPin,HIGH);
                OCR1A = 32000-ch1Pulse+5;   //channel 1 pulsetime subtracted from 2.0ms chunk 
		state=17;
                }

                else if (state==17)
		{
                //Mirror state for channel 2
                digitalWrite(outputPin,HIGH);
                OCR1A = 32000-ch2Pulse+5;   //channel 2 pulsetime subtracted from 2.0ms chunk 
		state=18;
                }

                else if (state==18)
		{
                //Mirror state for channel 3
                digitalWrite(outputPin,HIGH);
                OCR1A = 32000-ch3Pulse+5;   //channel 3 pulsetime subtracted from 2.0ms chunk 
		state=19;
                }

                else if (state==19)
		{
                //Mirror state for channel 4
                digitalWrite(outputPin,HIGH);
                OCR1A = 32000-ch4Pulse+5;   //channel 4 pulsetime subtracted from 2.0ms chunk 
		state=20;
                }

                else if (state==20)
		{
                //Mirror state for channel 5
                digitalWrite(outputPin,HIGH);
                OCR1A = 32000-ch5Pulse+5;   //channel 5 pulsetime subtracted from 2.0ms chunk 
		state=21;
                }
                
                else if (state==21)
		{
                //Mirror state for channel 6
                digitalWrite(outputPin,HIGH);
                OCR1A = 32000-ch6Pulse+5;   //channel 5 pulsetime subtracted from 2.0ms chunk 
		state=22;
                }
                
                else if (state==22)
		{
                //Mirror state for channel 7
                digitalWrite(outputPin,HIGH);
                OCR1A = 32000-ch7Pulse+5;   //channel 5 pulsetime subtracted from 2.0ms chunk 
		state=23;
                }


                else if (state==23)
		{
                //Mirror state for channel 8 
                digitalWrite(outputPin,HIGH);
                OCR1A = 32000-6400-6400;   // 7 mirror states and 1 completed ghost channel 8 state brings time line to 16ms
                state=24;  //need for another 6400 count to be subtracted is weird. Works in both situations anyway.
                }
                // need 2 more Dummy mirror states
                
                else if (state==24)
                {
                //Dummy state - counts 2.0msecs
                OCR1A = 32000;
		state=25;
                }
                
                
                else if (state==25)
                {
                //Dummy state - counts 2.0msecs
                OCR1A = 32000;
		state=1;
                }

		TCNT1 = 1;	  //Reset the timer, 
		sei(); //Reenable interrupts
				  
	}


//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------

void setup()
{

  TCCR1A = 0x00;
  TCCR1B = (1 << CS10); 
  TIMSK1 = (1 << OCIE1A); 
  TCNT1 = 1;
  OCR1A=32000;
  sei(); // Enable global interupts

  
  pinMode(ledout,OUTPUT);
  pinMode(outputPin,OUTPUT);
  Serial.begin(57600);  // opens serial port, set data rate to 9600 bps

}

void loop()
{

 
 // perform the following only when you receive data: 
 if(Serial.available() > 0)
 {                
   
        serialinput=Serial.read();  // read the incoming byte:
        //Serial.flush();  
        
        
        if (serialinput=='x'){ 
                  num1=1000;
                  num2=1000;
                  num3=1000;
                  num4=1000;
                  num5=1000;
                  updateFlag=1;
                }
        if (serialinput=='y'){ 
                  num1=9000;
                  num2=9000;
                  num3=9000;
                  num4=9000;
                  num5=9000;
                  updateFlag=1;
                }
                  
                           
        //Start with an 'a' , end with a 'z'
        if (serialinput=='a')
        {
         end=0;
         while(end==0) // Continue until stopped by 'z'
           {
            if(Serial.available() > 0)
            {
             serialinput=Serial.read();  
             //Serial.flush();  
           
               if ( serialinput == 'z'| serialinput==' z')
                   {
                    size=i;
                    end=1;
                    i=0;
                    j=0;
                  
                   
                 number1[0]=sentence[0]; number1[1]=sentence[1]; number1[2]=sentence[2]; number1[3]=sentence[3];
    
                 number2[0]=sentence[4]; number2[1]=sentence[5]; number2[2]=sentence[6]; number2[3]=sentence[7];                                                      
                 
                 number3[0]=sentence[8]; number3[1]=sentence[9]; number3[2]=sentence[10];number3[3]=sentence[11];
                 
                 number4[0]=sentence[12]; number4[1]=sentence[13]; number4[2]=sentence[14];number4[3]=sentence[15];
                  
                 number5[0]=sentence[16]; number5[1]=sentence[17]; number5[2]=sentence[18];number5[3]=sentence[19];
                         
                 number6[0]=sentence[20]; number6[1]=sentence[21]; number6[2]=sentence[22];number6[3]=sentence[23];

                 number7[0]=sentence[24]; number7[1]=sentence[25]; number7[2]=sentence[26];number7[3]=sentence[27];

                
                   num1=atoi(number1); //converts an ascii character array to an integer
                   num2=atoi(number2);
                   num3=atoi(number3);
                   num4=atoi(number4);
                   num5=atoi(number5);
                   num6=atoi(number6);
                   num7=atoi(number7);
                   
    
                  // Serial.print(sentence);
                  // Serial.print(' ');
                  // Serial.print(num1);
                  // Serial.print(' ');
                  // Serial.print(num2);
                  // Serial.print(' ');
                  // Serial.print(num3);
                  //num1 and 2 should be coming in as 100-200 with a centre at ~150
                  //num3 should be 100 onwards as well.
                   
                   //num1=num1-150;
                   //num2=num2-150;
                   //num3=num3-100;
                   
                   updateFlag=1;
                   }
             
                  else
                  {
                   //update sentance
                   sentence[i]=serialinput;
                   i=i+1;
                   }        

               }
           } // end while
        }
   
 }  //end  if serial loop
   
//   put rest of main stuff here
   
   
   
   
   
   
   
   
   if (updateFlag==1)
   { 
     
     //need a num to channelCommand converter
     
     //16mhz clock means 0.5msec=8000counts, 16000 steps from end-end deflection
     //8000 steps between end-end means taking numbers 0-9999 and helps serialstring formatting
     // so...a serial command of 1000 should correspond to a count of 16000 and a pulse of 1.0msec
     // and, a serial command of 5000 should correspond to a count of 24000 and a pulse of 1.5msec
     // and, a serial command of 9000 should correspond to a count of 32000 and a pulse of 2.0msec// 
     
     //pulse = 16000 + 2*(number-1000);
     
     ch1Pulse= 16000 + 2*(num1-1000);
     ch2Pulse= 16000 + 2*(num2-1000);
     ch3Pulse= 16000 + 2*(num3-1000);
     ch4Pulse= 16000 + 2*(num4-1000);
     ch5Pulse= 16000 + 2*(num5-1000);
     ch6Pulse= 16000 + 2*(num6-1000);
     ch7Pulse= 16000 + 2*(num7-1000);
     
     chann1Command=num1;
     chann2Command=num2;
     chann3Command=num3;
     chann4Command=num4;
     chann5Command=num5;
     chann6Command=num6;
     chann7Command=num7;
      
//    Serial.print('\n'); 
//    Serial.print(chann1Command);
//    Serial.print(' '); 
//    Serial.print(ch1Pulse);
//    
//    Serial.print('\n');
//    Serial.print(chann2Command);
//    Serial.print(' '); 
//    Serial.print(ch2Pulse);
//   
//    Serial.print('\n');
//    Serial.print(chann3Command);
//    Serial.print(' '); 
//    Serial.print(ch3Pulse);
//      
//    
//    Serial.print('\n');
//    Serial.print(chann4Command);
//    Serial.print(' '); 
//    Serial.print(ch4Pulse);
        
      
     updateFlag=0;
   }
 
   
  if (ledout==1) { digitalWrite(13,HIGH);}
  if (ledout==0) { digitalWrite(13,LOW);}
  
        
//        delay(500);
//        ch1Pulse=16500;ch2Pulse=16500;
//        ch3Pulse=16500;ch4Pulse=16500;
//      
//        delay(500);
//        ch1Pulse=24000;ch2Pulse=24000;
//        ch3Pulse=24000;ch4Pulse=24000;
//  
//        delay(500);
//        ch1Pulse=32000;ch2Pulse=32000;
//        ch3Pulse=32000;ch4Pulse=32000;
}     

      




