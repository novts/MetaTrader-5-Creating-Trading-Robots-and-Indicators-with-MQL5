//+------------------------------------------------------------------+
//|                                                        Sidus.mqh |
//|                                            Copyright 2018, NOVTS |
//|                                                 http://novts.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, NOVTS"
#property link      "http://novts.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Sidus
  {
private:
int numberBarOpenPosition;
int numberBarStopPosition;
int    handleIMA18; 
double    MA18Buffer[];
int    handleIMA28;
double    MA28Buffer[];
int    handleIWMA5; 
double    WMA5Buffer[];
int    handleIWMA8;
double    WMA8Buffer[];  

public:
                     Sidus(int BarOpenPosition, int BarStopPosition);
                    ~Sidus();
bool OnTradeSignalBuy();
bool OnTradeSignalBuyStop(MqlRates& mrate[]);
bool OnTradeSignalSell();
bool OnTradeSignalSellStop(MqlRates& mrate[]);                    
  };
//+------------------------------------------------------------------+
Sidus::Sidus(int BarOpenPosition, int BarStopPosition)
  {
  numberBarOpenPosition=BarOpenPosition;
  numberBarStopPosition=BarStopPosition;
  handleIMA18=iMA(_Symbol,PERIOD_H1,18,0,MODE_EMA,PRICE_WEIGHTED);
  handleIMA28=iMA(_Symbol,PERIOD_H1,28,0,MODE_EMA,PRICE_WEIGHTED);
  handleIWMA5=iMA(_Symbol,PERIOD_H1,5,0,MODE_LWMA,PRICE_WEIGHTED);
  handleIWMA8=iMA(_Symbol,PERIOD_H1,8,0,MODE_LWMA,PRICE_WEIGHTED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Sidus::~Sidus()
  {
  }
//+------------------------------------------------------------------+
bool Sidus::OnTradeSignalBuy(){

bool flagBuy=false;

 if(CopyBuffer(handleIMA18,0,0,numberBarOpenPosition,MA18Buffer)<0)
     {      
      return false;
     }
     
 if(CopyBuffer(handleIMA28,0,0,numberBarOpenPosition,MA28Buffer)<0)
     {      
      return false;
     } 
     
 if(CopyBuffer(handleIWMA5,0,0,numberBarOpenPosition,WMA5Buffer)<0)
     {      
      return false;
     }
     
 if(CopyBuffer(handleIWMA8,0,0,numberBarOpenPosition,WMA8Buffer)<0)
     {      
      return false;
     }     
 ArraySetAsSeries(MA18Buffer,true); 
 ArraySetAsSeries(MA28Buffer,true); 
 ArraySetAsSeries(WMA5Buffer,true);  
 
 bool flagCross1=false;
 bool flagCross2=false;
 bool flagCross=false;
 
 if(WMA5Buffer[1]>MA18Buffer[1]&&WMA5Buffer[1]>MA28Buffer[1]&&WMA8Buffer[1]>MA18Buffer[1]&&WMA8Buffer[1]>MA28Buffer[1]){
 for (int i=2;i<numberBarOpenPosition;i++){
if(WMA5Buffer[i]<MA18Buffer[i]&&WMA5Buffer[i]<MA28Buffer[i]){
 flagCross1=true;
 }
 if(WMA8Buffer[i]<MA18Buffer[i]&&WMA8Buffer[i]<MA28Buffer[i]){
 flagCross2=true;
 }
 } 
 if(flagCross1==true&&flagCross2==true){
 flagCross=true;
 }
 } 

if(flagCross==true){
 flagBuy=true;
 }
                  
return flagBuy;
}

bool Sidus::OnTradeSignalBuyStop(MqlRates& mrate[]){

bool flagBuyStop=false;
     
 if(CopyBuffer(handleIWMA5,0,0,numberBarStopPosition,WMA5Buffer)<0)
     {      
      return false;
     }
     
 if(CopyBuffer(handleIWMA8,0,0,numberBarStopPosition,WMA8Buffer)<0)
     {      
      return false;
     }        
     
 ArraySetAsSeries(WMA5Buffer,true);  
 ArraySetAsSeries(WMA8Buffer,true); 
 
 bool flagCross=false;
 
 if(WMA5Buffer[1]<WMA8Buffer[1]){
 for (int i=2;i<numberBarStopPosition;i++){
if(WMA5Buffer[i]>WMA8Buffer[i]){
 flagCross=true;
 }
 } 
 }
 
 double max=mrate[1].high;
 
 for (int i=1;i<numberBarStopPosition;i++){
 if(mrate[i].high>max)max=mrate[i].high;
 }
 
 if(flagCross==true&&mrate[1].high<=max&&mrate[numberBarStopPosition-1].high<=max){
 flagBuyStop=true;
 } 
                   
return flagBuyStop;
}

bool Sidus::OnTradeSignalSell(){

bool flagSell=false;

 if(CopyBuffer(handleIMA18,0,0,numberBarOpenPosition,MA18Buffer)<0)
     {      
      return false;
     }
     
 if(CopyBuffer(handleIMA28,0,0,numberBarOpenPosition,MA28Buffer)<0)
     {      
      return false;
     } 
     
 if(CopyBuffer(handleIWMA5,0,0,numberBarOpenPosition,WMA5Buffer)<0)
     {      
      return false;
     }
     
 if(CopyBuffer(handleIWMA8,0,0,numberBarOpenPosition,WMA8Buffer)<0)
     {      
      return false;
     }     
     
 ArraySetAsSeries(MA18Buffer,true); 
 ArraySetAsSeries(MA28Buffer,true); 
 ArraySetAsSeries(WMA5Buffer,true);  
 ArraySetAsSeries(WMA8Buffer,true);
 
 bool flagCross1=false;
 bool flagCross2=false;
 bool flagCross=false;
 
 if(WMA5Buffer[1]<MA18Buffer[1]&&WMA5Buffer[1]<MA28Buffer[1]&&WMA8Buffer[1]<MA18Buffer[1]&&WMA8Buffer[1]<MA28Buffer[1]){
 for (int i=2;i<numberBarOpenPosition;i++){
if(WMA5Buffer[i]>MA18Buffer[i]&&WMA5Buffer[i]>MA28Buffer[i]){
 flagCross1=true;
 }
 if(WMA8Buffer[i]>MA18Buffer[i]&&WMA8Buffer[i]>MA28Buffer[i]){
 flagCross2=true;
 }
 } 
 if(flagCross1==true&&flagCross2==true){
 flagCross=true;
 }
 } 
    
 if(flagCross==true){
 flagSell=true;
 }                
return flagSell;
}

bool Sidus::OnTradeSignalSellStop(MqlRates& mrate[]){

bool flagSellStop=false;
     
 if(CopyBuffer(handleIWMA5,0,0,numberBarStopPosition,WMA5Buffer)<0)
     {      
      return false;
     }
     
 if(CopyBuffer(handleIWMA8,0,0,numberBarStopPosition,WMA8Buffer)<0)
     {      
      return false;
     }         
     
 ArraySetAsSeries(WMA5Buffer,true);  
 ArraySetAsSeries(WMA8Buffer,true);
 
 bool flagCross=false;
 
 if(WMA5Buffer[1]>WMA8Buffer[1]){
 for (int i=2;i<numberBarStopPosition;i++){
if(WMA5Buffer[i]<WMA8Buffer[i]){
 flagCross=true;
 }
 } 
 }
 
 double min=mrate[1].low;
 
 for (int i=1;i<numberBarStopPosition;i++){
 if(mrate[i].low<min)min=mrate[i].low;
 }
 
 if(flagCross==true&&mrate[1].low>=min&&mrate[numberBarStopPosition-1].low>=min){
 flagSellStop=true;
 }  
                   
return flagSellStop;
}
