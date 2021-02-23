tool
extends RichTextEffect
class_name RichTextSleep

# Define the tag name.
var bbcode = "sleep"

func _process_custom_fx(char_fx):
	# Get parameters, or use the provided default value if missing.
	var freq = char_fx.env.get("freq", 1) # frequency of the wave
	var amount = char_fx.env.get("amount", 15) # "amount" of the wave (how much the letters swings from left to right)
	
	var alpha = sin(char_fx.elapsed_time + char_fx.absolute_index) * 0.5 + 0.5
	char_fx.color.a = alpha
	char_fx.offset = Vector2(sin((char_fx.elapsed_time + char_fx.absolute_index) * freq) * amount + amount,0)
	return true
