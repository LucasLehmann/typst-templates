#let binary(number, group: none, pad: none, literal: false,
            int-group: 4,     int-pad:  false, int-bits: 0,
            frac-group: none, frac-pad: false, frac-bits: 0) = {

	set line(stroke: (cap: "round", thickness: .07em))
	let one()  = box(line(end: (0em, .6em)))
	let zero() = box(line(end: (0em, .2em)))
	let space() = h(0.1em)
	let connector() = box(line(end: (0.1em, 0em)))
	let radix() = box(baseline: .07em, line(end: (0em, .07em)))
	let rep() = {
		box(baseline: .1em, line(end: (0em, .1em)))
		box(baseline: .1em, line(end: (.1em, 0em)))
	}
	let lrep() = {
		box(baseline: .1em, line(end: (.1em, 0em)))
		box(baseline: .1em, line(end: (0em, .1em)))
	}
	let minus() = box(baseline: -.3em, line(end: (.1em, 0em)))

	if group != none {
		int-group = group
		frac-group = group
	} else if frac-group == none {
		frac-group = int-group
	}
	if pad != none {
		pad-group = pad
		pad-group = pad
	}
	if int-group < 1 { panic("Group size cannot be less than one") }

	number = str(number)
	if number.starts-with(regex("[-−]")) { // ascii - or MINUS SIGN U+2212
		number=number.trim(number.first(), at: start)
		minus()
	}

	if literal {
		space()
		let group-start = true
		for bit in number {
			// Very inelegant but it what what i could think of.
			if not bit.contains(regex("[01]")) { group-start = true }
			if group-start {
				group-start = false
			} else {
				connector()
			}
			group-start = not bit.contains(regex("[01]"))
			if bit == "1" {
				one()
			} else if bit == "0" {
				zero()
			} else if bit == "." {
				space()
				radix()
				space()
			} else if bit == "r" {
				space()
				rep()
			} else if bit == "l" {
				lrep()
				space()
			} else if bit == " " or bit == "_" {
				space()
			} else {
				panic("Malformed input got " + bit + " instead of 1 or 0")
			}
		}
		return
	}


	// TODO: maybe implement left repetition also? But how to group?

	let parts = number.split(".")
	let int = parts.at(0)
	if int-pad {
		let rem = calc.rem(int.len(), int-group)
		let padding = 0
		if rem != 0 {
			padding = int-group - rem
		}
		int = "0" * padding + int
	}
	if int.len() < int-bits {
		int = "0" * (int-bits - int.len()) + int
	}

	let first = true
	for (i, bit) in int.codepoints().enumerate() {
		if calc.rem(int.len()-i, int-group) == 0 or first {
			first = false
			space()
		} else {
			connector()
		}

		if bit == "1" {
			one()
		} else if bit == "0" {
			zero()
		} else if bit == "l" or bit == "r" {
			lrep() // TODO: fix grouping
			panic("Unimplemented")
		} else {
			panic("Malformed input got " + bit + " instead of 1 or 0")
		}
	}

	if parts.len() == 1 {
		return
	}
	let frac = parts.at(1)
	space()
	radix()

	// TODO: wont work with repeating
	if frac-pad {
		let rem = calc.rem(frac.len(), frac-group)
		let padding = 0
		if rem != 0 {
			padding = frac-group - rem
		}
		frac += "0" * padding
	}
	for (i, bit) in frac.codepoints().enumerate() {
		if calc.rem(i, frac-group) == 0 or first {
			first = false
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
