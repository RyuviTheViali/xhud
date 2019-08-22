if SERVER then
	do util.AddNetworkString("sls-netchannel") end
	
	local functypes = {}
	functypes.Kill = function(p,v,g)
		if not v:Alive() then return end
		xsys.CallCommand(p,"kill","",{v:Nick()})
	end
	functypes.Slay = function(p,v,g)
		if not v:Alive() then return end
		xsys.CallCommand(p,"slay","",{v:Nick()})
	end
	functypes.Revive = function(p,v,g)
		if v:Alive() then return end
		xsys.CallCommand(p,"revive","",{v:Nick()})
	end
	functypes.Bring = function(p,v,g)
		if not v:Alive() then return end
		xsys.CallCommand(p,"bring","",{v:Nick()})
	end
	functypes.Kick = function(p,v,g)
		xsys.CallCommand(p,"kick","",{v:Nick(),"Quick Kick"})
	end
	functypes.Goto = function(p,v,g)
		xsys.CallCommand(p,"goto","",{v:Nick()})
	end
	functypes.Strip = function(p,v,g)
		xsys.CallCommand(p,"strip","",{v:Nick()})
	end
	functypes.Drop = function(p,v,g)
		xsys.CallCommand(p,"drop","",{v:Nick()})
	end
	functypes.Cleanup = function(p,v,g)
		xsys.CallCommand(p,"cleanup","",{v:Nick()})
	end
	functypes.SetGroup = function(p,v,g)
		xsys.CallCommand(p,"rank","",{v:Nick(),g[1]})
	end
	functypes.Freeze = function(p,v,g)
		xsys.CallCommand(p,"freeze","",{v:Nick()})
	end
	functypes.God = function(p,v,g)
		xsys.CallCommand(p,"god","",{v:Nick()})
	end
	
	net.Receive("sls-netchannel",function(l,p)
		local ftype = net.ReadString()
		local tar   = net.ReadEntity()
		local other = net.ReadTable()
		if functypes[ftype] then
			functypes[ftype](p,tar,other)
		end
	end)
end

if CLIENT then
	local function RunXScore()
	local GM = GM == nil and GAMEMODE or GM

	StarlightScoreVis = StarlightScoreVis or false
	GM.ShowScoreboard = GM.ShowScoreboard or false	
	
	surface.CreateFont("sls massive" ,{font="Helvetica",size=100,weight=0  ,antialias=true})
	surface.CreateFont("sls huge"    ,{font="Helvetica",size=75 ,weight=0  ,antialias=true})
	surface.CreateFont("sls host"    ,{font="Helvetica",size=40 ,weight=0  ,antialias=true})
	surface.CreateFont("sls bigtitle",{font="Helvetica",size=36 ,weight=700,antialias=true})
	surface.CreateFont("sls title"   ,{font="Helvetica",size=23 ,weight=700,antialias=true})
	surface.CreateFont("sls bigroll" ,{font="Helvetica",size=48 ,weight=700,antialias=true})
	surface.CreateFont("sls bigdata" ,{font="Helvetica",size=23 ,weight=700,antialias=true})
	surface.CreateFont("sls data"    ,{font="Helvetica",size=14 ,weight=700,antialias=true})
	
	local ox,oy       = ScrW()/2,ScrH()/2-ScrH()/6
	local ow,oh       = ScrW()/2,ScrH()/3
	local x,y         = ScrW()/2,ScrH()/2-ScrH()/6
	local w,h         = ScrW()/2,ScrH()/3	
	local cx,cy       = ScrW()/2,ScrH()/2-ScrH()/6
	local cw,ch       = ScrW()/2,ScrH()/3	
	local alpha       = 128
	local inl,inll    = 0,0
	local l,ll,il,ill = 0,0,0,0
	local cl,cll      = 0,0
	local g,gg        = 0,0
	local ina,inb,inc = 0,0,0
	local a,b,c       = 0,0,0
	local x1,x2,y1,y2 = 0,0,0,0
	local bgcol       = Color(0,0,0,alpha)
	local blur        = Material("pp/blurscreen")
	local glowmat     = Material("particle/particle_glow_05_addnofog")
	local maxsprites  = 24
	local sprites     = {}
	local speed       = 16
	local lspd        = 0.5
	
	local btndoub     = {}
	local grpenab     = false
	local grpdrop     = 0
	local grpordr     = {}
	
	local p           = {}
	local pdata       = {}
	local pdtcool     = CurTime()
	local ctxmenu     = NULL
	local txtmatx     = Matrix()
	
	local context     = false
	local ctxcool     = CurTime()
	
	local dptmenu     = NULL
	local indepth     = false
	local dptcool     = CurTime()
	local dptcply     = NULL
	
	function GM:ScoreboardShow()
		GM.ShowScoreboard = true
		StarlightScoreVis = true
		return true
	end
	
	function GM:ScoreboardHide() 
		StarlightScoreVis = false
		return true
	end
	
	local function CreateCTXMenu()
		if ctxmenu:IsValid() then ctxmenu:Remove() end
		local mu = vgui.Create("DFrame")
		mu:SetPos(0,0)
		mu:SetSize(ScrW(),ScrH())
		mu:SetTitle("")
		mu:SetVisible(true)
		mu:SetDraggable(false)
		mu:ShowCloseButton(true)
		mu.Paint = function(s,w,h) return true end
		mu.OnClose = function() end
		mu:MakePopup()
		ctxmenu = mu
	end
	
	local function ShowCTXMenu()
		if not ctxmenu or not ctxmenu:IsValid() then CreateCTXMenu() end
		if ctxmenu:IsVisible() then return end
		ctxmenu:SetVisible(true)
	end
	
	local function HideCTXMenu()
		if not ctxmenu or not ctxmenu:IsValid() then CreateCTXMenu() end
		if not ctxmenu:IsVisible() then return end
		ctxmenu:SetVisible(false)
		if context then context = false end
		for k,v in pairs(btndoub) do
			btndoub[k] = false
		end
	end
	
	local function CreateDPTMenu()
		if dptmenu:IsValid() then dptmenu:Remove() end
		local mu = vgui.Create("DFrame")
		mu:SetPos(ScrW()/2-ScrW()/6,ScrH()/2-ScrH()/6)
		mu:SetSize(ScrW()/3,ScrH()/3)
		mu:SetTitle("")
		mu:SetVisible(true)
		mu:SetDraggable(false)
		mu:ShowCloseButton(false)
		mu.Paint = function(s,w,h) return true end
		mu.OnClose = function() indepth = false end
		mu:MakePopup()
		dptmenu = mu	
	end
	
	local function ShowDPTMenu(ply)
		if not dptmenu or not dptmenu:IsValid() then CreateDPTMenu() end
		if dptmenu:IsVisible() then return end
		dptcply = ply
		dptmenu:SetVisible(true)
		dptmenu:RequestFocus()
	end
	
	local function HideDPTMenu()
		if not dptmenu or not dptmenu:IsValid() then CreateDPTMenu() end
		if not dptmenu:IsVisible() then return end
		dptmenu:SetVisible(false)
		if indepth then indepth = false end
		if grpenab then grpenab = false end
		for k,v in pairs(btndoub) do
			btndoub[k] = false
		end
	end
	
	local function DrawSprites(ct,s,a,d,x,y,l,rl,c)
		local alp = 0
		if (l-ct)/rl <= -0.66 then
			alp = math.Clamp(math.Remap((l-ct)/rl,-1,-0.66,0,255),0,255)
		elseif (l-ct)/rl >= -0.66 and (l-ct)/rl <= -0.33 then
			alp = 255
		else
			alp = math.Clamp(math.Remap((l-ct)/rl,-0.33,0,255,0),0,255)
		end
		surface.SetMaterial(glowmat)
		surface.SetDrawColor(Color(c.r,c.g,c.b,alp*c.a))
		surface.DrawTexturedRect(x-128*s,y-128*s,256*s,256*s)
	end
	
	local function NewSprite(ret)
		local ltr = CurTime()+math.random(5,9)
		local npx = math.random() > 0.5 and math.random(ScrW()/2+ScrW()/3,ScrW()/1.5) or math.random(ScrW()/3,-ScrW()/1.5)
		local npy = math.random() > 0.5 and math.random(ScrW()/2+ScrW()/3,ScrW()/1.5) or math.random(ScrW()/3,-ScrW()/1.5)
		local fcl = Color(math.random(64,128),math.random(64,255),math.random(64,255))
		local ncl = Color(math.random(64,255),math.random(64,255),math.random(64,255))
		if not ret then
			sprites[#sprites+1] = {math.random(18,28),0,Vector(math.random(-0.5,0.5),math.random(-0.5,0.5)),npx,npy,ltr,CurTime()-ltr,ncl}
		else
			sprites[ret]        = {math.random(18,28),0,Vector(math.random(-0.5,0.5),math.random(-0.5,0.5)),npx,npy,ltr,CurTime()-ltr,fcl}
		end
	end
	
	local function CursorWithin(x,y,w,h)
		local cx,cy = gui.MousePos()
		if cx >= x and cx <= x+w then
			if cy >= y and cy <= y+h then
				return true
			end
		end
		return false
	end
	
	local function TextButton(t,f,x,y)
		surface.SetFont(f)
		local tx,ty = surface.GetTextSize(t)
		local hov,cli = false,false
		if CursorWithin(x-tx/2,y-ty/2,tx,ty) then
			hov = true
			if input.IsButtonDown(MOUSE_LEFT) then
				cli = true
			else
				cli = false
			end
		else
			hov = false
		end
		return hov,cli
	end
	
	local function DepthButton(id,d,ac,t,f,x,y,w,h,a,c,cb)
		btndoub[id] = btndoub[id] or false
		t = type(t) == "table" and t or {t}
		if d then
			local hh,cc = CursorWithin(x,y,w,h),CursorWithin(x,y,w,h) and input.IsMouseDown(MOUSE_LEFT)
			draw.RoundedBox(0,x,y,w,h,Color(c.r,c.g,c.b,a/2))
			surface.SetDrawColor(Color(128,128,128,a))
			surface.DrawOutlinedRect(x,y,w,h)
			if hh then
				surface.SetDrawColor(Color(128,128,255,a))
				surface.DrawOutlinedRect(x,y,w,h)
				if cc and dptcool-CurTime() <= 0 then
					surface.SetDrawColor(Color(255,0,0,a))
					surface.DrawOutlinedRect(x,y,w,h)
					if t[2] then
						if btndoub[id] then
							cb()
							if ac then HideDPTMenu() end
							btndoub[id] = false
						else
							btndoub[id] = true
						end
					else
						cb()
						if ac then HideDPTMenu() end
					end
					dptcool = CurTime()+0.25
				end
			end
			draw.SimpleTextOutlined(btndoub[id] and t[2] or t[1],f,x+w/2,y+h/2,Color(255,255,255,a),1,1,1,Color(0,0,0,a))
		else
			draw.RoundedBox(0,x,y,w,h,Color(c.r,c.g,c.b,a/2))
			surface.SetDrawColor(Color(128,64,64,a))
			surface.DrawOutlinedRect(x,y,w,h)
			draw.SimpleTextOutlined(t[1],f,x+w/2,y+h/2,Color(80,80,80,a),1,1,1,Color(0,0,0,a))
		end
	end
	
	local function SendCommand(ftype,tar,...)
		local other = {...}
		net.Start("sls-netchannel")
			net.WriteString(ftype)
			net.WriteEntity(tar)
			net.WriteTable(other)
		net.SendToServer()
	end
	
	function GM:HUDDrawScoreBoard()
		if not GM.ShowScoreboard then return end
		local vis = StarlightScoreVis
		if not vis then HideCTXMenu() HideDPTMenu() end
		g,gg      = math.sin(CurTime()+0.66)*0.05,math.sin(CurTime())*0.05
		inl,inll  = vis and AdvLerp(inl,0,1,1,speed,0.01) or AdvLerp(inl,0,1,-1,speed,0.01),vis and AdvLerp(inll,0,1,1,speed*2,0.01) or AdvLerp(inll,0,1,-1,speed,0.01)
		l,ll      = inl,inll
		cl,cll    = inl,inll
		l,ll      = vis and l+g or l,vis and ll+gg or ll
		ina,inb   = vis and AdvLerp(ina,0,1,1,5,0.01) or AdvLerp(ina,0,1,-1,speed,0.01),context and AdvLerp(inb,0,1,1,speed,0.01) or AdvLerp(inb,0,1,-1,speed,0.01)
		inc       = indepth and AdvLerp(inc,0,1,1,speed/2,0.01) or AdvLerp(inc,0,1,-1,speed,0.01)
		a,b,c     = ina,inb,inc
		if not vis and l <= 0 and ll <= 0 then return end
		if vis and not context and input.IsMouseDown(MOUSE_RIGHT) and ctxcool-CurTime() <= 0 then context,ctxcool = true ,CurTime()+0.25 end
		if vis and     context and input.IsMouseDown(MOUSE_RIGHT) and not indepth and ctxcool-CurTime() <= 0 and dptcool-CurTime() <= 0 then context,ctxcool = false,CurTime()+0.25 end
		if vis and     context and input.IsMouseDown(MOUSE_RIGHT) and indepth and ctxcool-CurTime() <= 0 then HideDPTMenu() dptcool = CurTime()+0.25 end
		if not vis and context then context,ctxcool = false,CurTime() end
		if context then ShowCTXMenu() else HideCTXMenu() HideDPTMenu() end
		cx,cy = context and Lerp(lspd,cx,ScrW()/2) or Lerp(lspd,cx,x),vis and (context and Lerp(lspd,cy,ScrH()/2) or Lerp(lspd,cy,y)) or Lerp(lspd,cy,oy)
		cw,ch = context and Lerp(lspd,cw,ScrW()) or (vis and Lerp(lspd,cw,w) or Lerp(lspd,cw,cl*w)),context and Lerp(lspd,ch,ScrH()) or (vis and Lerp(lspd,ch,h) or Lerp(lspd,ch,cll*h))
		y,w,h = context and Lerp(lspd,y,ScrH()/2) or Lerp(lspd,y,oy),context and Lerp(lspd,w,ScrW()*1.5) or Lerp(lspd,w,ow),context and Lerp(lspd,h,ScrH()*1.5) or Lerp(lspd,h,oh)
		x1,x2,y1,y2 = (x-l*w*0.8)+5,(x+l*w*0.8)-5,(y-ll*h*0.2)+5,(y+ll*h*0.2)-5
		local p1 = {
			{["x"]=x1-5,["y"]=y,	["u"]=x1/ScrW(),["v"]=y /ScrH()},
			{["x"]=x,	["y"]=y1-5,	["u"]=x /ScrW(),["v"]=y1/ScrH()},
			{["x"]=x2+5,["y"]=y,	["u"]=x2/ScrW(),["v"]=y /ScrH()},
			{["x"]=x,	["y"]=y2+5,	["u"]=x /ScrW(),["v"]=y2/ScrH()}
		}
		x1,x2,y1,y2 = (x-l*w*0.7)+5,(x+l*w*0.7)-5,(y-ll*h*0.5)+5,(y+ll*h*0.5)-5
		local p2 = {
			{["x"]=x1-5,["y"]=y,	["u"]=x1/ScrW(),["v"]=y /ScrH()},
			{["x"]=x,	["y"]=y1-5,	["u"]=x /ScrW(),["v"]=y1/ScrH()},
			{["x"]=x2+5,["y"]=y,	["u"]=x2/ScrW(),["v"]=y /ScrH()},
			{["x"]=x,	["y"]=y2+5,	["u"]=x /ScrW(),["v"]=y2/ScrH()}
		}
		x1,x2,y1,y2 = (x-l*w*0.4)+5,(x+l*w*0.4)-5,(y-ll*h*0.6)+5,(y+ll*h*0.6)-5
		 local p3 = {
			{["x"]=x1-5,["y"]=y,	["u"]=x1/ScrW(),["v"]=y /ScrH()},
			{["x"]=x,	["y"]=y1-5,	["u"]=x /ScrW(),["v"]=y1/ScrH()},
			{["x"]=x2+5,["y"]=y,	["u"]=x2/ScrW(),["v"]=y /ScrH()},
			{["x"]=x,	["y"]=y2+5,	["u"]=x /ScrW(),["v"]=y2/ScrH()}
		}
		if #sprites <= maxsprites then NewSprite() end
		for i=1,#sprites do
			if CurTime()-sprites[i][6] >= 0 then NewSprite(i) end
			sprites[i][4] = sprites[i][4]+sprites[i][3].x*FrameTime()*32
			sprites[i][5] = sprites[i][5]+sprites[i][3].y*FrameTime()*32
			sprites[i][8].a = a*0.5
			DrawSprites(CurTime(),unpack(sprites[i]))
		end
		surface.SetMaterial(blur)
		for i=0.25,1,0.25 do
			blur:SetInt("$blur",10*i)
			render.UpdateScreenEffectTexture()
			surface.SetDrawColor(0,0,0,255)
			surface.DrawPoly(p1)
			surface.DrawPoly(p2)
			surface.DrawPoly(p3)
			surface.SetDrawColor(bgcol)
		end
		surface.SetTexture(surface.GetTextureID("vgui/white"))
		surface.SetDrawColor(bgcol)
		surface.DrawPoly(p1)
		surface.DrawPoly(p2)
		surface.DrawPoly(p3)
		draw.SimpleTextOutlined("X E N O R A",context and "sls massive" or "sls huge",cx,cy-ch/2*0.85,Color(255,255,255,a*180),1,1,1,Color(0,0,0,a*64))
		
		local cppiowners = {}

		for k,v in pairs(player.GetAll()) do
			p[#p+1] = v
			cppiowners[v] = 0
		end
		table.sort(p,function(a,b) return a:EntIndex() < b:EntIndex() end)

		for k,v in pairs(ents.GetAll()) do
			if v:EntIndex() <= 0 then continue end
			local e = v:CPPIGetOwner()
			if not e or not e:IsValid() then continue end
			if v:GetClass() == "gmod_hands" or v:GetClass() == "physgun_beam" then continue end
			cppiowners[e] = cppiowners[e]+1
		end
		
		local datafont  = context and "sls bigdata"  or "sls data"
		local titlefont = context and "sls bigtitle" or "sls title"
		
		draw.SimpleTextOutlined("Friend Status",titlefont,cx-cw/2*0.85,-ch*0.25+cy+(15+b*20),Color(255,255,255,a*255),1,1,1,Color(0,0,0,a*255))
		draw.SimpleTextOutlined("Ping"         ,titlefont,cx-cw/2*0.63,-ch*0.25+cy+(15+b*20),Color(255,255,255,a*255),1,1,1,Color(0,0,0,a*255))
		draw.SimpleTextOutlined("Hours"        ,titlefont,cx-cw/2*0.47,-ch*0.25+cy+(15+b*20),Color(255,255,255,a*255),1,1,1,Color(0,0,0,a*255))
		draw.SimpleTextOutlined("Props"        ,titlefont,cx-cw/2*0.30,-ch*0.25+cy+(15+b*20),Color(255,255,255,a*255),1,1,1,Color(0,0,0,a*255))
		draw.SimpleTextOutlined("Name"         ,titlefont,cx          ,-ch*0.25+cy+(15+b*20),Color(255,255,255,a*255),1,1,1,Color(0,0,0,a*255))
		draw.SimpleTextOutlined("Stats"        ,titlefont,cx+cw/2*0.30,-ch*0.25+cy+(15+b*20),Color(255,255,255,a*255),1,1,1,Color(0,0,0,a*255))
		draw.SimpleTextOutlined("Index"        ,titlefont,cx+cw/2*0.44,-ch*0.25+cy+(15+b*20),Color(255,255,255,a*255),1,1,1,Color(0,0,0,a*255))
		draw.SimpleTextOutlined("Steam ID"     ,titlefont,cx+cw/2*0.63,-ch*0.25+cy+(15+b*20),Color(255,255,255,a*255),1,1,1,Color(0,0,0,a*255))
		draw.SimpleTextOutlined("Group"        ,titlefont,cx+cw/2*0.85,-ch*0.25+cy+(15+b*20),Color(255,255,255,a*255),1,1,1,Color(0,0,0,a*255))
		
		for k,v in pairs(p) do
			local ct = #p
			local frnd,ping,hour = v:GetFriendStatus(),v:Ping(),math.Round(v:GetUTimeTotalTime()/3600)
			local name           = v:Nick():gsub("%^%d+", ""):gsub("<(.-)=(.-)>", "")
			local enid,stid,grou = v:EntIndex(),v:SteamID(),team.GetName(v:Team())
			local teamcol        = team.GetColor(v:Team())
			teamcol.a            = a*255
			grou = grou:sub(1,1):upper()..(grou:sub(-1) == "s" and grou:sub(2,-2) or grou:sub(2,nil))
			local invcol         = teamcol == Color(0,0,0,teamcol.a) and true or false
			local propcount      = cppiowners[v] or 0
			frnd = v == LocalPlayer() and "Yourself" or v:IsBot() and "Bot" or (frnd == "friend" and "Friend" or frnd == "blocked" and "Blocked" or "Not A Friend")
			ping = v:IsBot() and "N/A" or ping
			enid = "{"..enid.."}"
			stid = v:IsBot() and "STEAM_0:0:BOT" or stid
			pdata[v] = pdata[v] or {}
			local pdat  = {{frnd,0.85},{ping,0.63},{hour,0.47},{propcount,0.30},{name,0},{"hp-ar",-0.30},{enid,-0.44},{stid,-0.63},{grou,-0.85}}
			local cantar = LocalPlayer():CheckUserGroupLevel(v:GetUserGroup())
			local godded = v:GetNetData("GodMode")
			
			local usable = true

			usable = not indepth and (v ~= LocalPlayer())
			DepthButton(2000,usable,true,v:IsMuted() and "UNMUTE" or "MUTE","sls data",cx-cw/2*0.15-39+22,-ch*0.2+cy+k*cll*(15+b*20)-10,39,20,b*255,Color(0,0,0),function()
				v:SetMuted(not v:IsMuted())
			end)

			usable = not indepth and (LocalPlayer():CheckUserGroupLevel("designers") and cantar or (cantar and (v == LocalPlayer())))
			DepthButton(2001,usable,true,"CLEAN","sls data",cx-cw/2*0.15-39-22,-ch*0.2+cy+k*cll*(15+b*20)-10,39,20,b*255,Color(0,0,0),function()
				SendCommand("Cleanup",v)
			end)
			
			usable = not indepth and (v ~= LocalPlayer())
			DepthButton(2003,usable,true,"GOTO","sls data",cx-cw/2*-0.15-22,-ch*0.2+cy+k*cll*(15+b*20)-10,39,20,b*255,Color(0,0,0),function()
				SendCommand("Goto",v)	
			end)
			
			usable = not indepth and (v ~= LocalPlayer()) and cantar
			DepthButton(2004,usable,true,"BRING","sls data",cx-cw/2*-0.15+22,-ch*0.2+cy+k*cll*(15+b*20)-10,39,20,b*255,Color(0,0,0),function()
				SendCommand("Bring",v)	
			end)
			
			for kk,vv in ipairs(pdat) do
				if vv[1] == "hp-ar" then
					local ddx,ddy = cx-cw/2*vv[2],-ch*0.2+cy+k*cll*(15+b*20)
					draw.RoundedBox(0,ddx-30-b*30,ddy-3-b*3,60+b*60,6+b*6,Color(0,0,0,a*180))
					local hp,ar = math.Clamp(v:Health()/v:GetMaxHealth(),0,1),math.Clamp(v:Armor()/(v:Armor() <= 200 and 200 or 255),0,1)
					local hpcol = v:Health()/v:GetMaxHealth() <= 1 and Color(hp <= 0.25 and math.abs(math.sin(CurTime()*6)*255) or 255,64,64,a*128) or Color(255,200,64,a*128)
					local arcol = Color(64,ar <= 0.25 and math.abs(math.sin(CurTime()*6)*255) or 255,64,a*128)
					if godded then
						hpcol = Color(180,80,255,a*128)
					end
					draw.RoundedBox(0,ddx-30-b*30,ddy-3-b*3,(60+b*60)*hp,(ar == 0 and 6 or 3)+b*(ar == 0 and 6 or 3),hpcol)
					draw.RoundedBox(0,ddx-30-b*30,ddy      ,(60+b*60)*ar,3+b*3,arcol)
				else
					local ddx,ddy = cx-cw/2*vv[2],-ch*0.2+cy+k*cll*(15+b*20)
					local hh,cc = TextButton(vv[1],datafont,ddx,ddy)
					local ready = hh and not indepth and dptcool-CurTime() <= 0
					local fo    = ready and "sls bigroll" or datafont
					local col   = ready and (cc and Color(0  ,0,0,a*255) or (invcol and Color(255,255,255,a*255) or Color(0,0,0,a*255))	) or teamcol
					local oul   = ready and (cc and Color(255,0,0,a*255) or teamcol) or (invcol and Color(255,255,255,a*255) or Color(0,0,0,a*255))
					pdata[v][kk] = pdata[v][kk] or 0.5
					pdata[v][kk] = ready and Lerp(0.5,pdata[v][kk],1) or Lerp(0.25,pdata[v][kk],0.5)
					txtmatx:Translate(Vector(ddx,ddy))
					txtmatx:SetScale(Vector(pdata[v][kk],pdata[v][kk],pdata[v][kk]))
					txtmatx:SetTranslation(Vector(ddx,ddy))
					txtmatx:Translate(-Vector(ddx,ddy))
					if not ready and pdata[v][kk] <= 1 then
						draw.SimpleTextOutlined(vv[1],fo,ddx,ddy,col,1,1,1,oul)
					else
						cam.PushModelMatrix(txtmatx)
							draw.SimpleTextOutlined(vv[1],fo,ddx,ddy,col,1,1,1,oul)
						cam.PopModelMatrix()
					end
					if ready and cc and pdtcool-CurTime() <= 0 then
						if kk == 5 then
							pdtcool = CurTime()+0.45
							indepth,dptcool = true,CurTime()+0.25
							ShowDPTMenu(v)
						else	
							pdtcool = CurTime()+0.45
							vv[1] = isnumber(vv[1]) and tostring(vv[1]) or vv[1]
							SetClipboardText(vv[1]:sub(1,1) == "{" and vv[1]:sub(-1) == "}" and "Entity("..vv[1]:sub(2,-2)..")" or vv[1])
						end
					end
				end
			end
		end
		
		dptcply = dptcply:IsValid() and dptcply or LocalPlayer()
		
		if indepth or c > 0 then
			local xx,yy = dptmenu:GetPos()
			local ww,hh = dptmenu:GetWide(),dptmenu:GetTall()
			local dpol = {
				{["x"]=xx   ,["y"]=yy   ,["u"]=(xx   )/ScrW(),["v"]=(yy   )/ScrH()},
				{["x"]=xx+ww,["y"]=yy   ,["u"]=(xx+ww)/ScrW(),["v"]=(yy   )/ScrH()},
				{["x"]=xx+ww,["y"]=yy+hh,["u"]=(xx+ww)/ScrW(),["v"]=(yy+hh)/ScrH()},
				{["x"]=xx   ,["y"]=yy+hh,["u"]=(xx   )/ScrW(),["v"]=(yy+hh)/ScrH()}
			}
			surface.SetMaterial(blur)
			for i=0.25,1,0.25 do
				blur:SetInt("$blur",10*i)
				render.UpdateScreenEffectTexture()
				surface.SetDrawColor(0,0,0,c*255)
				surface.DrawPoly(dpol)
				surface.SetDrawColor(Color(bgcol.r,bgcol.g,bgcol.b,c*255))
			end
			surface.SetTexture(surface.GetTextureID("vgui/white"))
			surface.SetDrawColor(Color(bgcol.r,bgcol.g,bgcol.b,c*180))
			surface.DrawPoly(dpol)
			
			local cantar = LocalPlayer():CheckUserGroupLevel(dptcply:GetUserGroup())

			local bo = 16
			local bw,bh = dptmenu:GetWide()/4-bo*1.25,32
			local usable = true

			usable = dptcply ~= LocalPlayer() and cantar or false
			DepthButton(1,usable,true,"Bring","sls data",xx+bo,yy+bo,bw,bh,c*255,Color(0,0,0),function()
				SendCommand("Bring",dptcply)
			end)
			
			usable = LocalPlayer():CheckUserGroupLevel("designers") and cantar or (dptcply == LocalPlayer())
			DepthButton(2,usable,true,dptcply:Alive() and (dptcply == LocalPlayer() and "Suicide" or "Kill") or "Revive","sls data",xx+bw+bo*2,yy+bo,bw,bh,c*255,Color(0,0,0),function()
				SendCommand(dptcply:Alive() and (dptcply == LocalPlayer() and "Kill" or "Slay") or "Revive",dptcply)
			end)
			
			usable = LocalPlayer():CheckUserGroupLevel("guardians") and cantar
			DepthButton(3,usable,true,{"Kick","Are you sure?"},"sls data",xx+ww-bw*2-bo*2,yy+bo,bw,bh,c*255,Color(0,0,0),function()
				SendCommand("Kick",dptcply)	
			end)
			
			usable = true
			DepthButton(4,usable,true,"User Profile","sls data",xx+ww-bw-bo,yy+bo,bw,bh,c*255,Color(0,0,0),function()
				gui.OpenURL("http://steamcommunity.com/profiles/"..dptcply:SteamID64(),true)
			end)
			
			usable = dptcply ~= LocalPlayer()
			DepthButton(5,usable,true,"Goto","sls data",xx+bo,yy+bh+bo*2,bw,bh,c*255,Color(0,0,0),function()
				SendCommand("Goto",dptcply)
			end)
			
			usable = LocalPlayer():CheckUserGroupLevel("guardians") and cantar
			DepthButton(6,usable,true,"Strip Weapons","sls data",xx+bw+bo*2,yy+bh+bo*2,bw,bh,c*255,Color(0,0,0),function()
				SendCommand("Strip",dptcply)
			end)
			
			usable = LocalPlayer():CheckUserGroupLevel("overwatch") and cantar
			DepthButton(7,usable,true,{"Drop Connection","Are you sure?"},"sls data",xx+ww-bw*2-bo*2,yy+bh+bo*2,bw,bh,c*255,Color(0,0,0),function()
				SendCommand("Drop",dptcply)	
			end) 
			
			usable = (LocalPlayer():CheckUserGroupLevel("designers") and cantar or (cantar and (dptcply == LocalPlayer())))
			DepthButton(8,usable,true,"Cleanup","sls data",xx+ww-bw-bo,yy+bh+bo*2,bw,bh,c*255,Color(0,0,0),function()
				SendCommand("Cleanup",dptcply)	
			end)
			
			usable = LocalPlayer():CheckUserGroupLevel("guardians")
			DepthButton(9,usable,false,dptcply:IsFrozen() and "Unfreeze" or "Freeze","sls data",xx+bw+bo*2,yy+bh*2+bo*3,bw,bh,c*255,Color(0,0,0),function()
				SendCommand("Freeze",dptcply)
			end)

			usable = LocalPlayer():CheckUserGroupLevel("designers") and cantar or (dptcply == LocalPlayer())
			DepthButton(10,usable,false,dptcply:GetNetData("GodMode") and "Ungod" or "God","sls data",xx+bw+bo*2,yy+bh*3+bo*4,bw,bh,c*255,Color(0,0,0),function()
				SendCommand("God",dptcply)
			end)
			
			usable = LocalPlayer():CheckUserGroupLevel("overwatch") and cantar
			DepthButton(11,usable,false,"Set Rank","sls data",xx+ww-bw-bo,yy+bh*2+bo*3,bw,bh,c*255,Color(0,0,0),function()
				grpenab = not grpenab
			end)
			
			grpdrop = grpenab and AdvLerp(grpdrop,0,1,1,speed/2,0.01) or AdvLerp(grpdrop,0,1,-1,speed,0.01)
			if grpenab and grpdrop > 0 then
				if #grpordr == 0 then
					for k,v in pairs(team.GetAllTeams()) do
						if k >= 10 or k < 1 then continue end
						grpordr[#grpordr+1] = {k,v}
					end
				end
				for k,v in pairs(grpordr) do
					local clc = Color(v[2].Color.r,v[2].Color.g,v[2].Color.b,255)
					local ala = grpdrop >= 0.9 and grpenab and tonumber(v[1]) <= LocalPlayer():Team()
					DepthButton(50+k,ala,true,v[2].Name,"sls data",xx+ww-bw-bo,bh/2+yy+bh*2+bo*3+k*grpdrop*bh/2,bw,bh/2,grpdrop*255,clc,function()
						SendCommand("SetGroup",dptcply,v[2].Name:lower())
						grpenab = false
					end)
				end
			end
			
			local tc = team.GetColor(dptcply:Team())
			tc.a = c*255
			local invtc = tc == Color(0,0,0,tc.a)
			draw.SimpleTextOutlined(dptcply:Nick():gsub("%^%d+", ""):gsub("<(.-)=(.-)>", ""),"sls huge",xx+ww/2,yy+hh*0.8,tc,1,1,1,invtc and Color(255,255,255,c*255) or Color(0,0,0,c*255))
		end
		
		p = {}
	end
	end
	hook.Add("InitPostEntity","XenoraScoreboard_PostInit",RunXScore)
	RunXScore()
end