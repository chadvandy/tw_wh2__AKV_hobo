--# assume global class LICHE_MANAGER
--# assume global class LICHE_LOG

--# assume global class LICHE_REGIMENT
--# assume global class LICHE_LORD

--# assume LICHE_MANAGER._ruins: map<string, {turn: number, isLocked: boolean}>
--# assume LICHE_MANAGER._faction_key: string
--# assume LICHE_MANAGER._regiments: map<string, LICHE_REGIMENT>
--# assume LICHE_MANAGER._can_recruit_lord: map<string, bool>
--# assume LICHE_MANAGER._characterSelected: CA_CQI
--# assume LICHE_MANAGER._currentPower: number
--# assume LICHE_MANAGER.set_regiment_unlocked: method(key: string)
--# assume LICHE_MANAGER.get_unlocked_regiments: method() --> vector<LICHE_REGIMENT>
--# assume LICHE_MANAGER.get_locked_regiments: method() --> vector<LICHE_REGIMENT>
--# assume LICHE_MANAGER.get_recruited_regiments: method() --> vector<LICHE_REGIMENT>
--# assume LICHE_MANAGER.get_necropower: method() --> number

--# assume LICHE_MANAGER._is_draesca_unlocked: boolean
--# assume LICHE_MANAGER._is_nameless_unlocked: boolean
--# assume LICHE_MANAGER._is_priestess_unlocked: boolean

--# assume LICHE_LOG.lines: {}
--# assume LICHE_LOG.filePath: string
--# assume LICHE_LOG.write_log: boolean
--# assume LICHE_LOG.errorPath: string
--# assume LICHE_LOG.errorLines: {}

--# assume LICHE_REGIMENT._key: string