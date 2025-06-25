-- class Locale
local Locale = setmetatable({ }, {
	-- constructor redirection
	-- Locale(...)
	-- example: Locale("English", "en")
	__call = function(locale, ...)
		return locale.new(...)
	end
})

-- allow lookup of static variables
Locale.__index = Locale

-- constructor
-- Locale.new(languageName, languageCode)
function Locale.new(languageName, languageCode)
	-- create the object
	local self = setmetatable({}, Locale)

	-- set object properties
	self._languageName = languageName
	self._languageCode = languageCode
	self._translations = {}

	-- push the newly created object
	return self
end

local fields = {
        'languageName',
        'languageCode',
        -- compatibility aliases
        'name',
        'charset',
        'formatNumbers',
        'decimalSeperator',
        'thousandsSeperator',
        'translations',
        -- alias used by old locale tables
        'translation',
        'authors'
}

-- create fields
-- get: locale:field()
-- set: locale:field(value)
-- example get: locale:charset()
-- example set: locale:charset("cp1252")
for _, key in ipairs(fields) do
        local innerKey = string.format("_%s", key)
        Locale[key] = function(self, value)
                if value == nil then
                        return self[innerKey]
                end
                self[innerKey] = value
        end
end

-- compatibility aliases
function Locale:name(value)
        return Locale.languageCode(self, value)
end

function Locale:translation(value)
        return Locale.translations(self, value)
end
-- get/set localized string
-- get: locale:translate(key)
-- set: locale:translate(key, value)
-- example get: locale:translate("UIButtonOk")
-- example set: locale:translate("UIButtonOk", "OK")
function Locale:translate(key, value)
	-- get
	if not value then
		-- translation was found -> return translation
		-- translation was not found -> return key
		return self._translations[key] or key
	end

	-- set
	self._translations[key] = value
end

-- remove localized string
-- locale:removeTranslation(key)
-- example: locale:removeTranslation("UIButtonOk")
function Locale:removeTranslation(key)
	-- remove if key was found
	if key then
		self._translations[key] = nil
		return true
	end

	-- key was not found, push false
	return false
end
function Locale:normalize()
    if not self._translations then
        self._translations = self.translation or {}
    end
    self.translation = self._translations
end

-- register locale
-- locale:register()
function Locale:register()
        -- fetch the language code
        local langCode = self:languageCode()

	-- if "allowedLocales" table is defined,
	-- the locales that are not present in it won't be created
	if _G.allowedLocales and not _G.allowedLocales[langCode] then
		return false
	end

	-- check if the locale was already installed
    installedLocales = installedLocales or {}
    self:normalize()
    local installedLocale = installedLocales[langCode]

    -- first load scenario
    if not installedLocale then
        installedLocales[langCode] = self
        return true
    end

    -- ensure target locale has translations table
    if installedLocale.normalize then
        installedLocale:normalize()
    else
        if not installedLocale._translations then
            installedLocale._translations = installedLocale.translation or {}
        end
        installedLocale.translation = installedLocale._translations
    end

    -- reload scenario
    for word, translation in pairs(self._translations) do
        installedLocale._translations[word] = translation
    end

	-- push the function result
	return true
end

-- push Locale class to the global namespace
_G.Locale = Locale