SMODS.current_mod.optional_features = { retrigger_joker = true }

SMODS.Atlas {
    key = "YACBM",
    path = "YACBM.png",
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'antenna',
    loc_txt = {
        name = 'Antenna Tower',
        text = {
            "Earn {C:money}$#1#{} at end of round",
            "Amount increases by {C:money}$#2#{} per ",
            "extra {C:attention}Antenna Tower{} owned",
            "{C:inactive}Idea and art by @rad_banker!{}"
        }
    },
    config = { extra = {
        money = 4,
        extra = 1
        } },
    rarity = 3,
    loc_vars = function(self, info_queue, card)
       return { vars = { card.ability.extra.money, card.ability.extra.extra } }
    end,
    atlas = "YACBM",
    unlocked = true,
    discovered = true,
    pos = { x = 0, y = 0 },
    cost = 8,
    calc_dollar_bonus = function(self, card)
        if #SMODS.find_card('j_yacbm_antenna') <= 1 then
            return card.ability.extra.money
        else
            local bonus = (card.ability.extra.money + (card.ability.extra.extra * (#SMODS.find_card('j_yacbm_antenna') - 1)))
            if bonus > 0 then return bonus end
        end
    end
}

SMODS.Joker {
    key = 'jreader',
    loc_txt = {
        name = "J-Reader Card",
        text = {
            "Blind size multiplied {X:mult,C:white}X#1#{}",
            "Copies {C:attention}all Blueprint-compatible{} jokers",
            "{C:inactive}Idea and art by @hatstack!{}"
        }
    },
    config = { extra = {
        blindx = 2,
        }
    },
    rarity = 3,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.blindx } }
    end,
    atlas = "YACBM",
    unlocked = true,
    discovered = true,
    pos = { x = 1, y = 0 },
    cost = 8,
    blueprint_compat = false,
    calculate = function(self, card, context)
        if not context.no_blueprint then
            for k, v in ipairs(G.jokers.cards) do
                if v.ability.name == "Mime" or v.ability.name == "Sock and Buskin" or v.ability.name == "Hanging Chad"
                or v.ability.name == "Dusk" or v.ability.name == "Seltzer" or v.ability.name == "Hack" then
                    if context.retrigger_joker_check and context.other_card ~= card then
                        return {
                            repetitions = 1,
                            message = "Repeat!"
                        }
                    end
                end
                if v and v ~= card then
                    context.blueprint = (context.blueprint and (context.blueprint + 1)) or 1
                    context.blueprint_card = context.blueprint_card or card
                    if context.blueprint > #G.jokers.cards + 1 then return end
                    local copy = v:calculate_joker(context)
                    if copy then
                        SMODS.calculate_effect(copy, context.blueprint_card or card)
                    end
                    context.blueprint = false
                end
            end
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        local gba = get_blind_amount
        function get_blind_amount(ante)
            ante = G.GAME.round_resets.ante
            return gba(ante) * card.ability.extra.blindx
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        local gba = get_blind_amount
        function get_blind_amount(ante)
            ante = G.GAME.round_resets.ante
            return gba(ante) / card.ability.extra.blindx
        end
    end
}

SMODS.Joker {
    key = "estrogen",
    loc_txt = {
        name = "Estrogen",
        text = {
            "Convert {C:attention}all{} scored {C:attention}face",
            "cards{} into {C:purple}Queens{}",
            "{C:inactive}Idea and art by @hatstack!{}"
        }
    },
    config = {},
    rarity = 2,
    atlas = "YACBM",
    unlocked = true,
    discovered = true,
    pos = { x = 2, y = 0 },
    cost = 5,
    blueprint_compat = false,
    calculate = function(self, card, context)
        if context.before and context.cardarea == G.jokers and not context.repetition and not context.blueprint then
            local trans = {}
            for i, v in ipairs(context.scoring_hand) do
                if v:is_face(true) and not context.repetition then
                    if v:get_id() ~= 12 then
                        trans[#trans+1] = v
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                v:juice_up()
                                assert(SMODS.change_base(v, nil, "Queen"))
                                return true end
                        }))
                    end
                end
            end
            if #trans > 0 then
                return {
                    message = "Trans rights!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end
    end
}

SMODS.Joker {
    key = "4byteburg",
    loc_txt = {
        name = "Four Byte Burger",
        text = {
            "{C:mult}+#1#{} Mult",
            "{C:chips}+#2#{} Chips",
            "{C:inactive}Idea and art by @rad_banker!{}"
        }
    },
    config = { extra = {
        mult = 19,
        chips = 85
    } },
    rarity = 2,
    atlas = "YACBM",
    unlocked = true,
    discovered = true,
    pos = { x = 3, y = 0 },
    cost = 4,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.chips } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult = card.ability.extra.mult,
                chips = card.ability.extra.chips,
            }
        end
    end
}

SMODS.Joker {
    key = "jikjok",
    loc_txt = {
        name = "JikJok",
        text = {
            "{X:mult,C:white}#1#X{} blind size",
            "{C:chips}+#2#{} Chips if {C:attention}played hand{} scores",
            "{C:attention}#3#%{} of blind requirement",
            "{C:green}#4# in #5#{} chance to turn played base",
            "cards into {C:attention}bonus cards{}",
            "{C:inactive}(Currently{} {C:chips}#6#{} {C:inactive}Chips){}",
            "{C:inactive}Idea and art by @hyperrr721!{}"
        }
    },
    config = { extra = {
        blindx = 2,
        chip_gain = 60,
        percent = 35,
        chance = 3,
        chips = 0
    } },
    rarity = 3,
    atlas = "YACBM",
    unlocked = true,
    discovered = true,
    pos = { x = 4, y = 0 },
    cost = 8,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.blindx, card.ability.extra.chip_gain, card.ability.extra.percent, (G.GAME.probabilities.normal or 1), card.ability.extra.chance, card.ability.extra.chips } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                chips = card.ability.extra.chips
            }
        end

        if context.before and not context.repetition and context.cardarea == G.jokers and not context.blueprint then
            local bonus = {}
            for i, v in ipairs(context.scoring_hand) do
                if v.ability.set ~= "Enhanced" then
                    if pseudorandom('JikJok') < G.GAME.probabilities.normal / card.ability.extra.chance then
                        bonus[#bonus+1] = v
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                v:juice_up()
                                return true end
                        }))
                    end
                end
            end
            if #bonus > 0 then
                for i, v in ipairs(bonus) do
                    v:set_ability(G.P_CENTERS.m_bonus, nil, true)
                end
                return {
                    message = "Bonus'd!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end

        if context.after and context.main_eval and ((hand_chips * mult / G.GAME.blind.chips) >= (card.ability.extra.percent/100)) and not context.blueprint then
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_gain
            return {
                message = "Upgraded!",
                colour = G.C.CHIPS,
                card = card
            }
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        local gba = get_blind_amount
        function get_blind_amount(ante)
            ante = G.GAME.round_resets.ante
            return gba(ante) * card.ability.extra.blindx
        end
    end,

    remove_from_deck = function(self, card, from_debuff)
        local gba = get_blind_amount
        function get_blind_amount(ante)
            ante = G.GAME.round_resets.ante
            return gba(ante) / card.ability.extra.blindx
        end
    end
}