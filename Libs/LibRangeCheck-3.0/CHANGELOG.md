# Lib: RangeCheck-3.0

## [1.0.12](https://github.com/WeakAuras/LibRangeCheck-3.0/tree/1.0.12) (2024-03-05)
[Full Changelog](https://github.com/WeakAuras/LibRangeCheck-3.0/compare/1.0.11...1.0.12) [Previous Releases](https://github.com/WeakAuras/LibRangeCheck-3.0/releases)

- Fix spell checkers on Classic/SOD  
    Sspells with have a min range, e.g. a spell with an 8-30y range, cannot  
    be easily used of range checking, because if it isn't in range, that  
    could be <8 or >30. Thus we used a second checker to distinguish between  
    those two cases.  
    Previously only other spells would be consider, but in some cases  
    classes have no spells that can fill that gap.  
    Thus use an idea by kodewdle to fall-back to the interact list. All we  
    need is an interact distance that is bigger than min range and less than  
    the max range.  
    Fixes: #16  
- ShowAllSpellRanks causing range to be invalid when toggled. (#15)  
    The library internally in the spell checkers, e.g. checkers\_Spell uses the "spell index". The spell index is actually the index into the player's spell book, not the spell id.  
    Toggling the "Show all ranks" toggle does change these indexes, since multiple ranks are shown, thus the checkers need to reinitialized.  