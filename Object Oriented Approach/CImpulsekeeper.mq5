//+------------------------------------------------------------------+
//|                                               CImpulsekeeper.mq5 |
//|                                            Copyright 2018, NOVTS |
//|                                                 http://novts.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, NOVTS"
#property link      "http://novts.com"
#property version   "1.00"
#property indicator_chart_window

#include <Indicators\Trend.mqh>

CiMA              MA34H;
CiMA              MA34L;
CiMA              MA125;
CiSAR             SAR;

int    bars_calculated=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
MA34H.Create(_Symbol,PERIOD_CURRENT,34,0,MODE_EMA,PRICE_HIGH); 
MA34L.Create(_Symbol,PERIOD_CURRENT,34,0,MODE_EMA,PRICE_LOW);
MA125.Create(_Symbol,PERIOD_CURRENT,125,0,MODE_EMA,PRICE_CLOSE);
SAR.Create(_Symbol,PERIOD_CURRENT,0.02, 0.2);   
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
//---   
   int start;
   int calculated=MA34H.BarsCalculated();
   if(calculated<=0)
     {      
      return(0);
     }
   if(prev_calculated==0 || calculated!=bars_calculated)
     {
      start=rates_total-1;      
     }
   else
     {
     start=1;     
     }      
ArraySetAsSeries(time, true);
ArraySetAsSeries(high, true);
ArraySetAsSeries(low, true);
ArraySetAsSeries(open, true);
ArraySetAsSeries(close, true);

//Print(MA34H.BufferSize());

MA34H.BufferResize(rates_total);
MA34L.BufferResize(rates_total);
MA125.BufferResize(rates_total);
SAR.BufferResize(rates_total);

MA34H.Refresh();
MA34L.Refresh();
MA125.Refresh();
SAR.Refresh();

for(int i=start;i>=1;i--)
     {         
    if(close[i]>open[i]&&close[i]>MA34H.Main(i)&&close[i]>MA34L.Main(i)
    &&low[i]>MA125.Main(i)&&low[i]>SAR.Main(i)&&MA125.Main(i)<MA34L.Main(i)
    &&MA125.Main(i)<MA34H.Main(i)){
     if(!ObjectCreate(0,"Buy"+i,OBJ_ARROW,0,time[i],high[i]))
     {      
      return(false);
     }     
      ObjectSetInteger(0,"Buy"+i,OBJPROP_COLOR,clrGreen);
      ObjectSetInteger(0,"Buy"+i,OBJPROP_ARROWCODE,233);
      ObjectSetInteger(0,"Buy"+i,OBJPROP_WIDTH,2);
      ObjectSetInteger(0,"Buy"+i,OBJPROP_ANCHOR,ANCHOR_UPPER);
      ObjectSetInteger(0,"Buy"+i,OBJPROP_HIDDEN,true);
      ObjectSetString(0,"Buy"+i,OBJPROP_TOOLTIP,close[i]);    
     }    
     if(close[i]<open[i]&&close[i]<MA34H.Main(i)&&close[i]<MA34L.Main(i)
     &&high[i]<MA125.Main(i)&&high[i]<SAR.Main(i)&&MA125.Main(i)>MA34L.Main(i)
     &&MA125.Main(i)>MA34H.Main(i)){
     if(!ObjectCreate(0,"Sell"+i,OBJ_ARROW,0,time[i],low[i]))
     {      
      return(false);
     }     
      ObjectSetInteger(0,"Sell"+i,OBJPROP_COLOR,clrRed);
      ObjectSetInteger(0,"Sell"+i,OBJPROP_ARROWCODE,234);
      ObjectSetInteger(0,"Sell"+i,OBJPROP_WIDTH,2);
      ObjectSetInteger(0,"Sell"+i,OBJPROP_ANCHOR,ANCHOR_LOWER);
      ObjectSetInteger(0,"Sell"+i,OBJPROP_HIDDEN,true);
      ObjectSetString(0,"Sell"+i,OBJPROP_TOOLTIP,close[i]);     
     }     
     }    
     ChartRedraw(0);
     bars_calculated=calculated;     
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
void  OnDeinit(const int reason){
ObjectsDeleteAll(0,-1,-1);
}  