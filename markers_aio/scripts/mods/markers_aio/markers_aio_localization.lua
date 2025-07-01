local mod = get_mod("markers_aio")

local loc = {
    mod_name = {
        en = "Markers Improved AIO",
        ru = "Улучшенные метки - все в одном",
        ["zh-tw"] = "標記改進整合版",
        ["zh-cn"] = "图标改进集成"
    },
    mod_description = {
        en = "Combines all my 'Markers' mods in to one easy to install package. ",
        fr = "Combine tous mes mods 'Marqueurs' en un seul paquet facile à installer. ",
        ru = "Markers Improved AIO - Объединяет все мои моды «Меток» в один простой в установке пакет.",
        ["zh-tw"] = "將所有「標記」模組整合成一個方便安裝的套件。",
        ["zh-cn"] = "集成我的全部‘图标’模组为一个简单的安装包"
    },

    -- General Settings
    aio_settings = {
        en = "MARKERS IMPROVED AIO SETTINGS",
        fr = "MARKERS IMPROVED AIO SETTINGS",
        ru = "MARKERS IMPROVED AIO SETTINGS",
        ["zh-tw"] = "圖標改善設定",
        ["zh-cn"] = "图标改进集成设置"
    },
    los_fade_enable = {
        en = "Fade out icons out of line of sight",
        fr = "Fade out icons out of line of sight",
        ru = "Fade out icons out of line of sight",
        ["zh-tw"] = "視線外淡化圖標",
        ["zh-cn"] = "视野外图标淡出"
    },
    los_opacity = {
        en = "Line of sight alpha (percentage)",
        fr = "Line of sight alpha (percentage)",
        ru = "Line of sight alpha (percentage)",
        ["zh-tw"] = "視線外圖標透明度",
        ["zh-cn"] = "视野外图标透明度"
    },
    marker_background_colour = {
        en = "Marker background colour"
    },

    -- AMMO MED MARKERS
    ammo_med_markers_settings = {
        en = "AMMO & MED MARKERS",
        fr = "MARQUEURS DE MUNITIONS ET MÉDICAUX",
        ru = "МЕТКИ - БОЕПРИПАСЫ И МЕДИЦИНА",
        ["zh-tw"] = "彈藥與醫療標記",
        ["zh-cn"] = "弹药与医疗箱图标"
    },
    ammo_med_enable = {
        en = "Enable Markers",
        fr = "Activer les marqueurs",
        ru = "Включить метки",
        ["zh-tw"] = "啟用標記",
        ["zh-cn"] = "启用图标"
    },
    ammo_med_general_settings = {
        en = "General Settings",
        fr = "Paramètres généraux",
        ru = "Общие настройки",
        ["zh-tw"] = "一般設定",
        ["zh-cn"] = "通用设置"
    },
    ammo_med_markers_alternate_large_ammo_icon = {
        en = "Use Alternative Icon for Large Ammo pickups",
        fr = "Utiliser une icône alternative pour les grandes munitions ramassées",
        ru = "Использовать альтернативные значки для больших сумок с боеприпасами",
        ["zh-tw"] = "使用替代圖示表示大型彈藥",
        ["zh-cn"] = "为弹药包（大型）使用替代图标"
    },
    ammo_med_keep_on_screen = {
        en = "Keep on screen",
        fr = "Rester à l'écran",
        ru = "Держать на экране",
        ["zh-tw"] = "保持顯示於螢幕",
        ["zh-cn"] = "在画面中持续显示"
    },
    ammo_med_require_line_of_sight = {
        en = "Require line of sight",
        fr = "Nécessite une ligne de vue",
        ru = "Должно быть в зоне видимости",
        ["zh-tw"] = "需要視線範圍",
        ["zh-cn"] = "需要视野"
    },
    ammo_med_max_distance = {
        en = "Max distance",
        fr = "Distance maximale",
        ru = "Максимальное расстояние",
        ["zh-tw"] = "最遠距離",
        ["zh-cn"] = "最大距离"
    },
    ammo_med_max_size = {
        en = "Maximum size of marker",
        fr = "Taille maximale du marqueur",
        ru = "Максимальный размер метки",
        ["zh-tw"] = "圖標最大尺寸",
        ["zh-cn"] = "图标最大尺寸"
    },
    ammo_med_min_size = {
        en = "Minimum size of marker",
        fr = "Taille minimale du marqueur",
        ru = "Минимальный размер метки",
        ["zh-tw"] = "圖標的最小尺寸",
        ["zh-cn"] = "图标最小尺寸"
    },
    ammo_med_scale = {
        en = "Scale",
        fr = "Scale",
        ru = "Scale",
        ["zh-tw"] = "圖標縮放大小",
        ["zh-cn"] = "图标缩放比例"
    },
    ammo_med_alpha = {
        en = "Alpha Multiplier",
        fr = "Multiplicateur d'alpha",
        ru = "Прозрачность",
        ["zh-tw"] = "透明度倍增器",
        ["zh-cn"] = "透明度"
    },
    display_med_charges = {
        en = "Display Medical Charges",
        fr = "Afficher les charges médicales",
        ru = "Показывать заряды медстанции",
        ["zh-tw"] = "顯示醫療充能",
        ["zh-cn"] = "显示医疗箱充能"
    },
    display_ammo_charges = {
        en = "Display Ammo Charges",
        fr = "Afficher les charges de munitions",
        ru = "Показывать заряды ящика с боеприпасами",
        ["zh-tw"] = "顯示彈藥充能",
        ["zh-cn"] = "显示弹药箱充能数"
    },
    display_field_improv_colour = {
        en = "Adjust colour of markers if 'Field Improvisation' talent is active?",
        fr = "Ajuster la couleur pour le talent 'Improvisation sur le terrain' ? ",
        ru = "Изменять цвет маркеров, если активен талант «Полевая импровизация»?",
        ["zh-tw"] = "如果啟用「現場應變」天賦，調整標記顏色？",
        ["zh-cn"] = "‘临场发挥’天赋激活时，是否调整图标颜色"
    },
    display_field_improv_icon = {
        en = "Display New 'Field Improvisation' talent Icon",
        fr = "Afficher la nouvelle icône du talent 'Improvisation sur le terrain'",
        ru = "Показывать новый значок таланта «Полевая импровизация»",
        ["zh-tw"] = "顯示新的「現場應變」天賦圖示",
        ["zh-cn"] = "显示新的‘临场发挥’天赋图标"
    },
    display_med_ring = {
        en = "Display Proximity Radius Around Medkits?",
        fr = "Afficher le rayon de proximité autour des kits médicaux ?",
        ru = "Показывать радиус действия медпакетов?",
        ["zh-tw"] = "顯示醫療包周圍的接近半徑？",
        ["zh-cn"] = "是否显示医疗箱作用范围"
    },
    change_colour_for_ammo_charges = {
        en = "Change ammo & medicae crate colour depending on charges left?",
        fr = "Changer la couleur des caisses de munitions en fonction des charges ? ",
        ru = "Изменять цвет значка ящика с боеприпасами в зависимости от оставшихся зарядов?",
        ["zh-tw"] = "根據剩餘充能改變彈藥箱顏色？",
        ["zh-cn"] = "是否依剩余充能数改变弹药箱图标颜色"
    },
    ammo_small_colour = {
        en = "Ammo (Small) Colour",
        fr = "Couleur des munitions (petites)",
        ru = "Цвет малой сумки с боеприпасами",
        ["zh-tw"] = "彈藥（小型）顏色",
        ["zh-cn"] = "弹药罐（小型）颜色"
    },
    ammo_small_colour_R = {
        en = "R",
        fr = "R",
        ru = "К",
        ["zh-tw"] = "紅",
        ["zh-cn"] = "红"
    },
    ammo_small_colour_G = {
        en = "G",
        fr = "V",
        ru = "З",
        ["zh-tw"] = "綠",
        ["zh-cn"] = "绿"
    },
    ammo_small_colour_B = {
        en = "B",
        fr = "B",
        ru = "С",
        ["zh-tw"] = "藍",
        ["zh-cn"] = "蓝"
    },
    ammo_small_border_colour = {
        en = "Border Colour",
        fr = "Couleur de la bordure",
        ru = "Цвет границы",
        ["zh-tw"] = "邊框顏色",
        ["zh-cn"] = "边框颜色"
    },
    ammo_large_colour = {
        en = "Ammo (Large) Colour",
        fr = "Couleur des munitions (grandes)",
        ru = "Цвет большой сумки с боеприпасами",
        ["zh-tw"] = "彈藥（大型）顏色",
        ["zh-cn"] = "弹药包（大型）颜色"
    },
    ammo_large_colour_R = {
        en = "R",
        fr = "R",
        ru = "К",
        ["zh-tw"] = "紅",
        ["zh-cn"] = "红"
    },
    ammo_large_colour_G = {
        en = "G",
        fr = "V",
        ru = "З",
        ["zh-tw"] = "綠",
        ["zh-cn"] = "绿"
    },
    ammo_large_colour_B = {
        en = "B",
        fr = "B",
        ru = "С",
        ["zh-tw"] = "藍",
        ["zh-cn"] = "蓝"
    },
    ammo_large_border_colour = {
        en = "Border Colour",
        fr = "Couleur de la bordure",
        ru = "Цвет границы",
        ["zh-tw"] = "邊框顏色",
        ["zh-cn"] = "图标颜色"
    },
    ammo_crate_colour = {
        en = "Ammo Crate Colour",
        fr = "Couleur de la caisse de munitions",
        ru = "Цвет ящика с боеприпасами",
        ["zh-tw"] = "彈藥箱顏色",
        ["zh-cn"] = "弹药箱颜色"
    },
    ammo_crate_colour_R = {
        en = "R",
        fr = "R",
        ru = "К",
        ["zh-tw"] = "紅",
        ["zh-cn"] = "红"
    },
    ammo_crate_colour_G = {
        en = "G",
        fr = "V",
        ru = "З",
        ["zh-tw"] = "綠",
        ["zh-cn"] = "绿"
    },
    ammo_crate_colour_B = {
        en = "B",
        fr = "B",
        ru = "С",
        ["zh-tw"] = "藍",
        ["zh-cn"] = "蓝"
    },
    ammo_crate_border_colour = {
        en = "Border Colour",
        fr = "Couleur de la bordure",
        ru = "Цвет границы",
        ["zh-tw"] = "邊框顏色",
        ["zh-cn"] = "边框颜色"
    },
    med_crate_colour = {
        en = "Medical Crate Colour",
        fr = "Couleur de la caisse médicale",
        ru = "Цвет медпакета",
        ["zh-tw"] = "醫療箱顏色",
        ["zh-cn"] = "医疗箱颜色"
    },
    med_crate_colour_R = {
        en = "R",
        fr = "R",
        ru = "К",
        ["zh-tw"] = "紅",
        ["zh-cn"] = "红"
    },
    med_crate_colour_G = {
        en = "G",
        fr = "V",
        ru = "З",
        ["zh-tw"] = "綠",
        ["zh-cn"] = "绿"
    },
    med_crate_colour_B = {
        en = "B",
        fr = "B",
        ru = "С",
        ["zh-tw"] = "藍",
        ["zh-cn"] = "蓝"
    },
    med_crate_border_colour = {
        en = "Border Colour",
        fr = "Couleur de la bordure",
        ru = "Цвет границы",
        ["zh-tw"] = "邊框顏色",
        ["zh-cn"] = "图标颜色"
    },
    grenade_colour = {
        en = "Grenade Colour",
        fr = "Couleur des grenades",
        ru = "Цвет гранат",
        ["zh-tw"] = "手榴彈顏色",
        ["zh-cn"] = "手雷颜色"
    },
    grenade_colour_R = {
        en = "R",
        fr = "R",
        ru = "К",
        ["zh-tw"] = "紅",
        ["zh-cn"] = "红"
    },
    grenade_colour_G = {
        en = "G",
        fr = "V",
        ru = "З",
        ["zh-tw"] = "綠",
        ["zh-cn"] = "绿"
    },
    grenade_colour_B = {
        en = "B",
        fr = "B",
        ru = "С",
        ["zh-tw"] = "藍",
        ["zh-cn"] = "蓝"
    },
    grenade_border_colour = {
        en = "Border Colour",
        fr = "Couleur de la bordure",
        ru = "Цвет границы",
        ["zh-tw"] = "邊框顏色",
        ["zh-cn"] = "边框颜色"
    },

    -- CHEST MARKERS
    chest_markers_settings = {
        en = "CHEST MARKERS",
        fr = "MARQUEURS DE COFFRES",
        ru = "МЕТКИ ЯЩИКОВ",
        ["zh-tw"] = "寶箱圖標",
        ["zh-cn"] = "宝箱图标"
    },
    chest_enable = {
        en = "Enable Markers",
        fr = "Activer les marqueurs",
        ru = "Включить метки",
        ["zh-tw"] = "啟用標記",
        ["zh-cn"] = "启用图标"
    },
    chest_alternative_icon = {
        en = "Use Alternative Icon",
        fr = "Utiliser une icône alternative",
        ru = "Включить альтернативный значок",
        ["zh-tw"] = "使用替代圖示",
        ["zh-cn"] = "使用替代图标"
    },
    chest_icon = {
        en = "Use Alternative Icon",
        fr = "Utiliser une icône alternative",
        ru = "Включить альтернативный значок",
        ["zh-tw"] = "使用替代圖示",
        ["zh-cn"] = "使用替代图标"
    },
    Default = {
        en = "Default"
    },
    Video = {
        en = "Video"
    },
    Loot = {
        en = "Loot"
    },
    chest_general_settings = {
        en = "General Settings",
        fr = "Paramètres généraux",
        ru = "Общие настройки",
        ["zh-tw"] = "一般設定",
        ["zh-cn"] = "通用设置"
    },
    chest_keep_on_screen = {
        en = "Keep on screen",
        fr = "Rester à l'écran",
        ru = "Держать на экране",
        ["zh-tw"] = "保持顯示於螢幕",
        ["zh-cn"] = "在画面中持续显示"
    },
    chest_require_line_of_sight = {
        en = "Require line of sight",
        fr = "Nécessite une ligne de vue",
        ru = "Должно быть в зоне видимости",
        ["zh-tw"] = "需要視線範圍",
        ["zh-cn"] = "需要视野"
    },
    chest_max_distance = {
        en = "Max distance",
        fr = "Distance maximale",
        ru = "Максимальное расстояние",
        ["zh-tw"] = "最遠距離",
        ["zh-cn"] = "最大距离"
    },
    chest_max_size = {
        en = "Maximum size of marker",
        fr = "Taille maximale du marqueur",
        ru = "Максимальный размер метки",
        ["zh-tw"] = "圖標的最大尺寸",
        ["zh-cn"] = "图标最大尺寸"
    },
    chest_min_size = {
        en = "Minimum size of marker",
        fr = "Taille minimale du marqueur",
        ru = "Минимальный размер метки",
        ["zh-tw"] = "圖標的最小尺寸",
        ["zh-cn"] = "图标最小尺寸"
    },
    chest_scale = {
        en = "Scale",
        fr = "Scale",
        ru = "Scale",
        ["zh-tw"] = "圖標縮放大小",
        ["zh-cn"] = "图标缩放比例"
    },
    chest_alpha = {
        en = "Alpha Multiplier",
        fr = "Multiplicateur d'alpha",
        ru = "Прозрачность",
        ["zh-tw"] = "透明度倍增器",
        ["zh-cn"] = "透明度"
    },
    chest_icon_colour = {
        en = "Chest Icon Colour",
        fr = "Couleur de l'icône du coffre",
        ru = "Цвет значка ящика",
        ["zh-tw"] = "寶箱圖標顏色",
        ["zh-cn"] = "宝箱图标颜色"
    },
    chest_icon_colour_R = {
        en = "R",
        fr = "R",
        ru = "К",
        ["zh-tw"] = "紅",
        ["zh-cn"] = "红"
    },
    chest_icon_colour_G = {
        en = "G",
        fr = "V",
        ru = "З",
        ["zh-tw"] = "綠",
        ["zh-cn"] = "绿"
    },
    chest_icon_colour_B = {
        en = "B",
        fr = "B",
        ru = "С",
        ["zh-tw"] = "藍",
        ["zh-cn"] = "蓝"
    },
    chest_border_colour = {
        en = "Border Colour",
        fr = "Couleur de la bordure",
        ru = "Цвет границы",
        ["zh-tw"] = "邊框顏色",
        ["zh-cn"] = "边框颜色"
    },

    -- HERETICAL IDOL MARKERS
    heretical_idol_markers_settings = {
        en = "HERETICAL IDOL MARKERS",
        fr = "MARQUEURS D'IDÔLES HÉRÉTIQUES",
        ru = "МЕТКИ ЕРЕТИЧЕСКИХ ИДОЛОВ",
        ["zh-tw"] = "異端雕像圖標",
        ["zh-cn"] = "异端雕像图标"
    },
    heretical_idol_enable = {
        en = "Enable Markers",
        fr = "Activer les marqueurs",
        ru = "Включить метки",
        ["zh-tw"] = "啟用標記",
        ["zh-cn"] = "启用图标"
    },
    heretical_idol_general_settings = {
        en = "General Settings",
        fr = "Paramètres généraux",
        ru = "Общие настройки",
        ["zh-tw"] = "一般設定",
        ["zh-cn"] = "通用设置"
    },
    heretical_idol_keep_on_screen = {
        en = "Keep on screen",
        fr = "Rester à l'écran",
        ru = "Держать на экране",
        ["zh-tw"] = "保持顯示於螢幕",
        ["zh-cn"] = "在画面中持续显示"
    },
    heretical_idol_require_line_of_sight = {
        en = "Require line of sight",
        fr = "Nécessite une ligne de vue",
        ru = "Должно быть в зоне видимости",
        ["zh-tw"] = "需要視線範圍",
        ["zh-cn"] = "需要视野"
    },
    heretical_idol_max_distance = {
        en = "Max distance",
        fr = "Distance maximale",
        ru = "Максимальное расстояние",
        ["zh-tw"] = "最遠距離",
        ["zh-cn"] = "最大范围"
    },
    heretical_idol_max_size = {
        en = "Maximum size of marker",
        fr = "Taille maximale du marqueur",
        ru = "Максимальный размер метки",
        ["zh-tw"] = "標記的最大尺寸",
        ["zh-cn"] = "图标最大尺寸"
    },
    heretical_idol_min_size = {
        en = "Minimum size of marker",
        fr = "Taille minimale du marqueur",
        ru = "Минимальный размер метки",
        ["zh-tw"] = "圖標的最小尺寸",
        ["zh-cn"] = "图标最小尺寸"
    },
    heretical_idol_scale = {
        en = "Scale",
        fr = "Scale",
        ru = "Scale",
        ["zh-tw"] = "圖標縮放大小",
        ["zh-cn"] = "图标缩放比例"
    },
    heretical_idol_alpha = {
        en = "Alpha Multiplier",
        fr = "Multiplicateur d'alpha",
        ru = "Прозрачность",
        ["zh-tw"] = "透明度倍增器",
        ["zh-cn"] = "透明度"
    },

    icon_colour = {
        en = "Icon Colour",
        fr = "Couleur de l'icône",
        ru = "Цвет значка",
        ["zh-tw"] = "圖示顏色",
        ["zh-cn"] = "图标颜色"
    },
    icon_colour_R = {
        en = "R",
        fr = "R",
        ru = "К",
        ["zh-tw"] = "紅",
        ["zh-cn"] = "红"
    },
    icon_colour_G = {
        en = "G",
        fr = "V",
        ru = "З",
        ["zh-tw"] = "綠",
        ["zh-cn"] = "绿"
    },
    icon_colour_B = {
        en = "B",
        fr = "B",
        ru = "С",
        ["zh-tw"] = "藍",
        ["zh-cn"] = "蓝"
    },
    idol_border_colour = {
        en = "Border Colour",
        fr = "Couleur de la bordure",
        ru = "Цвет границы",
        ["zh-tw"] = "邊框顏色",
        ["zh-cn"] = "边框颜色"
    },

    -- MATERIAL MARKERS
    material_markers_settings = {
        en = "MATERIAL MARKERS",
        fr = "MARQUEURS DE MATÉRIAUX",
        ru = "МЕТКИ РЕСУРСОВ",
        ["zh-tw"] = "材料圖標",
        ["zh-cn"] = "材料图标"
    },
    material_enable = {
        en = "Enable Markers",
        fr = "Activer les marqueurs",
        ru = "Включить метки",
        ["zh-tw"] = "啟用標記",
        ["zh-cn"] = "启用图标"
    },
    material_general_settings = {
        en = "General Settings",
        fr = "Paramètres généraux",
        ru = "Общие настройки",
        ["zh-tw"] = "一般設定",
        ["zh-cn"] = "通用设置"
    },
    material_keep_on_screen = {
        en = "Keep on screen",
        fr = "Rester à l'écran",
        ru = "Держать на экране",
        ["zh-tw"] = "保持顯示於螢幕",
        ["zh-cn"] = "在画面中持续显示"
    },
    material_require_line_of_sight = {
        en = "Require line of sight",
        fr = "Nécessite une ligne de vue",
        ru = "Должно быть в зоне видимости",
        ["zh-tw"] = "需要視線範圍",
        ["zh-cn"] = "需要视野"
    },
    material_max_distance = {
        en = "Max distance",
        fr = "Distance maximale",
        ru = "Максимальное расстояние",
        ["zh-tw"] = "最遠距離",
        ["zh-cn"] = "最大距离"
    },
    material_max_size = {
        en = "Maximum size of marker",
        fr = "Taille maximale du marqueur",
        ru = "Максимальный размер метки",
        ["zh-tw"] = "圖標的最大尺寸",
        ["zh-cn"] = "图标最大尺寸"
    },
    material_min_size = {
        en = "Minimum size of marker",
        fr = "Taille minimale du marqueur",
        ru = "Минимальный размер метки",
        ["zh-tw"] = "圖標的最小尺寸",
        ["zh-cn"] = "图标最小尺寸"
    },
    material_scale = {
        en = "Scale",
        fr = "Scale",
        ru = "Scale",
        ["zh-tw"] = "圖標縮放大小",
        ["zh-cn"] = "图标缩放比例"
    },
    material_alpha = {
        en = "Alpha Multiplier",
        fr = "Multiplicateur d'alpha",
        ru = "Прозрачность",
        ["zh-tw"] = "透明度倍增器",
        ["zh-cn"] = "透明度"
    },
    marker_toggles = {
        en = "Toggle Materials",
        fr = "Basculer les matériaux",
        ru = "Переключение ресурсов",
        ["zh-tw"] = "切換材料",
        ["zh-cn"] = "材料切换"
    },
    toggle_large_plasteel = {
        en = "Show Large Plasteel Markers",
        fr = "Afficher les marqueurs des grandes caches de plastacier",
        ru = "Показывать метки больших кусков пластали",
        ["zh-tw"] = "顯示大型塑鋼標記",
        ["zh-cn"] = "显示大塑钢储物柜图标"
    },
    toggle_small_plasteel = {
        en = "Show Small Plasteel Markers",
        fr = "Afficher les marqueurs des petites caches de plastacier",
        ru = "Показывать метки малых кусков пластали",
        ["zh-tw"] = "顯示小型塑鋼標記",
        ["zh-cn"] = "显示小塑储物柜图标"
    },
    toggle_large_diamantine = {
        en = "Show Large Diamantine Markers",
        fr = "Afficher les marqueurs des grandes caches de diamantine",
        ru = "Показывать метки больших кусков диамантина",
        ["zh-tw"] = "顯示大型金剛晶石標記",
        ["zh-cn"] = "显示大金刚砂储物柜图标"
    },
    toggle_small_diamantine = {
        en = "Show Small Diamantine Markers",
        fr = "Afficher les marqueurs des petites caches de diamantine",
        ru = "Показывать малых больших кусков диамантина",
        ["zh-tw"] = "顯示小型金剛晶石標記",
        ["zh-cn"] = "显示小金刚砂储物柜图标"
    },
    plasteel_icon_colour = {
        en = "Plasteel Icon Colour",
        fr = "Couleur de l'icône plastacier",
        ru = "Цвет значка пластали",
        ["zh-tw"] = "塑鋼圖示顏色",
        ["zh-cn"] = "塑钢图标颜色"
    },
    plasteel_icon_colour_R = {
        en = "R",
        fr = "R",
        ru = "К",
        ["zh-tw"] = "紅",
        ["zh-cn"] = "红"
    },
    plasteel_icon_colour_G = {
        en = "G",
        fr = "V",
        ru = "З",
        ["zh-tw"] = "綠",
        ["zh-cn"] = "绿"
    },
    plasteel_icon_colour_B = {
        en = "B",
        fr = "B",
        ru = "С",
        ["zh-tw"] = "藍",
        ["zh-cn"] = "蓝"
    },
    diamantine_icon_colour = {
        en = "Diamantine Icon Colour",
        fr = "Couleur de l'icône diamantine",
        ru = "Цвет значка диамантина",
        ["zh-tw"] = "金剛晶石圖示顏色",
        ["zh-cn"] = "金刚砂图标颜色"
    },
    diamantine_icon_colour_R = {
        en = "R",
        fr = "R",
        ru = "К",
        ["zh-tw"] = "紅",
        ["zh-cn"] = "红"
    },
    diamantine_icon_colour_G = {
        en = "G",
        fr = "V",
        ru = "З",
        ["zh-tw"] = "綠",
        ["zh-cn"] = "绿"
    },
    diamantine_icon_colour_B = {
        en = "B",
        fr = "B",
        ru = "С",
        ["zh-tw"] = "藍",
        ["zh-cn"] = "蓝"
    },
    material_small_border_colour = {
        en = "Small Material Cache Border Colour",
        fr = "Couleur de la bordure des petites caches",
        ru = "Цвет границы малого тайника с ресурсами",
        ["zh-tw"] = "小型材料儲存邊框顏色",
        ["zh-cn"] = "小材料储存柜颜色"
    },
    material_large_border_colour = {
        en = "Large Material Cache Border Colour",
        fr = "Couleur de la bordure des grandes caches",
        ru = "Цвет границы большого тайника с ресурсами",
        ["zh-tw"] = "大型材料儲存邊框顏色",
        ["zh-cn"] = "大材料储存柜颜色"
    },

    -- STIMM MARKERS
    stimm_markers_settings = {
        en = "STIMM MARKERS",
        fr = "MARQUEURS STIMM",
        ru = "МЕТКИ СТИМУЛЯТОРОВ",
        ["zh-tw"] = "興奮劑標記",
        ["zh-cn"] = "兴奋剂图标"
    },
    stimm_enable = {
        en = "Enable Markers",
        fr = "Activer les marqueurs",
        ru = "Включить метки",
        ["zh-tw"] = "啟用標記",
        ["zh-cn"] = "启用图标"
    },
    stimm_general_settings = {
        en = "General Settings",
        fr = "Paramètres généraux",
        ru = "Общие настройки",
        ["zh-tw"] = "一般設定",
        ["zh-cn"] = "通用设置"
    },
    stimm_keep_on_screen = {
        en = "Keep on screen",
        fr = "Rester à l'écran",
        ru = "Держать на экране",
        ["zh-tw"] = "保持顯示於螢幕",
        ["zh-cn"] = "在画面中持续显示"
    },
    stimm_require_line_of_sight = {
        en = "Require line of sight",
        fr = "Nécessite une ligne de vue",
        ru = "Должно быть в зоне видимости",
        ["zh-tw"] = "需要視線範圍",
        ["zh-cn"] = "需要视野"
    },
    stimm_max_distance = {
        en = "Max distance",
        fr = "Distance maximale",
        ru = "Максимальное расстояние",
        ["zh-tw"] = "最遠距離",
        ["zh-cn"] = "最大距离"
    },
    stimm_max_size = {
        en = "Maximum size of marker",
        fr = "Taille maximale du marqueur",
        ru = "Максимальный размер метки",
        ["zh-tw"] = "圖標的最大尺寸",
        ["zh-cn"] = "图标最大尺寸"
    },
    stimm_min_size = {
        en = "Minimum size of marker",
        fr = "Taille minimale du marqueur",
        ru = "Минимальный размер метки",
        ["zh-tw"] = "圖標的最小尺寸",
        ["zh-cn"] = "图标最小尺寸"
    },
    stimm_scale = {
        en = "Scale",
        fr = "Scale",
        ru = "Scale",
        ["zh-tw"] = "圖標縮放大小",
        ["zh-cn"] = "图标缩放比例"
    },
    stimm_alpha = {
        en = "Alpha Multiplier",
        fr = "Multiplicateur d'alpha",
        ru = "Прозрачность",
        ["zh-tw"] = "透明度倍增器",
        ["zh-cn"] = "透明度"
    },
    boost_stimm_icon_colour = {
        en = "Boost Stimm Icon Colour",
        fr = "Couleur de l'icône de boost Stimm",
        ru = "Цвет значка стимулятора усиления",
        ["zh-tw"] = "增強興奮劑圖示顏色",
        ["zh-cn"] = "专注兴奋剂图标颜色"
    },
    boost_stimm_icon_colour_R = {
        en = "R",
        fr = "R",
        ru = "К",
        ["zh-tw"] = "紅",
        ["zh-cn"] = "红"
    },
    boost_stimm_icon_colour_G = {
        en = "G",
        fr = "V",
        ru = "З",
        ["zh-tw"] = "綠",
        ["zh-cn"] = "绿"
    },
    boost_stimm_icon_colour_B = {
        en = "B",
        fr = "B",
        ru = "С",
        ["zh-tw"] = "藍",
        ["zh-cn"] = "蓝"
    },
    boost_stimm_border_colour = {
        en = "Border Colour",
        fr = "Couleur de la bordure",
        ru = "Цвет границы",
        ["zh-tw"] = "邊框顏色",
        ["zh-cn"] = "边框颜色"
    },
    corruption_stimm_icon_colour = {
        en = "Corruption Stimm Icon Colour",
        fr = "Couleur de l'icône de corruption Stimm",
        ru = "Цвет значка стимулятора лечения",
        ["zh-tw"] = "治療針圖示顏色",
        ["zh-cn"] = "医疗兴奋剂图标颜色"
    },
    corruption_stimm_icon_colour_R = {
        en = "R",
        fr = "R",
        ru = "К",
        ["zh-tw"] = "紅",
        ["zh-cn"] = "红"
    },
    corruption_stimm_icon_colour_G = {
        en = "G",
        fr = "V",
        ru = "З",
        ["zh-tw"] = "綠",
        ["zh-cn"] = "绿"
    },
    corruption_stimm_icon_colour_B = {
        en = "B",
        fr = "B",
        ru = "С",
        ["zh-tw"] = "藍",
        ["zh-cn"] = "蓝"
    },
    corruption_stimm_border_colour = {
        en = "Border Colour",
        fr = "Couleur de la bordure",
        ru = "Цвет границы",
        ["zh-tw"] = "邊框顏色",
        ["zh-cn"] = "边框颜色"
    },
    power_stimm_icon_colour = {
        en = "Power Stimm Icon Colour",
        fr = "Couleur de l'icône de puissance Stimm",
        ru = "Цвет значка стимулятора силы",
        ["zh-tw"] = "戰鬥興奮劑圖示顏色",
        ["zh-cn"] = "作战兴奋剂图标颜色"
    },
    power_stimm_icon_colour_R = {
        en = "R",
        fr = "R",
        ru = "К",
        ["zh-tw"] = "紅",
        ["zh-cn"] = "红"
    },
    power_stimm_icon_colour_G = {
        en = "G",
        fr = "V",
        ru = "З",
        ["zh-tw"] = "綠",
        ["zh-cn"] = "绿"
    },
    power_stimm_icon_colour_B = {
        en = "B",
        fr = "B",
        ru = "С",
        ["zh-tw"] = "藍",
        ["zh-cn"] = "蓝"
    },
    power_stimm_border_colour = {
        en = "Border Colour",
        fr = "Couleur de la bordure",
        ru = "Цвет границы",
        ["zh-tw"] = "邊框顏色",
        ["zh-cn"] = "边框颜色"
    },
    speed_stimm_icon_colour = {
        en = "Speed Stimm Icon Colour",
        fr = "Couleur de l'icône de vitesse Stimm",
        ru = "Цвет значка стимулятора скорости",
        ["zh-tw"] = "速度興奮劑圖示顏色",
        ["zh-cn"] = "敏捷兴奋剂图标颜色"
    },
    speed_stimm_icon_colour_R = {
        en = "R",
        fr = "R",
        ru = "К",
        ["zh-tw"] = "紅",
        ["zh-cn"] = "红"
    },
    speed_stimm_icon_colour_G = {
        en = "G",
        fr = "V",
        ru = "З",
        ["zh-tw"] = "綠",
        ["zh-cn"] = "绿"
    },
    speed_stimm_icon_colour_B = {
        en = "B",
        fr = "B",
        ru = "С",
        ["zh-tw"] = "藍",
        ["zh-cn"] = "蓝"
    },
    speed_stimm_border_colour = {
        en = "Border Colour",
        fr = "Couleur de la bordure",
        ru = "Цвет границы",
        ["zh-tw"] = "邊框顏色",
        ["zh-cn"] = "边框颜色"
    },

    -- TOME MARKERS
    tome_markers_settings = {
        en = "TOME MARKERS",
        fr = "MARQUEURS DE TOME",
        ru = "МЕТКИ КНИГ",
        ["zh-tw"] = "聖典標記",
        ["zh-cn"] = "经文图标"
    },
    tome_enable = {
        en = "Enable Markers",
        fr = "Activer les marqueurs",
        ru = "Включить метки",
        ["zh-tw"] = "啟用標記",
        ["zh-cn"] = "启用图标"
    },
    tome_general_settings = {
        en = "General Settings",
        fr = "Paramètres généraux",
        ru = "Общие настройки",
        ["zh-tw"] = "一般設定",
        ["zh-cn"] = "通用设定"
    },
    tome_keep_on_screen = {
        en = "Keep on screen",
        ru = "Держать на экране",
        fr = "Rester à l'écran",
        ["zh-tw"] = "保持顯示於螢幕",
        ["zh-cn"] = "在画面中持续显示"
    },
    tome_require_line_of_sight = {
        en = "Require line of sight",
        fr = "Nécessite une ligne de vue",
        ru = "Должно быть в зоне видимости",
        ["zh-tw"] = "需要視線範圍",
        ["zh-cn"] = "需要视野"
    },
    tome_max_distance = {
        en = "Max distance",
        fr = "Distance maximale",
        ru = "Максимальное расстояние",
        ["zh-tw"] = "最遠距離",
        ["zh-cn"] = "最大距离"
    },
    tome_max_size = {
        en = "Maximum size of marker",
        fr = "Taille maximale du marqueur",
        ru = "Максимальный размер метки",
        ["zh-tw"] = "圖標的最大尺寸",
        ["zh-cn"] = "图标最大尺寸"
    },
    tome_min_size = {
        en = "Minimum size of marker",
        fr = "Taille minimale du marqueur",
        ru = "Минимальный размер метки",
        ["zh-tw"] = "圖標的最小尺寸",
        ["zh-cn"] = "图标最小尺寸"
    },
    tome_scale = {
        en = "Scale",
        fr = "Scale",
        ru = "Scale",
        ["zh-tw"] = "圖標縮放大小",
        ["zh-cn"] = "图标缩放比例"
    },
    tome_alpha = {
        en = "Alpha Multiplier",
        fr = "Multiplicateur d'alpha",
        ru = "Прозрачность",
        ["zh-tw"] = "透明度倍增器",
        ["zh-cn"] = "透明度"
    },
    grim_colour = {
        en = "Grimoire Colour",
        fr = "Couleur du grimoire",
        ru = "Цвет гримуара",
        ["zh-tw"] = "魔術書顏色",
        ["zh-cn"] = "魔法书颜色"
    },
    grim_colour_R = {
        en = "R",
        fr = "R",
        ru = "К",
        ["zh-tw"] = "紅",
        ["zh-cn"] = "红"
    },
    grim_colour_G = {
        en = "G",
        fr = "V",
        ru = "З",
        ["zh-tw"] = "綠",
        ["zh-cn"] = "绿"
    },
    grim_colour_B = {
        en = "B",
        fr = "B",
        ru = "С",
        ["zh-tw"] = "藍",
        ["zh-cn"] = "蓝"
    },
    script_colour = {
        en = "Scripture Colour",
        fr = "Couleur des textes sacrés",
        ru = "Цвет писания",
        ["zh-tw"] = "經典顏色",
        ["zh-cn"] = "圣经颜色"
    },
    script_colour_R = {
        en = "R",
        fr = "R",
        ru = "К",
        ["zh-tw"] = "紅",
        ["zh-cn"] = "红"
    },
    script_colour_G = {
        en = "G",
        fr = "V",
        ru = "З",
        ["zh-tw"] = "綠",
        ["zh-cn"] = "绿"
    },
    script_colour_B = {
        en = "B",
        fr = "B",
        ru = "С",
        ["zh-tw"] = "藍",
        ["zh-cn"] = "蓝"
    },
    tome_border_colour = {
        en = "Border Colour",
        fr = "Couleur de la bordure",
        ru = "Цвет границы",
        ["zh-tw"] = "邊框顏色",
        ["zh-cn"] = "边框颜色"
    },

    -- Tainted Communication Device Markers
    tainted_markers_settings = {
        en = "TAINTED COMMUNICATION DEVICE MARKERS",
        ["zh-cn"] = "腐化通讯装置图标"
    },
    tainted_enable = {
        en = "Enable Markers",
        fr = "Activer les marqueurs",
        ru = "Включить метки",
        ["zh-tw"] = "啟用標記",
        ["zh-cn"] = "启用图标"
    },
    tainted_general_settings = {
        en = "General Settings",
        fr = "Paramètres généraux",
        ru = "Общие настройки",
        ["zh-tw"] = "一般設定",
        ["zh-cn"] = "通用设定"
    },
    tainted_keep_on_screen = {
        en = "Keep on screen",
        ru = "Держать на экране",
        fr = "Rester à l'écran",
        ["zh-tw"] = "保持顯示於螢幕",
        ["zh-cn"] = "在画面中持续显示"
    },
    tainted_require_line_of_sight = {
        en = "Require line of sight",
        fr = "Nécessite une ligne de vue",
        ru = "Должно быть в зоне видимости",
        ["zh-tw"] = "需要視線範圍",
        ["zh-cn"] = "需要视野"
    },
    tainted_max_distance = {
        en = "Max distance",
        fr = "Distance maximale",
        ru = "Максимальное расстояние",
        ["zh-tw"] = "最遠距離",
        ["zh-cn"] = "最大距离"
    },
    tainted_max_size = {
        en = "Maximum size of marker",
        fr = "Taille maximale du marqueur",
        ru = "Максимальный размер метки",
        ["zh-tw"] = "圖標的最大尺寸",
        ["zh-cn"] = "图标最大尺寸"
    },
    tainted_min_size = {
        en = "Minimum size of marker",
        fr = "Taille minimale du marqueur",
        ru = "Минимальный размер метки",
        ["zh-tw"] = "圖標的最小尺寸",
        ["zh-cn"] = "图标最小尺寸"
    },
    tainted_scale = {
        en = "Scale",
        fr = "Scale",
        ru = "Scale",
        ["zh-tw"] = "圖標縮放大小",
        ["zh-cn"] = "图标缩放比例"
    },
    tainted_alpha = {
        en = "Alpha Multiplier",
        fr = "Multiplicateur d'alpha",
        ru = "Прозрачность",
        ["zh-tw"] = "透明度倍增器",
        ["zh-cn"] = "透明度"
    },
    tainted_border_colour = {
        en = "Border Colour",
        fr = "Couleur de la bordure",
        ru = "Цвет границы",
        ["zh-tw"] = "邊框顏色",
        ["zh-cn"] = "边框颜色"
    },
    tainted_colour = {
        en = "Tainted Communications Device Colour",
        ["zh-cn"] = "腐化通讯装置"
    },
    tainted_colour_R = {
        en = "R",
        fr = "R",
        ru = "К",
        ["zh-tw"] = "紅",
        ["zh-cn"] = "红"
    },
    tainted_colour_G = {
        en = "G",
        fr = "V",
        ru = "З",
        ["zh-tw"] = "綠",
        ["zh-cn"] = "绿"
    },
    tainted_colour_B = {
        en = "B",
        fr = "B",
        ru = "С",
        ["zh-tw"] = "藍",
        ["zh-cn"] = "蓝"
    },

    -- Tainted Skull Markers
    tainted_skull_markers_settings = {
        en = "TAINTED SKULL MARKERS"
    },
    tainted_skull_enable = {
        en = "Enable Markers",
        fr = "Activer les marqueurs",
        ru = "Включить метки",
        ["zh-tw"] = "啟用標記",
        ["zh-cn"] = "启用图标"
    },
    tainted_skull_general_settings = {
        en = "General Settings",
        fr = "Paramètres généraux",
        ru = "Общие настройки",
        ["zh-tw"] = "一般設定",
        ["zh-cn"] = "通用设定"
    },
    tainted_skull_keep_on_screen = {
        en = "Keep on screen",
        ru = "Держать на экране",
        fr = "Rester à l'écran",
        ["zh-tw"] = "保持顯示於螢幕",
        ["zh-cn"] = "在画面中持续显示"
    },
    tainted_skull_require_line_of_sight = {
        en = "Require line of sight",
        fr = "Nécessite une ligne de vue",
        ru = "Должно быть в зоне видимости",
        ["zh-tw"] = "需要視線範圍",
        ["zh-cn"] = "需要视野"
    },
    tainted_skull_max_distance = {
        en = "Max distance",
        fr = "Distance maximale",
        ru = "Максимальное расстояние",
        ["zh-tw"] = "最遠距離",
        ["zh-cn"] = "最大距离"
    },
    tainted_skull_max_size = {
        en = "Maximum size of marker",
        fr = "Taille maximale du marqueur",
        ru = "Максимальный размер метки",
        ["zh-tw"] = "圖標的最大尺寸",
        ["zh-cn"] = "图标最大尺寸"
    },
    tainted_skull_min_size = {
        en = "Minimum size of marker",
        fr = "Taille minimale du marqueur",
        ru = "Минимальный размер метки",
        ["zh-tw"] = "圖標的最小尺寸",
        ["zh-cn"] = "图标最小尺寸"
    },
    tainted_skull_scale = {
        en = "Scale",
        fr = "Scale",
        ru = "Scale",
        ["zh-tw"] = "圖標縮放大小",
        ["zh-cn"] = "图标缩放比例"
    },
    tainted_skull_alpha = {
        en = "Alpha Multiplier",
        fr = "Multiplicateur d'alpha",
        ru = "Прозрачность",
        ["zh-tw"] = "透明度倍增器",
        ["zh-cn"] = "透明度"
    },
    tainted_skull_border_colour = {
        en = "Border Colour",
        fr = "Couleur de la bordure",
        ru = "Цвет границы",
        ["zh-tw"] = "邊框顏色",
        ["zh-cn"] = "边框颜色"
    },
    tainted_skull_colour = {
        en = "Tainted Skull Colour"
    },
    tainted_skull_colour_R = {
        en = "R",
        fr = "R",
        ru = "К",
        ["zh-tw"] = "紅",
        ["zh-cn"] = "红"
    },
    tainted_skull_colour_G = {
        en = "G",
        fr = "V",
        ru = "З",
        ["zh-tw"] = "綠",
        ["zh-cn"] = "绿"
    },
    tainted_skull_colour_B = {
        en = "B",
        fr = "B",
        ru = "С",
        ["zh-tw"] = "藍",
        ["zh-cn"] = "蓝"
    },

    -- luggable Markers
    luggable_markers_settings = {
        en = "LUGGABLE MARKERS"
    },
    luggable_enable = {
        en = "Enable Markers",
        fr = "Activer les marqueurs",
        ru = "Включить метки",
        ["zh-tw"] = "啟用標記",
        ["zh-cn"] = "启用图标"
    },
    luggable_general_settings = {
        en = "General Settings",
        fr = "Paramètres généraux",
        ru = "Общие настройки",
        ["zh-tw"] = "一般設定",
        ["zh-cn"] = "通用设定"
    },
    luggable_keep_on_screen = {
        en = "Keep on screen",
        ru = "Держать на экране",
        fr = "Rester à l'écran",
        ["zh-tw"] = "保持顯示於螢幕",
        ["zh-cn"] = "在画面中持续显示"
    },
    luggable_require_line_of_sight = {
        en = "Require line of sight",
        fr = "Nécessite une ligne de vue",
        ru = "Должно быть в зоне видимости",
        ["zh-tw"] = "需要視線範圍",
        ["zh-cn"] = "需要视野"
    },
    luggable_max_distance = {
        en = "Max distance",
        fr = "Distance maximale",
        ru = "Максимальное расстояние",
        ["zh-tw"] = "最遠距離",
        ["zh-cn"] = "最大距离"
    },
    luggable_scale = {
        en = "Scale",
        fr = "Scale",
        ru = "Scale",
        ["zh-tw"] = "圖標縮放大小",
        ["zh-cn"] = "图标缩放比例"
    },
    luggable_alpha = {
        en = "Alpha Multiplier",
        fr = "Multiplicateur d'alpha",
        ru = "Прозрачность",
        ["zh-tw"] = "透明度倍增器",
        ["zh-cn"] = "透明度"
    },
    luggable_border_colour = {
        en = "Border Colour",
        fr = "Couleur de la bordure",
        ru = "Цвет границы",
        ["zh-tw"] = "邊框顏色",
        ["zh-cn"] = "边框颜色"
    },
    luggable_colour = {
        en = "Luggable Colour"
    },
    luggable_colour_R = {
        en = "R",
        fr = "R",
        ru = "К",
        ["zh-tw"] = "紅",
        ["zh-cn"] = "红"
    },
    luggable_colour_G = {
        en = "G",
        fr = "V",
        ru = "З",
        ["zh-tw"] = "綠",
        ["zh-cn"] = "绿"
    },
    luggable_colour_B = {
        en = "B",
        fr = "B",
        ru = "С",
        ["zh-tw"] = "藍",
        ["zh-cn"] = "蓝"
    },
    luggable_icon = {
        en = "Use Alternative Icon",
        fr = "Utiliser une icône alternative",
        ru = "Включить альтернативный значок",
        ["zh-tw"] = "使用替代圖示",
        ["zh-cn"] = "使用替代图标"
    },

    -- Martyrs Skull Markers
    martyrs_skull_markers_settings = {
        en = "MARTYRS SKULL MARKERS"
    },
    martyrs_skull_enable = {
        en = "Enable Markers",
        fr = "Activer les marqueurs",
        ru = "Включить метки",
        ["zh-tw"] = "啟用標記",
        ["zh-cn"] = "启用图标"
    },
    martyrs_skull_guide_enable = {
        en = "Enable Skull Collection Guide?"
    },
    martyrs_skull_guide_disable_if_collected = {
        en = "Only show guide if not collected?"
    },
    martyrs_skull_general_settings = {
        en = "General Settings",
        fr = "Paramètres généraux",
        ru = "Общие настройки",
        ["zh-tw"] = "一般設定",
        ["zh-cn"] = "通用设定"
    },
    martyrs_skull_keep_on_screen = {
        en = "Keep on screen",
        ru = "Держать на экране",
        fr = "Rester à l'écran",
        ["zh-tw"] = "保持顯示於螢幕",
        ["zh-cn"] = "在画面中持续显示"
    },
    martyrs_skull_require_line_of_sight = {
        en = "Require line of sight",
        fr = "Nécessite une ligne de vue",
        ru = "Должно быть в зоне видимости",
        ["zh-tw"] = "需要視線範圍",
        ["zh-cn"] = "需要视野"
    },
    martyrs_skull_max_distance = {
        en = "Max distance",
        fr = "Distance maximale",
        ru = "Максимальное расстояние",
        ["zh-tw"] = "最遠距離",
        ["zh-cn"] = "最大距离"
    },
    martyrs_skull_scale = {
        en = "Scale",
        fr = "Scale",
        ru = "Scale",
        ["zh-tw"] = "圖標縮放大小",
        ["zh-cn"] = "图标缩放比例"
    },
    martyrs_skull_alpha = {
        en = "Alpha Multiplier",
        fr = "Multiplicateur d'alpha",
        ru = "Прозрачность",
        ["zh-tw"] = "透明度倍增器",
        ["zh-cn"] = "透明度"
    },
    martyrs_skull_border_colour = {
        en = "Border Colour",
        fr = "Couleur de la bordure",
        ru = "Цвет границы",
        ["zh-tw"] = "邊框顏色",
        ["zh-cn"] = "边框颜色"
    },
    martyrs_skull_colour = {
        en = "Martyrs Skull Colour"
    },
    martyrs_skull_colour_R = {
        en = "R",
        fr = "R",
        ru = "К",
        ["zh-tw"] = "紅",
        ["zh-cn"] = "红"
    },
    martyrs_skull_colour_G = {
        en = "G",
        fr = "V",
        ru = "З",
        ["zh-tw"] = "綠",
        ["zh-cn"] = "绿"
    },
    martyrs_skull_colour_B = {
        en = "B",
        fr = "B",
        ru = "С",
        ["zh-tw"] = "藍",
        ["zh-cn"] = "蓝"
    },

    Exclamation = {
        en = "Exclamation"
    },
    Hands = {
        en = "Hands"
    },
    Fist = {
        en = "Fist"
    },
    Gold = {
        en = "Gold",
        fr = "Or",
        ru = "Золото",
        ["zh-tw"] = "金",
        ["zh-cn"] = "金"
    },
    Silver = {
        en = "Silver",
        fr = "Argent",
        ru = "Серебро",
        ["zh-tw"] = "銀",
        ["zh-cn"] = "银"
    },
    Steel = {
        en = "Steel",
        fr = "Acier",
        ru = "Сталь",
        ["zh-tw"] = "鋼",
        ["zh-cn"] = "钢"
    },
    Black = {
        en = "Black"
    },
    Terminal = {
        en = "Terminal"
    },

    -- new toggle LOS settings
    martyrs_skull_toggle_los = {
        en = "Toggle 'Require Line of Sight'"
    },
    ammo_med_toggle_los = {
        en = "Toggle 'Require Line of Sight'"
    },
    chest_toggle_los = {
        en = "Toggle 'Require Line of Sight'"
    },
    heretical_idol_toggle_los = {
        en = "Toggle 'Require Line of Sight'"
    },
    material_toggle_los = {
        en = "Toggle 'Require Line of Sight'"
    },
    stimm_toggle_los = {
        en = "Toggle 'Require Line of Sight'"
    },
    tome_toggle_los = {
        en = "Toggle 'Require Line of Sight'"
    },
    tainted_toggle_los = {
        en = "Toggle 'Require Line of Sight'"
    },
    tainted_skull_toggle_los = {
        en = "Toggle 'Require Line of Sight'"
    },
    luggable_toggle_los = {
        en = "Toggle 'Require Line of Sight'"
    },

    -- MARTYRS SKULL GUIDE LOCALIZATIONS... THERE'S LOTS x) 
    martyrs_skull_objective_hm_cartel_1 = {
        en = "Follow number sequence"
    },
    martyrs_skull_objective_km_enforcer_A = {
        en = "First player, press button to start sequence"
    },
    martyrs_skull_objective_km_enforcer_B = {
        en = "Second player, head through this door"
    },
    martyrs_skull_objective_km_enforcer_A1 = {
        en = "Press once to open first door"
    },
    martyrs_skull_objective_km_enforcer_A2 = {
        en = "Press once to open second door"
    },
    martyrs_skull_objective_km_enforcer_A3 = {
        en = "Press once to open third door"
    },
    martyrs_skull_objective_km_enforcer_B1 = {
        en = "Press first button to light up corresponding button in control room for player one for the fourth door"
    },
    martyrs_skull_objective_km_enforcer_B2 = {
        en = "Press second button to light up corresponding button in control room for player one for the final door"
    },
    martyrs_skull_objective_km_enforcer_A4 = {
        en = "Press button that lights up when player two completes B1 or B2"
    },
    martyrs_skull_objective_km_enforcer_B3 = {
        en = "Open door for other players"
    },
    martyrs_skull_objective_dm_stockpile_A = {
        en = "Climb up"
    },
    martyrs_skull_objective_dm_stockpile_B = {
        en = "Head to the control panel and try move the platform along the rails infront of you. The default pattern in the following order: \nDOWN, RIGHT, RIGHT, DOWN, LEFT"
    },
    martyrs_skull_objective_fm_cargo_1 = {
        en = "Turn on all showers with the red inquisition symbol quickly."
    },
    martyrs_skull_objective_dm_forge_1 = {
        en = "Follow number sequence"
    },
    martyrs_skull_objective_dm_forge_9 = {
        en = "Destroy all nurgle growths holding the door shut."
    },
    martyrs_skull_objective_dm_forge_10 = {
        en = "Open door"
    },
    martyrs_skull_objective_lm_cooling_1 = {
        en = "Climb up boxes to reach the top"
    },
    martyrs_skull_objective_lm_cooling_2 = {
        en = "Pick up the key in the body's hand"
    },
    martyrs_skull_objective_lm_cooling_3 = {
        en = "Head back over the bridge and use the key on the locked locker."
    },
    martyrs_skull_objective_lm_scavenge_1 = {
        en = "Head into room across the bridge"
    },
    martyrs_skull_objective_lm_scavenge_B1 = {
        en = "Player one, climb into the right elevator"
    },
    martyrs_skull_objective_lm_scavenge_A1 = {
        en = "Player two, climb into the left elevator to send player one upwards"
    },
    martyrs_skull_objective_lm_scavenge_B2 = {
        en = "Player one, grab the battery cell on the crate, and bring it back down in the elevator"
    },
    martyrs_skull_objective_lm_scavenge_B3 = {
        en = "Place the battery cell into the socket on the wall"
    },
    martyrs_skull_objective_fm_armoury_1 = {
        en = "Enter the building"
    },
    martyrs_skull_objective_fm_armoury_2 = {
        en = "Turn the valve"
    },
    martyrs_skull_objective_fm_armoury_3 = {
        en = "Climb up to begin parkour, continue up the stairs"
    },
    martyrs_skull_objective_fm_armoury_5 = {
        en = "Grab the power cell"
    },
    martyrs_skull_objective_fm_armoury_6 = {
        en = "Place the power cell into the socket, and pull the lever"
    },
    martyrs_skull_objective_fm_armoury_7 = {
        en = "Head back inside and press the button to open the gate to the skull"
    },
    martyrs_skull_objective_cm_raid_1 = {
        en = "Head into alleyway"
    },
    martyrs_skull_objective_cm_raid_2 = {
        en = "Grab the key on the dead body"
    },
    martyrs_skull_objective_cm_raid_3 = {
        en = "Head into the bar, and use the key to open the locked gate"
    },
    martyrs_skull_objective_cm_raid_4 = {
        en = "Go up the stairs, climb over the boxes and plant the breaching charge"
    },
    martyrs_skull_objective_cm_raid_5 = {
        en = "Pickup the key, then head back out to the bar"
    },
    martyrs_skull_objective_cm_raid_6 = {
        en = "Use the key to open the gate behind the bar"
    },
    martyrs_skull_objective_km_heresy_1 = {
        en = "Follow number sequence"
    },
    martyrs_skull_objective_template_1 = {
        en = "Input code: 213\nPress middle button"
    },
    martyrs_skull_objective_dm_propaganda_1 = {
        en = "Interact with the dumpster and pick up the 'skull weight' from the ground"
    },
    martyrs_skull_objective_dm_propaganda_2 = {
        en = "Head to the Martyr's Skull door and place the skull weight on the chain"
    },
    martyrs_skull_objective_fm_resurgence_1 = {
        en = "Head to control panel, you need to line up the pipes on the wall opposite, using the valves infront of you.\nThe default number of times you will need to turn the valves from left to right are as follows:\nx3,x1,x2,x3"
    },
    martyrs_skull_objective_hm_complex_1 = {
        en = "Remember the two symbols in the bottom right corner on the back of the panel"
    },
    martyrs_skull_objective_hm_complex_2 = {
        en = "Head to the chaos rune circle, and light the candles around the edge that match the two symbols from step 1"
    },
    martyrs_skull_objective_cm_archives_1 = {
        en = "This puzzle involves player one pulling the levers on the ground, whilst player two completes a parkour puzzle."
    },
    martyrs_skull_objective_cm_archives_2 = {
        en = "Player one, begin by pulling this lever to bring the chandelier to the ground, player two jump on, and player one pull the lever again to raise player two back up, then follow the 'B' sequence of markers."
    },
    martyrs_skull_objective_cm_archives_A1 = {
        en = "Raise"
    },
    martyrs_skull_objective_cm_archives_A2 = {
        en = "Lower then raise"
    },
    martyrs_skull_objective_cm_archives_A3 = {
        en = "Lower then raise"
    },
    martyrs_skull_objective_cm_archives_A4 = {
        en = "Climb up boxes and jump over to chandelier to grab martyr's skull, once player two has completed the puzzle"
    },
    martyrs_skull_objective_collect_skull = {
        en = "Collect Martyr's Skull!"
    },
    martyrs_skull_guide_title = {
        en = "MARTYR'S SKULL GUIDE"
    },
    martyrs_skull_guide_players_required = {
        en = "Player 1 = A, Player 2 = B"
    },
    martyrs_skull_guide_players_required_solo = {
        en = "Solo"
    },
    martyrs_skull_guide_players_required_solo_parkour = {
        en = "Solo (Parkour)"
    },
    martyrs_skull_objective_cm_habs_A1 = {
        en = "Input code: 213\nPress middle button"
    },
    martyrs_skull_objective_cm_habs_A2 = {
        en = "Press left button"
    },
    martyrs_skull_objective_cm_habs_A3 = {
        en = "Press right button"
    },
    martyrs_skull_objective_cm_habs_A4 = {
        en = "Hold lever for second player to complete B1"
    },
    martyrs_skull_objective_cm_habs_B1 = {
        en = "Second player, press button whilst first player holds A4"
    },

    martyrs_skull_objective_km_station_1 = {
        en = "Turn first valve"
    },
    martyrs_skull_objective_km_station_2 = {
        en = "Turn second valve"
    },
    martyrs_skull_objective_km_station_3 = {
        en = "Turn third valve"
    },
    martyrs_skull_objective_km_station_4 = {
        en = "Turn fourth valve"
    },
    martyrs_skull_objective_km_station_5 = {
        en = "Turn final valve"
    },

    martyrs_skull_objective_lm_rails_1 = {
        en = "Follow number sequence"
    },

    martyrs_skull_objective_dm_rise_A1 = {
        en = "Grab the power cell"
    },
    martyrs_skull_objective_dm_rise_A2 = {
        en = "Insert the power cell"
    },
    martyrs_skull_objective_dm_rise_B1 = {
        en = "Player two, enter elevator"
    },
    martyrs_skull_objective_dm_rise_A3 = {
        en = "Player one, hold the power switch once player 2 is in the elevator"
    },
    martyrs_skull_objective_dm_rise_B2 = {
        en = "Grab the next power cell"
    },
    martyrs_skull_objective_dm_rise_B3 = {
        en = "Throw power cell down to player one"
    },
    martyrs_skull_objective_dm_rise_A4 = {
        en = "Player one, insert second power cell"
    },
    martyrs_skull_objective_dm_rise_A5 = {
        en = "Hold the next lever for player two"
    },
    martyrs_skull_objective_dm_rise_B4 = {
        en = "Player two, press the elevator button"
    },
    martyrs_skull_objective_hm_strain_1 = {
        en = "Head to control room, and open the door"
    },
    martyrs_skull_objective_hm_strain_2 = {
        en = "Look above the door for the symbols, remember these"
    },
    martyrs_skull_objective_hm_strain_3A = {
        en = "Press the button until you see the right hand symbol from step 2 on the door through the window"
    },
    martyrs_skull_objective_hm_strain_3B = {
        en = "Press the button until you see the left hand symbol from step 2 on the door through the window"
    },
    martyrs_skull_objective_hm_strain_4 = {
        en = "Once the symbols match, press the final button"
    },
}

local apply_color_to_text = function(text, r, g, b)
    return "{#color(" .. r .. "," .. g .. "," .. b .. ")}" .. text .. "{#reset()}"
end


local lookup_border_color = function(colour_string)
    local border_colours = {
        ["Gold"] = {
            255,
            232,
            188,
            109
        },
        ["Silver"] = {
            255,
            187,
            198,
            201
        },
        ["Steel"] = {
            255,
            161,
            166,
            169
        }
    }
    return border_colours[colour_string]
end


local apply_colours = function()
    -- e.g. key = "Steel", values = "en = 'steel', fr = 'acier' etc"     ->    language = "en", text="Steel"
    for key, values in pairs(loc) do

        -- GENERAL RGB VALUES
        -- check the key contains "colour" but isnt the R/G/B values themselves...
        if string.find(key, "colour") and not string.find(key, "colour_R") and not string.find(key, "colour_G") and not string.find(key, "colour_B") then
            local r = mod:get(key .. "_R")
            local g = mod:get(key .. "_G")
            local b = mod:get(key .. "_B")

            if r ~= nil and g ~= nil and b ~= nil then
                for language, text in pairs(values) do
                    text = apply_color_to_text(text, r, g, b)
                    loc[key][language] = text
                end
            end
        end

        -- BORDER COLOURS
        if key == "Gold" or key == "Silver" or key == "Steel" then
            for language, text in pairs(values) do

                local argb = lookup_border_color(key)

                if argb ~= nil then
                    local temp = apply_color_to_text(key, argb[2], argb[3], argb[4])

                    if loc[temp] == nil then
                        loc[temp] = {}
                        loc[temp][language] = temp
                    else
                        loc[temp][language] = temp
                    end
                end
            end
        end
    end

    return loc
end


apply_colours()

mod.apply_colours = function()
    loc = apply_colours()
    dbg_loc = loc
    return loc
end


mod.get_loc = function()
    return loc
end


dbg_loc = loc

return loc
