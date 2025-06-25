

-- locale definitions
local locale = Locale("Español", "es")
locale:authors("OTClient contributors")
locale:charset("cp1252")
locale:formatNumbers(true)
locale:decimalSeperator('.')
locale:thousandsSeperator(',')

---- translations ----

-- case convention: PascalCase
-- recommended naming order:
-- Module -> Element -> Child -> Action

-- example:
-- module: ItemSelector
-- element: Title
-- child: -
-- action: RemoveConfig
-- full string: ItemSelectorTitleRemoveConfig

-- example2:
-- module: Minimap
-- element: Window
-- child: Title
-- action: SetMark
-- full string: MinimapWindowTitleSetMark

-- inserting arguments into translation strings:
-- %0 does not do anything
-- %1-%9 - arguments provided with the localize function

-- language selection
locale:translate("LanguagePickerWindowMessage", "Seleciona tu idioma")

-- UI: common buttons
locale:translate("UIButtonOk", "OK")
locale:translate("UIButtonCancel", "Cancelar")
locale:translate("UIButtonYes", "Si")
locale:translate("UIButtonNo", "No")
locale:translate("UIButtonOn", "ON")
locale:translate("UIButtonOff", "OFF")
locale:translate("UIButtonClose", "Cerrar")
locale:translate("UIButtonHelp", "Ayuda")
locale:translate("UIButtonSettings", "Ajustes")
locale:translate("UIButtonEdit", "Editar")
locale:translate("UIButtonRemove", "Remover")
locale:translate("UIButtonClear", "Limpiar")
locale:translate("UIButtonReset", "Reset")
locale:translate("UIButtonPaginationPrev", "Siguiente Paguina")
locale:translate("UIButtonPaginationNext", "Siguiente Pagina")

-- UI: common form fields
locale:translate("FormFieldDescription", "Descripción")
locale:translate("FormFieldPosition", "Posición")
locale:translate("FormFieldCurrentPage", "Página")
locale:translate("FormFieldFind", "Buscar")

-- UI: common dialog options
locale:translate("ContextMenuCopyName", "Copiar Nombre")

-- UI: system messages
locale:translate("Warning", "Advertencia")
locale:translate("Error", "Error")

-- date / time
-- for future
--[[
locale:translate("ClockAM", "AM")
locale:translate("ClockPM", "PM")
]]

-- weekday
locale:translate("Sunday", "Domingo")
locale:translate("Monday", "Lunes")
locale:translate("Tuesday", "Martes")
locale:translate("Wednesday", "Miércoles")
locale:translate("Thursday", "Jueves")
locale:translate("Friday", "Viernes")
locale:translate("Saturday", "Sábado")

-- month
locale:translate("January", "Enero")
locale:translate("February", "Febrero")
locale:translate("March", "Marzo")
locale:translate("April", "Abril")
locale:translate("May", "Mayo")
locale:translate("June", "Junio")
locale:translate("July", "Julio")
locale:translate("August", "Agosto")
locale:translate("September", "Septiembre")
locale:translate("October", "Octubre")
locale:translate("November", "Noviembre")
locale:translate("December", "Diciembre")

--[[
-- for future
-- month alternative
-- (this is for grammatical purposes in other languages)
locale:translate("AltJanuary", "of January")
locale:translate("AltFebruary", "of February")
locale:translate("AltMarch", "of March")
locale:translate("AltApril", "of April")
locale:translate("AltMay", "of May")
locale:translate("AltJune", "of June")
locale:translate("AltJuly", "of July")
locale:translate("AltAugust", "of August")
locale:translate("AltSeptember", "of September")
locale:translate("AltOctober", "of October")
locale:translate("AltNovember", "of November")
locale:translate("AltDecember", "of December")

-- month name short
locale:translate("ShortJanuary", "Jan")
locale:translate("ShortFebruary", "Feb")
locale:translate("ShortMarch", "Mar")
locale:translate("ShortApril", "Apr")
locale:translate("ShortMay", "May")
locale:translate("ShortJune", "Jun")
locale:translate("ShortJuly", "Jul")
locale:translate("ShortAugust", "Aug")
locale:translate("ShortSeptember", "Sep")
locale:translate("ShortOctober", "Oct")
locale:translate("ShortNovember", "Nov")
locale:translate("ShortDecember", "Dec")

-- place suffixes (1st, 2nd, ..., nth)
-- (this is for grammatical purposes in other languages)
locale:translate("suffix_0", "th")
locale:translate("suffix_1", "st")
locale:translate("suffix_2", "nd")
locale:translate("suffix_3", "rd")
locale:translate("suffix_4", "th")
locale:translate("suffix_5", "th")
locale:translate("suffix_6", "th")
locale:translate("suffix_7", "th")
locale:translate("suffix_8", "th")
locale:translate("suffix_9", "th")
locale:translate("suffix_10", "th")
locale:translate("suffix_11", "th")
locale:translate("suffix_12", "th")
locale:translate("suffix_13", "th")
locale:translate("suffix_14", "th")
locale:translate("suffix_15", "th")
locale:translate("suffix_16", "th")
locale:translate("suffix_17", "th")
locale:translate("suffix_18", "th")
locale:translate("suffix_19", "th")
locale:translate("suffix_20", "th")
locale:translate("suffix_n1", "st")
locale:translate("suffix_n2", "nd")
locale:translate("suffix_n3", "rd")
locale:translate("suffix_n4", "th")
locale:translate("suffix_n5", "th")
locale:translate("suffix_n6", "th")
locale:translate("suffix_n7", "th")
locale:translate("suffix_n8", "th")
locale:translate("suffix_n9", "th")
locale:translate("suffix_n0", "th")
]]

-- UI: window titles misc
locale:translate("WindowTitleTextEdit", "Editar texto")
locale:translate("WindowTitleGraphicsError", "Controlador de tarjeta gráfica no detectado")
locale:translate("WindowMessageGraphicsError", "No se detectó ninguna tarjeta gráfica, todo se dibujará utilizando la CPU,\npor lo tanto, el rendimiento será realmente malo.\nPor favor, actualiza tu controlador gráfico para tener un mejor rendimiento.")

-- UI: posiblemente no utilizado
locale:translate("ButtonsWindowTitle", "Botones")

-- bottom panel (login screen)
locale:translate("BottomPanelTitleRandomHint", "Consejo Aleatorio")
locale:translate("BottomPanelTitleEventSchedule", "Horario de Eventos")
locale:translate("BottomPanelActiveEvents", "Activos")
locale:translate("BottomPanelUpcomingEvents", "Próximos")
locale:translate("BottomPanelTitleBoosted", "Aumentado")
locale:translate("BottomPanelLabelBoostedCreature", "Criatura")
locale:translate("BottomPanelLabelBoostedBoss", "Jefe")
locale:translate("BottomPanelWindowTitleEventSchedule", "Horario de Eventos")
locale:translate("BottomPanelWindowHintEventSchedule", "* l evento comienza/termina en la hora de guardado del servidor de este día.")

-- misc
locale:translate("ThereIsNoWay", "No hay forma.")
locale:translate("DebugInfoTitle", "Información de Depuración")
locale:translate("DebugInfoProxies", "Proxies")

-- blessings
locale:translate("BlessingsLongTextPlaceholder", "Este es un marcador de posición para un texto muy largo.")

-- chat
locale:translate("ChatChannelNameDefault", "Chat Local")
locale:translate("ChatChannelNameServerLog", "Registro del Servidor")
locale:translate("ChatChannelNameLoot", "Botín")

-- character list + entergame
locale:translate("CharacterListTitleConnecting", "Por favor espera")
locale:translate("CharacterListMessageConnecting", "Conectando al servidor de juego...")
locale:translate("CharacterListMessageReconnect", "Intentando reconectar en %1 segundos.")
locale:translate("CharacterListTitleLoginError", "Error de Inicio de Sesión")
locale:translate("CharacterListTitleConnectionError", "Error de Conexión")
locale:translate("CharacterListTitleUpdateRequired", "Actualización Necesaria")
locale:translate("CharacterListMessageUpdateRequired", "Ingresa con tu cuenta nuevamente para actualizar tu cliente.")
locale:translate("CharacterListMessageUpdateNeeded", "Tu cliente necesita ser actualizado, intenta volver a descargarlo.")
locale:translate("CharacterListAccountStatus", "Estado de la Cuenta")
locale:translate("CharacterListAccountFrozen", "Congelada")
locale:translate("CharacterListAccountBanned", "Suspendida")
locale:translate("CharacterListAccountFree", "Cuenta Gratuita")
locale:translate("CharacterListAccountPremiumGratis", "Cuenta Premium Gratis")
locale:translate("CharacterListAccountPremiumNormal", "Cuenta Premium (%1) días restantes")
locale:translate("CharacterListMessageNoCharacterSelected", "¡Debes seleccionar un personaje para iniciar sesión!")
locale:translate("CharacterListWindowTitle", "Lista de Personajes")
locale:translate("CharacterListColumnPlayer", "Personaje")
locale:translate("CharacterListColumnStatus", "Estado")
locale:translate("CharacterListColumnLevel", "Nivel")
locale:translate("CharacterListColumnVocation", "Vocación")
locale:translate("CharacterListColumnWorld", "Mundo")
locale:translate("CharacterListMotd", "Mensaje del día")

-- entergame
locale:translate("EnterGameTitleOld", "Enter Game")
locale:translate("EnterGameTitleNew", "Journey Onwards")
locale:translate("EnterGameEmail", "Email")
locale:translate("EnterGameAccName", "Acc Name")
locale:translate("EnterGamePassword", "Password")
locale:translate("EnterGameClientVersion", "Versión del Cliente")
locale:translate("EnterGameClientPort", "Puerto")
locale:translate("EnterGameRememberEmail", "Recordar correo electrónico")
locale:translate("EnterGameTooltipRememberEmail", "Ten en cuenta que tu dirección de correo electrónico se almacenará en tu archivo de configuración \"config.otml\" si activas esta opción.")
locale:translate("EnterGameRememberPassword", "Recordar contraseña")
locale:translate("EnterGameTooltipRememberPassword", "Recordar cuenta y contraseña cuando se inicie el cliente")
locale:translate("EnterGameButtonAccountLost", "Olvidé la contraseña y/o el correo electrónico")
locale:translate("EnterGameAuthenticatorToken", "Token de Autenticación")
locale:translate("EnterGameCheckboxKeepSession", "Mantener sesión durante la sesión")
locale:translate("EnterGameThingsErrorAssets", "Las cosas no están cargadas, por favor coloca los assets en things/%1/<assets>.")
locale:translate("EnterGameThingsErrorSprites", "Las cosas no están cargadas, por favor coloca spr y dat en things/%1/<here>.")
locale:translate("EnterGameHttpError", "ERROR , intenta agregar \n- ip/login.php \n- Habilitar inicio de sesión HTTP")
locale:translate("EnterGameMessageConnectingHttp", "Conectando al servidor de inicio de sesión...\nServidor: [%1]")
locale:translate("EnterGameMessageConnecting", "Conectando al servidor de inicio de sesión...")
locale:translate("EnterGameMessageAlreadyLogged", "No se puede iniciar sesión mientras ya estás en el juego.")
locale:translate("EnterGameTitleWaitList", "Lista de Espera")
locale:translate("EnterGameTitleServerList", "Lista de Servidores")
locale:translate("EnterGameLabelServerList", "Asegúrate de que tu cliente use\nla versión correcta del cliente del juego")
locale:translate("EnterGameCheckboxAutoLogin", "Inicio de sesión automático")
locale:translate("EnterGameTooltipAutoLogin", "Abrir la lista de personajes automáticamente al iniciar el cliente")
locale:translate("EnterGameCheckboxHttpLogin", "Habilitar inicio de sesión HTTP")
locale:translate("EnterGameTooltipHttpLogin", "Si el inicio de sesión falla usando HTTPS (encriptado), intenta con HTTP (no encriptado)")
locale:translate("EnterGameButtonLogin", "Iniciar Sesión")
locale:translate("EnterGameButtonCreateAccount", "Crear Nueva Cuenta")
locale:translate("EnterGameLabelServer", "Servidor")

-- death screen
locale:translate("DeathWindowTitle", "Estás muerto")
locale:translate("DeathMessageRegular", "¡Ay! Valiente aventurero, has encontrado un triste destino.\nPero no desesperes, pues los dioses te devolverán\na este mundo a cambio de un pequeño sacrificio\n\n¡Simplemente haz clic en Aceptar para reanudar tus viajes!")
locale:translate("DeathMessageUnfair", "¡Ay! Valiente aventurero, has encontrado un triste destino.\nPero no desesperes, pues los dioses te devolverán\na este mundo a cambio de un pequeño sacrificio\n\nEsta penalización por muerte se ha reducido en %1%%\nporque fue una pelea injusta.\n\n¡Simplemente haz clic en Aceptar para reanudar tus viajes!")
locale:translate("DeathMessageBlessed", "¡Ay! Valiente aventurero, has encontrado un triste destino.\nPero no desesperes, pues los dioses te devolverán a este mundo\n\nEsta penalización por muerte se ha reducido en 100%\nporque estás bendecido con la Bendición del Aventurero\n\n¡Simplemente haz clic en Aceptar para reanudar tus viajes!")

-- item selector
locale:translate("ItemSelectorCountSubtype", "Cantidad / SubTipo")
locale:translate("ItemSelectorItemID", "ID del Objeto")
locale:translate("ItemSelectorWindowTitle", "Seleccionar Objeto")

-- minimap
locale:translate("MinimapWindowTitleSetMark", "Crear Marcador en el Mapa")
locale:translate("MinimapButtonCenter", "Centrar")

-- rule violation
locale:translate("RuleViolationRule1a", "1a) Nombre Ofensivo")
locale:translate("RuleViolationRule1b", "1b) Formato de Nombre Inválido")
locale:translate("RuleViolationRule1c", "1c) Nombre Inadecuado")
locale:translate("RuleViolationRule1d", "1d) Nombre Incitante a Violación de Reglas")
locale:translate("RuleViolationRule2a", "2a) Declaración Ofensiva")
locale:translate("RuleViolationRule2b", "2b) Spam")
locale:translate("RuleViolationRule2c", "2c) Publicidad Ilegal")
locale:translate("RuleViolationRule2d", "2d) Declaración Pública Fuera de Tema")
locale:translate("RuleViolationRule2e", "2e) Declaración Pública en Idioma No Inglés")
locale:translate("RuleViolationRule2f", "2f) Incitación a Violación de Reglas")
locale:translate("RuleViolationRule3a", "3a) Abuso de Bugs")
locale:translate("RuleViolationRule3b", "3b) Abuso de Debilidades del Juego")
locale:translate("RuleViolationRule3c", "3c) Uso de Software No Oficial para Jugar")
locale:translate("RuleViolationRule3d", "3d) Hackeo")
locale:translate("RuleViolationRule3e", "3e) Multi-Cliente")
locale:translate("RuleViolationRule3f", "3f) Comercio o Compartición de Cuentas")
locale:translate("RuleViolationRule4a", "4a) Amenazar a un Gamemaster")
locale:translate("RuleViolationRule4b", "4b) Pretender Tener Influencia en la Aplicación de Reglas")
locale:translate("RuleViolationRule4c", "4c) Informe Falso a un Gamemaster")
locale:translate("RuleViolationDestructiveBehaviour", "Comportamiento Destructivo")
locale:translate("RuleViolationExcessivePK", "Asesinato de Jugadores Excesivo e Injustificado")
locale:translate("RuleViolationActionNote", "Notación")
locale:translate("RuleViolationActionNamelock", "Informe de Nombre")
locale:translate("RuleViolationActionBan", "Banishment")
locale:translate("RuleViolationActionBanPlusNamelock", "Informe de Nombre + Banishment")
locale:translate("RuleViolationActionBanPlusFinalWarning", "Banishment + Advertencia Final")
locale:translate("RuleViolationActionBanPlusFinalPlusNamelock", "Informe de Nombre + Banishment + Advertencia Final")
locale:translate("RuleViolationActionReport", "Informe de Declaración")
locale:translate("RuleViolationNeedAction", "Debes seleccionar una acción.")
locale:translate("RuleViolationNeedReason", "Debes seleccionar una razón.")
locale:translate("RuleViolationNeedStatement", "No se ha seleccionado ninguna declaración.")
locale:translate("RuleViolationNeedComment", "Debes ingresar un comentario.")
locale:translate("RuleViolationLabelPlayerName", "Nombre")
locale:translate("RuleViolationLabelPlayerMessage", "Declaración")
locale:translate("RuleViolationLabelPenaltyReason", "Razón")
locale:translate("RuleViolationLabelAction", "Acción")
locale:translate("RuleViolationCheckboxIpBan", "Banishment de Dirección IP")
locale:translate("RuleViolationLabelComment", "Comentario")

-- screenshot
locale:translate("ScreenshotCheckboxGameWindow", "Only Capture Game Window")
locale:translate("ScreenshotTooltipGameWindow", "Si marcas esta opción, las capturas de pantalla solo se tomarán de la ventana del juego en lugar de la interfaz completa del cliente. Esto podría mejorar el rendimiento de tu juego, especialmente si has marcado la opción de Respaldo de Capturas de Pantalla.")
locale:translate("ScreenshotCheckboxBacklog", "Mantener Respaldo de las Capturas de Pantalla de los Últimos 5 Segundos")
locale:translate("ScreenshotTooltipBacklog", "Si marcas esta opción, el cliente tomará una captura de pantalla cada segundo y almacenará las últimas 5 de ellas. Siempre que se tome una captura de pantalla, ya sea automáticamente para un evento seleccionado o manualmente usando una tecla de acceso rápido, también se guardarán las capturas de pantalla de los 5 segundos anteriores. Si experimentas tartamudeos en el marco, deberías considerar desactivar esta opción.")
locale:translate("ScreenshotCheckboxAutoCapture", "Habilitar Capturas de Pantalla Automáticas")
locale:translate("ScreenshotTooltipAutoCapture", "Habilita esta opción para guardar capturas de pantalla de los momentos más importantes de tu carrera. Siempre que ocurra uno de los eventos que has seleccionado, se tomará una captura de pantalla automáticamente.\n\nLos siguientes eventos se pueden seleccionar para activar una captura de pantalla automática:\n\n- Nivel Arriba: Tu personaje ha alcanzado el siguiente nivel\n- Habilidad Arriba: Has avanzado en una de tus habilidades (por ejemplo, Nivel de Magia o Combate con Espadas)\n- Logro: Has ganado un logro, ya sea mientras juegas o al iniciar sesión\n- Entrada de Bestiario Desbloqueada: Has desbloqueado nueva información sobre una criatura en el Bestiario\n- Entrada de Bestiario Completada: Has desbloqueado toda la información sobre una criatura en el Bestiario\n- Tesoro Encontrado: Has recibido alguna recompensa de un contenedor por resolver una misión o un acertijo\n- Botín Valioso: Acabas de encontrar un botín que has marcado en el Rastreador de Caídas\n- Jefe Derrotado: Has derrotado a un monstruo jefe, ya sea solo o junto con otros jugadores, y tienes derecho a saquearlo\n- Muerte PvE: Acabas de ser asesinado por alguna criatura (PvE)\n- Muerte PvP: Acabas de ser asesinado por otro jugador (PvP)\n- Asesinato de Jugador: Has derrotado a otro jugador\n- Asistencia a Asesinato de Jugador: Has asistido en la muerte de otro jugador\n- Jugador Atacando: Otro jugador acaba de comenzar a atacarte\n- Mayor Daño Infligido: Has infligido un nuevo daño máximo histórico a un enemigo. Para ver o restablecer tu máximo histórico actual, consulta el Analizador de Impacto\n- Mayor Curación Realizada: Has curado a alguien con un nuevo valor de curación máximo histórico. Para ver o restablecer tu máximo histórico actual, consulta el Analizador de Impacto\n- Salud Baja: Has alcanzado un umbral de salud de color rojo intenso.")
locale:translate("ScreenshotLabelAutoCapture", "Selecciona todos los eventos que deberían activar capturas de pantalla automáticas")
locale:translate("ScreenshotButtonOpenFolder", "Abrir Carpeta de Capturas de Pantalla")

-- skills
locale:translate("SkillsWindowTitle", "Skills")
locale:translate("SkillsWindowTooltipPercentNeeded", "You have %1 percent to go")
locale:translate("SkillsWindowTooltipExperienceNeeded", "%1 of experience left")
locale:translate("SkillsWindowTooltipExperiencePerHour", "%1 of experience per hour")
locale:translate("SkillsWindowTooltipTimeToLevelUp", "Next level in %1 hours and %2 minutes")
locale:translate("SkillsWindowTooltipStaminaTimeLeft", "You have %1 hours and %2 minutes left")
locale:translate("SkillsWindowTooltipXPBoostTimeLeft", "You have %1 hours and %2 minutes left")
locale:translate("SkillsWindowTooltipXPBoostBonus", "Now you will gain 50%% more experience")
locale:translate("SkillsWindowTooltipStaminaPremiumOnly", "You will not gain 50%% more experience because you aren't premium player, now you receive only 1x experience points")
locale:translate("SkillsWindowTooltipStaminaPremiumActive", "If you are premium player, you will gain 50%% more experience")
locale:translate("SkillsWindowTooltipStaminaLow", "You gain only 50%% experience and you don't may gain loot from monsters")
locale:translate("SkillsWindowTooltipStaminaZero", "You don't may receive experience and loot from monsters")
locale:translate("SkillsWindowOfflineTimePercentLeft", "You have %1 percent")

-- these are translations for general stats that might be reused
locale:translate("StatExperience", "Experiencia")
locale:translate("StatLevel", "Nivel")
locale:translate("StatHealth", "Puntos de Vida")
locale:translate("StatMana", "Mana")
locale:translate("StatSoul", "Puntos de Alma")
locale:translate("StatCapacity", "Capacidad")
locale:translate("StatSpeed", "Velocidad")
locale:translate("StatRegeneration", "Tiempo de Regeneración")
locale:translate("StatStamina", "Resistencia")
locale:translate("StatOfflineTraining", "Entrenamiento Offline")
locale:translate("StatMitigation", "Mitigación")
locale:translate("SkillMagicLevel", "Nivel de Magia")
locale:translate("SkillFist", "Combate Cuerpo a Cuerpo")
locale:translate("SkillClub", "Combate con Garrote")
locale:translate("SkillSword", "Combate con Espada")
locale:translate("SkillAxe", "Combate con Hacha")
locale:translate("SkillDistance", "Combate a Distancia")
locale:translate("SkillShielding", "Escudo")
locale:translate("SkillFishing", "Pesca")
locale:translate("SkillCriticalHitChance", "Probabilidad de Golpe Crítico")
locale:translate("SkillCriticalHitDamage", "Daño de Golpe Crítico")
locale:translate("SkillLifeLeechChance", "Probabilidad de Robo de Vida")
locale:translate("SkillLifeLeechPercent", "Cantidad de Robo de Vida")
locale:translate("SkillManaLeechChance", "Probabilidad de Robo de Mana")
locale:translate("SkillManaLeechPercent", "Cantidad de Robo de Mana")
locale:translate("SkillOnslaught", "Asalto")
locale:translate("SkillRuse", "Estratagema")
locale:translate("SkillMomentum", "Momentum")
locale:translate("SkillTranscendence", "Trascendencia")

-- spell list
locale:translate("SpellListWindowTitle", "Lista de Hechizos")
locale:translate("SpellListLabelName", "Nombre")
locale:translate("SpellListLabelFilters", "Filtros")
locale:translate("SpellListLabelLevel", "Nivel")
locale:translate("SpellListLabelVocation", "Vocación")
locale:translate("SpellListLabelFormula", "órmula")
locale:translate("SpellListLabelGroup", "Grupo")
locale:translate("SpellListLabelType", "Tipo")
locale:translate("SpellListLabelCooldown", "Tiempo de Recarga")
locale:translate("SpellListLabelMana", "Mana")
locale:translate("SpellListLabelSoul", "Puntos de Alma")
locale:translate("SpellListLabelPremium", "Premium")
locale:translate("SpellListLabelDescription", "Description")
locale:translate("SpellListLabelVocationAny", "Any")
locale:translate("SpellListLabelVocationSorcerer", "Sorcerer")
locale:translate("SpellListLabelVocationDruid", "Druid")
locale:translate("SpellListLabelVocationPaladin", "Paladín")
locale:translate("SpellListLabelVocationKnight", "Caballero")
locale:translate("SpellListLabelTypeAny", "Cualquiera")
locale:translate("SpellListLabelTypeAttack", "Ataque")
locale:translate("SpellListLabelTypeHealing", "Curación")
locale:translate("SpellListLabelTypeSupport", "Soporte")
locale:translate("SpellListLabelTypeFreeOrPremium", "Cualquiera")
locale:translate("SpellListTooltipLevel", "Ocultar hechizos para niveles de experiencia más altos")
locale:translate("SpellListTooltipVocation", "Ocultar hechizos para otras vocaciones")

-- stash
locale:translate("StashWindowTitle", "Alijo de Suministros")
locale:translate("StashWindowWithdraw", "Retirar del Alijo")

-- store
locale:translate("StoreButtonBuyItem", "Comprar")
locale:translate("StoreButtonGiftTc", "Regalar")
locale:translate("StoreButtonGetCoins", "Obtener")
locale:translate("StoreButtonGetCoinsTooltip", "Obtener Tibia Coins")
locale:translate("StoreButtonTransactionHistory", "Historial")
locale:translate("StoreButtonTransferCoins", "Transferir Coins")
locale:translate("StoreButtonSellCharacter", "Configurar una subasta para vender tus personajes actuales.")
locale:translate("StoreWindowTitleGiftTc", "Regalar Tibia Coins")
locale:translate("StoreWindowLabelGiftAmount", "Amount to gift")
locale:translate("StoreItemStats", "General Stats")
locale:translate("StoreTransferableTc", "Transferable Tibia Coins")
locale:translate("StoreTcToTransfer", "Amount to transfer")
locale:translate("StoreTcRecipient", "Destinatario")
locale:translate("StoreMessageTcTransfer", "Please select the amount of Tibia\nCoins you like to gift and enter the\nname of the character that should\nreceive the Tibia Coins.")
locale:translate("StoreGiftTcButton", "Please select the amount of Tibia\nCoins you like to gift and enter the\nname of the character that should\nreceive the Tibia Coins.")
locale:translate("StoreWindowTitleRenameChar", "Enter New Character Name")
locale:translate("StoreWindowMessageRenameChar", "Please enter the new name for your character")
locale:translate("StoreWindowTitleMain", "Store")
locale:translate("StoreWindowTitleConfirmBuy", "Confirmation of Purchase")
locale:translate("StoreWindow", "Confirmation of Purchase")
locale:translate("StoreLabelPrice", "Price")
locale:translate("StoreMessageConfirmBuy", "Do you want to buy the product \"%1\" for %2 %3?")
locale:translate("StoreMessageNotEnoughCoins", "You don't have enough coins")
locale:translate("StoreCurrencyTcRegular", "regular coins")
locale:translate("StoreCurrencyTcTransferable", "transferable coins")
locale:translate("StoreTitleBuyItem", "Buying from shop")
locale:translate("StoreMessageBuyItem", "Do you want to buy %1 for %2 premium points?")
locale:translate("StoreCoinBalanceLabel", "Points")
locale:translate("StoreButton", "Tienda")
locale:translate("StoreWindowTitle", "Tienda")
locale:translate("StoreButtonBuyPoints", "Comprar puntos")

-- tasks
locale:translate("TaskSystemWindowTitle", "Tareas")
locale:translate("TaskSystemAlertTitle", "Tareas")
locale:translate("TaskSystemAbortMessage", "¿Realmente quieres abortar esta tarea?")

-- text window (books and house list)
locale:translate("TextWindowDescriptionWriter", "You read the following, written by \n%1\n")
locale:translate("TextWindowDescriptionTime", "You read the following, written on \n%1.\n")
locale:translate("TextWindowWrittenAt", "on %1.\n")
locale:translate("TextWindowEmpty", "It is empty.")
locale:translate("TextWindowWriteable", "You can enter new text.")
locale:translate("TextWindowShowText", "Mostrar Texto")
locale:translate("TextWindowEditText", "Edit Text")
locale:translate("TextWindowOneNamePerLine", "Enter one name per line.")
locale:translate("TextWindowDescriptionHouseList", "Edit List")

-- things
locale:translate("ThingsAssetLoadingFailed", "Couldn't load assets")
locale:translate("ThingsStaticDataLoadingFailed", "Couldn't load staticdata")
locale:translate("ThingsProtocolSpritesWarning", "Loading sprites instead of protobuf is unstable, use it at your own risk!")
locale:translate("ThingsDatLoadingFailed", "Unable to load dat file, please place a valid dat in '%1.dat'")
locale:translate("ThingsSprLoadingFailed", "Unable to load spr file, please place a valid spr in '%1.spr'")

-- unjustified kills panel
locale:translate("UnjustifiedPanelTitle", "Unjustified Points")
locale:translate("UnjustifiedPanelOpenPvP", "Open PvP")
locale:translate("UnjustifiedPanelOpenPvPSituations", "Open PvP Situations")
locale:translate("UnjustifiedPanelSkullTime", "Skull Time")

-- updater
locale:translate("UpdaterTitle", "Updater")
locale:translate("UpdaterChangeURL", "Change updater URL")
locale:translate("UpdaterCheckInProgress", "Checking for updates")
locale:translate("UpdaterMessageFileDownload", "Downloading:\n%1")
locale:translate("UpdaterMessageFileDownloadRetry", "Downloading (%1 retry):\n%2")
locale:translate("UpdaterError", "Updater Error")
locale:translate("UpdaterTimeout", "Timeout")
locale:translate("UpdaterMessagePending", "Updating client (may take few seconds)")
locale:translate("UpdaterMessageUpdatingFiles", "Updating %1 files")

-- viplist
locale:translate("VipListNoGroup", "No Group")
locale:translate("VipListPanelTitle", "VIP List")
locale:translate("VipListDialogVipAdd", "Add new VIP")
locale:translate("VipListDialogVipEdit", "Edit VIP")
locale:translate("VipListDialogVipEditDescription", "Description")
locale:translate("VipListDialogShowOffline", "Show Offline")
locale:translate("VipListDialogHideOffline", "Hide Offline")
locale:translate("VipListDialogShowGroups", "Show Groups")
locale:translate("VipListDialogHideGroups", "Hide Groups")
locale:translate("VipListDialogPlayerEdit", "Edit %1")
locale:translate("VipListDialogPlayerRemove", "Remove %1")
locale:translate("VipListDialogPlayerOpenChat", "Message to %1")
locale:translate("VipListDialogGroupAdd", "Add new group")
locale:translate("VipListDialogGroupEdit", "Edit group %1")
locale:translate("VipListDialogGroupRemove", "Remove group %1")
locale:translate("VipListPrivateChatInvite", "Invite to private chat")
locale:translate("VipListPrivateChatExclude", "Exclude from private chat")
locale:translate("VipListMessagePlayerLoggedIn", "%1 has logged in.")
locale:translate("VipListMessagePlayerLoggedOut", "%1 has logged out.")
locale:translate("VipListSortName", "Sort by name")
locale:translate("VipListSortType", "Sort by type")
locale:translate("VipListSortStatus", "Sort by status")
locale:translate("VipListGroupLimitTitle", "Maximum of User-Created Groups Reached")
locale:translate("VipListGroupLimitMessage", "You have already reached the maximum of groups you can create yourself.")
locale:translate("VipListWindowTitleGroupEdit", "Edit VIP group")
locale:translate("VipListWindowFormGroupName", "Please enter a group name")
locale:translate("VipListWindowTitleVipAdd", "Add to VIP list")
locale:translate("VipListLabelMemberOfGroups", "Member of the following groups")
locale:translate("VipListLabelNotifyOnLogin", "Notify-Login")
locale:translate("VipListCheckboxNotifyOnLogin", "Notify on login")
locale:translate("VipListCheckboxEmpty", "Empty")
locale:translate("VipListLabelCharacterName", "Please enter a character name")
locale:translate("VipListLabelGroupName", "Please enter a group name")

-- bot: main window
locale:translate("BotMainWindowTitle", "Config editor & manager")
locale:translate(
    "BotMainWindowText",
    "Config Manager\nYou can use config manager to share configs between different machines, especially smartphones. After you configure your config, you can upload it, then you'll get unique hash code which you can use on diffent machinge (for eg. mobile phone) to download it."
)
locale:translate("BotMainWindowConfigUploadLabel", "Upload config")
locale:translate("BotMainWindowConfigUploadButton", "Upload config")
locale:translate("BotMainWindowConfigUploadSelector", "Select config to upload")
locale:translate("BotMainWindowConfigDownloadLabel", "Download config")
locale:translate("BotMainWindowConfigDownloadButton", "Download config")
locale:translate("BotMainWindowConfigDownloadHashField", "Enter config hash code")
locale:translate("BotMainWindowInfoConfig", "Bot configs are stored in")
locale:translate("BotMainWindowOpenBotFolder", "Click here to open bot directory")
locale:translate(
    "BotMainWindowInfoDirectory",
    "Every directory in bot directory is treated as different config.\nTo create new config just create new directory."
)
locale:translate(
    "BotMainWindowInfoLoadingOrder",
    "Inside config directory put .lua and .otui files.\nEvery file will be loaded and executed in alphabetical order, .otui first and then .lua."
)
locale:translate(
    "BotMainWindowInfoReload",
    "To reload configs just press On and Off in bot window.\nTo learn more about bot click Tutorials button."
)
locale:translate("BotMainWindowDocumentation", "Documentation")
locale:translate("BotMainWindowTutorials", "Tutorials")
locale:translate("BotMainWindowScripts", "Scripts")
locale:translate("BotMainWindowForum", "Forum")
locale:translate("BotMainWindowDiscord", "Discord")

-- bot: config
locale:translate("BotConfigUploadPendingTitle", "Uploading config")
locale:translate("BotConfigUploadPendingText", "Uploading config %1. Please wait.")
locale:translate("BotConfigUploadFailTitle", "Config upload failed")
locale:translate("BotConfigUploadFailText", "Error while upload config %1:\n%2")
locale:translate("BotConfigUploadFailSize", "Config %1 is too big, maximum size is 1024KB. Now it has %2 KB.")
locale:translate("BotConfigUploadFailCompression", "Config %1 is invalid (can't be compressed)")
locale:translate("BotConfigUploadSuccessTitle", "Succesful config upload")
locale:translate("BotConfigUploadSuccessText", "Config %1 has been uploaded.\n%2")
locale:translate("BotConfigDownloadTitle", "Download Config")
locale:translate("BotConfigDownloadText", "Downloading config with hash %1. Please wait.")
locale:translate("BotConfigDownloadErrorTitle", "Config download error")
locale:translate("BotConfigDownloadErrorHash", "Enter correct config hash")
locale:translate("BotConfigDownloadErrorFailed", "Config with hash %1 cannot be downloaded")

-- bot: common strings
locale:translate("BotUnnamedConfig", "Unnamed Config")
locale:translate("BotRemoveConfig", "Remove Config")

-- bot: waypoints editor
locale:translate("WaypointsEditorTitle", "Waypoints editor")
locale:translate(
    "WaypointsEditorMessageRemoveConfig",
    "Do you want to remove current waypoints config?"
)
locale:translate("WaypointsEditorTitleAddFunction", "Add function")
locale:translate("WaypointsEditorErrorInvalidGoto", "Waypoints: invalid use of goto function")
locale:translate("WaypointsEditorErrorInvalidUse", "Waypoints: invalid use of use function")
locale:translate("WaypointsEditorErrorInvalidUseWith", "Waypoints: invalid use of usewith function")
locale:translate("WaypointsEditorErrorExecution", "Waypoints function execution error")

-- bot: looting
locale:translate("BotLootingBlacklist", "Loot every item, except these")
locale:translate("BotLootingAddItem", "Drag item or click on any of empty slot")
locale:translate("BotLootingConfigLootAll", "Loot every item")
locale:translate("BotLootingEditorTitle", "Looting editor")
locale:translate(
    "BotLootingEditorMessageRemoveConfig",
    "Do you want to remove current looting config?"
)

-- bot: attacking
locale:translate("BotAttackingButton", "AttackBot")
locale:translate("BotAttackingTitleEditMonster", "Edit monster")
locale:translate(
    "BotAttackingMessageRemoveConfig",
    "Do you want to remove current attacking config?"
)

-- bot: equipper
locale:translate("BotEquipperBossList", "Boss list")
locale:translate("BotEquipperMethodOrder", "More important methods come first.")
locale:translate("BotEquipperEQManager", "EQ Manager")

-- bot: botserver
locale:translate("BotServerWindowTitle", "BotServer")
locale:translate("BotServerWindowLabelData", "BotServer Data")
locale:translate("BotServerButton", "BotServer")

-- bot: cavebot
locale:translate("BotCavePing", "Server ping")
locale:translate("BotCaveWalkDelay", "Walk delay")
locale:translate("BotCaveMapClick", "Use map click")
locale:translate("BotCaveMapClickDelay", "Map click delay")
locale:translate("BotCaveIgnoreFields", "Ignore fields")
locale:translate("BotCaveSkipBlocked", "Skip blocked path")
locale:translate("BotCaveUseDelay", "Delay after use")

-- bot: other
locale:translate("BotSupplies", "Supplies")
locale:translate("BotHealerOptions", "Healer Options")
locale:translate("BotTitleHealBot", "HealBot")
locale:translate("BotFriendHealer", "Friend Healer")
locale:translate("BotSelfHealer", "Self Healer")
locale:translate("BotPushMaxSettings", "Pushmax Settings")
locale:translate("BotPushMaxButton", "PUSHMAX")
locale:translate("BotPlayerList", "Player List")
locale:translate("BotInfoMethodOrder", "More important methods come first (Example: Exura gran above Exura)")
locale:translate("BotButtonMinimiseAll", "Minimise All")
locale:translate("BotButtonReopenAll", "Reopen All")
locale:translate("BotButtonOpenMinimised", "Open Minimised")
locale:translate("BotButtonConditions", "Conditions")
locale:translate("BotButtonComboBot", "ComboBot")
locale:translate("BotWindowTitleExtras", "Extras")
locale:translate("BotWindowTitleDropper", "Dropper")
locale:translate("BotWindowTitleDepositer", "Depositer Panel")
locale:translate("BotWindowTitleContainerNames", "Container Names")
locale:translate("BotWindowTitleConditionManager", "Condition Manager")
locale:translate("BotWindowTitleComboOptions", "Combo Options")
locale:translate("BotAlarms", "Alarms")
locale:translate("BotHelpTutorials", "Help & Tutorials")
locale:translate("BotCreatureEditorHint_1", "You can use * (any characters) and ? (any character) in target name")
locale:translate("BotCreatureEditorHint_2", "You can also enter multiple targets, separate them by ,")
locale:translate("BotMinimapOptionCreateMark", "Create mark")
locale:translate("BotMinimapOptionAddGoTo", "Add CaveBot GoTo")
locale:translate("BotStatusWaiting", "Status: waiting")
locale:translate("BotMiniWindowTitle", "Bot")
locale:translate("BotMainPanelToggleButton", "Bot")

-- register
locale:register()
