//+------------------------------------------------------------------+
//|                                                MAMACDFitness.mqh |
//|                                            Copyright 2018, NOVTS |
//|                                                 http://novts.com |
//+------------------------------------------------------------------+

void FitnessFunction(int chromos)
{
 
double _MACD_Weight=0.0;
double _MA_Weight=0.0;
double sum=0.0;
int    cnt=1;
 
while (cnt<=GeneCount)
  {
    _MACD_Weight=Colony[cnt][chromos];
    cnt++;
    _MA_Weight=Colony[cnt][chromos];
    cnt++;
 
int handleInd; 
double BufferInd[]; 
double BufferColorInd[]; 
 
 
handleInd=iCustom(NULL,0,"IndSignals", 
Signal_ThresholdOpen,
Signal_ThresholdClose,
Signal_MACD_PeriodFast,
Signal_MACD_PeriodSlow,
Signal_MACD_PeriodSignal,
Signal_MACD_Applied,
_MACD_Weight,
Signal_MA_PeriodMA,
Signal_MA_Shift,
Signal_MA_Method,
Signal_MA_Applied,
_MA_Weight 
); 
 
ResetLastError();
 
int size=5000;
 
if(CopyBuffer(handleInd,0,0,size,BufferInd)<0) 
     { 
      PrintFormat("Error code %d",GetLastError()); 
            
     } 
 
 if(CopyBuffer(handleInd,1,0,size,BufferColorInd)<0) 
     { 
      PrintFormat("Error code %d",GetLastError()); 
          
     } 
 ArraySetAsSeries(BufferInd,true);  
 ArraySetAsSeries(BufferColorInd,true);  
 
bool flagBuy=false;
bool flagSell=false;
double priceBuy=0;
double priceStopBuy=0;
double profitBuy=0;
double profitTotalBuy=0;
int countProfitBuyPlus=0;
int countProfitBuyMinus=0;
double priceSell=0;
double priceStopSell=0;
double profitSell=0;
double profitTotalSell=0;
int countProfitSellPlus=0;
int countProfitSellMinus=0;
double sp=0.0002;
 
for (int i=0; i<size; i++){
 
if(BufferColorInd[i]==2)
     {
if(flagSell==true){
flagSell=false;
priceStopSell=BufferInd[i];
profitSell=(priceStopSell-priceSell-sp)*10000;
if(profitSell>0){countProfitSellPlus++;}else{countProfitSellMinus++;}
profitTotalSell=profitTotalSell+profitSell;
 }
 if(flagBuy==false){
 flagBuy=true;
 priceBuy=BufferInd[i];
 }
     } 
     
 if(BufferColorInd[i]==1){
if(flagBuy==true){
flagBuy=false;
priceStopBuy=BufferInd[i];
profitBuy=(priceStopBuy-priceBuy-sp)*10000;
if(profitBuy>0){countProfitBuyPlus++;}else{countProfitBuyMinus++;}
profitTotalBuy=profitTotalBuy+profitBuy;
 }
 if(flagSell==false){
priceSell=BufferInd[i];
flagSell=true; 
}
 } 
}
//Print(" ProfitBuy ", profitTotalBuy," countProfitBuyPlus ",countProfitBuyPlus," countProfitBuyMinus ",countProfitBuyMinus);
//Print(" ProfitSell ", profitTotalSell," countProfitSellPlus ",countProfitSellPlus," countProfitSellMinus ",countProfitSellMinus);
   
sum = profitTotalBuy + profitTotalSell;
  }
  AmountStartsFF++;
  Colony[0][chromos]=sum;
}
 
void ServiceFunction()
{ 
  
double _MACD_Weight=0.0;
double _MA_Weight=0.0;
int    cnt=1;
 
    while (cnt<=GeneCount)
    {
      _MACD_Weight=Chromosome[cnt];
      cnt++;
      _MA_Weight=Chromosome[cnt];
      cnt++;
    }
 Print("Fitness func =",Chromosome[0],"\n",
            "The resulting argument values:","\n",
            "_MACD_Weight =",Chromosome[1],"\n",
            "_MA_Weight =",Chromosome[2],"\n"
            );
  
}
//———————————————————————————————————————————————————————————————————