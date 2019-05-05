//+------------------------------------------------------------------+
//|                                                     IndTrade.mq5 |
//|                                            Copyright 2018, NOVTS |
//|                                                 http://novts.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, NOVTS"
#property link      "http://novts.com"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers 2
#property indicator_plots   1
#property indicator_type1    DRAW_COLOR_LINE
#property indicator_color1  clrBlack,clrRed,clrBlueViolet
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

input int ma_period=5;
input double delta=0.0001;
input int shift_delta=1;
int                  ma_shift=0;                   // Shift
ENUM_MA_METHOD       ma_method=MODE_EMA;           // Smoothing type
ENUM_APPLIED_PRICE   applied_price=PRICE_WEIGHTED;    // Price type
 
string               symbol=_Symbol;             // Symbol
ENUM_TIMEFRAMES      period=PERIOD_CURRENT;  // Timeframe

double         InBuffer[];
double         ColorBuffer[];
int    handleMA;
string name=symbol;
string short_name;
int    bars_calculated=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,InBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ColorBuffer,INDICATOR_COLOR_INDEX);
   name=symbol;
   StringTrimRight(name);
   StringTrimLeft(name);
   if(StringLen(name)==0)
     {
      name=_Symbol;
     }
handleMA=iMA(name,period,ma_period,ma_shift,ma_method,applied_price);
short_name="Profit";
IndicatorSetString(INDICATOR_SHORTNAME,short_name);  
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int values_to_copy;
   int calculated=BarsCalculated(handleMA);
   if(calculated<=0)
     {
      PrintFormat("BarsCalculated() вернул %d, код ошибки %d",calculated,GetLastError());
      return(0);
     }
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      if(calculated>rates_total) values_to_copy=rates_total;
      else                       values_to_copy=calculated;
     }
   else
     {
      values_to_copy=(rates_total-prev_calculated)+1;
     }

   if(!FillArrayFromBufferMA(InBuffer,ma_shift,handleMA,values_to_copy)) return(0);

bars_calculated=calculated;
if(values_to_copy>1){

bool flagSell=false;
double priceSellOpen;
double priceSellStop;
bool flagBuy=false;
double priceBuyOpen;
double priceBuyStop;

int size=values_to_copy;
for (int i=shift_delta; i<(size-1); i++){

ColorBuffer[i]=0;

if((InBuffer[i-shift_delta]-InBuffer[i])>delta){
ColorBuffer[i]=1;
if(flagSell==false){
priceSellOpen=open[i];
if(!ObjectCreate(0,"Sell"+i,OBJ_ARROW,0,time[i],low[i]))
     {      
      return(false);
     }     
      ObjectSetInteger(0,"Sell"+i,OBJPROP_COLOR,clrRed);
      ObjectSetInteger(0,"Sell"+i,OBJPROP_ARROWCODE,234);
      ObjectSetInteger(0,"Sell"+i,OBJPROP_WIDTH,1);
      ObjectSetInteger(0,"Sell"+i,OBJPROP_ANCHOR,ANCHOR_LOWER);
      ObjectSetInteger(0,"Sell"+i,OBJPROP_HIDDEN,true);
      ObjectSetString(0,"Sell"+i,OBJPROP_TOOLTIP,""+close[i]);     
      
      }
 flagSell=true;     
}else{
if(flagSell==true){
priceSellStop=open[i];
double profit=priceSellOpen-priceSellStop;
if(profit>spread[i]/MathPow(10,Digits())){
if(!ObjectCreate(0,"SellStop"+i,OBJ_TEXT,0,time[i],low[i]))
     {      
      return(false);
     }     
      ObjectSetString(0,"SellStop"+i,OBJPROP_TEXT,"Profit: "+DoubleToString(profit*MathPow(10,Digits()),1));
      ObjectSetDouble(0,"SellStop"+i,OBJPROP_ANGLE,90.0); 
      ObjectSetInteger(0,"SellStop"+i,OBJPROP_COLOR,clrRed); 
     }
flagSell=false;
}
}

if((InBuffer[i]-InBuffer[i-shift_delta])>delta){
ColorBuffer[i]=2;
if(flagBuy==false){
priceBuyOpen=open[i];
 if(!ObjectCreate(0,"Buy"+i,OBJ_ARROW,0,time[i],high[i]))
     {      
      return(false);
     }
     
      ObjectSetInteger(0,"Buy"+i,OBJPROP_COLOR,clrGreen);
      ObjectSetInteger(0,"Buy"+i,OBJPROP_ARROWCODE,233);
      ObjectSetInteger(0,"Buy"+i,OBJPROP_WIDTH,1);
      ObjectSetInteger(0,"Buy"+i,OBJPROP_ANCHOR,ANCHOR_UPPER);
      ObjectSetInteger(0,"Buy"+i,OBJPROP_HIDDEN,true);
      ObjectSetString(0,"Buy"+i,OBJPROP_TOOLTIP,""+close[i]);       
      }
flagBuy=true;
}else{
if(flagBuy==true){
priceBuyStop=open[i];
double profit=priceBuyStop-priceBuyOpen;
if(profit>spread[i]/MathPow(10,Digits())){
if(!ObjectCreate(0,"BuyStop"+i,OBJ_TEXT,0,time[i],high[i]))
     {      
      return(false);
     }     
      ObjectSetString(0,"BuyStop"+i,OBJPROP_TEXT,"Profit: "+DoubleToString(profit*MathPow(10,Digits()),1));
      ObjectSetDouble(0,"BuyStop"+i,OBJPROP_ANGLE,90.0); 
      ObjectSetInteger(0,"BuyStop"+i,OBJPROP_COLOR,clrBlueViolet); 
      }
flagBuy=false;
}}}} 
return(rates_total);
}
//+------------------------------------------------------------------+
bool FillArrayFromBufferMA(double &values[],   
                         int shift,          
                         int ind_handle,     
                         int amount          
                         )
  {
   ResetLastError();
   if(CopyBuffer(ind_handle,0,-shift,amount,values)<0)
     {
      PrintFormat("Failed to copy data from iMA indicator, error code %d", GetLastError());
      return(false);
     }
   return(true);
  }
void  OnDeinit(const int reason){
ObjectsDeleteAll(0,-1,-1);
}
