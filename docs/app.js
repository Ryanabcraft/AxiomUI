const navToggle=document.querySelector('.nav-toggle');
const nav=document.querySelector('#site-nav');

if(location.hash){
  window.addEventListener('load',async()=>{
    await document.fonts?.ready;
    const target=document.getElementById(decodeURIComponent(location.hash.slice(1)));
    target?.scrollIntoView({block:'start'});
  },{once:true});
}

navToggle?.addEventListener('click',()=>{
  const open=nav.classList.toggle('open');
  navToggle.setAttribute('aria-expanded',String(open));
});

document.querySelectorAll('a[href^="#"]').forEach(link=>link.addEventListener('click',event=>{
  const target=document.getElementById(decodeURIComponent(link.hash.slice(1)));
  if(!target)return;
  event.preventDefault();
  const behavior=matchMedia('(prefers-reduced-motion: reduce)').matches?'auto':'smooth';
  target.scrollIntoView({behavior,block:'start'});
  history.pushState(null,'',link.hash);
  nav?.classList.remove('open');
  navToggle?.setAttribute('aria-expanded','false');
}));

async function copyText(text){
  if(navigator.clipboard&&window.isSecureContext){
    try{
      await navigator.clipboard.writeText(text);
      return;
    }catch{}
  }
  const area=document.createElement('textarea');
  area.value=text;
  area.style.position='fixed';
  area.style.opacity='0';
  document.body.appendChild(area);
  area.select();
  const copied=document.execCommand('copy');
  area.remove();
  if(!copied)throw new Error('Copy unavailable');
}

document.querySelectorAll('[data-copy]').forEach(button=>{
  button.addEventListener('click',async()=>{
    const target=document.getElementById(button.dataset.copy);
    if(!target)return;
    try{
      await copyText(target.textContent.trim());
      const toast=document.querySelector('.copy-toast');
      toast.classList.add('show');
      button.textContent='Copiado';
      window.setTimeout(()=>{toast.classList.remove('show');button.textContent='Copiar'},1400);
    }catch{
      button.textContent='Selecione o código';
    }
  });
});
