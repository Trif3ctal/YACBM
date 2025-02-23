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
                if v and v ~= card and v.ability.name ~= "j_yacbm_jreader" then
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
        percent = 75,
        chance = 8,
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
                        card_eval_status_text(card, 'extra', nil, nil, nil, { message = "Drained!", colour = G.C.RED } )
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
            "{C:inactive}\"The master never falls\""
        }
    },
    config = {
        extra = {
            money = 0,
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
        if card.ability.extra.money then return card.ability.extra.money end
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
            "{C:inactive}\"GG\""
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
                    v.cost = 0
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
    calculate = function(self, card, context)
        if context.after then
            if card.ability.extra.mult / card.ability.extra.div <= 0 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('tarot1')
                        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                            func = function()
                                G.jokers:remove_card(card)
                                card:start_dissolve()
                                card = nil
                                return true; end}))
                        return true
                    end
                }))
                return {
                    message = "Burned!",
                    colour = G.C.RED
                }
            else
                card.ability.extra.mult = card.ability.extra.mult / card.ability.extra.div
                return {
                    message = "-"..(card.ability.extra.mult),
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