SMODS.current_mod.optional_features = { retrigger_joker = true }
SMODS.load_file('animateObject.lua')()

SMODS.Atlas {
    key = "YACBM",
    path = "YACBM.png",
    px = 71,
    py = 95
}
SMODS.Atlas {
    key = "bongcloud",
    path = "bongcloud.png",
    px = 78,
    py = 78
}
SMODS.Atlas {
    key = "jokagotchi",
    path = "jokagotchi.png",
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
                if v and v ~= card and v.ability.name ~= "j_yacbm_jreader" and v.ability.name ~= "Blueprint" and v.ability.name ~= "Brainstorm" then
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

SMODS.Joker{
    key = "corporate",
    loc_txt = {
        name = "Corporate Joker",
        text = {
            "Lose {C:money}$#1#{} per card played",
            "{C:attention}All{} items in shop are",
            "{C:money}free{}, except {C:green}Rerolls{}",
            "{C:inactive}Idea and art by @hatstack!"
        }
    },
    config = {
        extra = {
            money = 1
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.money } }
    end,
    rarity = 2,
    atlas = "YACBM",
    unlocked = true,
    discovered = true,
    pos = { x = 3, y = 1 },
    cost = 5,

    shop_function = function(self)
        local function make_free(type)
            if type and type.cards then
                for k,v in pairs(type.cards) do
                    v.cost = v.base_cost*0
                end
            end
        end
        make_free(G.shop_jokers)
        make_free(G.shop_booster)
        make_free(G.shop_vouchers)
    end,

    add_to_deck = function(self, card, from_debuff)
        self.shop_function(self)
    end,

    remove_from_deck = function(self, card, from_debuff)
        self.shop_function(self)
    end,

    calculate = function(self, card, context)
        if context.reroll_shop or context.shop_loaded then
            self.shop_function(self)
        end

        if context.before then
            for i = 1, #G.play.cards do
                G.E_MANAGER:add_event(Event({func = function() G.play.cards[i]:juice_up(); return true end }))
                ease_dollars(-1)
                delay(0.23)
            end
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
        percent = 75,
        chance = 8,
        chips = 0
    } },
    rarity = 3,
    atlas = "YACBM",
    unlocked = true,
    discovered = true,
    pos = { x = 4, y = 0 },
    pixel_size = { w = 63, h = 95 },
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

SMODS.Joker{
    key = "generator",
    loc_txt = {
        name = "Generator",
        text = {
            "Retrigger all {C:attention}played cards{},",
            "{C:red}destroys{} {C:attention}leftmost{} consumable",
            "at beginning of round",
            "{C:red}Self destructs{} if no consumables",
            "can be destroyed",
            "{C:inactive}Idea and art by @fennex!{}"
        }
    },
    config = {
        extra = {
            retriggers = 1
        }
    },
    rarity = 2,
    atlas = "YACBM",
    unlocked = true,
    discovered = true,
    pos = { x = 0, y = 1 },
    cost = 6,
    calculate = function(self, card, context)
        local destroyed = G.consumeables.cards[1]
        if context.setting_blind and G and G.consumeables and G.consumeables.cards then
            if destroyed then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        destroyed:start_dissolve()
                        card:juice_up()
                    return true end
                }))
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = "Fueled!", colour = G.C.RED } )
            end
            if not destroyed then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('tarot1')
                        card:start_dissolve()
                        G.jokers:remove_card(card)
                        card_eval_status_text(card, 'extra', nil, nil, nil, { message = "Drained!", colour = G.C.RED } )
                        card = nil
                    return true end
                }))
            end
        end
        if context.cardarea == G.play and context.repetition then
            return {
                    message = localize('k_again_ex'),
                    repetitions = card.ability.extra.retriggers,
                    card = card
            }
        end
    end
}

SMODS.Joker{
    key = "sharpshooter",
    loc_txt = {
        name = "Sharpshooter",
        text = {
            "Gains {C:money}$#1#{} at end of round for",
            "each {C:attention}blind{} beaten in one",
            "hand (Two if {C:attention}boss blind{})",
            "{C:inactive}(Currently: {C:money}$#2#{}{C:inactive}){}",
            "{C:inactive}Idea and art by @_tanghinh!{}",
            "{C:inactive,s:0.8}\"The master never falls\""
        }
    },
    config = {
        extra = {
            money = 1,
            increment = 1
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.increment, card.ability.extra.money } }
    end,
    rarity = 2,
    atlas = "YACBM",
    unlocked = true,
    discovered = true,
    pos = { x = 1, y = 1 },
    cost = 5,
    calculate = function(self, card, context)
        if context.end_of_round and context.cardarea == G.jokers and not context.blueprint then
            if G.GAME.blind.boss then
                if G.GAME.current_round.hands_played <= 2 then
                    card.ability.extra.money = card.ability.extra.money + card.ability.extra.increment
                    end
                return true
            else
                if G.GAME.current_round.hands_played <= 1 then
                    card.ability.extra.money = card.ability.extra.money + card.ability.extra.increment
                end
            end
        end
    end,
    calc_dollar_bonus = function(self, card)
        if card.ability.extra.money then return card.ability.extra.money else return false end
    end
}

SMODS.Joker{
    key = "checkmate",
    loc_txt = {
        name = "Checkmate",
        text = {
            "Gains {X:mult,C:white}X#1#{} Mult per {C:attention}discarded{} King",
            "Gains {X:mult,C:white}X#2#{} Mult per {C:attention}destroyed{} King",
            "{C:inactive}(Currently: {X:mult,C:white}X#3#{}{C:inactive}){}",
            "{C:inactive}Idea by @_tanghinh, art by{}",
            "{C:inactive}@matressinmylung and @arlisbloxer05!{}",
            "{C:inactive,s:0.8}\"GG\""
        }
    },
    config = {
        extra = {
            discard = 0.05,
            destroy = 0.5,
            disc_amt = 0,
            destroy_amt = 0
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.discard, card.ability.extra.destroy, 1 + ((card.ability.extra.discard * card.ability.extra.disc_amt) + (card.ability.extra.destroy * card.ability.extra.destroy_amt)) } }
    end,
    rarity = 3,
    atlas = "YACBM",
    unlocked = true,
    discovered = true,
    pos = { x = 2, y = 1 },
    cost = 7,
    blueprint_compat = true,
    calculate = function(self, card, context)
        local discarded = {}
        local destroyed = {}
        if context.remove_playing_cards and not context.blueprint then
            for i = 1, #context.removed do
                if context.removed[i]:get_id() == 13 then
                    destroyed[#destroyed+1] = context.removed[i]
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.1,
                    func = function()
                        card:juice_up()
                        card.ability.extra.destroy_amt = card.ability.extra.destroy_amt + 1
                        return true end
                    }))
                end
            end
            if #destroyed > 0 then
                return {
                    message = "Checkmate!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end
        if context.discard and context.other_card and not context.blueprint and not context.remove_playing_cards then
            if context.other_card:get_id() == 13 then
                discarded[#discarded+1] = context.other_card
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.1,
                func = function()
                    card:juice_up()
                    card.ability.extra.disc_amt = card.ability.extra.disc_amt + 1
                    return true end
                }))
            end
        end
        if #discarded > 0 and not context.remove_playing_cards then
            return {
                message = "Check!",
                colour = G.C.RED,
                card = card
            }
        end
        if context.joker_main then
            if 1 + ((card.ability.extra.discard * card.ability.extra.disc_amt) + (card.ability.extra.destroy * card.ability.extra.destroy_amt)) > 1 then
                return {
                    xmult = 1 + ((card.ability.extra.discard * card.ability.extra.disc_amt) + (card.ability.extra.destroy * card.ability.extra.destroy_amt))
                }
            end
        end
    end
}

SMODS.Joker {
    key = "bongcloud",
    loc_txt = {
        name = "Bongcloud",
        text = {
            "Gains {X:mult,C:white}X#1#{} Mult for each",
            "{C:attention}played hand{} containing",
            "a scoring {C:attention}King{}, {C:red}resets{}",
            "if no {C:attention}Kings{} played in",
            "#2# consecutive hands {C:inactive}(#3#/#2#)",
            "{C:inactive}(currently {X:mult,C:white}X#4#{C:inactive})",
            "{C:inactive}Idea and art by @_tanghinh!",
            "{C:inactive,s:0.8}\"Best chess opening move ever\""
        }
    },
    config = {
        extra = {
            xmult = 0.2,
            hands = 2,
            current = 0,
            total = 1,
            played = false
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.hands, card.ability.extra.current, card.ability.extra.total } }
    end,
    rarity = 2,
    atlas = "bongcloud",
    unlocked = true,
    discovered = true,
    pos = { x = 0, y = 0 },
    display_size = { w = 78, h = 78 },
    cost = 5,
    calculate = function(self, card, context)
        local first = nil
        if context.joker_main then
            return {
                xmult = card.ability.extra.total
            }
        end
        if context.individual and context.cardarea == G.play and not context.blueprint then
            for i = 1, #context.scoring_hand do
                if context.scoring_hand[i]:get_id() == 13 then
                    first = context.scoring_hand[i]
                    card.ability.extra.current = 0
                    card.ability.extra.played = true
                    break
                else
                    card.ability.extra.played = false
                end
            end
            if context.other_card == first then
                card.ability.extra.total = card.ability.extra.total + card.ability.extra.xmult
                card:juice_up(0.5, 0.5)
                play_sound('generic1')
            end
        end
        if context.after and not context.blueprint and not card.ability.extra.played then
            if card.ability.extra.current + 1 >= card.ability.extra.hands and card.ability.extra.total > 1 then
                card.ability.extra.current = 0
                card.ability.extra.total = 1
                return {
                    message = localize('k_reset'),
                    colour = G.C.RED,
                    card = card
                }
            elseif card.ability.extra.current < card.ability.extra.hands and card.ability.extra.total > 1 then
                card.ability.extra.current = card.ability.extra.current + 1
                return {
                    message = (card.ability.extra.current.."/"..card.ability.extra.hands),
                    colour = G.C.RED,
                    card = card
                }
            end
        end
        if context.setting_blind and not context.blueprint then
            if card.ability.extra.current >= card.ability.extra.hands then
                card.ability.extra.current = 0
                card.ability.extra.total = 1
                return {
                    message = localize('k_reset'),
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end
}

SMODS.Joker{
    key = "burningmemory",
    loc_txt = {
        name = "Burning Memory",
        text = {
            "{X:mult,C:white}X#1#{} Mult",
            "Mult {X:mult,C:white}/#2#{} every round",
            "{C:inactive}Idea and art by @arlisbloxer05!{}"
        }
    },
    config = {
        extra = {
            mult = 512,
            div = 2
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.div } }
    end,
    rarity = 4,
    atlas = "YACBM",
    unlocked = true,
    discovered = true,
    pos = { x = 4, y = 1 },
    cost = 20,
    eternal_compat = false,
    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval and not context.blueprint then
            if card.ability.extra.mult / card.ability.extra.div <= 0.5 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('tarot1')
                        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                            func = function()
                                G.jokers:remove_card(card)
                                card:start_dissolve()
                                card_eval_status_text(card, 'extra', nil, nil, nil, { message = "Burned!", colour = G.C.RED } )
                                card = nil
                                return true; end}))
                        return true
                    end
                }))
                return true
            else
                card.ability.extra.mult = card.ability.extra.mult / card.ability.extra.div
                return {
                    message = localize{type='variable',key='a_mult_minus',vars={card.ability.extra.mult}},
                    colour = G.C.MULT
                }
            end
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.mult
            }
        end
    end
}

-- this guy will have to come at a later point
--[[SMODS.Joker{
    key = "goldenrod",
    loc_txt = {
        name = "Goldenrodprint",
        text = {
            "{C:attention}Copies{} the abilities of the",
            "{C:attention}playing card{} corresponding",
            "to this Joker's {C:attention}position{}",
            "{C:inactive}(ex: copies 3rd playing card",
            "{C:inactive}if in 3rd joker slot)",
            "{C:inactive}Idea and art by @larantula_l!"
        }
    },
    config = {
        extra = {
            cardpos = 0,
            glass = 1
        }
    },
    rarity = 3,
    atlas = "YACBM",
    unlocked = true,
    discovered = true,
    pos = { x = 0, y = 2 },
    cost = 8,
    calculate = function(self, card, context)
        local ret = {}
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i] == card then
                local chosen = G.play.cards[i]
                --[[if context.cardarea == G.play and context.joker_main then
                    local chips = chosen:get_chip_bonus()
                    if chips > 0 then
                        ret.chips = chips
                    end
                    local mult = chosen:get_chip_mult()
                    if mult > 0 then
                        ret.mult = mult
                    end
                    local x_mult = chosen:get_chip_x_mult(context)
                    if x_mult > 0 then
                        ret.x_mult = x_mult
                    end
                    local p_dollars = chosen:get_p_dollars()
                    if p_dollars > 0 then
                        ret.dollars = p_dollars
                    end
                    local edition = chosen:get_edition(context)
                    if edition then
                        ret.edition = edition
                        if ret.chips then ret.chips = ret.chips + (ret.edition.chip_mod or 0) end
                        if ret.mult then ret.mult = ret.mult + (ret.edition.mult_mod or 0) end
                        if ret.x_mult then ret.x_mult = ret.x_mult + (ret.edition.x_mult_mod or 0) end
                    end
                    for k, v in pairs(ret) do
                        print(k, v)
                    end
                    return ret
                end
                if context.joker_main and context.scoring_hand[i] then
                    local echips = 0
                    local emult = 0
                    local exmult = 0
                    if chosen.edition.x_mult then exmult = chosen.edition.x_mult end
                    if chosen.edition.mult then emult = chosen.edition.mult end
                    if chosen.edition.chips then echips = chosen.edition.chips end
                    return {
                        chips = chosen.base.nominal + chosen.ability.bonus + (chosen.ability.perma_bonus or 0) + echips,
                        mult = chosen.ability.mult + chosen.ability.h_mult + emult,
                        x_mult = chosen.ability.x_mult + chosen.ability.h_x_mult + exmult,
                        dollars = chosen:get_p_dollars(),
                    }
                end
                if context.repetition and context.cardarea == G.play then
                    if chosen.seal == 'Red' then
                            return {
                                message = localize('k_again_ex'),
                                repetitons = 1,
                                card = card
                            }
                    end
                end
                if context.after and context.scoring_hand[i] then
                    if chosen.config.center_key == 'm_glass' and not chosen.debuff and pseudorandom('glass2') < G.GAME.probabilities.normal/card.ability.extra.glass then
                        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                            func = function()
                                G.jokers:remove_card(card)
                                card:shatter()
                                card = nil
                                return true; end}))
                        return true
                    end
                end
            end
        end
    end
}]]--

SMODS.Joker {
    key = "anaglyph",
    loc_txt = {
        name = "Anaglyph Joker",
        text = {
            "After defeating each {C:attention}boss",
            "{C:attention}blind{}, gain a {C:attention}Double Tag",
            "{C:inactive}Idea and art by",
            "{C:inactive}@probablyanaccount!"
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_TAGS.tag_double
    end,
    config = {},
    rarity = 2,
    atlas = "YACBM",
    unlocked = true,
    discovered = true,
    pos = { x = 1, y = 2 },
    cost = 5,
    calculate = function(self, card, context)
        if G.GAME.last_blind and G.GAME.last_blind.boss and context.end_of_round and context.main_eval then
            G.E_MANAGER:add_event(Event({
                func = function()
                    card:juice_up()
                    add_tag(Tag('tag_double'))
                    play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
                    play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
                    return true
                end
            }))
        end
    end
}

SMODS.Joker {
    key = "zodiac",
    loc_txt = {
        name = "Zodiac Joker",
        text = {
            "{C:planet}Planet{} and {C:tarot}Tarot{} cards",
            "appear {C:attention}#1#X{} more frequently",
            "in the shop",
            "{C:inactive}Idea and art by",
            "{C:inactive}@probablyanaccount!"
        }
    },
    config = {
        extra = {
            display = 2,
            amt = (9.6 / 4)
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.display } }
    end,
    rarity = 2,
    atlas = "YACBM",
    unlocked = true,
    discovered = true,
    pos = { x = 2, y = 2 },
    cost = 4,
    add_to_deck = function(self, card, context)
        G.E_MANAGER:add_event(Event({func = function()
            G.GAME.planet_rate = G.GAME.planet_rate * card.ability.extra.amt
            G.GAME.tarot_rate = G.GAME.tarot_rate * card.ability.extra.amt
            return true end }))
    end,
    remove_from_deck = function(self, card, context)
        G.E_MANAGER:add_event(Event({func = function()
            G.GAME.planet_rate = G.GAME.planet_rate / card.ability.extra.amt
            G.GAME.tarot_rate = G.GAME.tarot_rate / card.ability.extra.amt
            return true end }))
    end
}

SMODS.Joker {
    key = "all5s",
    loc_txt = {
        name = "Oh... It's 5s.",
        text = {
            "{C:red}Halves{} all listed",
            "{C:green,E:1,S:1.1}probabilities",
            "{C:inactive}(ex: {C:green}1 in 4{C:inactive} -> {C:green}0.5 in 4{C:inactive})",
            "{C:inactive}Idea and art by",
            "{C:inactive}@probablyanaccount!"
        }
    },
    config = {
    },
    rarity = 2,
    atlas = "YACBM",
    unlocked = true,
    discovered = true,
    pos = { x = 3, y = 2 },
    cost = 4,
    add_to_deck = function(self, card, from_debuff)
        for k, v in pairs(G.GAME.probabilities) do
            G.GAME.probabilities[k] = v/2
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        for k, v in pairs(G.GAME.probabilities) do
            G.GAME.probabilities[k] = v*2
        end
    end
}

SMODS.Joker {
    key = "jokagotchi",
    loc_txt = {
        name = "Jokagotchi",
        text = {
            "{C:red}Destroys{} all held {C:attention}consumables{}",
            "at start of {C:attention}round{}",
            "Gains {X:mult,C:white}X#1#{} Mult for each",
            "destroyed card, {C:red}resets{} if",
            "no {C:attention}consumables{} destroyed",
            "{C:inactive}Idea and art by @_samuran!",
            "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)",
        }
    },
    config = {
        extra = {
            gain = 0.25,
            base = 1,
            total = 1
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.gain, card.ability.extra.total } }
    end,
    rarity = 2,
    atlas = "jokagotchi",
    unlocked = true,
    discovered = true,
    pos = { x = 0, y = 0 },
    cost = 5,
    AddRunningAnimation({'j_yacbm_jokagotchi', 2, 2, 0, 'loop', 0, 0}),
    calculate = function(self, card, context)
        local destroy = {}
        if context.setting_blind and G and G.consumeables and G.consumeables.cards and not context.blueprint then
            for i = 1, #G.consumeables.cards do
                if G.consumeables.cards[i] then destroy[i] = G.consumeables.cards[i] end
            end
            if #destroy > 0 then
                card.ability.extra.total = card.ability.extra.total + (card.ability.extra.gain * #destroy)
                G.E_MANAGER:add_event(Event({
                    func = function()
                        for i = 1, #destroy do
                            destroy[i]:start_dissolve()
                        end
                        card:juice_up()
                        card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_xmult', vars = {card.ability.extra.total}}})
                    return true end
                }))
            else
                card.ability.extra.total = card.ability.extra.base
                return {
                    message = localize('k_reset'),
                    card = card
                }
            end
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.total
            }
        end
    end
}