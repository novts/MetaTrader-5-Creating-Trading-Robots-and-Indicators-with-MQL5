//+------------------------------------------------------------------+
//|                                                     ExpSidus.mq5 |
//|                                            Copyright 2018, NOVTS |
//|                                                 http://novts.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, NOVTS"
#property link      "http://novts.com"
#property version   "1.00"

input double   Lot=1;          
input int      EA_Magic=1000; 
input double spreadLevel=5.0;
input double StopLoss=0.01;
input double Profit=0.01;

input int numberBarOpenPosition=5;
input int numberBarStopPosition=5;


bool flagStopLoss=false;

int    handleIMA18; 
double    MA18Buffer[];
int    handleIMA28;
double    MA28Buffer[];
int    handleIWMA5; 
double    WMA5Buffer[];
int    handleIWMA8;
double    WMA8Buffer[];  

#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object

//---------------------------------------------------------------------------------

int OnCheckTradeInit(){
//Check expert start on a real account  
if((ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE)==ACCOUNT_TRADE_MODE_REAL){  
  int mb=MessageBox("Run the advisor on a real account?","Message Box",MB_YESNO|MB_ICONQUESTION);      
  if(mb==IDNO) return(0);     
 } 
//Checking: 
//No connection to the server, prohibition of trade on the server side
//The broker prohibits automatic trading

if(!TerminalInfoInteger(TERMINAL_CONNECTED)){
Alert("No connection to the trade server");
return(0);
}
if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)){
Alert("Trade for this account is prohibited");
return(0);
} 
if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT)){
Alert("Trade with the help of experts for the account is prohibited");
return(0);
}
//Check the correctness of the volume with which we are going to enter the market
   if(Lot<SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN)||Lot>SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX)){ 
 Alert("Lot is not correct!!!");      
      return(0);
}
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {  
handleIMA18=iMA(_Symbol,PERIOD_H1,18,0,MODE_EMA,PRICE_CLOSE);
handleIMA28=iMA(_Symbol,PERIOD_H1,28,0,MODE_EMA,PRICE_CLOSE);
handleIWMA5=iMA(_Symbol,PERIOD_H1,5,0,MODE_LWMA,PRICE_CLOSE);
handleIWMA8=iMA(_Symbol,PERIOD_H1,8,0,MODE_LWMA,PRICE_CLOSE);  
  
return(OnCheckTradeInit());
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {      
  }
  
int OnCheckTradeTick(){
//Check there is no connection to the server
if(!TerminalInfoInteger(TERMINAL_CONNECTED)){
Alert("No connection to the trade server");
return(0);
}
//Is the auto-trade button on the client terminal enabled? 
if (!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)){ 
Alert("Auto Trade Permission Off!");
return(0);
}
//Permission to trade with the help of an expert is disabled in the common properties of the expert itself.   
if(!MQLInfoInteger(MQL_TRADE_ALLOWED)){
Alert("Automatic trading is prohibited in the properties of the expert ",__FILE__);
return(0);
}
//Margin level at which account replenishment is required
if((ENUM_ACCOUNT_STOPOUT_MODE)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE)==ACCOUNT_STOPOUT_MODE_PERCENT){
if(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL)!=0&&AccountInfoDouble(ACCOUNT_MARGIN_LEVEL)
<=AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL)){
Alert("Margin Call!!!");
return(0);
}} 
if((ENUM_ACCOUNT_STOPOUT_MODE)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE)==ACCOUNT_STOPOUT_MODE_MONEY){
if(AccountInfoDouble(ACCOUNT_EQUITY)<=AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL)){
Alert("Margin Call!!!"); 
return(0); 
}}
//Margin level upon reaching which there is a forced closing of the most unprofitable position
if((ENUM_ACCOUNT_STOPOUT_MODE)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE)==ACCOUNT_STOPOUT_MODE_PERCENT){
if(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL)!=0&&AccountInfoDouble(ACCOUNT_MARGIN_LEVEL)
<=AccountInfoDouble(ACCOUNT_MARGIN_SO_SO)){
Alert("Stop Out!!!");
return(0);
}} 
if((ENUM_ACCOUNT_STOPOUT_MODE)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE)==ACCOUNT_STOPOUT_MODE_MONEY){
if(AccountInfoDouble(ACCOUNT_EQUITY)<=AccountInfoDouble(ACCOUNT_MARGIN_SO_SO)){
Alert("Stop Out!!!");
return(0);
}}
//Checking the free funds volume on the account available for opening a position
 double margin;
 MqlTick last_tick;
 ResetLastError();
 if(SymbolInfoTick(Symbol(),last_tick))
     {            
      if(OrderCalcMargin(ORDER_TYPE_BUY,Symbol(),Lot,last_tick.ask,margin))
        {
     if(margin>AccountInfoDouble(ACCOUNT_MARGIN_FREE)){
      Alert("Not enough money in the account!");
      return(0);     
     }      
        }
     }
   else
     {
      Print(GetLastError());
     }
//Broker spread control
double _spread=
SymbolInfoInteger(Symbol(),SYMBOL_SPREAD)*MathPow(10,-SymbolInfoInteger(Symbol(),SYMBOL_DIGITS))/MathPow(10,-4); 
 if(_spread>spreadLevel){
 Alert("Too big spread!");
 return(0);
 } 
//Check of restrictions on trading operations on the symbol set by the broker
if((ENUM_SYMBOL_TRADE_MODE)SymbolInfoInteger(Symbol(),SYMBOL_TRADE_MODE)!=SYMBOL_TRADE_MODE_FULL){
Alert("Restrictions on trading operations!");
return(0);
}
//Are there enough bars in the history to calculate the advisor
if(Bars(Symbol(), 0)<100)  
     {
      Alert("In the chart little bars, Expert will not work!!");
      return(0);
     } 
     
     return(1);    
}
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {    
if(!OnCheckTradeTick()){
return;
}
//Limit the calculations of the adviser by the appearance of a new bar on the chart
static datetime last_time;
datetime last_bar_time=(datetime)SeriesInfoInteger(Symbol(),Period(),SERIES_LASTBAR_DATE);  
if(last_time!=last_bar_time)
{
last_time=last_bar_time;     
}else{
return;
}
//Limit adviser calculation on flagStopLoss
static datetime last_time_daily;
datetime last_bar_time_daily=(datetime)SeriesInfoInteger(Symbol(),PERIOD_D1,SERIES_LASTBAR_DATE);  
if(last_time_daily!=last_bar_time_daily)
{
last_time_daily=last_bar_time_daily;
flagStopLoss=false;    
}
if(flagStopLoss==true)return;

//Check for an open position so as not to try to re-open it
   bool BuyOpened=false;  
   bool SellOpened=false;
   if(PositionSelect(_Symbol)==true) 
     {
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         BuyOpened=true;  
        }
      else if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         SellOpened=true; 
        }
     }
//To calculate the signals of the trading system requires symbol's historical data
int num;
if(numberBarOpenPosition>numberBarStopPosition)num=numberBarOpenPosition;
if(numberBarOpenPosition<=numberBarStopPosition)num=numberBarStopPosition;
MqlRates mrate[];
ResetLastError();
if(CopyRates(Symbol(),Period(),0,num,mrate)<0)
     {
Print(GetLastError());
      return;
     }  
     
ArraySetAsSeries(mrate,true);

bool TradeSignalBuy=false;
bool TradeSignalSell=false;

TradeSignalBuy=OnTradeSignalBuy();
TradeSignalSell=OnTradeSignalSell();

bool TradeSignalBuyStop=false;
bool TradeSignalSellStop=false;


TradeSignalBuyStop=OnTradeSignalBuyStop(mrate);
TradeSignalSellStop=OnTradeSignalSellStop(mrate);


//-----------------------------------------------------------------------------
MqlTradeRequest mrequest;
MqlTradeCheckResult check_result;
MqlTradeResult mresult;

MqlTick latest_price;
if(!SymbolInfoTick(_Symbol,latest_price))
     {
      Alert("Error getting the latest quotes - :",GetLastError(),"!!");
      return;
     }
if(TradeSignalBuy==true&&BuyOpened==false){ 
 
if(((ENUM_SYMBOL_TRADE_EXECUTION)SymbolInfoInteger(Symbol(),SYMBOL_TRADE_EXEMODE))==SYMBOL_TRADE_EXECUTION_INSTANT){
ZeroMemory(mrequest);
mrequest.action = TRADE_ACTION_DEAL;                              
mrequest.symbol = _Symbol;
mrequest.volume = Lot;
mrequest.price = NormalizeDouble(latest_price.ask,_Digits);
mrequest.sl = NormalizeDouble(latest_price.bid - StopLoss,_Digits); 
mrequest.tp = NormalizeDouble(latest_price.ask + Profit,_Digits);
mrequest.deviation=10;  
mrequest.type = ORDER_TYPE_BUY;                
mrequest.type_filling = ORDER_FILLING_FOK;

ZeroMemory(check_result);
ZeroMemory(mresult);
if(!OrderCheck(mrequest,check_result))
     {
      if (check_result.retcode == 10014) Alert ("Invalid volume in the request");
      if (check_result.retcode == 10015) Alert ("Incorrect price in the request");
      if (check_result.retcode == 10016) Alert ("Wrong stops in the request");
      if (check_result.retcode == 10019) Alert ("There is not enough money to execute the request");
      return;
     }else{ 
 if(OrderSend(mrequest,mresult)){
 if(mresult.retcode==10009 || mresult.retcode==10008) //request executed or order placed successfully
           {           
Print("Price ", mresult.price);                      
           }
         else
           {
if(mresult.retcode==10004) //Requote
{
Print("Requote bid ",mresult.bid);
Print("Requote ask ",mresult.ask);
}else{
Print("Retcode ",mresult.retcode);
}         
           }  
}else{
Print("Retcode ",mresult.retcode);
}
} 
}
//-------------------------------------------------------------------------------------------------------------
if(((ENUM_SYMBOL_TRADE_EXECUTION)SymbolInfoInteger(Symbol(),SYMBOL_TRADE_EXEMODE))==SYMBOL_TRADE_EXECUTION_EXCHANGE){
ZeroMemory(mrequest);
mrequest.action = TRADE_ACTION_DEAL;                              
mrequest.symbol = _Symbol;
mrequest.volume = Lot;
mrequest.type = ORDER_TYPE_BUY;                
mrequest.type_filling = ORDER_FILLING_FOK;

ZeroMemory(check_result);
ZeroMemory(mresult);
if(!OrderCheck(mrequest,check_result))
     {
      if (check_result.retcode == 10014) Alert ("Invalid volume in the request");
      if (check_result.retcode == 10019) Alert ("There is not enough money to execute the request");
      return;
     }else{ 
 if(OrderSend(mrequest,mresult)){
 if(mresult.retcode==10009 || mresult.retcode==10008) //request executed or order placed successfully
           { 
//-----------------------           
ZeroMemory(mrequest);           
mrequest.action = TRADE_ACTION_SLTP; 
mrequest.symbol = _Symbol;    
mrequest.sl = NormalizeDouble(mresult.price - StopLoss,_Digits); 
mrequest.tp = NormalizeDouble(mresult.price + Profit,_Digits);
ZeroMemory(check_result);
ZeroMemory(mresult);
if(!OrderCheck(mrequest,check_result))
     {     
      if (check_result.retcode == 10015) Alert ("Incorrect price in the request");
      if (check_result.retcode == 10016) Alert ("Wrong stops in the request");    
      return;
     }else{ 
 if(OrderSend(mrequest,mresult)){
 if(mresult.retcode==10009 || mresult.retcode==10008) //request executed or order placed successfully
           {           
Print("SL ", mrequest.sl, "TP ",mrequest.tp);                      
           }
         else
           {
Print("Retcode ",mresult.retcode);        
           }  
}else{
Print("Retcode ",mresult.retcode);
}
} 
//------------------------------------------                                   
           }
         else
           {
Print("Retcode ",mresult.retcode);    
           }  
}else{
Print("Retcode ",mresult.retcode);
}
} 
}

}   
//--------------------------------------------------------------------------------------------------------------     
if(TradeSignalSell==true&&SellOpened==false){

if(((ENUM_SYMBOL_TRADE_EXECUTION)SymbolInfoInteger(Symbol(),SYMBOL_TRADE_EXEMODE))==SYMBOL_TRADE_EXECUTION_INSTANT){
ZeroMemory(mrequest);
mrequest.action = TRADE_ACTION_DEAL;                              
mrequest.symbol = _Symbol;
mrequest.volume = Lot;
mrequest.price = NormalizeDouble(latest_price.bid,_Digits);
mrequest.sl = NormalizeDouble(latest_price.ask + StopLoss,_Digits); 
mrequest.tp = NormalizeDouble(latest_price.bid - Profit,_Digits);
mrequest.deviation=10;  
mrequest.type = ORDER_TYPE_SELL;                
mrequest.type_filling = ORDER_FILLING_FOK;

ZeroMemory(check_result);
ZeroMemory(mresult);
if(!OrderCheck(mrequest,check_result))
     {
     if (check_result.retcode == 10014) Alert ("Invalid volume in the request");
      if (check_result.retcode == 10015) Alert ("Incorrect price in the request");
      if (check_result.retcode == 10016) Alert ("Wrong stops in the request");
      if (check_result.retcode == 10019) Alert ("There is not enough money to execute the request");
      return;
     }else{ 
 if(OrderSend(mrequest,mresult)){
 if(mresult.retcode==10009 || mresult.retcode==10008) //request executed or order placed successfully
           {           
Print("Price ", mresult.price);                      
           }
         else
           {
if(mresult.retcode==10004) //Requote
{
Print("Requote bid ",mresult.bid);
Print("Requote ask ",mresult.ask);
}else{
Print("Retcode ",mresult.retcode);
}         
           }  
}else{
Print("Retcode ",mresult.retcode);
}
} 
} 
//-------------------------------------------------------------------------------------------------------------
if(((ENUM_SYMBOL_TRADE_EXECUTION)SymbolInfoInteger(Symbol(),SYMBOL_TRADE_EXEMODE))==SYMBOL_TRADE_EXECUTION_EXCHANGE){
ZeroMemory(mrequest);
mrequest.action = TRADE_ACTION_DEAL;                              
mrequest.symbol = _Symbol;
mrequest.volume = Lot;
mrequest.type = ORDER_TYPE_SELL;                
mrequest.type_filling = ORDER_FILLING_FOK;

ZeroMemory(check_result);
ZeroMemory(mresult);
if(!OrderCheck(mrequest,check_result))
     {
     if (check_result.retcode == 10014) Alert ("Invalid volume in the request");
      if (check_result.retcode == 10019) Alert ("There is not enough money to execute the request");
      return;
     }else{ 
 if(OrderSend(mrequest,mresult)){
 if(mresult.retcode==10009 || mresult.retcode==10008) //request executed or order placed successfully
           { 
//-----------------------           
ZeroMemory(mrequest);           
mrequest.action = TRADE_ACTION_SLTP; 
mrequest.symbol = _Symbol;    
mrequest.tp = NormalizeDouble(mresult.price - Profit,_Digits); 
mrequest.sl = NormalizeDouble(mresult.price + StopLoss,_Digits);
ZeroMemory(check_result);
ZeroMemory(mresult);
if(!OrderCheck(mrequest,check_result))
     {     
     if (check_result.retcode == 10015) Alert ("Incorrect price in the request");
      if (check_result.retcode == 10016) Alert ("Wrong stops in the request");     
      return;
     }else{ 
 if(OrderSend(mrequest,mresult)){
 if(mresult.retcode==10009 || mresult.retcode==10008) //request executed or order placed successfully
           {           
Print("SL ", mrequest.sl, "TP ",mrequest.tp);                      
           }
         else
           {
Print("Retcode ",mresult.retcode);        
           }  
}else{
Print("Retcode ",mresult.retcode);
}
} 
//------------------------------------------                                   
           }
         else
           {
Print("Retcode ",mresult.retcode);    
           }  
}else{
Print("Retcode ",mresult.retcode);
}
} 
}
    
}
//------------------------------------------------------------
 if(TradeSignalSellStop==true&&SellOpened==true){ 
      for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties  
      {       
           ENUM_POSITION_TYPE type = m_position.PositionType();
           if(type==POSITION_TYPE_SELL)  
           m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol  
      }
}     
//--------------------------------------------------------------------------------------------------------------     
if(TradeSignalBuyStop==true&&BuyOpened==true){
      for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties  
      {       
           ENUM_POSITION_TYPE type = m_position.PositionType();
           if(type==POSITION_TYPE_BUY)            
           m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol  
            
       }
}    

}  

//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
static int _deals;
ulong _ticket=0;

if(HistorySelect(0,TimeCurrent()))
  {
 int  i=HistoryDealsTotal()-1;

   if(_deals!=i) {    
   _deals=i; 
   } else { return; }

   if((_ticket=HistoryDealGetTicket(i))>0)
     {
      string _comment=HistoryDealGetString(_ticket,DEAL_COMMENT);      
      if(StringFind(_comment,"sl",0)!=-1) {       
      flagStopLoss=true;
      }           
     }
  }   
  }
//------------------------------------------------------------------------
bool OnTradeSignalBuy(){
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
 ArraySetAsSeries(WMA8Buffer,true); 
 
 bool flagCross1=false;
 bool flagCross2=false;
 bool flagCross=false;
 
 if(WMA5Buffer[1]>MA18Buffer[1]&&WMA5Buffer[1]>MA28Buffer[1]
 &&WMA8Buffer[1]>MA18Buffer[1]&&WMA8Buffer[1]>MA28Buffer[1]){
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
 flagBuy=flagCross;                  
return flagBuy;
}
//------------------------------------------------------------------------
bool OnTradeSignalBuyStop(MqlRates& mrate[]){
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
 } }  } 
 double max=mrate[1].high; 
 for (int i=1;i<numberBarStopPosition;i++){
 if(mrate[i].high>max)max=mrate[i].high;
 } 
 if(flagCross==true&&mrate[1].high<=max&&mrate[numberBarStopPosition-1].high<=max){
 flagBuyStop=true;
 }                   
return flagBuyStop;
}
//------------------------------------------------------------------------
bool OnTradeSignalSell(){

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
 
 flagSell=flagCross;
                  
return flagSell;
}
//------------------------------------------------------
bool OnTradeSignalSellStop(MqlRates& mrate[]){

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
