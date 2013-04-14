<!--#include file="../include.asp"-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Flash 版连连看 - <%=SiteName%></title>
<meta name="keywords" content="<%=sitekeywords%>" />
<meta name="description" content="<%=sitedesc%>" />
<style type="text/css">
*{margin:0;padding:0}
html,body,table{width:100%;height:100%;overflow:hidden;font-size:12px;}
td{text-align:center}
p a{margin:0 10px;}
</style>
</head>
<%
Dim configFile
Select Case Request.QueryString("skin")
Case "love"	:	configFile= "love.xml"
Case "game"	:	configFile= "game.xml"
Case "life"	:	configFile= "life.xml"
Case "flower"	:	configFile= "flower.xml"
Case "constellation"	:	configFile= "constellation.xml"
Case "scenery"	:	configFile= "scenery.xml"
Case "ico"	:	configFile= "ico.xml"
Case Else	:	configFile= "config.xml"
End Select
%>
<body>
<table><tr><td>
<p><a href="?skin=qq">QQ头像</a><a href="?skin=love">爱心头像</a><a href="?skin=game">游戏头像</a><a href="?skin=life">生活表情</a><a href="?skin=constellation">星座头像</a><a href="?skin=scenery">风景头像</a><a href="?skin=ico">黑底图标</a></p>
<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=5,0,0,0" width="900" height="600">
<param name=movie value="LinkGame.swf" ref>
<param name=quality value=High>
<param name="FlashVars" value="xmlfile=<%=configFile%>">
<param name="Src" ref value="LinkGame.swf">
<param name="WMode" value="Window">
<param name="AllowScriptAccess" value="always">
<embed src="LinkGame.swf" flashvars="xmlfile=<%=configFile%>" quality=high pluginspage="http://www.macromedia.com/shockwave/download/index.cgi?P1_Prod_Version=ShockwaveFlash" type="application/x-shockwave-flash" width="900" height="600">
</embed></object>
<p><a href="../link/link.htm">javascript版连连看</a></p>
<div style="display:none">
<script type="text/javascript">
var _bdhmProtocol = (("https:" == document.location.protocol) ? " https://" : " http://");
document.write(unescape("%3Cscript src='" + _bdhmProtocol + "hm.baidu.com/h.js%3F587bfb3d4c469f9904b9ba6004a084ba' type='text/javascript'%3E%3C/script%3E"));
</script>
</div>
</td></tr></table>
</body>
</html>
