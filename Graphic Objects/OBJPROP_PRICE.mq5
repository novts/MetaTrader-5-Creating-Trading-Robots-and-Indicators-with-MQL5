//+------------------------------------------------------------------+
//|                                                OBJPROP_PRICE.mq5 |
//|                                            Copyright 2018, NOVTS |
//|                                                 http://novts.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, NOVTS"
#property link      "http://novts.com"
#property version   "1.00"
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   
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
ArraySetAsSeries(time, true);
ArraySetAsSeries(high, true);
ArraySetAsSeries(low, true);
ArraySetAsSeries(close, true);
ObjectDelete(0,"Price");
    if(!ObjectCreate(0,"Price",OBJ_HLINE,0,time[1],close[1]))
     {      
      return(false);
     }          
      ObjectSetInteger(0,"Price",OBJPROP_COLOR,clrGreen);   
      ObjectSetInteger(0,"Price",OBJPROP_WIDTH,1);
      ObjectSetString(0,"Price",OBJPROP_TOOLTIP,close[1]);      
      if (open[1]>close[1])
      ObjectSetDouble(0,"Price",OBJPROP_PRICE,low[1]);       
      if (open[1]<close[1])
      ObjectSetDouble(0,"Price",OBJPROP_PRICE,high[1]);      
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
void  OnDeinit(const int reason){
ObjectsDeleteAll(0,-1,-1);
} 
