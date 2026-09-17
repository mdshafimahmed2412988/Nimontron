import {env} from 'cloudflare:workers';
import {cache} from 'react';
import {cookies} from 'next/headers';
import {getChatGPTUser} from '@/app/chatgpt-auth';
import {initialSettings,type Settings} from './config';
import {legalPages} from './editorial';
import {seedEvents,seedProducts,seedVariants,articles,faqs,regions} from './seed';
import type {EventRecord,Product,Variant,ContentRecord,Profile} from './types';
export const runtimeEnv=()=>env as unknown as Record<string,string|D1Database|R2Bucket|undefined>;
export const database=()=>{if(!env.DB)throw new Error('Our booking service is temporarily unavailable. Please try again shortly.');return env.DB;};
export const now=()=>new Date().toISOString();
export const id=()=>crypto.randomUUID();
export const parse=<T=Record<string,unknown>>(v:string|null|undefined,fallback:T={} as T):T=>{try{return JSON.parse(v||'') as T}catch{return fallback}};
let seeded=false;
export async function initialise(){if(seeded)return;const db=database();const row=await db.prepare('SELECT value FROM settings WHERE key=?').bind('seed_version').first();if(row){seeded=true;return;}
 const rows=[db.prepare('INSERT OR IGNORE INTO locations (id,name,public_area) VALUES (?,?,?)').bind('uk-launch','Launch venue',initialSettings.publicLocation),db.prepare('INSERT OR IGNORE INTO settings (key,value) VALUES (?,?)').bind('brand',JSON.stringify(initialSettings))];
 const insert=(table:string,item:Record<string,unknown>)=>{const keys=Object.keys(item);return db.prepare(`INSERT OR IGNORE INTO ${table} (${keys.join(',')}) VALUES (${keys.map(()=>'?').join(',')})`).bind(...keys.map(k=>item[k]));};
 seedEvents.forEach(e=>rows.push(insert('events',e)));seedProducts.forEach(p=>rows.push(insert('products',p)));seedVariants.forEach(v=>rows.push(insert('variants',v)));articles.forEach(a=>rows.push(insert('content',a)));
 faqs.forEach(([title,body],i)=>rows.push(insert('content',{id:'faq-'+i,type:'faq',title,body,image:'',published:1,data:'{}'})));
 regions.forEach(r=>rows.push(insert('content',{id:'region-'+r.id,type:'region',title:r.name,body:r.text,image:r.image,published:1,data:JSON.stringify(r)})));
 Object.entries(legalPages).forEach(([id,p])=>rows.push(insert('content',{id,type:'legal',title:p.title,body:p.body,image:'',published:1,data:JSON.stringify({approved:false})})));
 rows.push(db.prepare('INSERT OR IGNORE INTO settings (key,value) VALUES (?,?)').bind('seed_version','1'));await db.batch(rows);seeded=true;}
export const getSettings=cache(async():Promise<Settings>=>{try{await initialise();const row=await database().prepare('SELECT value FROM settings WHERE key=?').bind('brand').first<{value:string}>();return {...initialSettings,...parse<Partial<Settings>>(row?.value)};}catch(e){console.error('Settings unavailable',e);return initialSettings;}});
export const getPublicSettings=cache(async()=>{const {privateAddress,...s}=await getSettings();return s;});
export const getEvents=cache(async()=>{await initialise();return (await database().prepare('SELECT * FROM events ORDER BY date,start').all<EventRecord>()).results;});
export const getProducts=cache(async()=>{await initialise();return(await database().prepare('SELECT * FROM products WHERE active=1 ORDER BY featured DESC,name').all<Product>()).results;});
export const getVariants=cache(async()=>{await initialise();return(await database().prepare('SELECT * FROM variants ORDER BY product_id,size').all<Variant>()).results;});
export const getContent=cache(async(type:string)=>{await initialise();return(await database().prepare('SELECT * FROM content WHERE type=? AND published=1 ORDER BY id').bind(type).all<ContentRecord>()).results;});
export const identity=cache(async()=>{const u=await getChatGPTUser();if(!u)return null;await initialise();const adminEmails=String(runtimeEnv().ADMIN_EMAILS||'').split(',').map(x=>x.trim().toLowerCase()).filter(Boolean);const ownerAdmin=adminEmails.includes(u.email.toLowerCase());await database().prepare('INSERT INTO profiles (id,email,name,role,created_at) VALUES (?,?,?,?,?) ON CONFLICT(id) DO UPDATE SET email=excluded.email,name=excluded.name').bind(u.userId,u.email,u.displayName,ownerAdmin?'admin':'customer',now()).run();const profile=await database().prepare('SELECT * FROM profiles WHERE id=?').bind(u.userId).first<Profile>();return {...u,role:ownerAdmin?'admin':profile?.role==='admin'?'customer':profile?.role||'customer'};});
export async function needUser(){const u=await identity();if(!u)throw new HttpError('Please sign in to continue.',401);return u;}
export async function needAdmin(){const u=await needUser();if(!['admin','staff'].includes(u.role))throw new HttpError('This area is for authorised family administrators.',403);return u;}
export async function needOwner(){const u=await needAdmin();if(u.role!=='admin')throw new HttpError('Only an administrator can change these settings.',403);return u;}
export async function cartOwner(create=false){const u=await identity();if(u)return u.userId;const c=await cookies();let v=c.get('nimontron_cart')?.value;if(!v&&create){v=id();c.set('nimontron_cart',v,{httpOnly:true,sameSite:'lax',secure:process.env.NODE_ENV==='production',path:'/',maxAge:60*60*24*30});}return v?'guest:'+v:null;}
export async function mergeCart(){const u=await needUser();const c=await cookies();const v=c.get('nimontron_cart')?.value;if(v)await database().prepare('UPDATE cart_items SET owner=? WHERE owner=?').bind(u.userId,'guest:'+v).run();return u;}
export class HttpError extends Error{constructor(message:string,public status=400){super(message)}}
export function assert(condition:unknown,message:string,status=400):asserts condition{if(!condition)throw new HttpError(message,status);}
export async function checkMutation(req:Request){const origin=req.headers.get('origin');const url=new URL(req.url);if(origin&&new URL(origin).host!==url.host){const s=await getSettings();if(origin!==s.siteUrl)throw new HttpError('Please submit this form from Nimontron.',403);}if(req.headers.get('sec-fetch-site')==='cross-site')throw new HttpError('Cross-site requests are not allowed.',403);}
export async function rateLimit(key:string,max=30){const bucket=Math.floor(Date.now()/60000);const v=await database().prepare('INSERT INTO rate_limits (key,count,window) VALUES (?,1,?) ON CONFLICT(key) DO UPDATE SET count=CASE WHEN window=excluded.window THEN count+1 ELSE 1 END,window=excluded.window RETURNING count').bind(key,bucket).first<{count:number}>();if((v?.count||0)>max)throw new HttpError('Please wait a minute before trying again.',429);}
export async function audit(action:string,entity:string,details:unknown){const u=await needAdmin();await database().prepare('INSERT INTO audit_logs (id,user_id,action,entity_id,details,created_at) VALUES (?,?,?,?,?,?)').bind(id(),u.userId,action,entity,JSON.stringify(details),now()).run();}
