import type {PublicSettings} from './config';
export function ticketPrice(base:number,eligible:string[],settings:PublicSettings,member=false,promo=0){
 const options:{type:string,percent:number}[]=[{type:'standard',percent:0}];
 if(member)options.push({type:'member',percent:settings.memberDiscount});
 for(const type of eligible){if(type==='student')options.push({type,percent:settings.studentDiscount});if(type==='nhs')options.push({type,percent:settings.nhsDiscount});if(type==='older')options.push({type,percent:settings.olderDiscount});}
 if(promo>0)options.push({type:'promo',percent:promo});
 const best=options.sort((a,b)=>b.percent-a.percent)[0];
 return {price:Math.round(base*(100-best.percent)/100),...best};
}
export function packageSaving(ticketSaving:number,fullBundle:boolean,settings:PublicSettings){return fullBundle?Math.max(ticketSaving,settings.packageDiscount):ticketSaving;}
