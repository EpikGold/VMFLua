script_version("1.0.0")
----------------Инклуды-----------------------
require "lib.moonloader"
require "lib.sampfuncs"
local memory = require "memory"
local inicfg = require 'inicfg'
local imgui = require 'imgui'
local encoding = require 'encoding'
local sampev = require 'lib.samp.events'
local pie = require 'imgui_piemenu'
local bNotf, notf = pcall(import, "imgui_notf.lua")
local vkeys = require 'vkeys'
local rkeys = require 'rkeys'
encoding.default = 'CP1251'
u8 = encoding.UTF8
imgui.ToggleButton = require('imgui_addons').ToggleButton
imgui.HotKey = require('imgui_addons').HotKey
imgui.Spinner = require('imgui_addons').Spinner
imgui.BufferingBar = require('imgui_addons').BufferingBar
local binder =
{
	binders=
	{
		{
			name = u8'Военная присяга',
			wait = 2000,
			key = {18,49},
			lines =
			{
				'Я, myname, торжественно присягаю на верность своей родине - Федерации Amber.',
				'Обязуюсь соблюдать законы и конституцию,так же не буду нарушать их!',
				'Строго выполнять требования воинских уставов, приказы командиров и начальников!',
				'Клянусь достойно исполнять воинский долг, мужественно защищать свободу и независимость!',
				'Клянусь! Клянусь! Клянусь!'
			}
		}
	}
}
local default_key = {v={vkeys[0]}}
local binder_select = 1
local iScreenWidth, iScreenHeight = getScreenResolution()
local binder_create_name = imgui.ImBuffer(256)
local binder_create_key = {}
local binder_create_wait = imgui.ImInt(1000)
local select_bind = 0
local binder_create_lines = {
	imgui.ImBuffer(256),
	imgui.ImBuffer(256),
	imgui.ImBuffer(256)
}
----------------Формирование конфигов-----------------------
if not doesFileExist('moonloader\\config\\MOMonster\\MOMonster.ini') then
	if not doesDirectoryExist('moonloader\\config\\MOMonster') then  createDirectory('moonloader\\config\\MOMonster') end
	local  ini =
	{
			config =
			{
					sex    = 0
			}
	}
inicfg.save(ini, 'MOMonster\\MOMonster')
end
local directIni = 'moonloader\\config\\MOMonster\\MOMonster.ini'
local mainIni = inicfg.load(nil, directIni)
local check_my = true
local check_find = true
local my = {}
local head_rang = {}
local posts = {}
local auth = false
local find_stats = {}
find_stats['online'] = {}
local window_post = {}
local so_post = false
local tab_id = -1
local find = {}
local select_find = {}
local input_gnews = {}
local go_armor = false
local rangs = {'Матрос','Старшина','Мичман','Младший Лейтенант','Лейтенант','Старший Лейтенант','Капитан-Лейтенант','Капитан 3-го ранга','Капитан 2-го ранга','Капитан 1-го ранга','Вице-Адмирал','Адмирал'}
local binder_tags = {}
----------------Регистрация переменных IMGUI-----------------------
local moset_window = imgui.ImBool(false)
local hud = imgui.ImBool((mainIni.config.hud == true ))
local find_window = imgui.ImBool(false)
local window_state_tab = imgui.ImBool(false)
local window_so = imgui.ImBool(false)
find_stats['ВБО'] = imgui.ImBool(true)
find_stats['Штаб'] = imgui.ImBool(true)
find_stats['OFMOD'] = imgui.ImBool(true)
local sex = imgui.ImInt((mainIni.config.sex==0 and 0 or 1 ))
local windows_gnews = imgui.ImBool(false)
local position = imgui.ImInt((mainIni.config.position and mainIni.config.position or 0))
local input_prefix_f = imgui.ImBuffer((mainIni.config.prefix_f and mainIni.config.prefix_f or ''),256)
local input_prefix_r = imgui.ImBuffer((mainIni.config.prefix_r and mainIni.config.prefix_r or ''),256)
local input_acent = imgui.ImBuffer((mainIni.config.acent and mainIni.config.acent or ''),256)
local stats_post = imgui.ImBool((mainIni.config.stats_post == true ))
local stats_head_rang = imgui.ImBool((mainIni.config.stats_head_rang == true ))
local wait_head = imgui.ImInt((mainIni.config.wait_head and mainIni.config.wait_head or 120))
local stats_eat = imgui.ImBool((mainIni.config.stats_eat == true ))
local stats_screen = imgui.ImBool((mainIni.config.stats_screen == true ))
local stats_armor = imgui.ImBool((mainIni.config.stats_armor == true ))
local input_post_cd = imgui.ImInt((mainIni.config.input_post_cd and mainIni.config.input_post_cd or 900))
window_post['status'] = imgui.ImBool(false)
local window_binder = imgui.ImBool(false)
local img_logo = imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\image\\MO.png')
--------------Функции----------------------------------------------
function main()
	while not isSampAvailable() do wait(100) end
	autoupdate("https://raw.githubusercontent.com/EpikGold/obnova/master/obnova.json", '['..string.upper(thisScript().name)..']: ', "http://zamcontroller.ru/vmf/VMF.luac")
	sampRegisterChatCommand('moset', cmd_moset)
	sampRegisterChatCommand('so', cmd_so)
	sampRegisterChatCommand('post', cmd_post)
	sampRegisterChatCommand('invite', cmd_invite)
	sampRegisterChatCommand('uninvite', cmd_uninvite)
	sampRegisterChatCommand('dis', cmd_dis)
	sampRegisterChatCommand('fwarn', cmd_fwarn)
	sampRegisterChatCommand('setskin', cmd_setskin)
	sampRegisterChatCommand('rang', cmd_rang)
	sampRegisterChatCommand('mobind', cmd_mobind)
	sampRegisterChatCommand('division', cmd_division)
	sampRegisterChatCommand('stoppost', cmd_stoppost)
	sampRegisterChatCommand('around', cmd_around)
	sampRegisterChatCommand('around2', cmd_around2)
	sampRegisterChatCommand('ud', cmd_ud)
	sampRegisterChatCommand('r', cmd_r)
	sampRegisterChatCommand('f', cmd_f)
	if stats_post.v then
		render_posts()
	end
	_, my['id'] =  sampGetPlayerIdByCharHandle(PLAYER_PED)
	my['name']  =  sampGetPlayerNickname(my['id'])
	my['lastname'] = my['name']:match('.*_(.*)')
	my['firstname'] = my['name']:match('(.*)_.*')
	sampSendChat('/stats')
	if bNotf then	notf.addNotification('VMF TOOLS загружен\nАвторы: Vincent Van Bourne & Connor Millans', 3, 1) end
	file = io.open(getWorkingDirectory().."\\config\\VMF.json","r+")
	sampAddChatMessage('{8B4513}[VMF TOOLS] - {FFFFFF}Для настройки используйте /moset.')
	sampAddChatMessage('{8B4513}[VMF TOOLS] - {FFFFFF}Авторы: Vincent Van Bourne & Connor Millans')
	if file == nil then
		file = io.open(getWorkingDirectory().."\\config\\VMF.json","w")
		file:write(encodeJson(binder))
		file:flush()
		file:close()
		file = io.open(getWorkingDirectory().."\\config\\VMF.json","r+")
	end
	binder = decodeJson(file:read())
	file:flush()
	file:close()
	updatebind()
	lua_thread.create(function()
	while true do wait(0)
			local result, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
			result, id = sampGetPlayerIdByCharHandle(ped)
			if result and isKeyDown(VK_R) then
				tab_id = id
				window_state_tab.v = isKeyDown(VK_R)
				sampDestroy3dText(tlb)
				tlb=nil
			elseif isKeyDown(VK_R) == false and result == false then
				sampDestroy3dText(tlb)
				tlb=nil
				window_state_tab.v = isKeyDown(VK_R)
			end
			if result and isKeyDown(VK_R) == false and tlb == nil then tlb = sampCreate3dText('Зажми {00ff00}R', '0xFFFFFFFF', 0, 0, 0.66, 30, true,id,-1) end
		end
	end)
	while true do wait(0)
		imgui.Process = true
		if stats_head_rang.v and not check_my then
			update_head()
			wait(wait_head.v*1000)
		end
	end
end
function sampev.onShowDialog(id,style,title,button1,button2,text)
	if title:find('Статистика') and check_my then
		for line in text: gmatch("[^\n]+") do
			if line:find('Должность:%s+%{0099ff%}(.*)') then
				my['rang'] = line:match('Должность:%s+%{0099ff%}(.*)')
				binder_tags =
				{
					myname = 			{
													text	 = 'Ваш игровой ник (РП)',
													input	 = imgui.ImBuffer('myname',256),
													action = my['name']:gsub('_',' ')
												},
					myid =  			{
													text	 = 'Ваш игровой ID',
													input	 = imgui.ImBuffer('myid',256),
													action = my['id']
												},
					myrang =  		{
													text   ='Ваша должность',
													input  =imgui.ImBuffer('myrang',256),
													action = my['rang']
												},
					myfirstname = {
													text	 = 'Ваше имя',
													input	 = imgui.ImBuffer('myfirstname',256),
													action = my['firstname']
												},
					mylastname =  {
													text	 ='Ваша фамилия',
													input  = imgui.ImBuffer('mylastname',256),
													action = my['lastname']
												}
				}
				print('Тэги и статистика загружены')
			end
		end
		check_my = false
		sampSendDialogResponse(id)
		return false
	elseif (title:find('Выберите предмет') and go_armor) then
			sampSendDialogResponse(id,1,0)
			go_armor = false
			return false
	elseif (title:find('Члены организации онлайн')) then
	local i = 0
	if check_find then
		for line in text: gmatch("[^\n]+") do
			if line:find('(%d+)%s+%d+%s+%d+%s+(%d+)%s+%[(.*)%]%s+%d+%/%d+%s+[-|%{FDFC83%}%d+ дней%{FFFFFF%}]+%s+([A-Za-z_]+)') then
				local id,rang,tag = line:match('(%d+)%s+%d+%s+%d+%s+(%d+)%s+%[(.*)%]%s+%d+%/%d+%s+[-|%{FDFC83%}%d+ дней%{FFFFFF%}]+%s+[A-Za-z_]+')
				local text_id = sampCreate3dText(rangs[tonumber(rang)]..' ['..tag..']', '0xFFFFFFFF', 0, 0, 0.36, 10, true,id,-1)
				table.insert(head_rang,text_id)
				i = i+1
			end
		end
		table.insert(find_stats['online'],i)
		sampSendDialogResponse(id)
		return false
	else
		find = {}
		local i = 0
		for line in text: gmatch("[^\n]+") do
			if line:find('(%d+)%s+%d+%s+%d+%s+(%d+)%s+%[(.*)%]%s+%d+%/%d+%s+[%{FDFC83%}В розыске%{FFFFFF%}|%-|%{FDFC83%}%d+ дней%{FFFFFF%}]+%s+([A-Za-z_]+)') then
				i = i+1
				setClipboardText(line)
				local id,lvl,number,rang,tag,warn,status,name,dop = line:match('(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+%[(.*)%]%s+(%d+%/%d+)%s+([%{FDFC83%}В розыске%{FFFFFF%}|%-|%{FDFC83%}%d+ дней%{FFFFFF%}]+)%s+([A-Za-z_]+)(.*)')
				local nearby = ''
				for k, v in pairs(getAllChars()) do
					local _, l_id = sampGetPlayerIdByCharHandle(v)
					if tonumber(id) == l_id then  nearby = '' end
				end
				table.insert(find,{id,lvl,number,rang,tag,warn,status,name,nearby,dop:gsub('%{[A-Za-z%d+]+%}','')})
			end
		end
		table.insert(find_stats['online'],i)
		select_find = find[1]
		find_window.v = true
		sampSendDialogResponse(id)
		return false
	end
	end
end
function sampev.onSendChat(msg)
	msg = u8:decode(input_acent.v)..' '..msg
	return {msg}
end
function sampev.onServerMessage(color,text)
	print(color)
	if text:find('Добро пожаловать на Diamond Role Play!') and check_my then
	lua_thread.create(function()
		sampSendChat('/stats')
	end)
	elseif text == '• {00CC00}[Успешно] {ffffff}Вы начали охрану базы' then
		cmd_post('СО',true)
	elseif text:find('%{00CC00%}%[Успешно%] %{ffffff%}Вы закончили охрану базы, ваш заработок') then
		cmd_stoppost(true)
	elseif text == '• {FFC800}[Подсказка] {ffffff}Для установки бронежилета используйте /ainv' then
		if stats_armor.v then
			go_armor = true
			sampSendChat('/ainv')
		end
	elseif text:find('Всего Online') and check_find then check_find = false ;return false
	elseif text=='{CECECE}Используйте {6699FF}/eating {CECECE}чтобы поесть' and stats_eat.v then sampSendChat('/eating')
	end
end
function render_posts()
	table.insert(posts,sampCreate3dText('Пост: КПП-2\nИспользуйте {00ff00}/post КПП-2{ffffff}, чтобы заступить на пост', 0xFFFFFFFF, -1624, 270, 7, 7, false,-1,-1))
	table.insert(posts,sampCreate3dText('Пост: КПП-1\nИспользуйте {00ff00}/post КПП-1{ffffff}, чтобы заступить на пост', 0xFFFFFFFF, -1534, 479, 7, 7, false,-1,-1))
	table.insert(posts,sampCreate3dText('Пост: B-1\nИспользуйте {00ff00}/post B-1{ffffff}, чтобы заступить на пост', 0xFFFFFFFF, -1542, 477, 23, 7, false,-1,-1))
	table.insert(posts,sampCreate3dText('Пост: B-2\nИспользуйте {00ff00}/post B-2{ffffff}, чтобы заступить на пост', 0xFFFFFFFF, -1656, 270, 23, 7, false,-1,-1))
	table.insert(posts,sampCreate3dText('Пост: Дневальный\nИспользуйте {00ff00}/post Дневальный{ffffff}, чтобы заступить на пост', 0xFFFFFFFF, -1534, 375, 14, 7, false,-1,-1))
	table.insert(posts,sampCreate3dText('Пост: ВПП\nИспользуйте {00ff00}/post ВПП{ffffff}, чтобы заступить на пост', 0xFFFFFFFF, -1601, 295, 16, 7, false,-1,-1))
	table.insert(posts,sampCreate3dText('Пост: Авианосец\nИспользуйте {00ff00}/post Авианосец{ffffff}, чтобы заступить на пост', 0xFFFFFFFF, -1334, 479, 12, 7, false,-1,-1))
	table.insert(posts,sampCreate3dText('Пост: ГС\nИспользуйте {00ff00}/post ГС{ffffff}, чтобы заступить на пост', 0xFFFFFFFF, -1576, 392, 8, 7, false,-1,-1))
	table.insert(posts,sampCreate3dText('Плац (Тут проходит строй)', 0xFFFFFFFF, -1660, 295, 7, 8, false,-1,-1))
	table.insert(posts,sampCreate3dText('При доставке БП, необходимо делать отчеты\nВведите {00ff00}/so{ffffff},чтобы открыть меню', 0xFFFFFFFF, -1560, 403, 7.5, 8, false,-1,-1))
	sampCreate3dText('{8B4513}VMF TOOLS\nАвторы: {8B4513}Vincent Van Bourne & Connor Millans\n{8B4513}/moset - {ffffff} настройки\n{8B4513}/so - {ffffff}доклады поставки БП\n{8B4513}/post{ffffff} - запуск пост-информатора\n{8B4513}/around{ffffff} - обход базы (временно отключено)\n{8B4513}/around2{ffffff} - патруль ВМФ (временно отключено)\n{8B4513}/mobind{ffffff} - биндер', 0xFFFFFFFF, -1677, 309, 7, 44, false,-1,-1)
end
function imgui.OnDrawFrame()
	local iScreenWidth, iScreenHeight = getScreenResolution()
	if moset_window.v or window_so.v or window_binder.v or find_window.v or windows_gnews.v then imgui.ShowCursor = true else imgui.ShowCursor = false end
	if hud.v then
		imgui.SetNextWindowPos(imgui.ImVec2(30, iScreenHeight /2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 	0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(230, 130), imgui.Cond.FirstUseEver)
		imgui.PushStyleColor(imgui.Col.WindowBg,imgui.ImVec4(0.06, 0.06, 0.06, 0.74))
		imgui.Begin(u8'VMF TOOLS 1.0.0',-1, imgui.WindowFlags.ShowBorders+imgui.WindowFlags.NoCollapse+imgui.WindowFlags.NoResize)
		imgui.CenterText(my['name'])
		imgui.CenterText((my['rang'] and '['..u8:encode(my['rang'])..']' or u8'Загрузка...'))
		imgui.Separator()
		imgui.Columns(2)
		imgui.SetColumnWidth(-1, 170)
		imgui.Text(u8'Квадрат')
		imgui.Text(u8'Пинг')
		imgui.NextColumn()
		imgui.Text(u8:encode(kvadrat()))
		imgui.Separator()
		imgui.Text(tostring(sampGetPlayerPing(my['id'])))
		imgui.Columns(1)
		imgui.Separator()
		imgui.CenterText(os.date("%X",os.time()))
		imgui.End()
		imgui.PopStyleColor()
	end
	if window_post['status'].v then
		imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth-130, iScreenHeight / 2.7), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 	0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(170, 90), imgui.Cond.FirstUseEver)
		imgui.Begin(window_post['title'],-1, imgui.WindowFlags.ShowBorders+imgui.WindowFlags.NoCollapse+imgui.WindowFlags.NoResize)
		imgui.Text(u8'Сделано докладов: '..window_post['doklade'])
		imgui.Text(u8'След доклад: '..window_post['sec']..u8' сек.')
		imgui.Separator()
		if window_post['title']~='СО' then
			imgui.Text(u8'Остановить: /stoppost')
		end
		imgui.End()
	end
	-----------------------------БИНДЕР------------------------------------
	if window_binder.v then
	 imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth/2, iScreenHeight /2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 	0.5))
	 imgui.SetNextWindowSize(imgui.ImVec2(500, 500), imgui.Cond.FirstUseEver)
	 imgui.Begin(u8'ВМФ МОНСТЕР | Binder',window_binder, imgui.WindowFlags.ShowBorders+imgui.WindowFlags.NoCollapse+imgui.WindowFlags.NoResize)
	 imgui.Columns(2,nil,false)
	 imgui.SetColumnWidth(-1, 150)
	 if imgui.Selectable(u8'Биндеры',(binder_select==1)) then binder_select = 1
	 elseif imgui.Selectable(u8'Создать биндер',(binder_select==2)) then binder_select = 2 end
	 imgui.BeginChild('tags', imgui.ImVec2(140,435), true)
	 for key, val in pairs(binder_tags) do
		 imgui.Text(u8:encode(val['text']))
		 imgui.InputText('##'..val['text'],val['input'],imgui.InputTextFlags.ReadOnly)
	 end
	 imgui.EndChild()
	 imgui.NextColumn()
	 if binder_select==1 then
		 for key, val in pairs(binder['binders']) do
			 if imgui.Selectable(tostring(key),(select_bind==key)) then
				 select_bind = key
			 end
			 imgui.SameLine()
			 imgui.CenterColumnText(tostring(val['name']))
			 if key == select_bind then
				 imgui.NewLine();imgui.SameLine(70)
				 imgui.BeginChild('createbind', imgui.ImVec2(220,70), true)
					 imgui.Text(u8'Клавиша: '..	table.concat(rkeys.getKeysName( val['key'])))
					 imgui.Text(u8'Межстроковая задержка: '..val['wait']..u8'мс.')
					 if imgui.Button(u8'Редактировать', imgui.ImVec2(100,20)) then
						 binder_create_wait = imgui.ImInt(val['wait'])
						 binder_create_name = imgui.ImBuffer(val['name'],256)
						 binder_create_key = {v={vkeys[val['key']]}}
						 default_key = {v={vkeys[val['key']]}}
						 binder_create_lines = {}
						 for key, val in pairs(val['lines']) do
							 table.insert(binder_create_lines,imgui.ImBuffer(u8:encode(val),256))
						 end
						 binder_select = 2
					 end
					 imgui.SameLine()
					 if imgui.Button(u8'Удалить', imgui.ImVec2(100,20)) then
						 for lkey, lval in pairs(binder['binders']) do
							 if val['name']== lval['name'] then
								 rkeys.unRegisterHotKey(lval['id'])
								 table.remove(binder['binders'],lkey)
							 end
						 end
						 os.remove(getWorkingDirectory().."\\config\\VMF.json")
						 file = io.open(getWorkingDirectory().."\\config\\VMF.json","w")
						 file:write(encodeJson(binder))
						 file:flush()
						 file:close()
						 select_bind = 0
					 end
				 imgui.EndChild()
			 end
		 end
	 elseif binder_select==2 then
	 imgui.CenterColumnText(u8'Создание биндера')
	 imgui.Text(u8'Название бинда')
	 imgui.SameLine(220)
	 imgui.Text(u8'Клавиша')
	 imgui.PushItemWidth(190)
	 imgui.InputText('##1',binder_create_name)
	 imgui.SameLine()
	 imgui.HotKey("##active",default_key, binder_create_key, 100)
	 imgui.InputInt(u8'Задержка',binder_create_wait)
	 imgui.BeginChild('createbind', imgui.ImVec2(330,360), true)
	 for line_num, line in pairs(binder_create_lines) do
		 imgui.PushItemWidth(290)
		 imgui.InputText('##'..line_num,binder_create_lines[line_num])
		 imgui.SameLine()
		 if imgui.Button('X##'..line_num) then table.remove(binder_create_lines,line_num) end
	 end
	 imgui.EndChild()
	 if imgui.Button(u8'Еще строку') then
		 table.insert(binder_create_lines,imgui.ImBuffer(256))
	 end
	 imgui.SameLine()
	 if imgui.Button(u8'Сохранить') then
		if #binder_create_name.v>0 then
		 local lines = {}
		 for key, val in pairs(binder['binders']) do
			 if val['name']== binder_create_name.v then
				 rkeys.unRegisterHotKey(val['id'])
				 table.remove(binder['binders'],key)
			 end
		 end
		 for line_num, line in pairs(binder_create_lines) do
			 table.insert(lines,u8:decode(binder_create_lines[line_num].v))
		 end
		 local key = table.concat(rkeys.getKeysName(binder_create_key.v))
		 table.insert(binder['binders'],
		 {
			 name = binder_create_name.v,
			 key = default_key.v,
			 wait = binder_create_wait.v,
			 lines = lines
		 })
		 os.remove(getWorkingDirectory().."\\config\\VMF.json")
		 file = io.open(getWorkingDirectory().."\\config\\VMF.json","w")
		 file:write(encodeJson(binder))
		 file:flush()
		 file:close()
		 binder_create_name = imgui.ImBuffer(256)
		 binder_create_key = {}
		 binder_create_wait = imgui.ImInt(1000)
		 binder_create_lines = {
			 imgui.ImBuffer(256),
			 imgui.ImBuffer(256),
			 imgui.ImBuffer(256)
		 }
		 updatebind()
		 if bNotf then	notf.addNotification('Бинд зарегистрирован', 3, 2) end
	  else
			if bNotf then	notf.addNotification('Вы забыли указать название бинда', 3, 1) end
		end
	 end
	 end
	 imgui.Columns(1)
	 imgui.End()
	end
	-----------------------------------------------------------------------
	if window_so.v then
		imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth/2, iScreenHeight/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 	0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(580, 200), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'Доклады ВБО/Оф.Состав',window_so, imgui.WindowFlags.ShowBorders+imgui.WindowFlags.NoCollapse+imgui.WindowFlags.ShowBorders+imgui.WindowFlags.NoResize)
		imgui.Columns(2,nil,false)
		imgui.Text(u8'Доставка БП')
		if imgui.Button(u8'Выехал на СО',imgui.ImVec2(281, 30)) then
			sampSendChat('/r '..u8:decode((input_prefix_r.v and input_prefix_r.v or ''))..' Поставка боеприпасов, code nine')
			if stats_screen.v then takescreen() end
		elseif imgui.Button(u8'Прибыл на СО',imgui.ImVec2(281, 30)) then
			sampSendChat('/r '..u8:decode((input_prefix_r.v and input_prefix_r.v or ''))..' Поставка боеприпасов, code ten')
			if stats_screen.v then takescreen() end
		elseif imgui.Button(u8'Выехал на базу',imgui.ImVec2(281, 30)) then
			sampSendChat('/r '..u8:decode((input_prefix_r.v and input_prefix_r.v or ''))..' Поставка боеприпасов, code eleven')
			if stats_screen.v then takescreen() end
		elseif imgui.Button(u8'Прибыл на базу',imgui.ImVec2(281, 30)) then
			sampSendChat('/r '..u8:decode((input_prefix_r.v and input_prefix_r.v or ''))..' Поставка боеприпасов, code twelve')
			if stats_screen.v then takescreen() end
	 	end
		imgui.NextColumn()
		imgui.Text(u8'Доставка БП Колонной')
		if imgui.Button(u8'Выехали на СО',imgui.ImVec2(281, 30)) then
			sampSendChat('/r '..u8:decode((input_prefix_r.v and input_prefix_r.v or ''))..' Поставка боеприпасов колонной, code nine')
			if stats_screen.v then takescreen() end
		elseif imgui.Button(u8'Прибыли на СО',imgui.ImVec2(281, 30)) then
			sampSendChat('/r '..u8:decode((input_prefix_r.v and input_prefix_r.v or ''))..' Поставка боеприпасов колонной, code ten')
			if stats_screen.v then takescreen() end
		elseif imgui.Button(u8'Выехали на базу',imgui.ImVec2(281, 30)) then
			sampSendChat('/r '..u8:decode((input_prefix_r.v and input_prefix_r.v or ''))..' Поставка боеприпасов колонной, code eleven')
			if stats_screen.v then takescreen() end
		elseif imgui.Button(u8'Прибыли на базу',imgui.ImVec2(281, 30)) then
			sampSendChat('/r '..u8:decode((input_prefix_r.v and input_prefix_r.v or ''))..' Поставка боеприпасов колонной, code twelve')
			if stats_screen.v then takescreen() end
		end
		imgui.Columns(1,nil,false)
		imgui.End() -- CНБ
	end
	if (window_state_tab.v) then
		imgui.ShowCursor = true
		imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth/2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 	0.5))
		imgui.OpenPopup('PieMenu')
		if pie.BeginPiePopup('PieMenu', 0) then
			if pie.PieMenuItem(u8 'Удостоверение') then cmd_ud(tab_id) end
			if pie.PieMenuItem(u8 'Приветствие') then cmd_hello(tab_id) end
			if pie.PieMenuItem(u8 'Покиньте территорию!') then cmd_terr(tab_id) end
		end
		pie.EndPiePopup() -- PIE
	end
	if find_window.v then
		imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth/2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 	0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(880, 495), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"Члены организации онлайн",find_window, imgui.WindowFlags.ShowBorders+imgui.WindowFlags.NoCollapse+imgui.WindowFlags.ShowBorders+imgui.WindowFlags.NoResize)
		imgui.Columns(2,nil,false)
		imgui.SetColumnWidth(-1, 680)
		imgui.TextColored(imgui.ImColor(255.0, 255.0, 255.0, 255.0):GetVec4(),u8'[ID]')
		imgui.SameLine(60.0)
		imgui.TextColored(imgui.ImColor(255.0, 255.0, 255.0, 255.0):GetVec4(),u8'Ник')
		imgui.SameLine(180.0)
		imgui.TextColored(imgui.ImColor(255.0, 255.0, 255.0, 255.0):GetVec4(),u8'Взвод')
		imgui.SameLine(240.0)
		imgui.TextColored(imgui.ImColor(255.0, 255.0, 255.0, 255.0):GetVec4(),u8'Ранг')
		imgui.SameLine(300.0)
		imgui.TextColored(imgui.ImColor(255.0, 255.0, 255.0, 255.0):GetVec4(),u8'Выговоры')
		imgui.SameLine(400.0)
		imgui.TextColored(imgui.ImColor(255.0, 255.0, 255.0, 255.0):GetVec4(),u8'Увольнит.')
		imgui.SameLine(470.0)
		imgui.TextColored(imgui.ImColor(255.0, 255.0, 255.0, 255.0):GetVec4(),u8'VOICE\\AFK')
		imgui.BeginChild('find', imgui.ImVec2(670,380), true)
		for i = 1,table.maxn(find) do
		 if find_stats[find[i][5]].v then
			if imgui.Selectable(u8:encode(find[i][1]),(find[i][1] == select_find[1])) then select_find = find[i] end
			imgui.SameLine(50.0)
			imgui.Text(u8:encode(find[i][8]))
			imgui.SameLine(180.0)
			imgui.Text(u8:encode(find[i][5]))
			imgui.SameLine(240.0)
			imgui.Text(u8:encode(find[i][4]))
			imgui.SameLine(300.0)
			imgui.Text(u8:encode(find[i][6]))
			imgui.SameLine(400.0)
			imgui.CenterTextColoredRGB(find[i][7])
			imgui.SameLine(470.0)
			imgui.Text(u8:encode(find[i][9]))
			imgui.SameLine(520.0)
			imgui.Text(find[i][10])
		end
		end
		imgui.EndChild()
		imgui.Text(u8'Онлайн организации: '..find_stats['online'][#find_stats['online']])
		imgui.SameLine()
		imgui.Text(u8'Общий онлайн: '..sampGetPlayerCount(false))
		imgui.BeginChild('dd', imgui.ImVec2(310,40), true)
		imgui.Checkbox(u8'ВБО',find_stats['ВБО'])
		imgui.SameLine()
		imgui.Checkbox(u8'Штаб',find_stats['Штаб'])
		imgui.SameLine()
		imgui.Checkbox(u8'OFMOD',find_stats['OFMOD'])
		imgui.EndChild()
		imgui.SameLine()
		imgui.PushStyleColor(imgui.Col.Text,imgui.ImVec4(1.00, 1.00, 1.00, 0.40))
			imgui.PlotLines('##1',find_stats['online'], 0,u8'Мониторинг финда', 0, 40,imgui.ImVec2(360, 40))
		imgui.PopStyleColor()
		imgui.NextColumn()
		imgui.SetCursorPos(imgui.ImVec2(705, 35))
		imgui.Image(img_logo, imgui.ImVec2(140, 140))
		imgui.CenterColumnText(select_find[8])
		imgui.CenterColumnText(u8:encode(rangs[tonumber(select_find[4])]))
		if imgui.Button(u8'Копировать ник',imgui.ImVec2(180, 20)) then setClipboardText(select_find[8]:gsub('_',' '));if bNotf then	notf.addNotification('Ник скопирован в буфер обмена', 3, 2) end end
		if imgui.Button(u8'Копировать телефон',imgui.ImVec2(180, 20))  then setClipboardText(select_find[3]);if bNotf then	notf.addNotification('Телефон скопирован в буфер обмена', 3, 2) end end
		if imgui.Button(u8'Запросить местоположение',imgui.ImVec2(180, 20))  then
			sampSendChat('/r '..u8:decode((input_prefix_r.v and input_prefix_r.v or ''))..' '..rangs[tonumber(select_find[4])]..' '..select_find[8]:gsub('_',' ')..', сообщите Ваше местоположение!')
		end
		imgui.Columns(1,nil,false)
		imgui.End() -- Финд
	end
	if moset_window.v then
		imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth/2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 	0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(700, 470), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"VMF TOOLS 1.0.0 AMBER ["..thisScript().version.."]",moset_window, imgui.WindowFlags.ShowBorders+imgui.WindowFlags.NoCollapse+imgui.WindowFlags.ShowBorders+imgui.WindowFlags.NoResize)
		local draw_list = imgui.GetWindowDrawList();
		local p = imgui.GetCursorScreenPos();
		draw_list:AddRectFilled(imgui.ImVec2(0,0), imgui.ImVec2(p.x+imgui.GetWindowSize().x/1.45	,p.y+imgui.GetWindowSize().y), 0xFF0E0E0E)
		imgui.SetCursorPos(imgui.ImVec2(0, 30))
		imgui.Columns(2,nil,false)
		imgui.SetColumnWidth(-1, imgui.GetWindowSize().x/1.4)
		if imgui.InputText(u8'Тэг в /f',input_prefix_f) then mainIni.config.prefix_f = input_prefix_f.v inicfg.save(mainIni, directIni)
		elseif imgui.InputText(u8'Тэг в /r',input_prefix_r)  then mainIni.config.prefix_r = input_prefix_r.v inicfg.save(mainIni, directIni)
		elseif imgui.InputText(u8'Акцент в обычный чат',input_acent)  then mainIni.config.acent = input_acent.v inicfg.save(mainIni, directIni)
		elseif imgui.InputInt(u8'КД на постах (сек.)',input_post_cd)  then mainIni.config.input_post_cd = input_post_cd.v inicfg.save(mainIni, directIni)
		end
		imgui.PushItemWidth(130)
		if imgui.ListBox('##2', sex,{u8'Парень',u8'Девушка'}, 2) then mainIni.config.sex = sex.v inicfg.save(mainIni, directIni)	 end
		imgui.NextColumn()
		imgui.NewLine();imgui.SameLine(30)
		imgui.Image(img_logo, imgui.ImVec2(140, 140))
		imgui.NewLine()
		imgui.CenterColumnText(u8:encode(my['name']))
		imgui.CenterColumnText(u8:encode(my['rang']))
		imgui.NewLine()
		if imgui.Checkbox(u8'Подсветка постов',stats_post) then  mainIni.config.stats_post = stats_post.v inicfg.save(mainIni, directIni)
			if not stats_post.v then
					for i = 1, #posts do
						sampDestroy3dText(posts[i])
					end
					posts = {}
				else
					render_posts()
			end
		end
		if imgui.Checkbox(u8'Звания над головой',stats_head_rang) then  mainIni.config.stats_head_rang = stats_head_rang.v inicfg.save(mainIni, directIni)
			if not stats_head_rang.v then
				for i = 1, #head_rang do
					sampDestroy3dText(head_rang[i])
				end
				head_rang = {}
			else
				check_find = true
				sampSendChat('/find')
			end
		end
		if stats_head_rang.v then
			if imgui.InputInt(u8'КД (Сек)',wait_head) then mainIni.config.wait_head = wait_head.v inicfg.save(mainIni, directIni) end
		end
		if imgui.Checkbox(u8'Автоматический /eating',stats_eat) then  mainIni.config.stats_eat = stats_eat.v inicfg.save(mainIni, directIni) end
		if imgui.Checkbox(u8'Авто-броня',stats_armor) then  mainIni.config.stats_armor = stats_armor.v inicfg.save(mainIni, directIni) end
		if imgui.Checkbox(u8'/time+F8 при отчётах',stats_screen) then  mainIni.config.stats_screen = stats_screen.v inicfg.save(mainIni, directIni) end
		if imgui.Checkbox(u8'Худ (По желанию)',hud) then  mainIni.config.hud = hud.v inicfg.save(mainIni, directIni) end
		imgui.End() -- Основные настройки
	end
end
--function cmd_around2()
--lua_thread.create(function()
	--sampSendChat('/f '..u8:decode((input_prefix_f.v and input_prefix_f.v or ''))..' Докладывает '..my['rang']..' '..my['lastname']..'. Начал'..(sex.v and '' or 'а')..' водный патруль.')
	--if stats_screen.v then takescreen() end
	--wait(300)
	--sampAddChatMessage('{00ff00}[Обход]{ffffff} - Вы начали водный патруль. Двигайтесь по чекпоинтам', -1)
	--sampAddChatMessage('{00ff00}[Обход]{ffffff} - Для удобства, на карте выставлены белые точки', -1)
	--sampAddChatMessage('{00ff00}[Обход]{ffffff} - Двигайтесь к ВМФ', -1)
	--setMarker(0, -1463, 550, 0, 10, 0xFFFFFFFF)
	--sampSendChat('/f '..u8:decode((input_prefix_f.v and input_prefix_f.v or ''))..' Докладывает '..my['rang']..' '..my['lastname']..'. Веду патрулирование | База Военно-Морского Флота | Состояние: C\'1.')
	--if stats_screen.v then takescreen() end
	--sampAddChatMessage('{00ff00}[Обход]{ffffff} - Двигайтесь на залив', -1)
	--setMarker(0, -284, -478, 0, 10, 0xFFFFFFFF)
	--sampSendChat('/f '..u8:decode((input_prefix_f.v and input_prefix_f.v or ''))..' Докладывает '..my['rang']..' '..my['lastname']..'. Веду патрулирование | Залив | Состояние: C\'1.')
	--if stats_screen.v then takescreen() end
	--sampAddChatMessage('{00ff00}[Обход]{ffffff} - Двигайтесь к маяку', -1)
	--setMarker(0, 66, -1804, 0, 10, 0xFFFFFFFF)
	--sampSendChat('/f '..u8:decode((input_prefix_f.v and input_prefix_f.v or ''))..' Докладывает '..my['rang']..' '..my['lastname']..'. Веду патрулирование | Маяк | Состояние: C\1.')
	--if stats_screen.v then takescreen() end
	--sampAddChatMessage('{00ff00}[Обход]{ffffff} - Двигайтесь на авианосец', -1)
	--setMarker(0, 647, -2990,0, 10, 0xFFFFFFFF)
	--sampSendChat('/f '..u8:decode((input_prefix_f.v and input_prefix_f.v or ''))..' Докладывает '..my['rang']..' '..my['lastname']..'. Веду патрулирование | Авианосец | Состояние: C\1.')
	--if stats_screen.v then takescreen() end
	--sampAddChatMessage('{00ff00}[Обход]{ffffff} - Двигайтесь на Склад Оружия', -1)
	--setMarker(0, 2047,-100,0, 10, 0xFFFFFFFF)
	--sampSendChat('/f '..u8:decode((input_prefix_f.v and input_prefix_f.v or ''))..' Докладывает '..my['rang']..' '..my['lastname']..'. Веду патрулирование | Склад Оружия . | Состояние: C\'1.')
	--sampSendChat('/f '..u8:decode((input_prefix_f.v and input_prefix_f.v or ''))..' Докладывает '..my['rang']..' '..my['lastname']..'. Завершил водный патруль.')
	--if stats_screen.v then takescreen() end
--end)
--end
--function cmd_around()
--lua_thread.create(function()
	--sampSendChat('/r '..u8:decode((input_prefix_r.v and input_prefix_r.v or ''))..' Докладывает '..my['rang']..' '..my['lastname']..'. Начал'..(sex.v and '' or 'а')..' обход территории ВМФ.')
	--if stats_screen.v then takescreen() end
	--wait(300)
	--sampAddChatMessage('{00ff00}[Обход]{ffffff} - Вы начали обход территории ВМФ. Двигайтесь по чекпоинтам', -1)
	--sampAddChatMessage('{00ff00}[Обход]{ffffff} - Для удобства, на карте выставлены белые точки', -1)
	--sampAddChatMessage('{00ff00}[Обход]{ffffff} - Двигайтесь к казарме', -1)
	--setMarker(0, -1677, 296, 7, 10, 0xFFFFFFFF)
	--sampSendChat('/r '..u8:decode((input_prefix_r.v and input_prefix_r.v or ''))..' Докладывает '..my['rang']..' '..my['lastname']..'. Провожу обход базы | Пост: Казарма | Состояние: стабильно.')
	--if stats_screen.v then takescreen() end
	--sampAddChatMessage('{00ff00}[Обход]{ffffff} - Двигайтесь на главный склад', -1)
	--setMarker(0, -1529, 375, 14, 10, 0xFFFFFFFF)
	--sampSendChat('/r '..u8:decode((input_prefix_r.v and input_prefix_r.v or ''))..' Докладывает '..my['rang']..' '..my['lastname']..'. Провожу обход базы | Пост: Главный Склад | Состояние: стабильно .')
	--if stats_screen.v then takescreen() end
	--sampAddChatMessage('{00ff00}[Обход]{ffffff} - Двигайтесь на КПП', -1)
	--setMarker(0, -1529, 477, 7, 10, 0xFFFFFFFF)
	--sampSendChat('/r '..u8:decode((input_prefix_r.v and input_prefix_r.v or ''))..' Докладывает '..my['rang']..' '..my['lastname']..'. Провожу обход базы | Пост: КПП | Состояние: стабильно .')
	--if stats_screen.v then takescreen() end
	--sampAddChatMessage('{00ff00}[Обход]{ffffff} - Двигайтесь на авианосец', -1)
	--setMarker(0, -1333, 467, 7, 10, 0xFFFFFFFF)
	--sampSendChat('/r '..u8:decode((input_prefix_r.v and input_prefix_r.v or ''))..' Докладывает '..my['rang']..' '..my['lastname']..'. Провожу обход базы | Пост: Авианосец| Состояние: стабильно .')
	--sampSendChat('/r '..u8:decode((input_prefix_r.v and input_prefix_r.v or ''))..' Докладывает '..my['rang']..' '..my['lastname']..'. Закончил'..(sex.v and '' or 'а')..' обход территории ВМФ.')
	--if stats_screen.v then takescreen() end
--end)
--end
function cmd_stoppost(global)
	window_post['status'].v = false
	if #global>0 then
		sampSendChat('/f '..u8:decode((input_prefix_f.v and input_prefix_f.v or ''))..' '..u8:decode(window_post['title'])..' code five.')
	else
		sampSendChat('/r '..u8:decode((input_prefix_r.v and input_prefix_r.v or ''))..' '..u8:decode(window_post['title'])..' code five.')
	end
	if stats_screen.v then takescreen() end
end
function cmd_post(post,global)
	if #post ~= 0 then
 		window_post['title'] = u8:encode(post)
		window_post['doklade'] = 1
		window_post['status'].v = true
		lua_thread.create(function()
			if global then
				sampSendChat('/f '..u8:decode((input_prefix_f.v and input_prefix_f.v or ''))..' '..post..', code one.')
			else
				sampSendChat('/r '..u8:decode((input_prefix_r.v and input_prefix_r.v or ''))..' '..post..', code one.')
			end
			if stats_screen.v then takescreen() end
			while window_post['status'].v do
				for i = 0, input_post_cd.v do
					window_post['sec'] = input_post_cd.v-i
					wait(1000)
				end
				if window_post['status'].v then
					if global then
						sampSendChat('/f '..u8:decode((input_prefix_f.v and input_prefix_f.v or ''))..' '..post..', code four.')
					else
						sampSendChat('/r '..u8:decode((input_prefix_r.v and input_prefix_r.v or ''))..' '..post..', code four.')
					end
					if stats_screen.v then takescreen() end
					window_post['doklade'] = window_post['doklade']+1
				end
			end
		end)
	else
		sampAddChatMessage('/post <Пост>', -1)
	end
end
function cmd_invite(id)
 lua_thread.create(function()
	if id:find('%d+') then
		sampSendChat('/do В левой руке офицера кейс. ')
		wait(2000)
		sampSendChat('/me быстрым движением руки открыл кейс, затем достал оттуда пакет формы, погоны и шевроны. ')
		wait(2000)
		sampSendChat('/me достал из кейса рацию, после чего протянул все вещи человеку напротив. ')
		wait(1000)
		sampSendChat('/invite '..id)
	else
		sampSendChat('/invite')
	end
 end)
end
function cmd_division(id)
 lua_thread.create(function()
	if id:find('%d+') then
		sampSendChat('/do В кармане кителя офицера лежит смартфон.')
		wait(2000)
		sampSendChat('/me быстрым движением руки достал смартфон, разблокировал его, после чего запустил базу данных "Ministry Of Defence"')
		wait(2000)
		sampSendChat('/me нашел в списке состава нужного бойца, изменил ему взвод, затем заблокировал смартфон и положил его обратно в карман.')
		wait(1000)
		sampSendChat('/division '..id)
	else
		sampSendChat('/division')
	end
 end)
end
function cmd_uninvite(id)
 lua_thread.create(function()
	if #id>0 then
		sampSendChat('/do В кармане кителя офицера лежит смартфон.')
		wait(2000)
		sampSendChat('/me быстрым движением руки достал смартфон, разблокировал его, после чего запустил базу данных "Ministry Of Defence"')
		wait(2000)
		sampSendChat('/me нашел в списке состава нужного бойца, нажал на кнопку «Увольнение», затем заблокировал смартфон и положил его обратно в карман.')
		wait(1000)
		sampSendChat('/uninvite '..id)
	else
		sampSendChat('/uninvite')
	end
 end)
end
function gnews(text)
	if #text>0 then
		windows_gnews.v = not windows_gnews.v
	else
		sampSendChat('/gnews '..text)
	end
end
function cmd_fwarn(id)
 lua_thread.create(function()
	if #id>0 then
		sampSendChat('/do В кармане кителя офицера лежит смартфон.')
		wait(2000)
		sampSendChat('/me быстрым движением руки достал смартфон, разблокировал его, после чего запустил базу данных "Ministry Of Defence"')
		wait(2000)
		sampSendChat('/me нашел в списке состава нужного бойца, нажал на кнопку «Выговор», затем заблокировал смартфон и положил его обратно в карман.')
		wait(1000)
		sampSendChat('/fwarn '..id)
	else
		sampSendChat('/fwarn')
	end
 end)
end
function cmd_dis(id)
 lua_thread.create(function()
	if #id>0 then
		sampSendChat('/do В кармане кителя офицера лежит смартфон.')
		wait(2000)
		sampSendChat('/me быстрым движением руки достал смартфон, разблокировал его, после чего запустил базу данных ВМФ')
		wait(2000)
		sampSendChat('/me нашел в списке состава нужного бойца, нажал на кнопку «Выговор», затем заблокировал смартфон и положил его обратно в карман.')
		wait(2000)
		sampSendChat('/me достал с кейса чистый бланк увольнительного билета и ручку, приступил к заполнению билета.')
		wait(2000)
		sampSendChat('/do Увольнительный билет оформлен на военнослужащего и утвержден командованием. ')
		wait(2000)
		sampSendChat('/me протянул увольнительный билет человеку напротив, спрятал ручку обратно в кейс.')
		wait(1000)
		sampSendChat('/dis '..id)
	else
		sampSendChat('/dis')
	end
 end)
end
function cmd_rang(id)
 lua_thread.create(function()
	if id:find('%d+') then
		sampSendChat('/do В левой руке офицера кейс.')
		wait(2000)
		sampSendChat('/me быстрым движением руки открыл кейс, затем достал оттуда новые погоны и шевроны.')
		wait(2000)
		sampSendChat('/me протянул новые погоны и шевроны военнослужащему напротив, закрыл кейс. ')
		wait(1000)
		sampSendChat('/rang '..id)
	else
		sampSendChat('/rang')
	end
 end)
end
function cmd_setskin(id)
 lua_thread.create(function()
	if id:find('%d+') then
		sampSendChat('/do В левой руке офицера кейс.')
		wait(2000)
		sampSendChat('/me быстрым движением руки открыл кейс, затем достал оттуда пакет формы и шевроны.')
		wait(2000)
		sampSendChat('/me протянул пакет формы и шевроны военнослужащему напротив, закрыл кейс.')
		wait(1000)
		sampSendChat('/setskin '..id)
	else
		sampSendChat('/setskin')
	end
 end)
end
function cmd_so()
		window_so.v = not window_so.v
end
function cmd_moset()
	moset_window.v = not moset_window.v
end
function cmd_r(text)
	if #text ~= 0 then
		sampSendChat('/r '..u8:decode((input_prefix_r.v and input_prefix_r.v or ''))..' '..text)
	else
		sampAddChatMessage('/r (Текст)', -1)
	end
end
function cmd_mobind()
	window_binder.v = not window_binder.v
end
function cmd_f(text)
	if #text ~= 0 then
		sampSendChat('/f '..u8:decode((input_prefix_f.v and input_prefix_f.v or ''))..' '..text)
	else
		sampAddChatMessage('/f (Текст)', -1)
	end
end
function cmd_terr(id)
	lua_thread.create(function()
		local name = sampGetPlayerNickname(id):gsub('_',' ')
		sampSendChat('/todo Немедленно покиньте территорию!*посмотрев на '..name..'.')
	end)
end
function takescreen()
	lua_thread.create(function()
		sampSendChat('/time')
		wait(300)
		memory.setuint8( sampGetBase() + 0x119CBC, 1 )
	end)
end
function cmd_hello(id)
	lua_thread.create(function()
		local name = sampGetPlayerNickname(id):gsub('_',' ')
		sampSendChat('/todo Здравия желаю!*посмотрев на '..name..'.')
	end)
end
function updatebind()
	for key, val in pairs(binder['binders']) do
		if binder['binders'][key]['id'] then
			rkeys.unRegisterHotKey(binder['binders'][key]['id'])
		end
		binder['binders'][key]['id'] = rkeys.registerHotKey(val['key'], true, function ()
			lua_thread.create(function()
				for num_line, line in pairs(val['lines']) do
					for tag, val_tag in pairs(binder_tags) do
						if line:find (tostring(val_tag['input'].v)) then
						 line = line:gsub(tostring(val_tag['input'].v),val_tag['action']) end
					end
					if line:find('^%/f') then
						sampSendChat('/f '..u8:decode((input_prefix_f.v and input_prefix_f.v or ''))..' '..line:gsub('%/f',''))
					elseif line:find('^%/r') then
						sampSendChat('/r '..u8:decode((input_prefix_r.v and input_prefix_r.v or ''))..' '..line:gsub('%/r',''))
					else
						sampSendChat(line)
					end
						wait(val['wait'])
				end
			end) -- поток
		end) -- функция
	end
end
function cmd_ud(id)
	print(id)
if (id>=0 and id <1000) then
	lua_thread.create(function()
		sampSendChat('/me чуть распахнув грудь, вытащил'..(sex.v and '' or 'а')..' удостоверение')
		wait(2000)
		sampSendChat('/todo '..my['rang']..' '..my['lastname']..'*раскрыв удостоверение перед лицом человека напротив.')
		wait(2000)
		sampSendChat('/ud '..id)
	end)
else
	sampSendChat('/ud')
end
end
function onWindowMessage(msg, wparam, lparam)
	if(msg == 0x100) then
		if(wparam == VK_ESCAPE and (moset_window.v or window_binder.v or find_window.v or window_so.v)) then
			moset_window.v = false
			window_so.v = false
			find_window.v = false
			window_binder.v = false
			consumeWindowMessage()
		end
	end
end
function update_head()
			if stats_head_rang.v then
				if #head_rang > 0 then
					for i = 1, #head_rang do
						sampDestroy3dText(head_rang[i])
					end
					head_rang = {}
				end
				check_find = true
				sampSendChat('/find')

			end
end
function apply_custom_style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    style.WindowRounding = 6.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.54)
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 2.0
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0

    colors[clr.FrameBg]                = ImVec4(0.48, 0.23, 0.16, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.43, 0.26, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.98, 0.43, 0.26, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.48, 0.23, 0.16, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.98, 0.43, 0.26, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.88, 0.39, 0.24, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.43, 0.26, 1.00)
    colors[clr.Button]                 = ImVec4(0.48, 0.23, 0.16, 0.54)
    colors[clr.ButtonHovered]          = ImVec4(0.98, 0.43, 0.26, 0.70)
    colors[clr.ButtonActive]           = ImVec4(0.98, 0.28, 0.06, 1.00)
    colors[clr.Header]                 = ImVec4(0.98, 0.43, 0.26, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.98, 0.43, 0.26, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.98, 0.43, 0.26, 1.00)
    colors[clr.Separator]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.25, 0.10, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.75, 0.25, 0.10, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.98, 0.43, 0.26, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.43, 0.26, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.43, 0.26, 0.95)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.50, 0.35, 0.40)
    colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.43, 0.26, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.61, 0.61, 0.61, 0.70)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end
apply_custom_style()
function imgui.CenterColumnText(text)
    imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
    imgui.Text(text)
end
function imgui.CenterText(text)
    imgui.SetCursorPosX((imgui.GetWindowSize().x/2) - (imgui.CalcTextSize(text).x / 2))
    imgui.Text(text)
end
function autoupdate(json_url, prefix, url)
  local dlstatus = require('moonloader').download_status
  local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
  if doesFileExist(json) then os.remove(json) end
  downloadUrlToFile(json_url, json,
    function(id, status, p1, p2)
      if status == dlstatus.STATUSEX_ENDDOWNLOAD then
        if doesFileExist(json) then
          local f = io.open(json, 'r')
          if f then
            local info = decodeJson(f:read('*a'))
            updatelink = info.updateurl
            updateversion = info.latest
            f:close()
            os.remove(json)
            if updateversion ~= thisScript().version then
              lua_thread.create(function(prefix)
                local dlstatus = require('moonloader').download_status
                local color = -1
                wait(250)
                downloadUrlToFile(updatelink, thisScript().path,
                  function(id3, status1, p13, p23)
                    if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                      print(string.format('Загружено %d из %d.', p13, p23))
                    elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                      print('Загрузка обновления завершена.')

                      goupdatestatus = true
                      lua_thread.create(function() wait(500) thisScript():reload() end)
                    end
                    if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                      if goupdatestatus == nil then
                        update = false
                      end
                    end
                  end
                )
                end, prefix
              )
            else
              update = false
            end
          end
        else
          print('v'..thisScript().version..': Не могу проверить обновление. Смиритесь или проверьте самостоятельно на '..url)
          update = false
        end
      end
    end
  )
  while update ~= false do wait(100) end
end
function imgui.CenterTextColoredRGB(text)
    local width = imgui.GetWindowWidth()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, 1000):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local textsize = w:gsub('{.-}', '')
            local text_width = imgui.CalcTextSize(u8(textsize))
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else
                imgui.Text(u8(w))
            end
        end
    end
    render_text(text)
end
function setMarker(type, x, y, z, radius, color)
    deleteCheckpoint(marker)
    removeBlip(checkpoint)
    checkpoint = addBlipForCoord(x, y, z)
    marker = createCheckpoint(type, x, y, z, 1, 1, 1, radius)
    changeBlipColour(checkpoint, color)
    repeat
        wait(0)
        local x1, y1, z1 = getCharCoordinates(PLAYER_PED)
        until getDistanceBetweenCoords3d(x, y, z, x1, y1, z1) < radius or not doesBlipExist(checkpoint)
        deleteCheckpoint(marker)
        removeBlip(checkpoint)
        addOneOffSound(0, 0, 0, 1149)
end
function kvadrat()
    local KV = {
        [1] = "А",
        [2] = "Б",
        [3] = "В",
        [4] = "Г",
        [5] = "Д",
        [6] = "Ж",
        [7] = "З",
        [8] = "И",
        [9] = "К",
        [10] = "Л",
        [11] = "М",
        [12] = "Н",
        [13] = "О",
        [14] = "П",
        [15] = "Р",
        [16] = "С",
        [17] = "Т",
        [18] = "У",
        [19] = "Ф",
        [20] = "Х",
        [21] = "Ц",
        [22] = "Ч",
        [23] = "Ш",
        [24] = "Я",
    }
    local X, Y, Z = getCharCoordinates(playerPed)
    X = math.ceil((X + 3000) / 250)
    Y = math.ceil((Y * - 1 + 3000) / 250)
    Y = KV[Y]
    local KVX = (Y.."-"..X)
    return KVX
end
