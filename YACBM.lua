
SMODS.Atlas {
    key = "YACBM",
    path = "YACBM.png",
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'listflipper',
    loc_txt = {
        name = 'List Flipper',
        text = {
            "Rotates {C:attention}hand list{} by 1",
            "{C:inactive}(High Card becomes Pair, Pair becomes",
            "{C:inactive}Two Pair, and so on)",
            "{C:inactive}Idea by @poppycars!"
        }
    },
    config = { extra = { rotations = 1, temp_mult = 4 } },
    rarity = 3,
    loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.temp_mult } }
	end,
    atlas = "YACBM",
    pos = { x = 0, y = 0 },
    cost = 5,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult_mod = card.ability.extra.temp_mult,
                message = localize { type = "variable", key = "a_mult", vars = { card.ability.extra.temp_mult } }
            }
        end
    end
}
