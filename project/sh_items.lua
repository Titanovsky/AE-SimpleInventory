if not Ambi.SimpleInventory then return end

local Add = Ambi.SimpleInventory.AddClass
-- Аргументы:
-- 1 - Это класс в кавычках, должен быть уникальный
-- 2 - Название предмета
-- 3 - Категория (для сортировки), можно nil
-- 4 - Ссылка на картинку, в конце должен быть формат изображения
-- 5 - Описание, можно nil
-- 6 - (Для продвинутых) это функция, первый аргумент в ней игрок, который активирует предмет. Если возвращает true - предмет потратится, false - не потратится

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function GiveWeapon( ePly, sClass ) -- Здесь функция на выдачу пушки, первый аргумент игрок, второй класс оружия
    if ePly:HasWeapon( sClass ) then return false end
 
    ePly:Give( sClass, true )  
 
    return true  
end

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
Add( 'test1', 'Жопа Бобра', 'Test', 'https://i.imgur.com/r1IyYst.png', 'Просто предмет' )
Add( 'toolgun', 'Tool Gun', 'Оружия', 'https://i.ibb.co/2Nqtqy3/toolgun-png-2637760a4be609bad49994b26d6df18d.png', 'Инструмент для строительства', function( ePly ) 
    return GiveWeapon( ePly, 'gmod_tool' ) 
end )