#set text(size: 48pt)
#let binary(number, group-size: 4, pad: false) = {
	set line(stroke: (cap: "round", thickness: .07em))
	if group-size < 1 { panic("Group size cannot be less than one") }
	let one()  = box(line(end: (0em, .6em)))
	let zero() = box(line(end: (0em, .2em)))
	let space() = h(0.1em)
	let connector() = box(line(end: (0.1em, 0em)))
	let radix() = box(baseline: .07em, line(end: (0em, .07em)))
	let rep() = {
		box(baseline: .1em, line(end: (0em, .1em)))
		box(baseline: .1em, line(end: (.1em, 0em)))
	}
	let minus() = box(baseline: -.3em, line(end: (.1em, 0em)))

	// TODO: maybe implement left repetition also? But how to group?
	number = str(number)
	if number.first() == "-" {
		number=number.slice(1)
		minus()
	}

	if pad {
		let rem = calc.rem(group.len(), group-size)
		let padding = 0
		if rem != 0 {
			padding = group-size - rem
		}
		group = "0" * padding + group
	}

	let int = true
	for group in number.split(".") {
		if int {int = false
		} else {space();radix()}

		for (i, bit) in group.codepoints().enumerate() {
			if calc.rem(i, group-size) == 0 {
				space()
			} else {
				connector()
			}
			
			if bit == "1" {
				one()
			} else if bit == "0" {
				zero()
			} else if bit == "r" {
				rep() // TODO: fix grouping
				panic("Unimplemented")
			} else {
				panic("Malformed input got " + bit + " instead of 1 or 0")
			}
		}
	}
}
