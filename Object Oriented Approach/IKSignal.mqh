//+------------------------------------------------------------------+
//|                                                     IKSignal.mqh |
//|                                            Copyright 2018, NOVTS |
//|                                                 http://novts.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, NOVTS"
#property link      "http://novts.com"
#property version   "1.00"
#include <Indicators\Trend.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class IKSignal
  {
private:
int _start;
datetime _time[];
double _open[];
double _high[];
double _low[];
double _close[];

public:
                     IKSignal(
                int start,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[]             
                 );
bool draw(CiMA &MA34H, CiMA &MA34L, CiMA &MA125, CiSAR &SAR);            
                    ~IKSignal();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IKSignal::IKSignal(int start,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[]             
                )
  {
  _start=start;
  if(ArraySize(time)>0)
     {
     ArrayResize(_time,ArraySize(time));
     ArrayCopy(_time, time);
     }
   if(ArraySize(open)>0)
     {
     ArrayResize(_open,ArraySize(open));
     ArrayCopy(_open, open);
     }
   if(ArraySize(high)>0)
     {
     ArrayResize(_high,ArraySize(high));
     ArrayCopy(_high, high);
     }
   if(ArraySize(low)>0)
     {
     ArrayResize(_low,ArraySize(low));
     ArrayCopy(_low, low);
     }
   if(ArraySize(close)>0)
     {
     ArrayResize(_close,ArraySize(close));
     ArrayCopy(_close, close);
     }     
ArraySetAsSeries(_time, true);
ArraySetAsSeries(_high, true);
ArraySetAsSeries(_low, true);
ArraySetAsSeries(_open, true);
ArraySetAsSeries(_close, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IKSignal::~IKSignal()
  {
  }
//+------------------------------------------------------------------+
bool IKSignal::draw(CiMA &MA34H, CiMA &MA34L, CiMA &MA125, CiSAR &SAR){
for(int i=_start;i>=1;i--)
     {    if(_close[i]>_open[i]&&_close[i]>MA34H.Main(i)&&_close[i]>MA34L.Main(i)
     &&_low[i]>MA125.Main(i)&&_low[i]>SAR.Main(i)&&MA125.Main(i)<MA34L.Main(i)&&MA125.Main(i)<MA34H.Main(i)){
     if(!ObjectCreate(0,"Buy"+i,OBJ_ARROW,0,_time[i],_high[i]))
     {      
      return(false);
     }     
      ObjectSetInteger(0,"Buy"+i,OBJPROP_COLOR,clrGreen);
      ObjectSetInteger(0,"Buy"+i,OBJPROP_ARROWCODE,233);
      ObjectSetInteger(0,"Buy"+i,OBJPROP_WIDTH,2);
      ObjectSetInteger(0,"Buy"+i,OBJPROP_ANCHOR,ANCHOR_UPPER);
      ObjectSetInteger(0,"Buy"+i,OBJPROP_HIDDEN,true);
      ObjectSetString(0,"Buy"+i,OBJPROP_TOOLTIP,_close[i]);    
     }   
     if(_close[i]<_open[i]&&_close[i]<MA34H.Main(i)&&_close[i]<MA34L.Main(i)
     &&_high[i]<MA125.Main(i)&&_high[i]<SAR.Main(i)&&MA125.Main(i)>MA34L.Main(i)&&MA125.Main(i)>MA34H.Main(i)){
     if(!ObjectCreate(0,"Sell"+i,OBJ_ARROW,0,_time[i],_low[i]))
     {      
      return(false);
     }     
      ObjectSetInteger(0,"Sell"+i,OBJPROP_COLOR,clrRed);
      ObjectSetInteger(0,"Sell"+i,OBJPROP_ARROWCODE,234);
      ObjectSetInteger(0,"Sell"+i,OBJPROP_WIDTH,2);
      ObjectSetInteger(0,"Sell"+i,OBJPROP_ANCHOR,ANCHOR_LOWER);
      ObjectSetInteger(0,"Sell"+i,OBJPROP_HIDDEN,true);
      ObjectSetString(0,"Sell"+i,OBJPROP_TOOLTIP,_close[i]);     
     }     
     }    
     ChartRedraw(0);
     return(true);
}
