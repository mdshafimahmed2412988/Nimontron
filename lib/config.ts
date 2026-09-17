export const initialSettings = {
  brand: "Nimontron", byline: "by Sanzida", fullName: "Nimontron by Sanzida",
  tagline: "Come as a guest. Experience Bangladesh. Leave as family.",
  marketingLine: "An invitation to Bangladesh.",
  adultPrice: 4900, childPrice: 2500, cookingPrice: 3900, photographyPrice: 3900, clothingPrice: 2500,
  memberDiscount: 15, studentDiscount: 10, nhsDiscount: 10, olderDiscount: 10,
  olderAge: 60, olderRule: "above", childMaxAge: 12, childAgeConfirmed: false,
  membershipMethod: "To be confirmed", verification: "on arrival", packageDiscount: 0,
  publicLocation: "United Kingdom · location to be announced", privateAddress: "", revealAddress: false,
  contactEmail: "", contactPhone: "", launchReady: false, demoMode: true,
  photobookDelivery: "Your host will confirm editing, production and delivery arrangements before your event.",
  shippingPrice: 495, shippingEnabled: false, shippingNote: "Collection at your event is available in this preview. Shipping details will be confirmed before launch.",
  partnerName: "Go Plane", partnerUrl: "", partnerApproved: false, partnerMethod: "enquiry",
  instagram: "", facebook: "", youtube: "", tiktok: "", heroVideo: "",
  newsletterEnabled: true, locale: "en-GB", currency: "GBP", timeZone: "Europe/London",
  siteUrl: "https://nimontron-by-sanzida.open-toad-0522.chatgpt.site"
};
export type Settings = typeof initialSettings;
export type PublicSettings = Omit<Settings, "privateAddress">;
export const money = (pence:number) => new Intl.NumberFormat("en-GB",{style:"currency",currency:"GBP",minimumFractionDigits:pence%100===0?0:2}).format(pence/100);
export const dateLabel = (date:string) => new Date(date+"T12:00:00").toLocaleDateString("en-GB",{day:"numeric",month:"long",year:"numeric"});
export const images = {hero:"/images/dawat.webp",street:"/images/fuchka.webp",cooking:"/images/kitchen.webp",tea:"/images/tea-gardens.webp",river:"/images/river.webp",dhaka:"/images/dhaka.webp",cloth:"/images/textiles.webp",craft:"/images/crafts.webp",forest:"/images/sundarbans.webp"};
