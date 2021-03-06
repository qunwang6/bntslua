require "cfgBN"

-- +--------------------------------+
-- | Convert Hex color value
-- | to RGBs
-- +--------------------------------+
function hex2RGB(c)
  local r=math.modf(c/65536);
  local g=math.modf(c/256)%256;
  local b=c%256;
  return r,g,b
end


-- +--------------------------------+
-- | Fuzzy method of color compare
-- +--------------------------------+
function colorCompareFuzzy(c, c1, diff)
  diff=diff or 0
  local r,g,b = hex2RGB(c)
  local r1,g1,b1 = hex2RGB(c1)

  if math.abs(r-r1)<=diff and math.abs(g-g1)<=diff and math.abs(b-b1)<=diff then
    return true
  else
    return false
  end
end


function waitForMultiPixelFuzzy( tab, waitfor, diff )
  diff=diff or 0
  for i=1,waitfor*4 do
    mSleep(250)
    for j=1, #(tab) do
      xx=getColor(tab[j].x,tab[j].y)
      if colorCompareFuzzy(xx, tab[j].color, diff) == false then
        break
      end
    end 

    if j == #(tab) then
      return true
    end
  end
  return false
end


-- +--------------------------------+
-- | Wait until one pixel change to
-- | color, or timeout
-- +--------------------------------+
function waitPixel( x,y,color,waitfor,inaccuracy )
  inaccuracy=inaccuracy or 10

  for i=1,waitfor*4 do
    mSleep(250)
    xx=getColor(x,y)

    if  colorCompareFuzzy(xx, color, inaccuracy)==true then
      return true
    end   
  end

  return false
end


-- +--------------------------------+
-- | Wait until several pixels change
-- | to the preset color
-- +--------------------------------+
function waitMultiPixel(img,inaccuracy,waitfor)
  for i=1,waitfor*4 do
    mSleep(250)
    
    keepScreen(true)
    for j=1,#(img) do
      local rx = findColorInRegionFuzzy(img[j].color, inaccuracy, img[j].x, img[j].y, img[j].x, img[j].y)
      m=j
      if rx==-1 then
        break
      end
    end
    keepScreen(false) 

    if m == #(img) then
      return true
    end
  end

  return false
end

-- +--------------------------------+
-- | Wait until at least one pixel
-- | change to THE color
-- +--------------------------------+
function waitForTwoColor(color1,d1,x1,y1,color2,d2,x2,y2,waitfor)
    for i=1,waitfor*4 do
        mSleep(250)
        keepScreen(true)                
        local x1,y1 = findColorInRegionFuzzy(color1,d1,x1,y1,x1,y1)
        local x2,y2 = findColorInRegionFuzzy(color2,d2,x2,y2,x2,y2)
        keepScreen(false)               
        if  x1~=-1 or x2~=-1 then
          return x1,y1,x2,y2
        end   
    end
    return -1,-1,-1,-1
end


function vict_dialog()
    -- click(966,800)    -- ok
    click(BS_victok.x, BS_victok.y)
    mSleep(500)
    -- click(1013,782)   -- ok2
    click(BS_victok2.x, BS_victok2.y)
  end


-- +--------------------------------+
-- | drag from 1 to 2 in b steps
-- +--------------------------------+

function dragDrop(x1,y1,x2,y2,b)
  touchDown(x1,y1)
  mSleep(50)
  i=(x2-x1)/b
  j=(y2-y1)/b
  for step=1,b do
    touchMove(x1+i*step,y1+j*step)
    mSleep(30)
  end 
  mSleep(150)
  touchUp(x2,y2)
end


-- function dropDrag(x1,y1,x2,y2)
--   touchDown(x1,y1)
--   mSleep(50)
--   touchMove(x1,y2)
--   mSleep(50)
--   touchUp(x1,y2)
--   mSleep(50)
-- end

-- +--------------------------------+
-- | drag from p1 to p2, and precisly
-- | stop on p2
-- +--------------------------------+

function preciseDrag(x1,y1,x2,y2,b)
  touchDown(x1,y1)
  mSleep(50)
  i=(x2-x1)/b
  j=(y2-y1)/b
  for step=1,b do
    touchMove(x1+i*step,y1+j*step)
    mSleep(30)
  end
  touchMove(x2-1,y2-1)
  mSleep(50)
  touchMove(x2,y2)
  mSleep(50)
  touchUp(x2,y2)
end



function mapZoomOut()
  mSleep(500)
  touchDown(4,1000,500)
  mSleep(400)
  touchDown(2,500,1500)
  mSleep(400)   
  touchMove(4,900,750)
  mSleep(60)
  touchMove(2,650,1350)
  mSleep(60)      
  touchMove(4,800,1000)
  mSleep(60)
  touchMove(2,800,1200)
  mSleep(60)
  touchUp(4,800,1000)
  mSleep(400)
  touchUp(2,800,1200)
  mSleep(500)
end


function click(x,y) 
  touchDown(x,y)
  mSleep(50)
  touchUp(x,y)
  mSleep(100)
end


-- +--------------------------------+
-- | quick version of click
-- +--------------------------------+
function touchScreen(x,y) 
  touchDown(x,y)
  mSleep(20)
  touchUp(x,y)
  mSleep(30)
end

-- +--------------------------------+
-- | find the img once every second
-- | return when found, or time is out
-- +--------------------------------+
function waitForImage( imgFile,d,x1,y1,x2,y2,color,seconds )
  local waitfor
  local xx=-1
  local yy=-1

  waitfor = 0
  for i=1,seconds do
    mSleep(1000)
    xx,yy=findImageInRegionFuzzy(imgFile,d,x1,y1,x2,y2,color)

    if (xx~=-1 and yy~=-1) or waitfor==seconds then
      return xx,yy,waitfor
    end
  end
end

-- +--------------------------------+
-- | --detect two imgs, return x,y 
-- | when at least one img appears 
-- +--------------------------------+
function waitForTwoImages( img1,d1,x1,y1,x2,y2,color1,img2,d2,x3,y3,x4,y4,color2,seconds )
  local waitfor
  local xx1=-1
  local yy1=-1
  local xx2=-1
  local yy2=-1

  waitfor = 0
  while true do
    mSleep(1000)

    xx1,yy1=findImageInRegionFuzzy(img1,d1,x1,y1,x2,y2,color1)
    xx2,yy2=findImageInRegionFuzzy(img2,d2,x3,y3,x4,y4,color2)

    if (xx1~=-1 and yy1~=-1) or (xx2~=-1 and yy2~=-1) or waitfor==seconds then
      return xx1,yy1,xx2,yy2
    end

    waitfor=waitfor+1

  end
end


-- +--------------------------------+
-- | Traversal enemy grid 
-- +--------------------------------+

function beatit()
  for i=1,2 do
    for j=1,5 do
      touchDown(ehl[i][j].x,ehl[i][j].y)
      mSleep(50)
      touchUp(ehl[i][j].x,ehl[i][j].y)
      mSleep(50)
    end
  end
  for i=2,4 do
    touchDown(ehl[3][i].x,ehl[3][i].y)
    mSleep(50)
    touchUp(ehl[3][i].x,ehl[3][i].y)
    mSleep(50)
  end
  mSleep(50)

  touchScreen(764,1913)
end


function lastPage()
  mSleep(1000)
  dragDrop(unitx,unity[9],unitx,unity[3],5)
  mSleep(500)
  dragDrop(unitx,unity[9],unitx,unity[3],5)
  mSleep(1000)
  -- dragDrop(unitx,unity[9],unitx,unity[2],10)
  -- mSleep(1000)
  -- preciseDrag(unitx,unity[6],unitx,unity[3],10)
  -- dragDrop(unitx,unity[9],unitx,unity[2],7)
  -- mSleep(500)
end

function deployTroop( u )
  local row,col,row1,col1

  for i=1,#(u) do
    click(unitselectx, unitselecty[u[i].cat])                -- unit category button
    mSleep(500)
    -- touchScreen(unitselecty[u[i].cat], unitselecty)      -- category
    
    mSleep(300)
    pg=1                                              -- page
    while pg<=u[i].page do
      preciseDrag(unitx,unity[11],unitx,unity[1]+5,18)
      mSleep(200)
      pg=pg+1
    end

    if u[i].page == -1 then
      lastPage()
    end

    mSleep(u[i].delay)

    mSleep(200)

    for j=1,u[i].num do                           -- deploy the unit(s)
      touchScreen(unitx, unity[u[i].pos])
    end

    for k=1,#(u[i].drag)/4 do                    -- drag unit(s) to the right position
      local start=4*(k-1)+1
      row=u[i].drag[start]
      col=u[i].drag[start+1]
      row1=u[i].drag[start+2]
      col1=u[i].drag[start+3]

      dragDrop(hl[row][col].x,hl[row][col].y,hl[row1][col1].x,hl[row1][col1].y,5)
      mSleep(300)
    end
  end
end


-- +--------------------------------+
-- | Compute the weapon coordinate
-- +--------------------------------+
function weaponCoordinate( wpn, armrack, ammorack )
  local c
  c = 1700 - 130*wpn - 95*(armrack-1) + (armrack-ammorack)*40
  return 1484,c
end

-- +--------------------------------+
-- | retreat from battle
-- +--------------------------------+
function retreat( battlescene )
  battlescene=battlescene or "BIGFOOT"

  for i=1,3 do              -- touch pullback button 2 times
    click(BS_pullback.x, BS_pullback.y)
    mSleep(200)
  end
  mSleep(500)

  if battlescene=="BS" then
    touchScreen(BS_BS_PULLBACKCONFIRM.x, BS_BS_PULLBACKCONFIRM.y)
    mSleep(500)
  end
  -- touchScreen(966,800)          -- ok
  touchScreen(BS_pullbackok.x, BS_pullbackok.y)
end


function proceedAttackSequence( as, battlescene )
  local xx,yy
  local c1,c2
  local row,col,row1,col1
  battlescene=battlescene or "BIGFOOT"

  bigonefound=false

  for i=1,#(as) do
    resetIDLETimer()
    if i==1 then
      local v = waitPixel(BS_abort.x, BS_abort.y, BS_abort.color,15)       --abortx, aborty, abortcolor,
      if v==false then                                          -- timeout, mission failed
        return i,false,false
      end
    end
 
    if battlescene=="DRAGON" then           -- for env damage delay
      -- mSleep(1000)
    end

    xx=hl[as[i].row][as[i].col].x     -- get unit position
    yy=hl[as[i].row][as[i].col].y

    click(xx,yy)                      -- activate unit

    if as[i].wpn~=-1 then
      wx,wy = weaponCoordinate(as[i].wpn, as[i].armrack, as[i].ammorack)
      -- dialog(string.format("%d,%d",wx,wy), 4)
      click(wx,wy)                   -- switch weapon
    end


    beatit()                    -- gatling method fire


    if i<#(as) then             -- we are in middle of attack sequence

      rx,ry,rx1,ry1 = waitForTwoColor(BM_win[1].color,90,BM_win[1].x,BM_win[1].y,       -- 
                                      BS_abort.color, 90,BS_abort.x,BS_abort.y,50)

      if rx~=-1 and ry~=-1 then          -- victory dialog found
        click(BM_win[1].x, BM_win[1].y)
        return i,true,bigonefound
      else 
        if rx==-1 and ry==-1 and rx1==-1 and ry1==-1 then         -- timeout, mission failed
          return i,false,bigonefound
        end
      end
    else                              -- It's the Last round
      v = waitPixel(BM_win[1].x, BM_win[1].y, BM_win[1].color,50)
      if v==false then
        return i,false,bigonefound
      else
        click(BM_win[1].x, BM_win[1].y)
        return i,true,bigonefound
      end
    end                 -- [ if i<attacks ]
    mSleep(200)
  end    -- [for i=1,attacks do]
end


function saveScreen(filename,x,y,x1,y1,reason)
  snapshot(filename,x,y,x1,y1)
  appendLog(LOGFILE,"screen saved in "..filename)
end


function appendLog( logfile, str )
  initLog(logfile,0)
  wLog(logfile, str )
  closeLog(logfile)
end

-- +----------------------------------+
-- | send SP dragon troop
-- +----------------------------------+

function dragonSet()
  while true do

    click( BFFx.x, BFFx.y)

    rx = waitMultiPixel( BM_glass_BS, 95, 50 )           --Wait the search button for 50 seconds

    if rx == false then
      return false
    end

    deployTroop( units.dragon )

    click(BS_fight.x, BS_fight.y)

    v = waitPixel(BS_victok.x, BS_victok.y, BS_victok.color,80)
    vict_dialog()                -- victory dialog found

    found = waitMultiPixel( MM_base_F, 90, 50 )
  end

end

-- +----------------------------------+
-- | Kill Dragon
-- +----------------------------------+

function repelInvader()
  local failure=0
  local x,y

  while true do  

    x,y = findMultiColorInRegionFuzzy(0xff8000, logoMultiColor.invasion,90,
                                              searchmap.x,searchmap.y,searchmap.x1,searchmap.y1) 

    -- dialog(string.format("%d,%d",x,y), 4 )

    if x~=-1 and y~=-1 then
      
      click(x,y)
      mSleep(1300) 

      click(x,y-220)
      
      rx = waitMultiPixel( BM_glass_BS, 95, 30 )           --Wait the round grey button for 30 seconds
      -- rx = waitMultiPixel( BM_beginGrey, 95, 30 )           --Wait the round grey button for 30 seconds
      if rx == false then
        return false
      end

      deployTroop( units.invasion )

      click(BS_fight.x, BS_fight.y)

      rounds,finished,bigone = proceedAttackSequence( attackSequence.invasion, "DRAGON" )   -- Proceed the attack plan

      if finished==false then
        failure=failure+1
        appendLog(LOGFILE,"Battle failed #"..string.format("%d",failure))
      else
        failure=0
      end
      
      if failure==5 then
        return false        -- too many fails
      end       

      found = waitMultiPixel( MM_base, 90, 35 )              -- wait for the map mark: base shield button

      if found==true then
        appendLog(LOGFILE, "[Invader]"..string.format(" %d rounds", rounds) )
      else
        return false      -- home land not found
      end
    else        
      return  true
    end     
  end     
end


function findGoodMan()
  local rx, ry, found

  while true do

    rx,ry=findImageInRegionFuzzy("tecourt.png", 95, 289,654,1487,1287, 0)

    if rx~=-1 and ry~=-1 then
      dialog("got cha", 5)
      return rx,ry
    end

    click(70,70)   -- close arena challenge dialog

    found = waitMultiPixel( BM_arenalogo, 90, 60 )
    if found == true then
      click( BM_arenalogo[1].x, BM_arenalogo[1].y )
    else
      return -1,-1
    end

    found = waitMultiPixel(BM_arena, 90, 15)
    if found == true then
      click( BM_arena[2].x, BM_arena[2].y )
      
      found = waitPixel(400, 146, 0xF26A21, 90, 50)     -- the list appears
      if found == false then      -- timeout
        return -1, -1
      end
    end

  end
end


function doPVP()
  local rx, rx1

  for i=1,PVP_MAX do
    resetIDLETimer()
    rx = waitMultiPixel( BM_again, 90, 60)    -- wait for the "again" button

    if rx == false then
      return false
    end

    click( 574, 591)

    rx = waitMultiPixel( BM_nano, 95, 5 )           --Wait the search button for 30 seconds

    if rx == true then
      click(BM_nano[3].x, BM_nano[3].y)          -- here is your nano!
      mSleep(500)
      click(BS_nanoconfirm.x, BS_nanoconfirm.y)  -- confirm

      rx1 = waitPixel(BS_nanook.x, BS_nanook.y, BS_nanook.color,90, 45)
      if rx == false then
        return false
      end
      click(BS_nanook.x, BS_nanook.y)      -- click ok

      rx = waitMultiPixel( BM_again, 90, 60)    -- wait for the "again" button
      if rx == false then
        return false
      end
      click( 574, 591)

    end

    rx = waitMultiPixel( BM_glass_BS, 95, 70 )           --Wait the round grey button for 30 seconds
    if rx == false then
      return false
    end

    deployTroop( units[PVP_CURRENT] )

    click(BS_fight.x, BS_fight.y)

    rounds,finished,bigone = proceedAttackSequence( attackSequence[PVP_CURRENT] )   -- Proceed the attack plan

    if finished==false then
      failure=failure+1
      appendLog(LOGFILE,"pvp Battle failed #"..string.format("%d",failure))
    else
      failure=0
      appendLog(LOGFILE,string.format("pvp Battle # %d",i) )
    end
    
    if failure==5 then
      return false        -- too many fails
    end       
  end    -- for 

end


-- -- if choice==2 then
-- choice = dialogRet("Chose your Mission","Cancel","扫龙神器","投龙猪手",10)
    
-- if choice==1 then
--   init("0",0)
--   mSleep(500)

--   -- click(5,5)

--   success=repelInvader()

--   lockDevice()
--   lua_exit()  
--   -- lua_exit()
-- end

-- if choice==0 then
  init("0",0)
  mSleep(500)
  x,y = findGoodMan()
  dialog( string.format("%d, %d",x,y), 5 )
  -- doPVP()
  lockDevice()
  lua_exit()  
-- end

-- if choice==2 then
--   init("0",0)
--   mSleep(500)

--   dragonSet()

--   lockDevice()
--   lua_exit()
-- end