//+------------------------------------------------------------------+
//|                                               CImpulsekeeper.mq5 |
//|                                            Copyright 2018, NOVTS |
//|                                                 http://novts.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, NOVTS"
#property link      "http://novts.com"
#property version   "1.00"
#property indicator_chart_window

#include <IKSignal.mqh>

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
     
IKSignal iks(start,time,open,high,low,close);        

//Print(MA34H.BufferSize());

MA34H.BufferResize(rates_total);
MA34L.BufferResize(rates_total);
MA125.BufferResize(rates_total);
SAR.BufferResize(rates_total);

     MA34H.Refresh();
     MA34L.Refresh();
     MA125.Refresh();
     SAR.Refresh();
     
     if(!iks.draw(MA34H, MA34L, MA125, SAR)){
     return(false);
     }        
     bars_calculated=calculated;     
//--- return value of prev_calculated for next call
   return(rates_total);
  }

//+------------------------------------------------------------------+
void  OnDeinit(const int reason){
ObjectsDeleteAll(0,-1,-1);
}  