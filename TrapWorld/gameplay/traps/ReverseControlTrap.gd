extends TrapBase
## Reverse Control (GDD 6): invisible trigger zone that flips left/right for
## the rest of this level attempt, undermining a habit the player just
## learned. Stays reversed permanently (until death/restart) rather than
## reverting after a few seconds, per user feedback that a timed revert felt
## like it was randomly flip-flopping between normal and reversed mid-level.

var player_ref: Node

func fire() -> void:
	if fired:
		return
	super.fire()
	if player_ref and player_ref.has_method("apply_reverse"):
		player_ref.apply_reverse()
