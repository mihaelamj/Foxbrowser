(function(){var e,t;e=function(e,t){return Array.prototype.slice.call(t.querySelectorAll(e))};var n=function(){for(var e={},t=[],n=0;n<256;n++)t[n]=(n<16?"0":"")+n.toString(16);return e.generate=function(){var e=4294967295*Math.random()|0,n=4294967295*Math.random()|0,i=4294967295*Math.random()|0,l=4294967295*Math.random()|0;return t[255&e]+t[e>>8&255]+t[e>>16&255]+t[e>>24&255]+"-"+t[255&n]+t[n>>8&255]+"-"+t[n>>16&15|64]+t[n>>24&255]+"-"+t[63&i|128]+t[i>>8&255]+"-"+t[i>>16&255]+t[i>>24&255]+t[255&l]+t[l>>8&255]+t[l>>16&255]+t[l>>24&255]},e}();t=function(){function t(e){this.window=e,this.init()}return t.create=function(e){return new t(e)},t.prototype.version="1.10",t.prototype.id=n.generate(),t.prototype.eventStream=[],t.prototype.submitting=!1,t.prototype.done=!1,t.prototype.timing={start:Date.now(),end:null},t.prototype.mappings=null,t.prototype.fields=null,t.prototype.autofillUsed=!1,t.prototype.handlers={formSubmitted:function(e){var t,n,i,l,o;if("button"===(null!=e&&null!=(t=e.target)&&null!=(n=t.nodeName)?n.toLowerCase():void 0)||"submit"===(null!=e&&null!=(i=e.target)&&null!=(l=i.type)?l.toLowerCase():void 0))return this.timing.end=Date.now(),this.eventStream.push({message:"formSubmitted",timestamp:Date.now(),buttonHTML:null!=e&&null!=(o=e.target)?o.outerHTML:void 0})},abandon:function(e){return this.timing.end=Date.now(),this.eventStream.push({message:"formAbandoned",timestamp:Date.now()}),this.sendReport()},filled:function(e){var t,n,i,l,o,s,r,d,a,u,h,m,f,p,c,g,v;return this.autofillUsed=!0,this.mappings=e.mappings,this.filledDataKeys=e.filledDataKeys,s=null!=e&&null!=(r=e.mappings)&&null!=(d=r.fields)?d.length:void 0,i=null!=e&&null!=(u=e.mappings)&&null!=(h=u.fields)?h.filter(function(e){return"ignore"===e.param}).length:void 0,l=s-i,n="undefined"!=typeof document&&null!==document&&null!=(m=document.querySelectorAll(".pop-filled"))?m.length:void 0,o=null!=e&&null!=(f=e.mappings)&&null!=(p=f.fields)?p.filter(function(e){return"Passwords.Password.Password"===e.param}).length:void 0,t=null!=e&&null!=(c=e.mappings)&&null!=(g=c.fields)?g.filter(function(e){return"CreditCards.CreditCard.Number"===e.param}).length:void 0,this.eventStream.push({message:"fillSummary",timestamp:Date.now(),ignored:i,total:s,autofilled:n,mapped:l,fill_id:null!=e&&null!=(v=e.mappings)?v.fill_id:void 0,passwords:o,creditCards:t}),null!=e&&null!=(a=e.mappings)?a.fields.map(function(e){return function(t){return e.eventStream.push({message:"ignore"===t.param?"fieldIgnored":"fieldAutofilled",param:t.param,id:t.pop_id})}}(this)):void 0},keypress:function(e){var t,n,i,l;if(!0!==(null!=e?e.isFillrWidgetEvent:void 0))return this._isInput(null!=e?e.target:void 0)?(t=e.target,this.eventStream.push({message:"fieldChanged",id:t.nodeName.toLowerCase()+"#"+t.id+"."+t.name+"."+(null!=t&&null!=(n=t.attributes.class)&&null!=(i=n.value)&&null!=(l=i.split(" "))?l.join("."):void 0),timestamp:Date.now(),afterAutofill:this.autofillUsed})):void 0}},t.prototype.listeners={formSubmitted:null,abandon:null,filled:null,keypress:null},t.prototype.init=function(){return this.fields=e("input:not([type=hidden]),select,textarea",this.window.document),this.attachHandlers()},t.prototype.attachHandlers=function(){return this.clearHandlers(),this.listeners.formSubmitted=this.handlers.formSubmitted.bind(this),this.listeners.abandon=this.handlers.abandon.bind(this),this.listeners.filled=this.handlers.filled.bind(this),this.listeners.keypress=this.handlers.keypress.bind(this),this.window.document.addEventListener("click",this.listeners.formSubmitted,!0),this.isIOS()?this.window.addEventListener("pagehide",this.listeners.abandon,!0):this.window.addEventListener("beforeunload",this.listeners.abandon,!0),this.window.document.addEventListener("Fillr:fill:done",this.listeners.filled,!0),this.window.document.addEventListener("keyup",this.listeners.keypress,!0),this.window.document.addEventListener("submit",this.listeners.formSubmitted,!0),console.log("Fillr Abandonment attached")},t.prototype.clearHandlers=function(){return this.window.document.removeEventListener("click",this.listeners.formSubmitted,!0),this.window.removeEventListener("beforeunload",this.listeners.abandon,!0),this.window.removeEventListener("pagehide",this.listeners.abandon,!0),this.window.document.removeEventListener("Fillr:fill:done",this.listeners.filled,!0),this.window.document.removeEventListener("keyup",this.listeners.keypress,!0),this.window.document.removeEventListener("submit",this.listeners.formSubmitted,!0),this.listeners.formSubmitted=null,this.listeners.abandon=null,this.listeners.filled=null,this.listeners.keypress=null},t.prototype._isInput=function(e){var t,n;return t=null!=e&&null!=(n=e.nodeName)?n.toLowerCase():void 0,["input","select","password","textarea"].indexOf(t)>-1},t.prototype.sendReport=function(e){var t,n;if(!this.done&&(null!=(e=this.collateReport())?e.total:void 0)>0)return"undefined"!=typeof fillrAbandonmentJNI&&null!==fillrAbandonmentJNI?"undefined"!=typeof fillrAbandonmentJNI&&null!==fillrAbandonmentJNI&&fillrAbandonmentJNI.report(JSON.stringify(e)):this.isIOS()&&(null!=(null!=(t=this.window.webkit)&&null!=(n=t.messageHandlers)?n.abandonmentReportHandler:void 0)?this.window.webkit.messageHandlers.abandonmentReportHandler.postMessage(JSON.stringify(e)):console.log("Fillr webkit messageHandlers not defined")),this.done=!0},t.prototype.collateReport=function(){var e,t,n,i,l,o,s,r,d,a,u,h,m,f,p,c,g,v;return l=this.eventStream.filter(function(e){return"formSubmitted"===e.message}).length>0?"submitted":"abandoned",i=this.eventStream.filter(function(e){return"fieldIgnored"===e.message}),n=this.groupByPopId(this.eventStream.filter(function(e){return"fieldChanged"===e.message})),t=this.groupByPopId(this.eventStream.filter(function(e){return"fieldChanged"===e.message&&!e.afterAutofill})),e=this.groupByPopId(this.eventStream.filter(function(e){return"fieldChanged"===e.message&&e.afterAutofill})),o=this.eventStream.filter(function(e){return"fillSummary"===e.message}),{id:this.id,type:l,timeOnPage:this.timing.end-this.timing.start,version:this.version,domain:document.location.hostname,path:document.location.pathname,href:document.location.href,autofillUsed:(null!=o?o.length:void 0)>0,total:(null!=(s=o[0])?s.total:void 0)||(null!=(r=this.fields)?r.length:void 0),autofilled:(null!=(u=o[0])?u.autofilled:void 0)>0?null!=(h=o[0])?h.autofilled:void 0:null,ignored:(null!=i?i.length:void 0)>0?null!=i?i.length:void 0:null,fill_id:null!=(m=o[0])?m.fill_id:void 0,passwords:null!=(f=o[0])?f.passwords:void 0,cards:null!=(p=o[0])?p.creditCards:void 0,changedCount:null!=(c=Object.keys(n||{}))?c.length:void 0,changedBeforeFill:(null!=(g=Object.keys(n||{}))?g.length:void 0)>0?null!=(v=Object.keys(t||{}))?v.length:void 0:null,changedAfterFill:(null!=(d=Object.keys(n||{}))?d.length:void 0)>0?null!=(a=Object.keys(e||{}))?a.length:void 0:null}},t.prototype.fieldStats=function(){return this.eventStream.filter(function(e){return~["fieldChanged","fieldAutoFilled","fieldIgnored"].indexOf(e.message)})},t.prototype.groupByPopId=function(e){var t,n,i,l,o;for(n={},i=0,l=e.length;i<l;i++)null==n[o=(t=e[i]).id]&&(n[o]=[]),n[t.id].push(t);return n},t.prototype.isIOS=function(){return/iPad|iPhone|iPod/.test(this.window.navigator.userAgent)&&!this.window.MSStream},t}(),null==window.FillrAbandonmentAnalytics&&(window.FillrAbandonmentAnalytics=t.create(window))}).call(this);