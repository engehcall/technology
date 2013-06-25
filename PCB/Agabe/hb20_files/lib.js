




/*
     FILE ARCHIVED ON 23:39:12 Mar 9, 2007 AND RETRIEVED FROM THE
     INTERNET ARCHIVE ON 14:14:44 Mai 24, 2013.
     JAVASCRIPT APPENDED BY WAYBACK MACHINE, COPYRIGHT INTERNET ARCHIVE.

     ALL OTHER CONTENT MAY ALSO BE PROTECTED BY COPYRIGHT (17 U.S.C.
     SECTION 108(a)(3)).
*/
/*startList = function() {
if (document.all&&document.getElementById) {
navRoot = document.getElementById("nav");
for (i=0; i<navRoot.childNodes.length; i++) {
node = navRoot.childNodes[i];
if (node.nodeName=="LI") {
node.onmouseover=function() {
this.className+=" over";
  }
  node.onmouseout=function() {
  this.className=this.className.replace
	(" over", "");
   }
   }
  }
 }
}
window.onload=startList;
*/

function MostraCombo()
{
qtdSelect = document.getElementsByTagName("select");
for (i = 0; i < qtdSelect.length; i++)
{
    objSelect = qtdSelect[i];
    objSelect.style.visibility = "visible";
   }
}

function EscondeCombo()
{
qtdSelect = document.getElementsByTagName("select");
for (i = 0; i < qtdSelect.length; i++)
{
    objSelect = qtdSelect[i];
    objSelect.style.visibility = "hidden";
   }
}

startList = function() {
	if (document.all&&document.getElementById) {
		navRoot = document.getElementById("nav");
		
		for (i=0; i<navRoot.childNodes.length; i++) {
			node = navRoot.childNodes[i];
			if (node.nodeName=="LI") {
				node.onmouseover=function() {
					this.className+=" over";
					EscondeCombo();
				  }
				node.onmouseout=function() {
					this.className=this.className.replace(" over", "");
					MostraCombo();
				}
			}
		  }
	 }
}
window.onload=startList;


function ConteudoFlash(swf,largura,altura,LocalId){
    STRFlash = '<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="/web/20070309233912/http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=7,0,19,0" width="'+largura+'" height="'+altura+'">'
    STRFlash += '<param name="movie" value="'+swf+'" />'
    STRFlash += '<param name="quality" value="high" />'
    STRFlash += '<param name="wmode" value="transparent" />'
    STRFlash += '<embed src="'+swf+'" quality="high" pluginspage="/web/20070309233912/http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" width="'+largura+'" height="'+altura+'" wmode="transparent"></embed>'
    STRFlash += '</object>'
    document.getElementById(LocalId).innerHTML = STRFlash;
} 