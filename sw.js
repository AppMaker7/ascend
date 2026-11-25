const CACHE='ascend-v75';
const FILES=['./','./index.html','./manifest.webmanifest'];
self.addEventListener('install',e=>e.waitUntil((async()=>{
  const cache=await caches.open(CACHE);
  await cache.addAll(FILES);
  await self.skipWaiting();
})()));
self.addEventListener('activate',e=>e.waitUntil((async()=>{
  const keys=await caches.keys();
  await Promise.all(keys.filter(k=>k!==CACHE).map(k=>caches.delete(k)));
  await self.clients.claim();
})()));
self.addEventListener('fetch',e=>{
  if(e.request.method!=='GET')return;
  const url=new URL(e.request.url);
  const isAppDocument=e.request.mode==='navigate'||url.pathname.endsWith('/index.html');
  if(isAppDocument){
    e.respondWith((async()=>{
      try{
        const fresh=await fetch(e.request,{cache:'no-store'});
        if(fresh.ok){
          const cache=await caches.open(CACHE);
          cache.put(e.request,fresh.clone()).catch(()=>{});
        }
        return fresh;
      }catch(error){
        const cached=await caches.match(e.request)||await caches.match('./index.html')||await caches.match('./');
        if(cached)return cached;
        throw error;
      }
    })());
    return;
  }
  e.respondWith(caches.match(e.request).then(r=>r||fetch(e.request)));
});
